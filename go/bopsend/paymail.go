package bopsend

import (
	"fmt"
	"net"
	"time"

	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	paymail "github.com/tonicpow/go-paymail"
)

//GetAddress get a BSV address for the given paymail
func GetAddressFromPaymail(paymailAddress string) (string, error) {
	t := trace.New().Source("main.go", "", "GetAddress")
	log.Println(trace.Debug("resolving address").UTC().Add("address", paymailAddress).Append(t))

	handle, domain, pym := paymail.SanitizePaymail(paymailAddress)

	client, err := paymail.NewClient()
	if err != nil {
		log.Println(trace.Alert("error loading paymail client").UTC().Add("address", paymailAddress).Error(err).Append(t))
		return "", err
	}

	var srv *net.SRV
	if srv, err = client.GetSRVRecord(paymail.DefaultServiceName, paymail.DefaultProtocol, domain); err != nil {
		log.Println(trace.Alert("error getting server").UTC().Add("domain", domain).Error(err).Append(t))
		return "", err
	}
	log.Println(trace.Debug("found server").UTC().Add("domain", domain).Add("target", srv.Target).Append(t))

	var capabilities *paymail.Capabilities
	if capabilities, err = client.GetCapabilities(srv.Target, int(srv.Port)); err != nil {
		log.Println(trace.Alert("get capabilities failes").UTC().Add("target", srv.Target).Add("port", fmt.Sprintf("%d", srv.Port)).Error(err).Append(t))
		return "", err
	}
	log.Println(trace.Debug("found capabilities").UTC().Add("capabilities", fmt.Sprintf("%v", capabilities.Capabilities)).Append(t))

	resolveURL := capabilities.GetString(paymail.BRFCBasicAddressResolution, paymail.BRFCPaymentDestination)

	senderRequest := &paymail.SenderRequest{
		Dt:           time.Now().UTC().Format(time.RFC3339),
		SenderHandle: "bop@simply.cash",
		SenderName:   "BOP",
	}

	var resolution *paymail.Resolution
	if resolution, err = client.ResolveAddress(resolveURL, handle, domain, senderRequest); err != nil {
		log.Println(trace.Alert("paymail address resolution failed").UTC().Add("handle", handle).Add("domain", domain).Error(err).Append(t))
		return "", err
	}
	log.Println(trace.Debug("found address").UTC().Add("paymail", pym).Add("address", resolution.Address).Append(t))
	return resolution.Address, err
}

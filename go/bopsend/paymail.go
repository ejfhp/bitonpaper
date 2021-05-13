package bopsend

import (
	"fmt"
	"net"
	"time"

	"github.com/bitcoinsv/bsvutil"
	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	"github.com/libsv/go-bt"
	paymail "github.com/tonicpow/go-paymail"
)

//GetAddress get a BSV address for the given paymail
func GetAddress(address string) (string, error) {
	t := trace.New().Source("main.go", "", "GetAddress")
	log.Println(trace.Debug("resolving address").UTC().Add("address", address).Append(t))

	handle, domain, pym := paymail.SanitizePaymail(address)

	client, err := paymail.NewClient()
	if err != nil {
		log.Println(trace.Alert("error loading paymail client").UTC().Add("address", address).Error(err).Append(t))
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

func CreateTX(string address) {
	tx := bt.NewTx()

	_ = tx.From(
		"11b476ad8e0a48fcd40807a111a050af51114877e09283bfa7f3505081a1819d",
		0,
		"76a914eb0bd5edba389198e73f8efabddfc61666969ff788ac6a0568656c6c6f",
		1500)

	_ = tx.PayTo("1NRoySJ9Lvby6DuE2UQYnyT67AASwNZxGb", 1000)

	wif, _ := bsvutil.DecodeWIF("KznvCNc6Yf4iztSThoMH6oHWzH9EgjfodKxmeuUGPq5DEX5maspS")

	inputsSigned, err := tx.SignAuto(&bt.InternalSigner{PrivateKey: wif.PrivKey, SigHashFlag: 0})
	if err != nil && len(inputsSigned) > 0 {
		log.Fatal(err.Error())
	}
	log.Println("tx: ", tx.ToString())
}

// diego  ~  curl https://api.whatsonchain.com/v1/bsv/main/chain/info

// {"chain":"main","blocks":687021,"headers":687021,"bestblockhash":"000000000000000000e41102e9155547f624f1835c216bce22b2808115750bfa","difficulty":126153521434.1866,"mediantime":1620886801,"verificationprogress":0.9999989121629042,"pruned":false,"chainwork":"0000000000000000000000000000000000000000012b59edd308d12ef82e10da"}
//  diego  ~  https://api.whatsonchain.com/v1/bsv/main/address/1NRoySJ9Lvby6DuE2UQYnyT67AASwNZxGb/unspent
// bash: https://api.whatsonchain.com/v1/bsv/main/address/1NRoySJ9Lvby6DuE2UQYnyT67AASwNZxGb/unspent: No such file or directory
//  diego  ~  127  curl https://api.whatsonchain.com/v1/bsv/main/address/1NRoySJ9Lvby6DuE2UQYnyT67AASwNZxGb/unspent
// []
//  diego  ~  curl https://api.whatsonchain.com/v1/bsv/main/address/12LwgC8RQ6ScX5mLbNYL6twZba6SpkoLh2/unspent
// [{"height":317563,"tx_pos":0,"tx_hash":"73908464acc24e75af7d0046c2ee01a305e235e18b4e941ee75b9dd371b0169b","value":293000}]
//  diego  ~  curl https://api.whatsonchain.com/v1/bsv/main/tx/hash/73908464acc24e75af7d0046c2ee01a305e235e18b4e941ee75b9dd371b0169b
// {"hex":"","txid":"73908464acc24e75af7d0046c2ee01a305e235e18b4e941ee75b9dd371b0169b","hash":"73908464acc24e75af7d0046c2ee01a305e235e18b4e941ee75b9dd371b0169b","version":1,"size":224,"locktime":0,"vin":[{"coinbase":"","txid":"8dfa23287954d56468dd198406f008e8d832b32323e6bbe0ef5eae10f7de1ea9","vout":0,"scriptSig":{"asm":"3045022100b3eee592241bdb4f3f224314098a471c144ba006bd16f60579ae986fe97aabed022044f041ec057b3954e26ddf74f4752c4da68a468ba112be3e387ee95e0748ef8c[ALL] 0400386a7507ca0978a5ace99daf70591815590e455754f7c8aeaf9a37e729385f1f1844165712bd7852d482c47b7ca652fa51cb0c1b34ae80c7d59f5b0d0d6914","hex":"483045022100b3eee592241bdb4f3f224314098a471c144ba006bd16f60579ae986fe97aabed022044f041ec057b3954e26ddf74f4752c4da68a468ba112be3e387ee95e0748ef8c01410400386a7507ca0978a5ace99daf70591815590e455754f7c8aeaf9a37e729385f1f1844165712bd7852d482c47b7ca652fa51cb0c1b34ae80c7d59f5b0d0d6914"},"sequence":4294967295}],"vout":[{"value":0.00293,"n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 0ebdab88841e57f5b57cada04a6c5972d844b620 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a9140ebdab88841e57f5b57cada04a6c5972d844b62088ac","reqSigs":1,"type":"pubkeyhash","addresses":["12LwgC8RQ6ScX5mLbNYL6twZba6SpkoLh2"],"opReturn":null,"isTruncated":false}}],"blockhash":"0000000000000000099e0c61c8c9b268e8077179897cdc48160b79f2dd87c5dd","confirmations":369459,"time":1409057378,"blocktime":1409057378,"blockheight":317563}
//  diego  ~ 

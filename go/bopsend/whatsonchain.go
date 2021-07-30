package bopsend

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
)

// curl https://api.whatsonchain.com/v1/bsv/main/chain/info
// curl https://api.whatsonchain.com/v1/bsv/main/address/1NRoySJ9Lvby6DuE2UQYnyT67AASwNZxGb/unspent
// curl https://api.whatsonchain.com/v1/bsv/main/address/12LwgC8RQ6ScX5mLbNYL6twZba6SpkoLh2/unspent
// curl https://api.whatsonchain.com/v1/bsv/main/tx/hash/73908464acc24e75af7d0046c2ee01a305e235e18b4e941ee75b9dd371b0169b

type WOC struct {
	BaseURL string
}

func NewWOC() *WOC {
	w := WOC{BaseURL: "https://api.whatsonchain.com/v1/bsv"}
	return &w
}

func (w *WOC) GetUnspent(net string, address string) ([]*Unspent, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetUnspent")
	url := fmt.Sprintf("%s/%s/address/%s/unspent", w.BaseURL, net, address)
	log.Println(trace.Debug("get unspent").UTC().Add("address", address).Add("net", net).Add("url", url).Append(t))
	resp, err := http.Get(url)
	if err != nil {
		log.Println(trace.Alert("error while getting unspent").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while getting unspent: %w", err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(trace.Alert("error while reading response").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while reading response: %w", err)
	}
	unspent := []*Unspent{}
	err = json.Unmarshal(body, &unspent)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while unmarshalling: %w", err)
	}
	return unspent, nil
}

//GetUnspentAmount returns the number of unspent output and the total amount for the given address
func (w *WOC) GetUnspentAmount(net string, address string) (int, uint64, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetUnspentAmount")
	unspent, err := w.GetUnspent(net, address)
	if err != nil {
		log.Println(trace.Alert("cannot get unspent").UTC().Add("address", address).Add("net", net).Error(err).Append(t))
		return -1, 0, fmt.Errorf("error while getting unspent: %w", err)
	}
	amount := uint64(0)
	for _, u := range unspent {
		amount += u.Value
	}
	return len(unspent), amount, nil
}

func (w *WOC) GetUTXOs(net string, address string) ([]*UTXO, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetUTXOs")
	unspent, err := w.GetUnspent(net, address)
	if err != nil {
		return nil, fmt.Errorf("error while getting unspent: %w", err)
	}
	outs := make([]*UTXO, 0)
	for _, u := range unspent {
		tx, err := w.GetTX(net, u.TXHash)
		if err != nil {
			log.Println(trace.Alert("cannot get TX").UTC().Add("address", address).Add("net", net).Add("TxHash", u.TXHash).Error(err).Append(t))
			return nil, fmt.Errorf("cannot get TX: %w", err)
		}
		for _, to := range tx.Out {
			if to.N == u.TXPos {
				u := UTXO{
					TXHash:       u.TXHash,
					TXPos:        to.N,
					Value:        to.Value,
					ScriptPubKey: to.ScriptPubKey,
				}
				outs = append(outs, &u)
			}
		}
	}
	return outs, nil
}

func (w *WOC) GetTX(net string, txHash string) (*TX, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetTX")
	url := fmt.Sprintf("%s/%s/tx/hash/%s", w.BaseURL, net, txHash)
	log.Println(trace.Debug("get tx").UTC().Add("hash", txHash).Add("net", net).Add("url", url).Append(t))
	resp, err := http.Get(url)
	if err != nil {
		log.Println(trace.Alert("error while getting TX").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while getting TX: %w", err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(trace.Alert("error while reading response").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while reading response: %w", err)
	}
	tx := TX{}
	err = json.Unmarshal(body, &tx)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while unmarshalling: %w", err)
	}
	return &tx, nil
}

func (w *WOC) BroadcastTX(net string, rawHex string) (string, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "BroadcastTX")
	url := fmt.Sprintf("%s/%s/tx/raw", w.BaseURL, net)
	log.Println(trace.Debug("broadcast tx").UTC().Add("net", net).Add("url", url).Append(t))
	resp, err := http.Post(url, "", strings.NewReader(rawHex))
	if err != nil {
		log.Println(trace.Alert("error while broadcasting TX").UTC().Add("rawHex", rawHex).Add("net", net).Add("url", url).Error(err).Append(t))
		return "", fmt.Errorf("error while broadcasting TX: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		log.Println(trace.Alert("broadcast NOT OK").UTC().Add("http status", fmt.Sprintf("%d", resp.StatusCode)).Add("net", net).Add("url", url).Append(t))
		return "", fmt.Errorf("broadcast NOT OK: %w", err)

	}
	body, err := ioutil.ReadAll(resp.Body)
	fmt.Printf("Response: status: %s body:%s\n", resp.Status, string(body))
	return string(body), nil

}

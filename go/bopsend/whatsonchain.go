package bopsend

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
)

type WOC struct {
	BaseURL string
}

func NewWOC() *WOC {
	w := WOC{BaseURL: "https://api.whatsonchain.com/v1/bsv"}
	return &w
}

func (w *WOC) GetUnspent(net string, address string) ([]*Unspent, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetUTXOs")
	url := fmt.Sprintf("%s/%s/address/%s/unspent", w.BaseURL, net, address)
	log.Println(trace.Debug("get unspent").UTC().Add("address", address).Add("net", net).Add("url", url).Append(t))
	resp, err := http.Get(url)
	if err != nil {
		log.Println(trace.Alert("error while getting unspent").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(trace.Alert("error while reading response").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	txs := []*Unspent{}
	err = json.Unmarshal(body, &txs)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling").UTC().Add("address", address).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	return txs, nil
}

func (w *WOC) GetTX(net string, txHash string) (*TX, error) {
	t := trace.New().Source("whatsonchain.go", "WOC", "GetTX")
	url := fmt.Sprintf("%s/%s/tx/hash/%s", w.BaseURL, net, txHash)
	log.Println(trace.Debug("get tx").UTC().Add("hash", txHash).Add("net", net).Add("url", url).Append(t))
	resp, err := http.Get(url)
	if err != nil {
		log.Println(trace.Alert("error while getting unspent").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(trace.Alert("error while reading response").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	tx := TX{}
	err = json.Unmarshal(body, &tx)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling").UTC().Add("txHash", txHash).Add("net", net).Add("url", url).Error(err).Append(t))
		return nil, err
	}
	return &tx, nil
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

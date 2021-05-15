package bopsend

import (
	"fmt"
	"math"

	"github.com/bitcoinsv/bsvutil"
	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	"github.com/libsv/go-bt"
)

type UTXO struct {
	TxPos        int
	TxHash       string
	Value        int
	ScriptPubKey ScriptPubKey
}

type Unspent struct {
	Height int    `json:"height"`
	TxPos  int    `json:"tx_pos"`
	TxHash string `json:"tx_hash"`
	Value  int    `json:"value"`
}

type TX struct {
	ID       string `json:"txid"`
	Hash     string `json:"hash"`
	Hex      string `json:"hex"`
	Version  int    `json:"version"`
	Size     int    `json:"size"`
	Locktime int    `json:"locktime"`
	In       []Vin  `json:"vin"`
	Out      []Vout `json:"vout"`
}

type Vin struct {
	Coinbase  string    `json:"coinbase"`
	TXID      string    `json:"txid"`
	Vout      int       `json:"vout"`
	ScriptSig ScriptSig `json:"scriptSig>"`
	Sequence  int       `json:"sequence"`
}

type Vout struct {
	Value        float64      `json:"value"`
	N            int          `json:"n"`
	ScriptPubKey ScriptPubKey `json:"scriptPubKey"`
}

type ScriptSig struct {
	Asm string `json:"asm"`
	Hex string `json:"hex"`
}

type ScriptPubKey struct {
	Asm      string   `json:"asm"`
	Hex      string   `json:"hex"`
	ReqSigs  int      `json:"reqSigs"`
	Type     string   `json:"type"`
	Adresses []string `json:"adresses"`
}

func CreateTX(address string) {
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
		fmt.Println(err.Error())
	}
	fmt.Println("tx: ", tx.ToString())
}

func SendUTXOsToAddress(utxos []*UTXO, address string, key string) (*bt.Tx, error) {
	t := trace.New().Source("transaction.go", "", "SendUTXOsToAddress")
	tx := bt.NewTx()
	satInput := 0
	for _, u := range utxos {
		input, err := bt.NewInputFromUTXO(u.TxHash, uint32(u.TxPos), uint64(u.Value), u.ScriptPubKey.Asm, math.MaxUint32)
		if err != nil {
			log.Println(trace.Alert("cannot add UTXO").UTC().Add("TxHash", u.TxHash).Add("TxPos", fmt.Sprintf("%d", u.TxPos)).Error(err).Append(t))
			return nil, fmt.Errorf("cannot get UTXOs: %w", err)
		}
		satInput += u.Value
		tx.AddInput(input)
	}
	fee, err := tx.CalculateFee(bt.DefaultFees())
	if err != nil {
		log.Println(trace.Alert("cannot calculate fee").UTC().Error(err).Append(t))
		return nil, fmt.Errorf("cannot get UTXOs: %w", err)
	}
	satOutput := satInput - int(fee)
	log.Println(trace.Info("calculating fee").UTC().Add("inputs", fmt.Sprintf("%d", satInput)).Add("outputs", fmt.Sprintf("%d", satOutput)).Add("fee", fmt.Sprintf("%d", fee)).Append(t))
	tx.PayTo(address, uint64(satOutput))

	wif, _ := bsvutil.DecodeWIF(key)
	inputsSigned, err := tx.SignAuto(&bt.InternalSigner{PrivateKey: wif.PrivKey, SigHashFlag: 0})
	if err != nil && len(inputsSigned) > 0 {
		log.Println(trace.Alert("cannot sign transaction").UTC().Error(err).Append(t))
		return nil, fmt.Errorf("cannot sign transaction: %w", err)
	}
	fmt.Println("tx: ", tx.ToString())
	return tx, nil
}

func GetOutputsOf(woc *WOC, net string, address string) ([]*UTXO, error) {
	t := trace.New().Source("transaction.go", "", "GetOutputOf")
	unspent, err := woc.GetUnspent(net, address)
	if err != nil {
		log.Println(trace.Alert("cannot get UTXOs").UTC().Add("address", address).Add("net", net).Error(err).Append(t))
		return nil, fmt.Errorf("cannot get UTXOs: %w", err)
	}
	outs := make([]*UTXO, 0)
	for _, u := range unspent {
		tx, err := woc.GetTX(net, u.TxHash)
		if err != nil {
			log.Println(trace.Alert("cannot get TX").UTC().Add("address", address).Add("net", net).Add("TxHash", u.TxHash).Error(err).Append(t))
			return nil, fmt.Errorf("cannot get TX: %w", err)
		}
		for _, to := range tx.Out {
			if to.N == u.TxPos {
				u := UTXO{
					TxHash:       u.TxHash,
					TxPos:        to.N,
					Value:        int(to.Value),
					ScriptPubKey: to.ScriptPubKey,
				}
				outs = append(outs, &u)
			}
		}
	}
	return outs, nil

}

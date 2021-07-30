package bopsend

import (
	"fmt"
	"math"

	"github.com/bitcoinsv/bsvd/bsvec"
	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	"github.com/libsv/go-bk/wif"
	"github.com/libsv/go-bt"
)

func UTXOsToAddress(utxos []*UTXO, toAddress string, key string, fee uint64) (*bt.Tx, error) {
	t := trace.New().Source("transaction.go", "", "SendUTXOsToAddress")
	tx := bt.NewTx()
	var satInput uint64 = 0
	log.Println(trace.Info("reading UTXO").UTC().Add("len UTXO", fmt.Sprintf("%d", len(utxos))).Append(t))
	for _, u := range utxos {
		input, err := bt.NewInputFromUTXO(u.TXHash, u.TXPos, u.Satoshis(), u.ScriptPubKey.Hex, math.MaxUint32)
		if err != nil {
			log.Println(trace.Alert("cannot add UTXO").UTC().Add("TxHash", u.TXHash).Add("TxPos", fmt.Sprintf("%d", u.TXPos)).Error(err).Append(t))
			return nil, fmt.Errorf("cannot get UTXOs: %w", err)
		}
		satInput += u.Satoshis()
		tx.AddInput(input)
	}
	satOutput := satInput - fee
	log.Println(trace.Info("calculating fee").UTC().Add("inputs", fmt.Sprintf("%d", satInput)).Add("outputs", fmt.Sprintf("%d", satOutput)).Add("fee", fmt.Sprintf("%d", fee)).Append(t))
	output, err := bt.NewP2PKHOutputFromAddress(toAddress, satOutput)
	if err != nil {
		log.Println(trace.Alert("cannot create output").UTC().Add("toAddress", toAddress).Add("satoshi", fmt.Sprintf("%d", satOutput)).Error(err).Append(t))
		return nil, fmt.Errorf("cannot create output to %s for %d satoshi: %w", toAddress, satOutput, err)
	}
	tx.AddOutput(output)
	w, err := wif.DecodeWIF(key)
	if err != nil {
		log.Println(trace.Alert("error decoding key").UTC().Error(err).Append(t))
		return nil, fmt.Errorf("error decoding key: %w", err)
	}
	signer := &bt.InternalSigner{PrivateKey: (*bsvec.PrivateKey)(w.PrivKey), SigHashFlag: 0x40 | 0x01}
	// signed, err := tx.SignAuto(signer)
	// if err != nil || len(signed) != len(utxos) {
	// 	log.Println(trace.Alert("cannot sign transaction inputs").UTC().Error(err).Append(t))
	// 	return nil, fmt.Errorf("cannot sign transaction inputs: %w", err)
	// }
	for i := range tx.Inputs {
		err = tx.Sign(uint32(i), signer)
		if err != nil {
			log.Println(trace.Alert("cannot sign transaction").UTC().Add("input", fmt.Sprintf("%d", i)).Error(err).Append(t))
			return nil, fmt.Errorf("cannot sign input %d: %w", i, err)
		}
	}
	return tx, nil
}

//GetBalance return the number of UTXO and the amount of satoshi for the given address
func GetBalance(address string) (int, uint64, error) {
	t := trace.New().Source("transaction.go", "", "CalculateFee")
	woc := NewWOC()
	num, amount, err := woc.GetUnspentAmount("main", address)
	if err != nil {
		log.Println(trace.Alert("cannot get balance").UTC().Add("address", address).Error(err).Append(t))
		return 0, 0, fmt.Errorf("cannot get balance: %w", err)
	}
	return num, amount, nil
}

//Sweep send all the balance connected to the given key to the given address and returns the TXID if success
func Sweep(fromKey string, toAddress string) (string, error) {
	t := trace.New().Source("transaction.go", "", "Sweep")
	woc := NewWOC()
	fromAddress, err := AddressOf(fromKey)
	if err != nil {
		log.Println(trace.Alert("failed to get derive address from key").UTC().Add("key", fromKey).Error(err).Append(t))
		return "", fmt.Errorf("failed to get derive address from key: %v", err)
	}
	utxo, err := woc.GetUTXOs("main", fromAddress)
	if err != nil {
		log.Println(trace.Alert("failed to get UTXO").UTC().Add("address", fromAddress).Error(err).Append(t))
		return "", fmt.Errorf("failed to get UTXO: %v", err)
	}
	taal := NewTAAL()
	fees, err := taal.GetFee()
	if err != nil {
		log.Println(trace.Alert("failed to get fees").UTC().Error(err).Append(t))
		return "", fmt.Errorf("failed to get fees: %v", err)
	}
	pretx, err := UTXOsToAddress(utxo, toAddress, fromKey, 0)
	if err != nil {
		log.Println(trace.Alert("failed to build TX").UTC().Error(err).Append(t))
		return "", fmt.Errorf("failed to build TX: %v", err)
	}
	fee, err := CalculateFee(pretx.ToBytes(), fees)
	if err != nil {
		log.Println(trace.Alert("failed to calculate fees").UTC().Error(err).Append(t))
		return "", fmt.Errorf("failed to calculate fees: %v", err)
	}
	tx, err := UTXOsToAddress(utxo, toAddress, fromKey, fee)
	if err != nil {
		log.Println(trace.Alert("failed to build TX").UTC().Error(err).Append(t))
		return "", fmt.Errorf("failed to build TX: %v", err)
	}
	txid, err := taal.SubmitTX(tx.ToString())
	if err != nil {
		log.Println(trace.Alert("failed to submit TX").UTC().Error(err).Append(t))
		return "", fmt.Errorf("failed to submit TX: %v", err)
	}
	if txid != tx.GetTxID() {
		log.Println(trace.Alert("weird, the returned TX ID is unexpected").UTC().Add("TXID from MAPI", txid).Add("TXID", tx.GetTxID()).Append(t))
	}
	return txid, nil
}

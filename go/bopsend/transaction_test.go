package bopsend_test

import (
	"os"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestUTXOToAddress(t *testing.T) {
	log.SetWriter(os.Stdout)
	key := "L2Aoi3Zk9oQhiEBwH9tcqnTTRErh7J3bVWoxLDzYa8nw2bWktG6M"
	destination := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	utxos := []*bopsend.UTXO{
		{
			TXPos:  1,
			TXHash: "e6706b900df5a46253b8788f691cbe1506c1e9b76766f1f9d6b3602e1458f055",
			Value:  0.000402740,
			ScriptPubKey: &bopsend.ScriptPubKey{
				Asm:      "OP_DUP OP_HASH160 2f353ff06fe8c4d558b9f58dce952948252e5df7 OP_EQUALVERIFY OP_CHECKSIG",
				Hex:      "76a9142f353ff06fe8c4d558b9f58dce952948252e5df788ac",
				ReqSigs:  1,
				Type:     "pubkeyhash",
				Adresses: []string{"15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"},
			},
		},
		{
			TXPos:  1,
			TXHash: "d715807cf35de1663d9413b0b0863aae83876c81a78206cedf4fd60bb0a986b7",
			Value:  0.000203310,
			ScriptPubKey: &bopsend.ScriptPubKey{
				Asm:      "OP_DUP OP_HASH160 2f353ff06fe8c4d558b9f58dce952948252e5df7 OP_EQUALVERIFY OP_CHECKSIG",
				Hex:      "76a9142f353ff06fe8c4d558b9f58dce952948252e5df788ac",
				ReqSigs:  1,
				Type:     "pubkeyhash",
				Adresses: []string{"15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"},
			},
		},
	}
	tx, err := bopsend.UTXOsToAddress(utxos, destination, key, 170)
	if err != nil {
		t.Fatalf("failed to create tx: %v", err)
	}
	if len(tx.ToString()) < 300 {
		t.Fatalf("failed to create tx, hex too short: %d", len(tx.ToString()))

	}
}

func TestSubmitRealTX(t *testing.T) {
	log.SetWriter(os.Stdout)
	toAddress := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	fromKey := "L2Aoi3Zk9oQhiEBwH9tcqnTTRErh7J3bVWoxLDzYa8nw2bWktG6M"
	woc := bopsend.NewWOC()
	utxo, err := woc.GetUTXOs("main", toAddress)
	if err != nil {
		t.Fatalf("failed to get UTXO: %v", err)
	}
	taal := bopsend.NewTAAL()
	fees, err := taal.GetFee()
	if err != nil {
		t.Fatalf("failed to get fees: %v", err)
	}
	pretx, err := bopsend.UTXOsToAddress(utxo, toAddress, fromKey, 0)
	if err != nil {
		t.Fatalf("failed to build TX: %v", err)
	}
	fee, err := bopsend.CalculateFee(pretx.ToBytes(), fees)
	if err != nil {
		t.Fatalf("failed to calculate fee: %v", err)
	}
	tx, err := bopsend.UTXOsToAddress(utxo, toAddress, fromKey, fee)
	if err != nil {
		t.Fatalf("failed to build TX: %v", err)
	}
	_, err = taal.SubmitTX(tx.ToString())
	if err != nil {
		t.Fatalf("failed to submit TX: %v", err)
	}
}

func TestRealSweep(t *testing.T) {
	log.SetWriter(os.Stdout)
	toAddress := "1AmHgmXUoBjW2NLymaNzQTwQCCob5VazUT"
	fromKey := "L5DrVc3Czbwv4azbXmjZt4QEEhmW3PnLJn9Y57hcyZGMV7ALgiZ1"
	id, err := bopsend.Sweep(fromKey, toAddress)
	if err != nil {
		t.Fatalf("failed to sweep address: %v", err)
	}
	if len(id) < 20 {
		t.Fatalf("returned TXID is too short %s", id)

	}
}

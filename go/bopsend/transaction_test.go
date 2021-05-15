package bopsend_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestGetOutputOf(t *testing.T) {
	log.SetWriter(os.Stdout)
	// utxos, err := bopsend.GetOutputsOf("main", "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3")
	woc := bopsend.NewWOC()
	utxos, err := bopsend.GetOutputsOf(woc, "main", "1EMV6A4qGgKJM2SVh6ZHMGx9oyGwB4EXJs")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	for i, u := range utxos {
		fmt.Printf("%d val: %d  %s\n", i, u.Value, u.ScriptPubKey.Asm)
	}
	t.Fail()
}

func TestUTXOToAddress(t *testing.T) {
	log.SetWriter(os.Stdout)
	address := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	key := "L2Aoi3Zk9oQhiEBwH9tcqnTTRErh7J3bVWoxLDzYa8nw2bWktG6M"
	destination := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	woc := bopsend.NewWOC()
	utxos, err := bopsend.GetOutputsOf(woc, "main", address)
	if err != nil {
		t.Fatalf("failed to get outputs: %v", err)
	}
	for i, u := range utxos {
		fmt.Printf("%d val: %d  %s\n", i, u.Value, u.ScriptPubKey.Asm)
	}
	tx, err := bopsend.UTXOsToAddress(utxos, destination, key)
	if err != nil {
		t.Fatalf("failed to create tx: %v", err)
	}
	fmt.Println(tx)
	t.Fail()
}

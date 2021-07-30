package bopsend_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestGetUnspent(t *testing.T) {
	log.SetWriter(os.Stdout)
	woc := bopsend.NewWOC()
	unsTx, err := woc.GetUTXOs("main", "1K2HC5AQQniJ2zcWSyjjtkKZgKMkZ1CGNr")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	fmt.Printf("Unspent: \n%v\n", unsTx[0].Value)
}

func TestGetUnspentAmount(t *testing.T) {
	log.SetWriter(os.Stdout)
	woc := bopsend.NewWOC()
	num, amount, err := woc.GetUnspentAmount("main", "1K2HC5AQQniJ2zcWSyjjtkKZgKMkZ1CGNr")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	expeNum := 4
	if num != expeNum {
		t.Fatalf("wrong num of input: %d, expected: %d ", num, expeNum)
	}
	expeAmount := uint64(13780292094)
	if amount != expeAmount {
		t.Fatalf("wrong unspent amount: %d, expected: %d", amount, expeAmount)
	}
}

func TestGetTX(t *testing.T) {
	log.SetWriter(os.Stdout)
	woc := bopsend.NewWOC()
	tx, err := woc.GetTX("main", "d715807cf35de1663d9413b0b0863aae83876c81a78206cedf4fd60bb0a986b7")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	fmt.Printf("TX ID: \n%v\n", tx.ID)
}

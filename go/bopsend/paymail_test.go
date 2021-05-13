package bopsend_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestGetAddress(t *testing.T) {
	log.SetWriter(os.Stdout)
	bopsend.GetAddress("diego@handcash.io")
	bopsend.GetAddress("diego@relayx.io")
	bopsend.GetAddress("diego@simply.cash")
	bopsend.GetAddress("diego@moneybutton.com")
}

func TestGetUnspent(t *testing.T) {
	log.SetWriter(os.Stdout)
	unsTx, err := bopsend.GetUnspent("main", "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	fmt.Printf("Unspent: \n%v\n", unsTx[0].Value)
	t.Fail()
}

func TestGetTX(t *testing.T) {
	log.SetWriter(os.Stdout)
	unsTx, err := bopsend.GetTX("main", "d715807cf35de1663d9413b0b0863aae83876c81a78206cedf4fd60bb0a986b7")
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	fmt.Printf("Unspent: \n%v\n", unsTx.Value)
	t.Fail()
}

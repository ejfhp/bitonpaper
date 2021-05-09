package bopsend_test

import (
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

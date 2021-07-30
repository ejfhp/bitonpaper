package bopsend_test

import (
	"os"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestGetAddressFromPaymail(t *testing.T) {
	log.SetWriter(os.Stdout)
	mails := []string{
		"diego@handcash.io",
		"diego@relayx.io",
		"diego@simply.cash",
		"diego@moneybutton.com",
	}
	for _, p := range mails {
		add, err := bopsend.GetAddressFromPaymail(p)
		if err != nil {
			t.Logf("Error getting %s: %v", p, err)
			t.Fail()
		}
		if add == "" {
			t.Logf("Address for %s id null", p)
			t.Fail()
		}
	}
}

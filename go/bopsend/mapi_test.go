package bopsend_test

import (
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
)

func TestBitcoinToSatoshi(t *testing.T) {
	utxos := map[uint64]*bopsend.UTXO{
		1:         {Value: 0.00000001},
		211337:    {Value: 0.00211337},
		211338:    {Value: 0.00211338},
		211336:    {Value: 0.00211336},
		100211337: {Value: 1.00211337},
		10:        {Value: 0.00000010},
		11:        {Value: 0.00000011},
		12:        {Value: 0.00000012},
		13:        {Value: 0.00000013},
		14:        {Value: 0.00000014},
		15:        {Value: 0.00000015},
		16:        {Value: 0.00000016},
		17:        {Value: 0.00000017},
		18:        {Value: 0.00000018},
		19:        {Value: 0.00000019},
	}
	for v, u := range utxos {
		sat := u.Satoshis()
		if sat != v {
			t.Logf("Amount are different! %d != %d", v, sat)
			t.Fail()
		}
	}
}

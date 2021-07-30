package bopsend_test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func TestGetFee(t *testing.T) {
	log.SetWriter(os.Stdout)
	taal := bopsend.NewTAAL()
	fees, err := taal.GetFee()
	if err != nil {
		t.Fatalf("error: %v", err)
	}
	if len(fees) < 2 {
		t.Fatalf("Incomplete fees array: %v", fees)
	}
	for i, f := range fees {
		fmt.Printf("%d val: %s  %d\n", i, f.FeeType, f.MiningFee.Satoshis)
	}
}

func TestSubmitTX(t *testing.T) {
	log.SetWriter(os.Stdout)
	txText := `010000000255f058142e60b3d6f9f16667b7e9c10615be1c698f78b85362a4f50d906b70e6010000006a47304402201381149727662d250c0eaee3030ace078d5e335c5b9375414b211773915e1c17022017101cecbe7d2e053252ebe4aa03889ac537f97fc45e44cba55fc0e978691b754121032f8bdd0bdb654616c362a427a01cf7abafa0b61831297c09211998ede8b99b45ffffffffb786a9b00bd64fdfce0682a7816c8783ae3a86b0b013943d66e15df37c8015d7010000006b483045022100dfd3f3742f160ccd6464e970c96b60c9a45ea486d24f47cdf292885908b4fed60220663696ddd16b3e6712964f8271567a364b4f12085a8d49d07562974eab8b766e4121032f8bdd0bdb654616c362a427a01cf7abafa0b61831297c09211998ede8b99b45ffffffff01c3eb0000000000001976a9142f353ff06fe8c4d558b9f58dce952948252e5df788ac00000000`
	taal := bopsend.NewTAAL()
	txid, err := taal.SubmitTX(txText)
	if txid != "" {
		if strings.Contains(err.Error(), "failure") == false {
			t.Fatalf("Miner should reply with an failure: %v", err)
		}
	}
	fmt.Printf("txid: '%s'\n", txid)
}

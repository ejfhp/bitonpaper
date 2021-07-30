package bopsend

import (
	"encoding/hex"
	"fmt"

	"github.com/bitcoinsv/bsvd/bsvec"
	"github.com/bitcoinsv/bsvd/chaincfg"
	"github.com/bitcoinsv/bsvutil"
	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
)

func DecodeWIF(wifkey string) (*bsvec.PrivateKey, error) {
	t := trace.New().Source("keys.go", "", "DecodeWIF")
	wif, err := bsvutil.DecodeWIF(wifkey)
	if err != nil {
		log.Println(trace.Alert("cannot decode WIF").UTC().Error(err).Append(t))
		return nil, fmt.Errorf("cannot decode WIF: %w", err)
	}
	priv := wif.PrivKey
	return priv, nil
}

func CheckWIFReEncoding(wifkey string) (bool, error) {
	t := trace.New().Source("keys.go", "", "CheckWIFReencoding")
	w1, err := bsvutil.DecodeWIF(wifkey)
	if err != nil {
		log.Println(trace.Alert("cannot decode WIF").UTC().Error(err).Append(t))
		return false, fmt.Errorf("cannot decode WIF: %w", err)
	}
	w2, err := bsvutil.NewWIF(w1.PrivKey, &chaincfg.MainNetParams, true)
	if err != nil {
		log.Println(trace.Alert("cannot create WIF from decoded key").UTC().Error(err).Append(t))
		return false, fmt.Errorf("cannot create WIF from decoded key: %w", err)
	}
	if wifkey != w2.String() {
		log.Println(trace.Warning("rencoded WIF is different from the original").UTC().Add("original", wifkey).Add("reencoded", w2.String()).Append(t))
		return false, fmt.Errorf("rencoded WIF is different from the original")
	}
	return true, nil
}

func PrivKeyFromHex(keyHex string) (*bsvec.PrivateKey, error) {
	t := trace.New().Source("keys.go", "", "PriveKeyFromHex")
	keyB, err := hex.DecodeString(keyHex)
	if err != nil {
		log.Println(trace.Alert("cannot decode HEX string").UTC().Add("hex", keyHex).Error(err).Append(t))
		return nil, fmt.Errorf("cannot decode HEX string: %w", err)
	}
	priv, _ := bsvec.PrivKeyFromBytes(bsvec.S256(), keyB)
	return priv, nil
}

func AddressOf(wifkey string) (string, error) {
	t := trace.New().Source("keys.go", "", "AddressOf")
	w, err := bsvutil.DecodeWIF(wifkey)
	if err != nil {
		log.Println(trace.Alert("cannot decode WIF").UTC().Error(err).Append(t))
		return "", fmt.Errorf("cannot decode WIF: %w", err)
	}
	fmt.Printf("compressed: %t\n", w.CompressPubKey)
	add, err := bsvutil.NewAddressPubKey(w.SerializePubKey(), &chaincfg.MainNetParams)

	// add, err := bscript.NewAddressFromPublicKeyHash(wif.SerialisePubKey(), true)

	if err != nil {
		log.Println(trace.Alert("cannot generate address from WIF").UTC().Error(err).Append(t))
		return "", fmt.Errorf("cannot generate address from WIF: %w", err)
	}
	return add.EncodeAddress(), nil

}

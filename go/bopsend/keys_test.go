package bopsend_test

import (
	"testing"

	"github.com/ejfhp/bitonpaper/go/bopsend"
)

func TestCheckWIFReEncoding(t *testing.T) {
	wif := "2BqadCTrAg7EgJbe8hs1TrBxysBK4p4ig8Xhwr3kzj4pMJDhhde8"
	ok, err := bopsend.CheckWIFReEncoding(wif)
	if ok == true {
		t.Fatalf("check should fail")
	}
	if err == nil {
		t.Fatalf("check should fail")
	}
}

func TestDecodeWIF(t *testing.T) {
	wif := "L2Aoi3Zk9oQhiEBwH9tcqnTTRErh7J3bVWoxLDzYa8nw2bWktG6M"
	k, err := bopsend.DecodeWIF(wif)
	if err != nil {
		t.Fatalf("WIF decoding failed: %v", err)
	}
	if k == nil {
		t.Fatalf("WIF decoded key is nil")
	}
}

func TestKeyFromHex(t *testing.T) {
	hex := "6452f68642cbdd900f50d4d41db159d2ccc27396d2e8c9bc2413b90e31319070"
	k, err := bopsend.PrivKeyFromHex(hex)
	if err != nil {
		t.Fatalf("key decoding failed: %v", err)
	}
	if k == nil {
		t.Fatalf("key decoded key is nil")
	}
}

func TestAddressOf(t *testing.T) {
	keys := map[string]string{
		"1GB5MLgNF4zDVQc65BdrXKac1GJK8K59Ck": "KxdpCLdUFVuY9KCLaRVGfsSKQWnFobegqVjn8tM8oPo3UBbzgraF",
		"17cM2c5ybSidHThYa5rBykMEJ5dANkJWVW": "L3MB8BnEVH1gM4oGADEqXLWLpVXvbXP5pf7ezZaSoWi37sig3ZA6",
		"1KiMqNRH98WJGosedCZyw3nzJQG8w3iN54": "KzQiUaeAx9vfDSdMaFseaNzgvkXYzDPLJEiTxFHT4oQKgT4zLowf",
		"1JLqtRfMf77vbeE8ASPP3hWLduLBow5fQP": "Kzx2g5x4tDavJfRX7fhewQvjtR2kg5EkF47y2NPnN6vxux4Ag7pT",
		"1KKK563UqCR5nz5figdRekp4BUzvCQ7S3B": "L3HcLioKSRRsCjafvRfZ7Yre2UqSU5cQ6C8W6zi849RjzJ9cN3Wh",
		"1Nme23uK2iFW3MX8UEguLQeNNHwdEr23TL": "L1htQ8AePB3t4PxUr4wAojWYZmB9RiQCDBRB5C97GynkmvPKXrGn",
		"17HKJKar5dh3HbzGpB4Hoy7WHHo5totazd": "L4yumTCmLnJQBvDrKy1gTS1fbGrw792uWBftZaShg67uT7CapX7T",
		"1BXbpQ9ffsXRr9uyUCy1X4mXDnz7iHY7Qs": "L49YYrcxJWDG8emWPGrdTisSCsq1HYLRnqP2rzXHrHcCgNZ6khG7",
		"1ADi6SNG6LqX3PmdANhBAZY8oGbZbDFtAb": "L12fQB2YPC6rXZB2f8y2j6c2dzjiMQA58vuuBNJXYbNtiiL7yKq1",
		"1BRiuijd9zSsybGdQqoC5G67oXQLgMTojg": "KxGcDN28hBLfEDF6wPfB9c4ftVFm4nddMB2AoSDFVwz4sTw9CMmQ"}

	for add, key := range keys {
		a, err := bopsend.AddressOf(key)
		if err != nil {
			t.Error(err)
		}
		if a != add {
			t.Fatalf("geerated %s != expected  %s", a, add)
		}
	}
}

package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	log "github.com/ejfhp/trail"
	"github.com/julienschmidt/httprouter"
)

func TestPage(t *testing.T) {
	log.SetWriter(os.Stdout)
	router := httprouter.New()
	router.GET("/*FILE", NewContentHandler("/", "./", "index.html").LocalFile)
	req, _ := http.NewRequest("GET", "/testdata/test.txt", nil)
	rr := httptest.NewRecorder()

	router.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Wrong status")
	}
	if rr.Body.String() != "Bitcoin is BSV" {
		t.Fatalf("wrong body: '%s'\n", rr.Body.String())
	}
}

func TestAlias(t *testing.T) {
	log.SetWriter(os.Stdout)
	router := httprouter.New()
	router.GET("/*FILE", NewContentHandler("/alias", "./testdata", "index.html").LocalFile)
	req, _ := http.NewRequest("GET", "/alias/test.txt", nil)
	rr := httptest.NewRecorder()

	router.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Wrong status")
	}
	if rr.Body.String() != "Bitcoin is BSV" {
		t.Fatalf("wrong body: '%s'\n", rr.Body.String())
	}
}

func TestPaymail(t *testing.T) {
	log.SetWriter(os.Stdout)
	address := "diego@handcash.io"
	router := httprouter.New()
	router.GET("/paymail/:PAYMAIL/:SECRET", NewBitcoinHandler().Paymail)
	req, _ := http.NewRequest("GET", fmt.Sprintf("/paymail/%s/%s", address, SECRET), nil)
	rr := httptest.NewRecorder()

	router.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Wrong status")
	}
	if strings.Contains(rr.Body.String(), "address") != true {
		t.Fatalf("wrong body: '%s'\n", rr.Body.String())
	}
}

func TestBalance(t *testing.T) {
	log.SetWriter(os.Stdout)
	address := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	router := httprouter.New()
	router.GET("/balance/:ADDRESS/:SECRET", NewBitcoinHandler().Balance)
	req, _ := http.NewRequest("GET", fmt.Sprintf("/balance/%s/%s", address, SECRET), nil)
	rr := httptest.NewRecorder()

	router.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Wrong status")
	}
	if strings.Contains(rr.Body.String(), "balance") != true {
		t.Fatalf("wrong body: '%s'\n", rr.Body.String())
	}
}

func TestSweep(t *testing.T) {
	log.SetWriter(os.Stdout)
	toAddress := "15JcYsiTbhFXxU7RimJRyEgKWnUfbwttb3"
	fromKey := "L2Aoi3Zk9oQhiEBwH9tcqnTTRErh7J3bVWoxLDzYa8nw2bWktG6M"
	router := httprouter.New()
	router.GET("/sweep/:KEY/:FROMADDRESS/:TOADDRESS/:SECRET", NewBitcoinHandler().Sweep)
	req, _ := http.NewRequest("GET", fmt.Sprintf("/sweep/%s/%s/%s/%s", fromKey, toAddress, toAddress, SECRET), nil)
	rr := httptest.NewRecorder()

	router.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Wrong status")
	}
	if strings.Contains(rr.Body.String(), "txid") != true {
		t.Fatalf("wrong body: '%s'\n", rr.Body.String())
	}
}

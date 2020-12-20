package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/julienschmidt/httprouter"
)

func TestPage(t *testing.T) {
	router := httprouter.New()
	router.GET("/*file", NewPageHandler("/", "./").LocalFile)
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
	router := httprouter.New()
	router.GET("/*file", NewPageHandler("/alias", "./testdata").LocalFile)
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

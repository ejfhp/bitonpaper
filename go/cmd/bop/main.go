package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	"github.com/julienschmidt/httprouter"
)

const (
	SECRET = "76a9142f353ff06fe8c4d558b9"
)

func FileNotFound(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, "/bop", http.StatusPermanentRedirect)
}

//PageHandler implements httprouter.Handle and serve static content from a local dir
type ContentHandler struct {
	alias string
	path  string
	index string
}

func NewContentHandler(alias, localPath, index string) *ContentHandler {
	ph := ContentHandler{alias: alias, path: localPath, index: index}
	return &ph
}

func (h *ContentHandler) LocalFile(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	t := trace.New().Source("main.go", "ContentHandler", "LocalFile")
	rf := ps.ByName("FILE")
	log.Println(trace.Info("getting file").UTC().Add("URI", r.RequestURI).Add("file param", rf).Append(t))
	rel, err := filepath.Rel(h.alias, rf)
	if rel == "." {
		rel = h.index
	}
	if rel == "favicon.ico" {
		rel = "img/favicon.ico"
	}
	localfile := filepath.Join(h.path, rel)
	log.Println(trace.Info("getting file").UTC().Add("rel", rel).Add("localfile", localfile).Append(t))
	f, err := os.Open(localfile)
	if err != nil {
		log.Println(trace.Alert("cannot access file - status 404").UTC().Add("localfile", localfile).Error(err).Append(t))
		w.WriteHeader(404)
		return
	}
	stat, err := f.Stat()
	if err != nil {
		log.Println(trace.Alert("cannot get stat of file - status 404").UTC().Add("localfile", localfile).Error(err).Append(t))
		w.WriteHeader(404)
		return
	}
	if stat.IsDir() {
		log.Println(trace.Alert("dir list not allowed - status 403").UTC().Add("localfile", localfile).Error(err).Append(t))
		w.WriteHeader(403)
	}
	switch filepath.Ext(localfile) {
	case ".html":
		w.Header().Set("Content-Type", "text/html")
		w.Header().Set("Content-Disposition", "inline")
	case ".png":
		w.Header().Set("Content-Type", "image/png")
		w.Header().Set("Content-Disposition", "inline")
	case ".jpg":
		w.Header().Set("Content-Type", "image/jpeg")
		w.Header().Set("Content-Disposition", "inline")
	case ".js":
		w.Header().Set("Content-Type", "application/javascript")
		w.Header().Set("Content-Disposition", "inline")
	case ".css":
		w.Header().Set("Content-Type", "text/css")
		w.Header().Set("Content-Disposition", "inline")
	case ".ico":
		w.Header().Set("Content-Type", "image/x-icon")
		w.Header().Set("Content-Disposition", "inline")
	}
	io.Copy(w, f)
}

type BitcoinHandler struct {
}

func NewBitcoinHandler() *BitcoinHandler {
	return &BitcoinHandler{}
}

func (b *BitcoinHandler) Paymail(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	t := trace.New().Source("main.go", "BitcoinHandler", "Paymail")
	secret := ps.ByName("SECRET")
	if secret != SECRET {
		log.Println(trace.Alert("invalid secret - status 403").UTC().Add("secret", secret).Append(t))
		w.WriteHeader(403)
		return
	}
	paymail := ps.ByName("PAYMAIL")
	log.Println(trace.Info("getting address").UTC().Add("paymail", paymail).Append(t))
	toAddress, err := bopsend.GetAddressFromPaymail(paymail)
	if err != nil {
		log.Println(trace.Alert("invalid paymail - status 400").UTC().Add("paymail", paymail).Error(err).Append(t))
		w.WriteHeader(400)
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(fmt.Sprintf("{\"address\": \"%s\"}", toAddress)))
}

func (b *BitcoinHandler) Balance(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	t := trace.New().Source("main.go", "BitcoinHandler", "CheckPaymail")
	secret := ps.ByName("SECRET")
	if secret != SECRET {
		log.Println(trace.Alert("invalid secret - status 403").UTC().Add("secret", secret).Append(t))
		w.WriteHeader(403)
		return
	}
	address := ps.ByName("ADDRESS")
	log.Println(trace.Info("getting balance").UTC().Add("address", address).Append(t))
	nout, balance, err := bopsend.GetBalance(address)
	if err != nil {
		log.Println(trace.Alert("cannot get balance - status 500").UTC().Add("address", address).Error(err).Append(t))
		w.WriteHeader(500)
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(fmt.Sprintf("{\"balance\": \"%d\", \"outputs\": \"%d\"}", balance, nout)))
}

func (b *BitcoinHandler) Sweep(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	t := trace.New().Source("main.go", "BitcoinHandler", "Sweep")
	secret := ps.ByName("SECRET")
	if secret != SECRET {
		log.Println(trace.Alert("invalid secret - status 403").UTC().Add("secret", secret).Append(t))
		w.WriteHeader(403)
		return
	}
	fromAddress := ps.ByName("FROMADDRESS")
	key := ps.ByName("KEY")
	toAddress := ps.ByName("TOADDRESS")
	log.Println(trace.Info("sweep wallet").UTC().Add("fromAddress", fromAddress).Add("toAddress", toAddress).Append(t))
	keyAdd, err := bopsend.AddressOf(key)
	if err != nil {
		log.Println(trace.Alert("cannot get address from key - status 500").UTC().Error(err).Append(t))
		w.WriteHeader(500)
		return
	}
	if keyAdd != fromAddress {
		log.Println(trace.Alert("key address and from address are different").UTC().Error(err).Append(t))
		w.WriteHeader(500)
		return
	}
	txid, err := bopsend.Sweep(key, toAddress)
	if err != nil {
		log.Println(trace.Alert("cannot sweep key - status 500").UTC().Error(err).Append(t))
		w.WriteHeader(500)
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(fmt.Sprintf("{\"txid\": \"%s\"}", txid)))
}

//go:generate go run buildscript/includekey.go
func main() {
	t := trace.New().Source("main.go", "", "main")
	log.SetWriter(os.Stdout)
	fmt.Printf("Starting BitOnPaper - ready to build Bitcoin paper wallet for the world...\n")
	router := httprouter.New()
	contentHandler := NewContentHandler("/", "./web", "index.html")
	router.GET("/bop/*FILE", contentHandler.LocalFile)
	router.GET("/paymail/:PAYMAIL/:SECRET", NewBitcoinHandler().Paymail)
	router.GET("/balance/:ADDRESS/:SECRET", NewBitcoinHandler().Balance)
	router.GET("/sweep/:KEY/:FROMADDRESS/:TOADDRESS/:SECRET", NewBitcoinHandler().Sweep)
	// Serve static files from the ./public directory
	router.NotFound = http.HandlerFunc(FileNotFound)
	err := http.ListenAndServe(":8080", router)
	if err != nil {
		log.Println(trace.Alert("ListAndServe failed").UTC().Error(err).Append(t))
	}
}

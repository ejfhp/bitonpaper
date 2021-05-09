package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
	"github.com/julienschmidt/httprouter"
)

//PageHandler implements httprouter.Handle and serve static content from a local dir
type PageHandler struct {
	alias string
	path  string
	index string
}

func NewPageHandler(alias, localPath, index string) *PageHandler {
	t := trace.New().Source("main.go", "PageHandler", "NewPageHandler")
	log.Println(trace.Debug("NewPageHandler").Append(t))
	ph := PageHandler{alias: alias, path: localPath, index: index}
	return &ph
}

func (h *PageHandler) LocalFile(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	t := trace.New().Source("main.go", "PageHandler", "LocalFile")
	rf := ps.ByName("file")
	log.Println(trace.Debug("responding").UTC().Add("URI", r.RequestURI).Add("file", rf).Append(t))
	rel, err := filepath.Rel(h.alias, rf)
	if rel == "." {
		rel = h.index
	}
	if rel == "favicon.ico" {
		rel = "img/favicon.ico"
	}
	log.Println(trace.Debug("responding").UTC().Add("URI", r.RequestURI).Add("rel", rel).Append(t))
	localfile := filepath.Join(h.path, rel)
	log.Println(trace.Debug("responding").UTC().Add("URI", r.RequestURI).Add("localfile", localfile).Append(t))
	f, err := os.Open(localfile)
	if err != nil {
		log.Println(trace.Alert("cannot access file").UTC().Add("URI", r.RequestURI).Add("localfile", localfile).Append(t))
		w.WriteHeader(404)
		return
	}
	stat, err := f.Stat()
	if err != nil {
		log.Println(trace.Alert("cannot get stat of file").UTC().Add("URI", r.RequestURI).Add("localfile", localfile).Append(t))
		w.WriteHeader(404)
		return
	}
	if stat.IsDir() {
		log.Println(trace.Alert("dir list not allowed").UTC().Add("URI", r.RequestURI).Add("localfile", localfile).Append(t))
		w.WriteHeader(403)
	}
	switch filepath.Ext(localfile) {
	case ".html":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "text/html").Append(t))
		w.Header().Set("Content-Type", "text/html")
		w.Header().Set("Content-Disposition", "inline")
	case ".png":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "image/png").Append(t))
		w.Header().Set("Content-Type", "image/png")
		w.Header().Set("Content-Disposition", "inline")
	case ".jpg":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "image/jpeg").Append(t))
		w.Header().Set("Content-Type", "image/jpeg")
		w.Header().Set("Content-Disposition", "inline")
	case ".js":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "application/javascript").Append(t))
		w.Header().Set("Content-Type", "application/javascript")
		w.Header().Set("Content-Disposition", "inline")
	case ".css":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "text/css").Append(t))
		w.Header().Set("Content-Type", "text/css")
		w.Header().Set("Content-Disposition", "inline")
	case ".ico":
		log.Println(trace.Debug("from extension").UTC().Add("Content-Type", "image/x-icon").Append(t))
		w.Header().Set("Content-Type", "image/x-icon")
		w.Header().Set("Content-Disposition", "inline")
	}
	io.Copy(w, f)
}

//go:generate go run buildscript/includekey.go
func main() {
	fmt.Printf("Starting BitOnPaper - ready to build Bitcoin paper wallet for the world...\n")
	router := httprouter.New()
	router.GET("/*file", NewPageHandler("/", "./web", "index.html").LocalFile)
	err := http.ListenAndServe(":8080", router)
	if err != nil {
		fmt.Printf("ListenAndServe failed: %v\n", err)
	}
}

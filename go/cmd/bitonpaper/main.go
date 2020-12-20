package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/julienschmidt/httprouter"
)

//PageHandler implements httprouter.Handle and serve static content from a local dir
type PageHandler struct {
	alias string
	path  string
	index string
}

func NewPageHandler(alias, localPath, index string) *PageHandler {
	ph := PageHandler{alias: alias, path: localPath, index: index}
	return &ph
}

func (h *PageHandler) LocalFile(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	fmt.Printf("URI: %s   FILE: %s\n", r.RequestURI, ps.ByName("file"))
	rf := ps.ByName("file")
	fmt.Printf("File: %s\n", rf)
	rel, err := filepath.Rel(h.alias, rf)
	if rel == "." {
		rel = h.index
	}
	if rel == "favicon.ico" {
		rel = "img/favicon.ico"
	}
	fmt.Printf("Rel: %s\n", rel)
	localfile := filepath.Join(h.path, rel)
	fmt.Printf("Localpath %s\n", localfile)
	f, err := os.Open(localfile)
	if err != nil {
		fmt.Printf("cannot access file: %s", localfile)
		w.WriteHeader(404)
		return
	}
	stat, err := f.Stat()
	if err != nil {
		fmt.Printf("cannot get stat of file: %s", localfile)
		w.WriteHeader(404)
		return
	}
	if stat.IsDir() {
		fmt.Printf("dir list not allowed: %s", localfile)
		w.WriteHeader(403)
	}
	fmt.Printf("Ext: %s\n", filepath.Ext(localfile))
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

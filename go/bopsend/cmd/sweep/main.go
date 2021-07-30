package main

import (
	"fmt"
	"os"

	"github.com/ejfhp/bitonpaper/go/bopsend"
	log "github.com/ejfhp/trail"
)

func main() {

	log.SetWriter(os.Stdout)
	if len(os.Args) != 3 {
		fmt.Printf("%s requires two parameters: <key> <paymail>\n", os.Args[0])
		os.Exit(-1)
	}
	key := os.Args[1]
	paymail := os.Args[2]
	toAddress, err := bopsend.GetAddressFromPaymail(paymail)
	if err != nil {
		fmt.Printf("FAILED TO GET ADDRESS FROM PAYMAIL")
		os.Exit(-1)
	}
	ok, err := bopsend.Sweep(key, toAddress)
	if err != nil {
		fmt.Printf("FAILED TO SWEEP")
		os.Exit(-1)
	}
	fmt.Printf("Result is: %t\n", ok)

}

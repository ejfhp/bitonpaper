package main

import (
	"fmt"
	"os"

	"github.com/ejfhp/bitonpaper/go/bopsend"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("%s requires a list of addresses separated by space\n", os.Args[0])
	}
	addresses := os.Args[1:]
	totAmount := uint64(0)
	for i, add := range addresses {
		_, amount, err := bopsend.GetBalance(add)
		if err != nil {
			fmt.Printf("error while getting balance for address num %d - %s: %v", i, add, err)
		}
		totAmount += amount
	}
	bsv := float64(totAmount) / 100000000
	fmt.Printf("%.8f\n", bsv)

}

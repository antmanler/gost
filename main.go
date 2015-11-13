// main
package main

import (
	"flag"
	"fmt"
	"github.com/golang/glog"
	"sync"
)

const (
	LFATAL = iota
	LERROR
	LWARNING
	LINFO
	LDEBUG
)

var (
	listenAddr, forwardAddr strSlice
	pv                      bool // print version

	listenArgs  []Args
	forwardArgs []Args
	version     = "2.0-20151106"
	gitRev      = "dev"
)

func init() {
	flag.Var(&listenAddr, "L", "listen address, can listen on multiple ports")
	flag.Var(&forwardAddr, "F", "forward address, can make a forward chain")
	flag.BoolVar(&pv, "V", false, "print version")
	flag.Parse()
}

func main() {
	defer glog.Flush()

	if flag.NFlag() == 0 {
		flag.PrintDefaults()
		return
	}
	if pv {
		fmt.Println("gost", version, "git:", gitRev)
		return
	}

	listenArgs = parseArgs(listenAddr)
	forwardArgs = parseArgs(forwardAddr)

	if len(listenArgs) == 0 {
		glog.Exitln("no listen addr")
	}
	glog.Infof("gost %s(git: %s) started", version, gitRev)

	var wg sync.WaitGroup
	for _, args := range listenArgs {
		wg.Add(1)
		go func(arg Args) {
			defer wg.Done()
			listenAndServe(arg)
		}(args)
	}
	wg.Wait()
}

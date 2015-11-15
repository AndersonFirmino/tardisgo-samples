// Copyright 2013 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"flag"
	"fmt"
	"go/build"
	"log"
	"os"
	"runtime"
	"runtime/pprof"
	"time"

	"github.com/tardisgo/tardisgo-samples/wip/ssainterp/interp"
	//"./interp"

	"golang.org/x/tools/go/loader"
	"golang.org/x/tools/go/ssa"
	"golang.org/x/tools/go/ssa/ssautil"
	"golang.org/x/tools/go/types"
)

var cpuprofile = flag.String("cpuprofile", "", "write cpu profile to file")

// This program demonstrates how to run the SSA builder on a "Hello,
// World!" program and shows the printed representation of packages,
// functions and instructions.
//
// Within the function listing, the name of each BasicBlock such as
// ".0.entry" is printed left-aligned, followed by the block's
// Instructions.
//
// For each instruction that defines an SSA virtual register
// (i.e. implements Value), the type of that value is shown in the
// right column.
//
// Build and run the ssadump.go program if you want a standalone tool
// with similar functionality. It is located at
// golang.org/x/tools/cmd/ssadump.
//

func main() {
	flag.Parse()
	const hello = `
package main
import "runtime"
import "unsafe"
import "fmt"
import "os"
import b64 "encoding/base64"
import "text/scanner"	

func b64main() {

	// Here's the string we'll encode/decode.
	data := "abc123!?$*&()'-=@~"

	// Go supports both standard and URL-compatible
	// base64. Here's how to encode using the standard
	// encoder. The encoder requires a []byte so we
	// cast our string to that type.
	sEnc := b64.StdEncoding.EncodeToString([]byte(data))
	println(sEnc)

	// Decoding may return an error, which you can check
	// if you don't already know the input to be
	// well-formed.
	sDec, _ := b64.StdEncoding.DecodeString(sEnc)
	println(string(sDec))
	println(" ") // TODO fix this bug - println() generates a haxe error : Unexpected )

	// This encodes/decodes using a URL-compatible base64
	// format.
	uEnc := b64.URLEncoding.EncodeToString([]byte(data))
	println(uEnc)
	uDec, _ := b64.URLEncoding.DecodeString(uEnc)
	println(string(uDec))
}

const message = "Testing, testing, 1... 2... 3..."

func Foo(a,b int) int 

var zero = 0

func fact(n int) int {
	//println("fact",n)
	if n == 0 {
		return 1
	}
	return n * fact(n-1)
}

func mandelbrot(n int) int {
	const Iter = 50
	const Zero float64 = 0
	const Limit = 2.0
	ok := 0
	for y := 0; y < n; y++ {
		for x := 0; x < n; x++ {
			Zr, Zi, Tr, Ti := Zero, Zero, Zero, Zero
			Cr := (2*float64(x)/float64(n) - 1.5)
			Ci := (2*float64(y)/float64(n) - 1.0)

			for i := 0; i < Iter && (Tr+Ti <= Limit*Limit); i++ {
				Zi = 2*Zr*Zi + Ci
				Zr = Tr - Ti + Cr
				Tr = Zr * Zr
				Ti = Zi * Zi
			}

			if Tr+Ti <= Limit*Limit {
				ok++
			}
		}
	}
	return ok
}

var testStruct scanner.Position

type xT struct {
	a,b int
}

type yT struct {
	c,d xT
}

func main() {
	println(Foo(1,2)) // call a func defined externally

	println(message)
	fmt.Println("testing,testing",1,2,3)
    fmt.Printf("Hello %v/%v\n", runtime.GOOS, runtime.GOARCH)
	mol := fmt.Sprintf("The meaning of life the universe and everything is %d",42)
	println(mol)
	u := uintptr(42)
	println("The size of a uintptr is ", unsafe.Sizeof(u))
	
	println("ten factorial is ", fact(10)) 
	x := float64(0)
	for i:=0;i<10; i++ {
		x += float64(fact(i))
	}
	fmt.Printf("grand total is %v:%T\n",x,x)

	b64main() // demonstrate use of encoding/base64

	println(mandelbrot(100)) //benchmark speed when fast enough...

	// play with an externally defined structure
	testStruct = scanner.Position{
		Filename: "ZombieApocolypse",
        Offset: 0,
        Line: 1,
        Column: 2, 
	}
	testStruct.Filename+="!"
	testStruct.Offset++
	testStruct.Line++
	testStruct.Column++
	println(testStruct.Filename,testStruct.Offset,testStruct.Line,testStruct.Column)
	fmt.Fprintf(os.Stdout, "PRINTed via os.Stdout %#v\n",testStruct)

	// alter a field within a sub-structure
	z := yT{xT{1,2},xT{3,4}}
	fmt.Printf("z initialized=%#v\n",z)
	twotwo := &z.c.b
	fmt.Println("*twotwo=",*twotwo)
	z.c = xT{5,6}
	fmt.Printf("z altered=%#v\n",z)
	
	// play with unsafe pointers
	fmt.Println("*twotwo=",*twotwo)
	uptr := unsafe.Pointer(twotwo)
	fmt.Printf("uptr=%v:%T\n",uptr,uptr)
	iptr := (*int)(uptr)
	fmt.Printf("iptr=%v:%T\n",iptr,iptr)
	fmt.Println("*uptr=",*iptr)
	
}
`

	conf := loader.Config{
		Build: &build.Default,
	}

	//if runtime.GOOS == "linux" { // for testing in docker
	//	conf.Build.GOROOT = "/usr/src/go"
	//}
	//conf.Build.GOOS = "nacl" // to avoid using the file system
	//conf.Build.GOARCH = "386"

	println("Compiler:", runtime.Compiler)

	// Parse the input file.
	file, err := conf.ParseFile("hello.go", hello)
	if err != nil {
		fmt.Print(err) // parse error
		return
	}

	// Create single-file main package.
	conf.CreateFromFiles("main", file)
	conf.Import("runtime") // always need this for ssa/interp

	// Load the main package and its dependencies.
	iprog, err := conf.Load()
	if err != nil {
		fmt.Print(err) // type error in some package
		return
	}

	// Create SSA-form program representation.
	prog := ssautil.CreateProgram(iprog, ssa.SanityCheckFunctions)

	var mainPkg *ssa.Package
	for _, pkg := range prog.AllPackages() {
		if pkg.Pkg.Name() == "main" {
			mainPkg = pkg
			if mainPkg.Func("main") == nil {
				panic(fmt.Errorf("no func main() in main package"))
			}
			break
		}
	}
	if mainPkg == nil {
		panic(fmt.Errorf("no main package"))
	}

	// Build SSA code for bodies for whole program
	prog.Build()

	mainPkg.Func("main").WriteTo(os.Stdout) // list the main func in SSA form

	if *cpuprofile != "" {
		f, err := os.Create(*cpuprofile)
		if err != nil {
			log.Fatal(err)
		}
		pprof.StartCPUProfile(f)
		defer pprof.StopCPUProfile()
	}

	exts := interp.NewExternals()
	// add a callable external function
	exts.AddExtFunc("main.Foo", func(args []interp.Ivalue) interp.Ivalue {
		return args[0].(int) + args[1].(int)
	})

	start := time.Now()
	ctxt, exitCode := interp.Interpret(mainPkg, 0, &types.StdSizes{8, 8}, "hello.go", []string{}, exts)
	fmt.Println("Time taken:", time.Since(start), "Exit code:", exitCode)

	// call a function within the interpreter context
	fmt.Println("context call fact(10)=",
		ctxt.Call("main.fact", []interp.Ivalue{int(10)}))
}

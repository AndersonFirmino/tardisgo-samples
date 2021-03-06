package main

import (
	"fmt"
	"reflect"
	"strconv"

	"github.com/tardisgo/tardisgo/haxe/hx"
)

type I int

func (i I) String() string { return fmt.Sprintf("<%d>", int(i)) }

//func (p *I) String() string { return fmt.Sprintf("<%d>", int(*p)) }

type B struct {
	I I
	j int
}

var b12 = B{1, 2}

func main() {
	//m1 := map[int]string{1: "one", 2: "two", 3: "three"}
	//fmt.Printf("value %v\n", m1)
	//fmt.Printf("&value %v\n", &m1)

	x := interface{}(I(777))

	s, ok := x.(fmt.Stringer)
	if ok {
		fmt.Printf("implements Stringer: %v\n", s)
	}

	fmt.Printf("%v\n", I(42))
	fmt.Printf("%v\n", b12)
	fmt.Printf("%#v\n", b12)

	//fmt.Println(reflect.TypeOf(b12).NumField())
	//fmt.Println(reflect.TypeOf(b12).NumMethod())
	//fmt.Println(reflect.TypeOf(b12.I).NumMethod())

	for f := 0; f < reflect.TypeOf(b12).NumField(); f++ {
		fmt.Printf("%d %#v \n", f, reflect.TypeOf(b12).Field(f))
		fmt.Printf("%d %v \n", f, reflect.TypeOf(b12).Field(f))
		fmt.Printf("%d Type= %#v \n", f, reflect.TypeOf(b12).Field(f).Type)
		fmt.Printf("%d Type= %v \n", f, reflect.TypeOf(b12).Field(f).Type)
	}

	fmt.Printf("ValueOf=%v\n", reflect.ValueOf(b12).Field(0))

	y := float64(0)
	fmt.Println("-0=", y*-1)
	fmz := hx.CodeFloat("", "Force.minusZero;")
	fmt.Println("Force -0=", fmz, 1/fmz)

	u, err := strconv.ParseUint("1e19", 10, 64)
	println("1e19", u, err.Error())

	e := int64(-1 << 63)
	eu := uint64(e)
	eum := -eu
	eumd := eum % 10
	eumdb := byte(eumd)
	fmt.Println("e,eu,-,%10,byte()=", e, eu, eum, eumd, eumdb)

	x777 := 777
	fmt.Println("Cast from int +/-", x777, -x777, " to uint8 ", uint8(x777), uint8(-x777))
}

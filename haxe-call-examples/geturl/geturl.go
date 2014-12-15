package main

import (
	"github.com/tardisgo/tardisgo/tardisgolib"
	"github.com/tardisgo/tardisgo/tardisgolib/hx"
)

// Print tardisgo web site LICENSE in the simplest way possible
func main() {

	s := "Sorry haxe.Http.requestUrl() is not available on the Flash or NodeJS platforms"
	if tardisgolib.Platform() != "flash" && tardisgolib.Platform() != "js" {
		s = hx.CallString("!flash && !js", "haxe.Http.requestUrl", 1, "http://tardisgo.github.io/LICENSE")
	}
	switch tardisgolib.Platform() {
	case "neko", "cpp", "php":
		hx.Call("neko", "neko.Lib.println", 1, s)
		hx.Call("cpp", "cpp.Lib.println", 1, s)
		hx.Call("php", "php.Lib.println", 1, s)

	default:
		// print using the built-in trace-style println() for other platforms
		println(s)
	}
}

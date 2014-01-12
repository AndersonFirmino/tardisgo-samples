tardisgo-samples
================

Sample code using TARDIS Go (not yet published).


To run these examples you will need to install Haxe (from http://haxe.org).

From the directory containing the .go files, to translate Go to Haxe, type the command line: "tardisgo filename.go". Note that a "tardis" sub-directory must exist before the command is run (which it does in these samples). 

Then to run the tardis/Go.hx file generated, type the command line: "haxe -main tardis.Go --interp", or whatever Haxe compilation options you want to use. (Note that to compile for PHP you currently need to add the haxe compilation option "--php-prefix tardisgo" to avoid name confilcts).

To run the examples using OpenFL you will need to install both Haxe (from http://haxe.org) and then OpenFL (from http://openfl.org). Run the tardisgo command as described above from the Source directory. Then follow the normal OpenFL/Lime development process.


Haxe-gobyexample examples
-------------------------

Examples adapted from https://gobyexample.com/
- hello world
- recursion
- closures
- interfaces
- stateful goroutines



Haxe-OpenFL examples
--------------------
- gohandlingmouseevents (adapted from the OpenFL example)





 

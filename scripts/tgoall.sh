# Test TARDIS Go on all supported targets (assuming output only via console)
# only tested on OSX
# NOTE neko vm only works on very small examples 
tardisgo $* *.go
if [ "$?" = "0" ]; then
	haxe -main tardis.Go -dce full -swf tardis/tardisgo.swf
	#haxe -main tardis.Go -dce full -neko tardis/tardisgo.n
	haxe -main tardis.Go -dce full -D dataview -js tardis/tardisgo_dv.js
	haxe -main tardis.Go -dce full -js tardis/tardisgo.js
	haxe -main tardis.Go -dce full -cpp tardis/cpp 
	haxe -main tardis.Go -dce full -java tardis/java
	haxe -main tardis.Go -dce full -cs tardis/cs
	haxe -main tardis.Go -dce full -php tardis/php --php-prefix tgo
	echo "Neko (haxe --interp):"
	haxe -main tardis.Go --interp
	#echo "Neko (only works on very small projects):"
	#neko tardis/tardisgo.n
	echo "Node/JS (using dataview):"
	# NOTE on Linux, the line below should use nodejs rather than node
	node < tardis/tardisgo_dv.js
	echo "Node/JS:"
	# NOTE on Linux, the line below should use nodejs rather than node
	node < tardis/tardisgo.js
	echo "CPP:"
	./tardis/cpp/Go
	echo "Java:"
	java -jar tardis/java/Go.jar
	echo "CS:"
	mono ./tardis/cs/bin/Go.exe
	echo "PHP:"
	php tardis/php/index.php
	echo "Opening swf file (Chrome as a file association for swf works to test on OSX):"
	open tardis/tardisgo.swf
fi

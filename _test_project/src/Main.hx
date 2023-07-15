// Let the Haxe compiler know this module wants to use Evil Haxe mods.
// Let's use the "pipe" mod and our custom "my_mod".
#evil(pipe, my_mod)

package;

function main() {
	// Built-in "pipe" mod.
	"test" |> repeat(3) |> trace;

	// New "loop" feature created by "my_mod".
	var i = 1;
	loop {
		i *= 2;
		if(i > 20) {
			break;
		}
	}
	trace(i);
}

function repeat(number: Int, s: String): String {
	var result = "";
	for(i in 0...number) {
		result += s;
	}
	return result;
}

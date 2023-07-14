// Let the Haxe compiler know this module wants to use Evil Haxe mods.
// The only mod this module is using is the "pipe" mod.
#evil(pipe)

package;

function main() {
	"test" |> repeat(3) |> trace;
}

function repeat(number: Int, s: String): String {
	var result = "";
	for(i in 0...number) {
		result += s;
	}
	return result;
}

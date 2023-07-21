// Let the Haxe compiler know this module wants to use Evil Haxe mods.
// Let's use the "pipe" mod and our custom "my_mod".
#evil(pipe, defer, pow, kotlin_keywords, return_assign, my_mod)

package;

fun main() {
	// "pipe" mod.
	"test" |> repeat(3) |> trace;

	// "defer" mod
	defer trace("happen last");
	defer trace("happen before last");

	// "pow" mod
	trace('8 == ${2 * 2 * 2} == ${2 ** 3}');

	// "kotlin_keywords" mod
	val constant_val = 123;
	constant_val |> trace;

	// "return assign" mod
	fun get_123(x: Int) = 123 * x;
	trace(get_123(1) == get_123_top());

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

fun repeat(number: Int, s: String): String {
	var result = "";
	for(i in 0...number) {
		result += s;
	}
	return result;
}

// return assign (top-level)
fun get_123_top() = 123;

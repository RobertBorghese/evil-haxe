// Let the Haxe compiler know this module wants to use Evil Haxe mods.
// Let's use the "pipe" mod and our custom "my_mod".
#evil(
	pipe, defer, pow, kotlin_keywords, return_assign,
	trailing_lambda, shorthand_null, my_mod
)

package;

@:nullSafety(Strict)
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

	call_func {
		trace("Trailing lambda success!");
	};

	trace(do_calc(10) { num -> return num * 2; });
	trace(do_calc(10) { num -> num * 2; });

	final qwqwe: Int? = null;
	trace(qwqwe);
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

fun call_func(a: () -> Void) {
	a();
}

fun do_calc(base_num: Int, transform_num: (Int) -> Int) =
	transform_num(base_num);

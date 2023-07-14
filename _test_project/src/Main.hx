#evil

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

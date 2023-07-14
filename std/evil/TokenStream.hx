package evil;

typedef TokenStream = {
	function peek(): evil.Token;
	function consume(): Void;
}

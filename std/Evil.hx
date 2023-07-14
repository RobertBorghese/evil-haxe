package;

class Evil {
	/**
		This is implemented in OCaml.

		ALlows calling certain OCaml functions related to
		Evil Haxe from Haxe code.
	**/
	public static extern function nativeCall(name: String): Dynamic;

	/**
		Called super early during the compilation process.
	**/
	public static function init() {
		test();
	}

	static function test() {
		trace("test");

		nativeCall("test")("fgds");

		final a = nativeCall("test_callback")(function(s: String) {
			trace(s);
			return 123;
		});

		nativeCall("setup_hook")(function(token: evil.Token) {
			return switch(token) {
				case Const(CIdent("blabla")): macro 1111;
				case _: null;
			}
		});

		trace(a);
	}
}

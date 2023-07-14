package;

#if macro

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

		// onExpr(function(token: evil.TokenStream) {
		// 	return switch(token.peek().token) {
		// 		case Kwd(Typedef): {
		// 			token.consume();
		// 			macro 1111;
		// 		}
		// 		case _: null;
		// 	}
		// });

		onAfterExpr(function(token: evil.TokenStream, parsedExpr: haxe.macro.Expr) {
			return switch(token.peek().token) {
				case Kwd(Typedef): {
					token.consume();
					macro 1111;
				}
				case _: null;
			}
		});

		trace(a);
	}

	public static function onExpr(callback: (evil.TokenStream) -> haxe.macro.Expr) {
		nativeCall("setup_hook")(evil.HookType.OnExpr, callback);
	}

	public static function onAfterExpr(callback: (evil.TokenStream, haxe.macro.Expr) -> haxe.macro.Expr) {
		nativeCall("setup_hook")(evil.HookType.OnAfterExpr, callback);
	}
}

#end

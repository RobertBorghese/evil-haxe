package evil.mods;

#if (macro || display)

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Initializes the Return Assign mod.
**/
function init() {
	Evil.addParserMod("return_assign", {
		onFunctionExpr: onFunctionExpr
	});
}

/**
	Called whenever an expression for a function is parsed.

	Parses an preceding `=` like a `return`.
**/
function onFunctionExpr(stream: TokenStream): Null<Expr> {
	return switch(stream.peek().token) {
		case Binop(OpAssign): {
			stream.consume();
			final e = stream.nextExpr();
			macro return $e;
		}
		case _: {
			null;
		}
	}
}

#end

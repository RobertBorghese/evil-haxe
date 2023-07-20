package evil.mods;

#if (macro || display)

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Initializes the Pow mod.
**/
function init() {
	Evil.addParserMod("pow", {
		onAfterExpr: onAfterExpr
	});
}

/**
	Called at the "after expression" hook when parsing.

	Parses the `**` operator and generates a `Math.pow(e1, e2)` statement.
**/
function onAfterExpr(stream: TokenStream, expr: Expr): Expr {
	return switch(stream.peek().token) {
		case Binop(OpMult): {
			stream.consume();
			switch(stream.peek().token) {
				case Binop(OpMult): {
					stream.consume();
					final e2 = stream.nextExpr();
					macro Math.pow($expr, $e2);
				}
				case _: {
					final e2 = stream.nextExpr();
					{
						expr: EBinop(OpMult, expr, e2),
						pos: stream.posUnion(expr.pos, e2.pos)
					};
				}
			}
		}
		case _: {
			null;
		}
	}
}

#end

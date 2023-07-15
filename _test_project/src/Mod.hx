package;

function init() {
	trace("Called in conspire-time!");

	// Register our mod.
	Evil.addParserMod("my_mod", {
		onExpr: parseExpr
	});
}

function parseExpr(tokenStream: evil.macro.TokenStream): Null<haxe.macro.Expr> {
	// Check the current token...
	return switch(tokenStream.peek().token) {

		// Check for "loop" token...
		case Const(CIdent("loop")): {

			// Move on from the current token to the next one.
			tokenStream.consume();

			// Parse the next expression.
			final expr = tokenStream.nextExpr();

			// Generate the expression our new syntax will generate.
			macro while(true) $expr;
		}

		// Otherwise, return `null` to use default parsing behavior.
		case _: {
			null;
		}
	}
}

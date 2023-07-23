package evil.mods;

#if (macro || display)

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Initializes the Shorthand Null mod.
**/
function init() {
	Evil.addParserMod("shorthand_null", {
		onType: onType
	});
}

/**
**/
function onType(stream: TokenStream): Null<{ type: ComplexType, pos: Position }> {
	final t = stream.peek();
	return switch(t.token) {
		case Const(CIdent("Bla")): {
			stream.consume();
			stream.nextType();
		}
		case _: {
			null;
		}
	}
}

#end

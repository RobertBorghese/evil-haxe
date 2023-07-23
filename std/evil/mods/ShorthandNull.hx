package evil.mods;

#if (macro || display)

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Initializes the Shorthand Null mod.
**/
function init() {
	Evil.addParserMod("shorthand_null", {
		onAfterType: onAfterType
	});
}

/**
**/
function onAfterType(stream: TokenStream, type: { type: ComplexType, pos: Position }): Null<{ type: ComplexType, pos: Position }> {
	final t = stream.peek();
	return switch(t.token) {
		case Question: {
			stream.consume();
			final prevType = type.type;
			final result = {
				type: macro : Null<$prevType>,
				pos: stream.posUnion(type.pos, t.pos)
			};
			stream.parsePostType(result);
		}
		case _: {
			null;
		}
	}
}

#end

package evil.mods;

#if (macro || display)

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Initializes the Shorthand Array mod.
**/
function init() {
	Evil.addParserMod("shorthand_array", {
		onAfterType: onAfterType
	});
}

/**
	If `[]` proceeds a type, wrap it with `Array`.
**/
function onAfterType(stream: TokenStream, type: { type: ComplexType, pos: Position }): Null<{ type: ComplexType, pos: Position }> {
	return switch(stream.peek().token) {
		case BkOpen: {
			stream.consume();
			final t2 = stream.peek();
			switch(t2.token) {
				case BkClose: {
					stream.consume();
					final prevType = type.type;
					final result = {
						type: macro : Array<$prevType>,
						pos: stream.posUnion(type.pos, t2.pos)
					};
					stream.parsePostType(result);
				}
				case _: null;
			}
		}
		case _: null;
	}
}

#end

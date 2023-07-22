package evil.mods;

#if (macro || display)

import evil.macro.TokenType;

/**
	Initializes the Kotlin Keywords mod.

	We can use `tokenTransmuter` to transform tokens before
	they are processed.
**/
function init() {
	Evil.addParserMod("kotlin_keywords", {
		tokenTransmuter: tokenTransmuter
	});
}

/**
	Allow `fun` be used as `function` keyword.
	Allow `val` be used as `final` keyword.
**/
function tokenTransmuter(token: TokenType): Null<TokenType> {
	return switch(token) {
		case Const(CIdent("fun")): {
			Kwd(Function);
		}
		case Const(CIdent("val")): {
			Kwd(Final);
		}
		case _: {
			null;
		}
	}
}

#end

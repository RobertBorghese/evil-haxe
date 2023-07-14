package evil.macro;

import evil.macro.TokenStream;

/**
	The parser mod structure.

	Each field can be optionally provided to modify the parser
	at certain points.
**/
typedef Mod = {
	?onExpr: (TokenStream) -> haxe.macro.Expr,
	?onAfterExpr: (TokenStream, haxe.macro.Expr) -> haxe.macro.Expr,
	?onTypeDeclaration: (TokenStream, evil.macro.TypeDeclCompletionMode) -> haxe.macro.Expr.TypeDefinition,
	?onClassField: (TokenStream, Bool) -> haxe.macro.Expr.Field
}

package evil.macro;

import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	The parser mod structure.

	Each field can be optionally provided to modify the parser
	at certain points.
**/
typedef Mod = {
	?onExpr: (TokenStream, Bool) -> Null<Expr>,
	?onAfterExpr: (TokenStream, Expr) -> Null<Expr>,
	?onFunctionExpr: (TokenStream) -> Null<Expr>,
	?onBlockExpr: (TokenStream) -> Void,
	?onAfterBlockExpr: (TokenStream, Expr) -> Null<Expr>,
	?onTypeDeclaration: (TokenStream, evil.macro.TypeDeclCompletionMode) -> Null<TypeDefinition>,
	?onClassField: (TokenStream, Bool) -> Null<Field>,
	?tokenTransmuter: (TokenType) -> Null<TokenType>
}

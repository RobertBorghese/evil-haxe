package evil.macro;

/**
	Combines a token with its position.

	Provided from the `evil.macro.TokenStream`.
**/
typedef Token = {
	token: evil.macro.TokenType,
	pos: haxe.macro.Expr.Position
}

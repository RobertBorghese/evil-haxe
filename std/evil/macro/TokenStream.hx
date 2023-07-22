package evil.macro;

import haxe.macro.Expr;

/**
	Represents the structure provided to mods to parse the tokens.
**/
typedef TokenStream = {
	/**
		Get the current token of the stream.
	**/
	function peek(): evil.macro.Token;

	/**
		Discard the current token and move to the next one.
	**/
	function consume(): Void;

	/**
		Parse and return the next expression.
	**/
	function nextExpr(): Expr;

	/**
		Consume the next semicolon.
		Throws an error if it doesn't exist, UNLESS the previous token was `}`.
	**/
	function semicolon(): Position;

	/**
		Combine two positions.
	**/
	function posUnion(p1: Position, p2: Position): Position;
}

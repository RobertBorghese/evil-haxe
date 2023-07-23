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
		Parses the content within a block expression AFTER the `{` token.
		Does not parse the ending `}` token.
	**/
	function parseBlockInternals(): Array<Expr>;

	/**
		Returns `true` if the compiler is currently parsing an expression immediately 
		after the `switch` keyword (but before the switch statement `{`).
	**/
	function isParsingSwitchExpr(): Bool;

	/**
		Combine two positions.
	**/
	function posUnion(p1: Position, p2: Position): Position;
}

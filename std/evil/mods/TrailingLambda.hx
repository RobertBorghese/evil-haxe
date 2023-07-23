package evil.mods;

#if (macro || display)

import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Initializes the Trailing Lambda mod.
**/
function init() {
	Evil.addParserMod("trailing_lambda", {
		onAfterExpr: onAfterExpr
	});
}

/**
	Parses the trailing lambda after an expression.

	```haxe
	// This is how the input syntax looks:
	callable(arg1, arg2) { lambdaArg1, lambdaArg2 ->
		blockExpr1();
		blockExpr2();
	};

	// And this is what is generated:
	callable(arg1, arg2, function(lambdaArg1, lambdaArg2) {
		blockExpr1();
		blockExpr2();
	});
	```
**/
function onAfterExpr(stream: evil.macro.TokenStream, expr: Expr): Null<Expr> {
	// Trailing lambda syntax is incompatible with switch statement expressions.
	if(stream.isParsingSwitchExpr()) {
		return null;
	}

	// Trailing lambda syntax is incompatible with macro reification expressions.
	switch(expr.expr) {
		case EConst(CIdent(c)) if(StringTools.startsWith(c, "$")): {
			return null;
		}
		case _:
	}

	final firstToken = stream.peek();
	return switch(firstToken.token) {
		case BrOpen: {
			stream.consume();

			// Parse the lambda arguments
			// The arguments are separated with commas and end with an arrow.
			final args: Array<String> = [];
			var expectIdent = false;
			var ident: Null<String> = null;
			var identPos: Null<Position> = null;
			while(true) {
				final t = stream.peek();
				switch(t.token) {
					case Const(CIdent(n)): {
						stream.consume();
						identPos = t.pos;

						// Parse comma or arrow.
						final t = stream.peek();
						switch(t.token) {
							case Comma | Arrow: {
								args.push(n);
								stream.consume();
								switch(t.token) {
									case Comma: {
										expectIdent = true;
										continue;
									}
									case Arrow: {
										break;
									}
									case _:
								}
							}
							// It's possible no arguments are provided.
							// In that case, let's store the identifier (since there's no way to put it
							// back in the stream) and add it to the block's expressions later.
							case _: {
								ident = n;
								break;
							}
						}
					}
					case _: {
						// If `expectIdent` is true, that means arguments were already found and
						// they ended abruptly without the arrow token.
						if(expectIdent) {
							Context.error("[trailing_lambda] Identifier expected", t.pos);
						}
						break;
					}
				}
			}

			// If an identifier was parsed but not an argument,
			// let's parse it like an expression.
			var firstExpr: Null<Expr> = null;
			if(ident != null) {
				firstExpr = stream.parsePostExpr({
					expr: EConst(CIdent(ident)),
					pos: identPos
				});
				stream.semicolon();
			}

			// Check for the end of the block statement.
			final noContent = switch(stream.peek().token) {
				case BrClose: {
					stream.consume();
					true;
				}
				case _: false;
			}

			// Parse block
			var endPos = firstExpr?.pos ?? identPos;
			var content = if(noContent) {
				firstExpr == null ? [] : [firstExpr];
			} else {
				final content = stream.parseBlockInternals();
				if(firstExpr != null) content.unshift(firstExpr);

				final endToken = stream.peek();
				switch(endToken.token) {
					case BrClose: stream.consume();
					case _: Context.error("[trailing_lambda] Expected }", endToken.pos);
				}
				endPos = endToken.pos;

				content;
			}

			// Construct block expression for function argument
			final blockExpr = if(content.length == 1) {
				expr: EReturn(content[0]),
				pos: stream.posUnion(firstToken.pos, endPos)
			} else {
				expr: EBlock(content),
				pos: stream.posUnion(firstToken.pos, endPos)
			};

			// Create function argument
			final functionExpr = {
				expr: EFunction(FArrow, {
					expr: blockExpr,
					args: args.map(function(a: String): haxe.macro.Expr.FunctionArg return { name: a })
				}),
				pos: blockExpr.pos
			};

			// Wrap target expression with call (if it isn't already),
			// and add the function as an argument
			switch(expr.expr) {
				case ECall(called, args): {
					{
						expr: ECall(called, args.concat([functionExpr])),
						pos: stream.posUnion(expr.pos, functionExpr.pos)
					};
				}
				case _: {
					{
						expr: ECall(expr, [functionExpr]),
						pos: stream.posUnion(expr.pos, functionExpr.pos)
					};
				}
			}
		}
		case _: {
			null;
		}
	}
}

#end

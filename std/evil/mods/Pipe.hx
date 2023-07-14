package evil.mods;

import haxe.macro.Expr;
import evil.macro.TokenStream;

var pipeForwardMetaName = "--pipe";

/**
	Initializes the Pipe mod.
**/
function init() {
	trace('fdjsklfds');
	Evil.addParserMod("pipe", {
		onAfterExpr: onAfterExpr
	});
}

/**
	Called at the "after expression" hook when parsing.

	Parses the `|>` operator and generates valid Haxe expressions.
**/
function onAfterExpr(stream: TokenStream, expr: Expr): Expr {
	return switch(stream.peek().token) {
		case Binop(OpOr): {
			stream.consume();
			switch(stream.peek().token) {
				case Binop(OpGt): {
					stream.consume();
					final e2 = stream.nextExpr();
					makePipeExpr(expr, e2);
				}
				case _: {
					final e2 = stream.nextExpr();
					{
						expr: EBinop(OpOr, expr, e2),
						pos: stream.posUnion(expr.pos, e2.pos)
					};
				}
			}
		}
		case _: {
			null;
		}
	}
}

function wrapOperatorMeta(e: Expr): Expr {
	return {
		expr: EMeta({
			name: pipeForwardMetaName,
			pos: e.pos
		}, e),
		pos: e.pos
	}
}

function makePipeExpr(e1: Expr, e2: Expr): Expr {
	return switch(e2.expr) {
		case EMeta(entry, e2i): {
			final p = e2.pos;
			final n = entry.name;
			if(n == pipeForwardMetaName) {
				switch(e2i.expr) {
					case ECall(ecall, eparams): {
						if(eparams.length > 0) {
							final last = eparams[eparams.length - 1];
							final args = eparams
								.slice(0, eparams.length - 2)
								.concat([makePipeExpr(e1, last)]);
							{
								expr: ECall(ecall, args),
								pos: e2i.pos
							}
						} else {
							{
								expr: ECall(ecall, [e1]),
								pos: e2i.pos
							}
						}
					}
					case _: {
						throw '@$pipeForwardMetaName meta should only surrond ECall';
					}
				}
			} else {
				makePipeExpr(e1, e2i);
			}
		}
		case ECall(e2call, e2param) if(e2param.length > 0): {
			wrapOperatorMeta({
				expr: ECall(e2call, e2param.concat([e1])),
				pos: e2.pos
			});
		}
		case _: {
			wrapOperatorMeta({
				expr: ECall(e2, [e1]),
				pos: e2.pos
			});
		}
	}
}

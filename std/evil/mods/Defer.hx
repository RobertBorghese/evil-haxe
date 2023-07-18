package evil.mods;

#if (macro || display)

import haxe.ds.GenericStack;

import haxe.macro.Context;
import haxe.macro.Expr;

import evil.macro.TokenStream;

/**
	This stack stores deferred expressions.
**/
var deferredExpressions: GenericStack<GenericStack<Expr>> = new GenericStack();

/**
	Initializes the Defer mod.
**/
function init() {
	Evil.addParserMod("defer", {
		onExpr: onExpr,
		onBlockExpr: onBlockExpr,
		onAfterBlockExpr: onAfterBlockExpr
	});
}

/**
	Parse `defer` tokens and save their subsequent expression.
**/
function onExpr(stream: TokenStream, isTopLevel: Bool): Expr {
	return switch(stream.peek().token) {
		case Const(CIdent("defer")): {
			stream.consume();

			// `defer` expressions do not return a value.
			// They must be used within a block expression.
			if(!isTopLevel) {
				Context.error("Defer expression cannot be used as a value.", stream.peek().pos);
			}

			// Parse the subsequent expression and add it to the stack.
			// If there's nothing in the stack for some reason, throw an error?
			if(!deferredExpressions.isEmpty()) {
				deferredExpressions.first().add(stream.nextExpr());
			} else {
				Context.error("Cannot use defer here.", stream.peek().pos);
			}

			// We don't want an expression to be generated, so just return `null`.
			macro null;
		}
		case _: {
			null;
		}
	}
}

/**
	When a block expression has begun parsing, add to the defer stack.
**/
function onBlockExpr(stream: TokenStream): Void {
	deferredExpressions.add(new GenericStack());
}

/**
	When a block expression has finished parsing, remove the top stack member.
	If it contains any deferred expressions, add them to the block expression.
**/
function onAfterBlockExpr(stream: TokenStream, blockExpr: Expr): Expr {
	final exprs = if(!deferredExpressions.isEmpty()) {
		deferredExpressions.pop();
	} else {
		null;
	}
	return switch(blockExpr.expr) {
		case EBlock(e) if(exprs != null && !exprs.isEmpty()): {
			final blockExprs = e.copy();
			while(!exprs.isEmpty()) {
				blockExprs.push(exprs.pop());
			}
			{
				expr: EBlock(blockExprs),
				pos: blockExpr.pos
			};
		}
		case _: blockExpr;
	}
}

#end

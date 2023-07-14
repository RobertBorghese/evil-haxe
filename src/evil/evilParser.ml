(**
	Types of parser hooks available.
**)
type hook_type =
	| OnExpr
	| OnAfterExpr
	| OnTypeDeclaration
	| OnClassField

(**
	A type for the stream used by the Haxe parser.
	(Don't know why this isn't a thing here already?)
**)
type token_stream = (Ast.token * Globals.pos) Stream.t

(**
	Call a list of hook functions given a list of params.
**)
let rec call_hooks hook params =
	match hook with
	| h :: l -> (
		match h params with
		| None -> call_hooks l params
		| r -> r
	)
	| [] -> None

(***************************************************)

(**
	The type used for global hooks.
	TODO: Remove?
**)
type global_parser_hooks = {
	mutable has_mods : bool;
	mutable defaults : string list;
	mutable on_expr : (token_stream -> (Ast.expr option)) list;
	mutable on_expr_next : ((token_stream * Ast.expr) -> (Ast.expr option)) list;
	mutable on_type_decl : ((token_stream * Parser.type_decl_completion_mode) -> (Ast.type_decl option)) list;
	mutable on_class_field : ((token_stream * bool) -> (Ast.class_field option)) list;
}

(**
	Global variable for global hooks.
**)
let hooks : global_parser_hooks = {
	has_mods = false;
	defaults = ["pipe"];
	on_expr = [];
	on_expr_next = [];
	on_type_decl = [];
	on_class_field = [];
}

(***************************************************)

(**
	The type for an instance of a parser mod.
**)
type parser_mod = {
	on_expr : (token_stream -> (Ast.expr option)) option;
	on_expr_next : ((token_stream * Ast.expr) -> (Ast.expr option)) option;
	on_type_decl : ((token_stream * Parser.type_decl_completion_mode) -> (Ast.type_decl option)) option;
	on_class_field : ((token_stream * bool) -> (Ast.class_field option)) option;
}

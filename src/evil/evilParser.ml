type token_stream = (Ast.token * Globals.pos) Stream.t

type parser_hooks = {
	mutable on_expr : (token_stream -> (Ast.expr option)) list;
	mutable on_expr_next : ((token_stream * Ast.expr) -> (Ast.expr option)) list;
	mutable on_expr_expected : (token_stream -> (Ast.expr option)) list;
	mutable on_type_decl : ((token_stream * Parser.type_decl_completion_mode) -> (Ast.type_decl option)) list;
	mutable on_class_field : ((token_stream * bool) -> (Ast.class_field option)) list;
}

let rec call_hooks hook params =
	match hook with
	| h :: l -> (
		match h params with
		| None -> call_hooks l params
		| r -> r
	)
	| [] -> None

let hooks : parser_hooks = {
	on_expr = [];
	on_expr_next = [];
	on_expr_expected = [];
	on_type_decl = [];
	on_class_field = [];
}

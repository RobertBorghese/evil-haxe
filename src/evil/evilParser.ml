(**
	Types of parser hooks available.
**)
type hook_type =
	| OnExpr
	| OnAfterExpr
	| OnFunctionExpr
	| OnBlockStart
	| OnAfterBlockExpr
	| OnTypeDeclaration
	| OnClassField
	| TokenTransmuter

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

let call_hooks_unit hook params =
	List.iter (fun h -> h params) hook;

(***************************************************)

(**
	The type used for global hooks.
**)
type global_parser_hooks = {
	mutable has_mods : bool;
	mutable defaults : string list;
	mutable conspiracies : string list;

	mutable parsing_switch_expr : bool;

	mutable on_expr : ((token_stream * bool) -> (Ast.expr option)) list;
	mutable on_expr_next : ((token_stream * Ast.expr) -> (Ast.expr option)) list;
	mutable on_function_expr : (token_stream -> (Ast.expr option)) list;
	mutable on_block : (token_stream -> unit) list;
	mutable on_block_next : ((token_stream * Ast.expr) -> (Ast.expr option)) list;
	mutable on_type_decl : ((token_stream * Parser.type_decl_completion_mode) -> (Ast.type_decl option)) list;
	mutable on_class_field : ((token_stream * bool) -> (Ast.class_field option)) list;
	mutable token_transmuter : (Ast.token -> (Ast.token option)) list;
}

(**
	Global variable for global hooks.
**)
let hooks : global_parser_hooks = {
	has_mods = false;
	defaults = ["pipe"];
	conspiracies = [];

	parsing_switch_expr = false;

	on_expr = [];
	on_expr_next = [];
	on_function_expr = [];
	on_block = [];
	on_block_next = [];
	on_type_decl = [];
	on_class_field = [];
	token_transmuter = [];
}

(***************************************************)

(**
	The type for an instance of a parser mod.
**)
type parser_mod = {
	on_expr : ((token_stream * bool) -> (Ast.expr option)) option;
	on_expr_next : ((token_stream * Ast.expr) -> (Ast.expr option)) option;
	on_function_expr : (token_stream -> (Ast.expr option)) option;
	on_block : (token_stream -> unit) option;
	on_block_next : ((token_stream * Ast.expr) -> (Ast.expr option)) option;
	on_type_decl : ((token_stream * Parser.type_decl_completion_mode) -> (Ast.type_decl option)) option;
	on_class_field : ((token_stream * bool) -> (Ast.class_field option)) option;
	token_transmuter : (Ast.token -> (Ast.token option)) option;
}

(***************************************************)

(**
	Check if there are any active hooks.
**)
let has_any_hooks () =
	List.length hooks.on_expr > 0 &&
	List.length hooks.on_expr_next > 0 &&
	List.length hooks.on_function_expr > 0 &&
	List.length hooks.on_block > 0 &&
	List.length hooks.on_block_next > 0 &&
	List.length hooks.on_type_decl > 0 &&
	List.length hooks.on_class_field > 0 &&
	List.length hooks.token_transmuter > 0

(**
	Add a mod's hooks to the global hooks.
	TODO: Is there a way to clean this up??
**)
let apply_mod parser_mod =
	EvilUtil.unwrap_opt (fun h ->
		hooks.on_expr <- (h :: hooks.on_expr);
	) parser_mod.on_expr;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_expr_next <- (h :: hooks.on_expr_next);
	) parser_mod.on_expr_next;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_function_expr <- (h :: hooks.on_function_expr);
	) parser_mod.on_function_expr;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_block <- (h :: hooks.on_block);
	) parser_mod.on_block;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_block_next <- (h :: hooks.on_block_next);
	) parser_mod.on_block_next;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_type_decl <- (h :: hooks.on_type_decl);
	) parser_mod.on_type_decl;

	EvilUtil.unwrap_opt (fun h ->
		hooks.on_class_field <- (h :: hooks.on_class_field);
	) parser_mod.on_class_field;

	EvilUtil.unwrap_opt (fun h ->
		hooks.token_transmuter <- (h :: hooks.token_transmuter);
	) parser_mod.token_transmuter;

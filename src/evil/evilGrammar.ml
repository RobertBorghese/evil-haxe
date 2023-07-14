open EvilGlobals
open EvilParser

open Ast

let parse_evil_header s =
	match Stream.peek s with
		| Some (Sharp ("evil"), p) -> (
			Stream.junk s;
			true
		)
		| _ -> false

let clear_hooks () =
	if hooks.has_mods = true then (
		hooks.on_expr <- [];
		hooks.on_expr_next <- [];
		hooks.on_type_decl <- [];
		hooks.on_class_field <- [];
		hooks.has_mods <- false; 
	)

let install_mod name =
	if Hashtbl.mem EvilGlobalState.mods name then (
		let parser_mod = Hashtbl.find EvilGlobalState.mods name in

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr <- (h :: hooks.on_expr);
		) parser_mod.on_expr;

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr_next <- (h :: hooks.on_expr_next);
		) parser_mod.on_expr_next;

		if (
			List.length hooks.on_expr > 0 &&
			List.length hooks.on_expr_next > 0 &&
			List.length hooks.on_type_decl > 0 &&
			List.length hooks.on_class_field > 0
		) then hooks.has_mods <- true;
	)

let on_parse_file_start s =
	let setup_hooks = parse_evil_header s in

	clear_hooks();

	if setup_hooks then
		List.iter install_mod hooks.defaults

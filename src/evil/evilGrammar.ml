open EvilGlobals

let on_parse_file_start () =
	if Hashtbl.mem EvilGlobalState.mods "pipe" then (
		let open EvilParser in
		let parser_mod = Hashtbl.find EvilGlobalState.mods "pipe" in

		hooks.on_expr = [];
		hooks.on_expr_next = [];
		hooks.on_type_decl = [];
		hooks.on_class_field = [];

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr <- (h :: hooks.on_expr);
		) parser_mod.on_expr;

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr_next <- (h :: hooks.on_expr_next);
		) parser_mod.on_expr_next;

		()
	);

	()

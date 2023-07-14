let on_compile_start (ctx: CompilationContext.compilation_context) call_light_init_macro =
	Hashtbl.replace
		EvilGlobals.EvilGlobalState.module_attributes
		"evil"
		(true, (fun file_key args ->
			Hashtbl.replace EvilGlobals.EvilGlobalState.evil_modules file_key args;
			Some (Sharp "evil")
		));

	let com = ctx.com in
	let _ = call_light_init_macro com "Evil.init()" in
	EvilMacro.setup_macro_functions;
	()

(**
	Called near the start of `Compiler.compile`.	
**)
let on_compile_start (ctx: CompilationContext.compilation_context) call_light_init_macro =
	(* Register module-level attribute "evil" *)
	Hashtbl.replace
		EvilGlobals.EvilGlobalState.module_attributes
		"evil"
		(true, (fun file_key args ->
			Hashtbl.replace EvilGlobals.EvilGlobalState.evil_modules file_key args;
			Some (Sharp "evil")
		));

	(* Setup *)
	let com = ctx.com in
	EvilMacro.setup_macro_functions;

	(* Run all conspiracies *)
	List.iter (fun hxpath -> 
		ignore (call_light_init_macro com hxpath);
	) EvilParser.hooks.conspiracies;
	
	(* Run `Evil.init` *)
	ignore (call_light_init_macro com "Evil.init()");

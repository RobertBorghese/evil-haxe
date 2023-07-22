(**
	Called near the start of `Compiler.compile`.

	NOTE: This file is slightly different in the Haxe v4.3 version.	
**)
let on_compile_start (ctx: CompilationContext.compilation_context) call_init_macro =
	(* Register module-level attribute "evil" *)
	Hashtbl.replace
		EvilGlobals.EvilGlobalState.module_attributes
		"evil"
		(true, (fun file_key args ->
			Hashtbl.replace EvilGlobals.EvilGlobalState.evil_modules file_key args;
			Some (Sharp "evil")
		));

	(* Setup *)
	EvilMacro.setup_macro_functions;

	(* Run all conspiracies *)
	List.iter (fun hxpath -> 
		call_init_macro hxpath;
	) EvilParser.hooks.conspiracies;
	
	(* Run `Evil.init` *)
	call_init_macro "Evil.init()";

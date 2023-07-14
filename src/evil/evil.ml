let on_compile_start com call_light_init_macro =
	let _ = call_light_init_macro com "Evil.init()" in
	EvilMacro.setup_macro_functions;
	()
let on_compile com call_light_init_macro =
	begin try
		Some (call_light_init_macro com "Evil.init()")
	with (Error.Error { err_message = Module_not_found (["Bla"],"Init") }) ->
		None
	end

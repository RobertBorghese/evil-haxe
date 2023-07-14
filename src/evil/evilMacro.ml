open EvalValue
open EvalEncode
open EvalDecode

open EvilGlobals

(**
	Given a `name` and an instance of `VFunction`, adds a
	function that can be called from Haxe using `Eval.nativeCall`.
**)
let add_macro_function name func =
	Hashtbl.replace EvilGlobalState.macro_lib name func

(**
	Sets up all the functions callable using `Eval.nativeCall`.
**)
let setup_macro_functions =
	add_macro_function "test" (
		vfun1 (fun f ->
			vnull
		)
	);

	add_macro_function "setup_hook" (
		vfun1 (fun callback ->
			let hxf = EvalMisc.prepare_callback callback 1 in
			let f = (fun token_stream ->
				let ctx = EvalContext.get_ctx() in
				let hxstream = EvilTokenStream.make_token_stream_for_haxe token_stream in
				let hxexpr = hxf [hxstream] in
				if hxexpr = vnull then None
				else Some (ctx.curapi.MacroApi.decode_expr hxexpr)
			) in
			EvilParser.hooks.on_expr <- (f :: EvilParser.hooks.on_expr);
			vnull
		)
	);

	add_macro_function "test_callback" (
		vfun1 (fun callback ->
			let f = EvalMisc.prepare_callback callback 1 in
			f [encode_string "string from ocaml"]
		)
	)


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
				let t = Stream.peek token_stream in
				match t with
				| Some (token, token_pos) -> (
					let ctx = EvalContext.get_ctx() in
					let hxexpr = hxf [(EvilEncode.encode_token token)] in
					if hxexpr = VNull then (
						None
					) else (
						Stream.junk token_stream;
						Some (ctx.curapi.MacroApi.decode_expr hxexpr)
					)
				)
				| _ ->
					None
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


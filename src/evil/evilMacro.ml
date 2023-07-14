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
	Given a `EvalValue.value` callback and the hook type,
	setup the callback to make a parser mod.
**)
let setup_hook (t: EvilParser.hook_type) hx_callback =
	let hooks = EvilParser.hooks in
	match t with
		| OnExpr -> (
			let hxf = EvalMisc.prepare_callback hx_callback 1 in
			let f = (fun token_stream ->
				let ctx = EvalContext.get_ctx() in
				let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
				let hx_expr = hxf [hx_stream] in
				if hx_expr = vnull then None
				else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
			) in
			hooks.on_expr <- (f :: hooks.on_expr)
		)
		| OnAfterExpr -> (
			let hxf = EvalMisc.prepare_callback hx_callback 2 in
			let f = (fun (token_stream, (expr: Ast.expr)) ->
				let ctx = EvalContext.get_ctx() in
				let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
				let expr_arg = ctx.curapi.MacroApi.encode_expr expr in
				let hx_expr = hxf [hx_stream; expr_arg] in
				if hx_expr = vnull then None
				else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
			) in
			hooks.on_expr_next <- (f :: hooks.on_expr_next)
		)
		| OnTypeDeclaration -> () (* on_type_decl *)
		| OnClassField -> () (* on_class_field *)

(**
	Sets up all the functions callable using `Eval.nativeCall`.
**)
let setup_macro_functions =
	add_macro_function "test" (
		vfun1 (fun f -> vnull)
	);

	add_macro_function "setup_hook" (
		vfun2 (fun hook_type callback ->
			setup_hook (EvilDecode.decode_hook_type hook_type) callback;
			vnull
		)
	);

	add_macro_function "test_callback" (
		vfun1 (fun callback ->
			let f = EvalMisc.prepare_callback callback 1 in
			f [encode_string "string from ocaml"]
		)
	)

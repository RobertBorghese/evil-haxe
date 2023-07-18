open EvalValue
open EvalEncode
open EvalDecode

open MacroContext

open EvilGlobals

(**
	Given a `name` and an instance of `VFunction`, adds a
	function that can be called from Haxe using `Eval.nativeCall`.
**)
let add_macro_function name func =
	Hashtbl.replace EvilGlobalState.macro_lib name func

(**
	Converts a Haxe callback into an OnExpr hook-callable function.
**)
let encode_on_expr_callback (hx_callback: EvalValue.value) = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun ((token_stream: EvilParser.token_stream), (top_level: bool)) ->
		let ctx = EvalContext.get_ctx() in
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_expr = hxf [hx_stream; vbool top_level] in
		if hx_expr = vnull then None
		else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
	)
)

(**
	Converts a Haxe callback into an OnAfterExpr hook-callable function.
**)
let encode_on_after_expr_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun (token_stream, (expr: Ast.expr)) ->
		let ctx = EvalContext.get_ctx() in
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let expr_arg = ctx.curapi.MacroApi.encode_expr expr in
		let hx_expr = hxf [hx_stream; expr_arg] in
		if hx_expr = vnull then None
		else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
	)
)

let encode_on_block_start_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun (token_stream) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		ignore (hxf [hx_stream]);
	)
)

(**
	Converts a Haxe callback into an OnAfterBlockExpr hook-callable function.
**)
let encode_on_block_expr_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun (token_stream, (expr: Ast.expr)) ->
		let ctx = EvalContext.get_ctx() in
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let expr_arg = ctx.curapi.MacroApi.encode_expr expr in
		let hx_expr = hxf [hx_stream; expr_arg] in
		if hx_expr = vnull then None
		else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
	)
)

(**
	Converts a Haxe callback into an OnTypeDecl hook-callable function.
**)
let encode_on_type_decl_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun (token_stream, (mode: Parser.type_decl_completion_mode)) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_mode = EvilEncode.encode_type_decl_completion_mode mode in
		let hx_type_decl = hxf [hx_stream; hx_mode] in
		if hx_type_decl = vnull then None
		else (
			let _, def, pos = Interp.decode_type_def hx_type_decl in
			Some (def, pos)
		)
	)
)

(**
	Converts a Haxe callback into an OnClassField hook-callable function.
**)
let encode_on_class_field_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun (token_stream, (is_module_level: bool)) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_field = hxf [hx_stream; vbool is_module_level] in
		if hx_field = vnull then None
		else Some (Interp.decode_field hx_field)
	)
)

(**
	Given a `EvalValue.value` callback and the hook type,
	setup the callback to make a parser mod.
**)
let setup_hook (t: EvilParser.hook_type) (hx_callback: EvalValue.value) =
	let hooks = EvilParser.hooks in
	match t with
		| OnExpr -> (
			let f = encode_on_expr_callback hx_callback in
			hooks.on_expr <- (f :: hooks.on_expr)
		)
		| OnAfterExpr -> (
			let f = encode_on_after_expr_callback hx_callback in
			hooks.on_expr_next <- (f :: hooks.on_expr_next)
		)
		| OnBlockStart -> (
			let f = encode_on_block_start_callback hx_callback in
			hooks.on_block <- (f :: hooks.on_block)
		)
		| OnAfterBlockExpr -> (
			let f = encode_on_block_expr_callback hx_callback in
			hooks.on_block_next <- (f :: hooks.on_block_next)
		)
		| OnTypeDeclaration -> (
			let f = encode_on_type_decl_callback hx_callback in
			hooks.on_type_decl <- (f :: hooks.on_type_decl)
		)
		| OnClassField -> (
			let f = encode_on_class_field_callback hx_callback in
			hooks.on_class_field <- (f :: hooks.on_class_field)
		)

(********************************************)
let key_on_expr = EvalHash.hash "onExpr"
let key_on_after_expr = EvalHash.hash "onAfterExpr"
let key_on_block_start = EvalHash.hash "onBlockExpr"
let key_on_block_expr = EvalHash.hash "onAfterBlockExpr"
let key_on_type_decl = EvalHash.hash "onTypeDeclaration"
let key_on_class_field = EvalHash.hash "onClassField"

(**
	Sets up all the functions callable using `Eval.nativeCall`.
**)
let setup_macro_functions =
	add_macro_function "add_parser_mod" (
		vfun2 (fun (name: EvalValue.value) (mod_obj: EvalValue.value) ->
			let obj = Interp.decode_object mod_obj in
			let n = Interp.decode_string name in
			Hashtbl.replace EvilGlobalState.mods n {
				on_expr = (
					let f = EvalField.object_field obj key_on_expr in
					EvalDecode.decode_optional encode_on_expr_callback f
				);
				on_expr_next = (
					let f = EvalField.object_field obj key_on_after_expr in
					EvalDecode.decode_optional encode_on_after_expr_callback f
				);
				on_block = (
					let f = EvalField.object_field obj key_on_block_start in
					EvalDecode.decode_optional encode_on_block_start_callback f
				);
				on_block_next = (
					let f = EvalField.object_field obj key_on_block_expr in
					EvalDecode.decode_optional encode_on_block_expr_callback f
				);
				on_type_decl = (
					let f = EvalField.object_field obj key_on_type_decl in
					EvalDecode.decode_optional encode_on_type_decl_callback f
				);
				on_class_field = (
					let f = EvalField.object_field obj key_on_class_field in
					EvalDecode.decode_optional encode_on_class_field_callback f
				);
			};

			vnull
		)
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

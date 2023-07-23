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
let decode_on_expr_callback (hx_callback: EvalValue.value) = (
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
let decode_on_after_expr_callback hx_callback = (
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
	Converts a Haxe callback into an OnFunctionExpr hook-callable function.
**)
let decode_on_function_expr_callback (hx_callback: EvalValue.value) = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun (token_stream: EvilParser.token_stream) ->
		let ctx = EvalContext.get_ctx() in
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_expr = hxf [hx_stream] in
		if hx_expr = vnull then None
		else Some (ctx.curapi.MacroApi.decode_expr hx_expr)
	)
)

(**
	Converts a Haxe callback into an OnBlockExpr hook-callable function.
**)
let decode_on_block_start_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun (token_stream) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		ignore (hxf [hx_stream]);
	)
)

(**
	Converts a Haxe callback into an OnAfterBlockExpr hook-callable function.
**)
let decode_on_block_expr_callback hx_callback = (
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
	Converts a Haxe callback into an OnType hook-callable function.
**)
let decode_on_type_callback (hx_callback : EvalValue.value): (EvilParser.token_stream -> (Ast.type_hint option)) = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun (token_stream: EvilParser.token_stream): (Ast.type_hint option) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_type_hint = hxf [hx_stream] in
		if hx_type_hint = vnull then None
		else (
			Some (EvilDecode.decode_ctype_and_pos hx_type_hint)
		)
	)
)

(**
	Converts a Haxe callback into an OnAfterType hook-callable function.
**)
let decode_on_after_type_callback (hx_callback : EvalValue.value) = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun ((token_stream: EvilParser.token_stream), (type_hint: Ast.type_hint)) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_type_hint_arg = Interp.encode_obj [
			"type", Interp.encode_ctype type_hint;
			"pos", Interp.encode_pos (snd type_hint)
		] in
		let hx_type_hint = hxf [hx_stream; hx_type_hint_arg] in
		if hx_type_hint = vnull then None
		else Some (EvilDecode.decode_ctype_and_pos hx_type_hint)
	)
)

(**
	Converts a Haxe callback into an OnTypeDecl hook-callable function.
**)
let decode_on_type_decl_callback hx_callback = (
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
let decode_on_class_field_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 2 in
	(fun (token_stream, (is_module_level: bool)) ->
		let hx_stream = EvilTokenStream.make_token_stream_for_haxe token_stream in
		let hx_field = hxf [hx_stream; vbool is_module_level] in
		if hx_field = vnull then None
		else Some (Interp.decode_field hx_field)
	)
)

(**
	Converts a Haxe callback into an TokenTransmuter hook-callable function.
**)
let decode_token_transmuter_callback hx_callback = (
	let hxf = EvalMisc.prepare_callback hx_callback 1 in
	(fun (token: Ast.token) ->
		let hx_field = hxf [EvilEncode.encode_token token] in
		if hx_field = vnull then None
		else Some (EvilDecode.decode_token hx_field)
	)
)

(**
	Given a `EvalValue.value` callback and the hook type,
	setup the callback to make a parser mod.
**)
let setup_hook (t: EvilParser.hook_type) (hx_callback: EvalValue.value) =
	let hooks = EvilParser.hooks in
	let add decode_func hook_list =
		let f = decode_func hx_callback in
		(f :: hook_list)
	in
	(* TODO: is there better way to do this? Can I put the assignment in `add`? *)
	match t with
		| OnExpr            -> hooks.on_expr          <- add decode_on_expr_callback hooks.on_expr
		| OnAfterExpr       -> hooks.on_expr_next     <- add decode_on_after_expr_callback hooks.on_expr_next
		| OnFunctionExpr    -> hooks.on_function_expr <- add decode_on_function_expr_callback hooks.on_function_expr
		| OnBlockStart      -> hooks.on_block         <- add decode_on_block_start_callback hooks.on_block
		| OnAfterBlockExpr  -> hooks.on_block_next    <- add decode_on_block_expr_callback hooks.on_block_next
		| OnType            -> hooks.on_type          <- add decode_on_type_callback hooks.on_type
		| OnAfterType       -> hooks.on_after_type    <- add decode_on_after_type_callback hooks.on_after_type
		| OnTypeDeclaration -> hooks.on_type_decl     <- add decode_on_type_decl_callback hooks.on_type_decl
		| OnClassField      -> hooks.on_class_field   <- add decode_on_class_field_callback hooks.on_class_field
		| TokenTransmuter   -> hooks.token_transmuter <- add decode_token_transmuter_callback hooks.token_transmuter

(********************************************)

let key_on_expr = EvalHash.hash "onExpr"
let key_on_after_expr = EvalHash.hash "onAfterExpr"
let key_on_function_expr = EvalHash.hash "onFunctionExpr"
let key_on_block_start = EvalHash.hash "onBlockExpr"
let key_on_block_expr = EvalHash.hash "onAfterBlockExpr"
let key_on_type = EvalHash.hash "onType"
let key_on_after_type = EvalHash.hash "onAfterType"
let key_on_type_decl = EvalHash.hash "onTypeDeclaration"
let key_on_class_field = EvalHash.hash "onClassField"
let key_token_transmuter = EvalHash.hash "tokenTransmuter"

(**
	Sets up all the functions callable using `Eval.nativeCall`.
**)
let setup_macro_functions =
	add_macro_function "add_parser_mod" (
		vfun2 (fun (name: EvalValue.value) (mod_obj: EvalValue.value) ->
			let obj = Interp.decode_object mod_obj in
			let n = Interp.decode_string name in
			let decode_callback decode_func key =
				let f = EvalField.object_field obj key in
				EvalDecode.decode_optional decode_func f
			in
			Hashtbl.replace EvilGlobalState.mods n {
				on_expr          = decode_callback decode_on_expr_callback key_on_expr;
				on_expr_next     = decode_callback decode_on_after_expr_callback key_on_after_expr;
				on_function_expr = decode_callback decode_on_function_expr_callback key_on_function_expr;
				on_block         = decode_callback decode_on_block_start_callback key_on_block_start;
				on_block_next    = decode_callback decode_on_block_expr_callback key_on_block_expr;
				on_type          = decode_callback decode_on_type_callback key_on_type;
				on_after_type    = decode_callback decode_on_after_type_callback key_on_after_type;
				on_type_decl     = decode_callback decode_on_type_decl_callback key_on_type_decl;
				on_class_field   = decode_callback decode_on_class_field_callback key_on_class_field;
				token_transmuter = decode_callback decode_token_transmuter_callback key_token_transmuter;
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

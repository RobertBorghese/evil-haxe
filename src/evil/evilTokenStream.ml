open EvalValue
open EvalEncode
open MacroContext

(**
	Generates the `evil.macro.TokenStream` structure in Haxe.

	[NOTE]
	Tried putting the parsing functions into their own classes (i.e. the `Grammar`-related functions
	into a Haxe exposed `Grammar` class), but could not for the life of me resolve all the dependency-cycle issues.
	To any future person looking at this... just be warned.
**)
let make_token_stream_for_haxe (token_stream: EvilParser.token_stream) =
	Interp.encode_obj [
		"peek", vfun0 (fun () ->
			match Stream.peek token_stream with
			| Some (token, pos) ->
				Interp.encode_obj [
					"token", EvilEncode.encode_token token;
					"pos", Interp.encode_pos pos
				]
			| None -> vnull
		);
		"consume", vfun0 (fun () ->
			Stream.junk token_stream;
			vnull
		);
		"nextExpr", vfun0 (fun () ->
			Interp.encode_expr (Grammar.secure_expr token_stream)
		);
		"parsePostExpr", vfun1 (fun e ->
			Interp.encode_expr (Grammar.expr_next (Interp.decode_expr e) token_stream)
		);
		"nextType", vfun0 (fun () ->
			let type_hint = Grammar.parse_complex_type token_stream in
			EvilEncode.encode_ctype_and_pos type_hint
		);
		"parsePostType", vfun1 (fun t ->
			let type_hint = EvilDecode.decode_ctype_and_pos t in
			let type_hint = Grammar.parse_complex_type_next type_hint token_stream in
			EvilEncode.encode_ctype_and_pos type_hint
		);
		"semicolon", vfun0 (fun () ->
			Interp.encode_pos (Grammar.semicolon token_stream)
		);
		"parseBlockInternals", vfun0 (fun () ->
			encode_array (List.map Interp.encode_expr (Grammar.on_block1_parse_block token_stream))
		);
		"isParsingSwitchExpr", vfun0 (fun () ->
			vbool EvilParser.hooks.parsing_switch_expr
		);
		"posUnion", vfun2 (fun p1 p2 ->
			Interp.encode_pos (Ast.punion (Interp.decode_pos p1) (Interp.decode_pos p2))
		)
	]

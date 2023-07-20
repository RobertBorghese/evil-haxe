open EvalValue
open EvalEncode
open MacroContext

(**
	Generates the `evil.macro.TokenStream` structure in Haxe.

	TODO: Should probably expose the parsing functions in separate class.
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
		"semicolon", vfun0 (fun () ->
			Interp.encode_pos (Grammar.semicolon token_stream)
		);
		"posUnion", vfun2 (fun p1 p2 ->
			Interp.encode_pos (Ast.punion (Interp.decode_pos p1) (Interp.decode_pos p2))
		)
	]

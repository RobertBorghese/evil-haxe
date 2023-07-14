open EvalValue
open EvalEncode
open MacroContext

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
		)
	]
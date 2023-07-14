let encode_token (t: Ast.token) =
	let open MacroContext in
	let ctx = EvalContext.get_ctx() in
	let tag, pl = match t with
		| Eof -> 0, []
		| Const (c: Ast.constant) -> 1, [Interp.encode_const c]
		| Kwd (k: Ast.keyword) -> 2, [] (* TODO *)
		| Comment (s: string) -> 3, [Interp.encode_string s]
		| CommentLine (s: string) -> 4, [Interp.encode_string s]
		| Binop (binop: Ast.binop) -> 5, [Interp.encode_binop binop]
		| Unop (unop: Ast.unop) -> 6, [Interp.encode_unop unop]
		| Semicolon -> 7, []
		| Comma -> 8, []
		| BrOpen -> 9, []
		| BrClose -> 10, []
		| BkOpen -> 11, []
		| BkClose -> 12, []
		| POpen -> 13, []
		| PClose -> 14, []
		| Dot -> 15, []
		| DblDot -> 16, []
		| QuestionDot -> 17, []
		| Arrow -> 18, []
		| IntInterval (s: string) -> 19, [Interp.encode_string s]
		| Sharp (s: string) -> 20, [Interp.encode_string s]
		| Question -> 21, []
		| At -> 22, []
		| Dollar (s: string) -> 23, [Interp.encode_string s]
		| Spread -> 24, []
	in
	Interp.encode_enum IToken tag pl

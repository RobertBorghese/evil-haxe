let encode_keyword (k: Ast.keyword) =
	let tag = match k with
		| Function -> 0
		| Class -> 1
		| Var -> 2
		| If -> 3
		| Else -> 4
		| While -> 5
		| Do -> 6
		| For -> 7
		| Break -> 8
		| Continue -> 9
		| Return -> 10
		| Extends -> 11
		| Implements -> 12
		| Import -> 13
		| Switch -> 14
		| Case -> 15
		| Default -> 16
		| Static -> 17
		| Public -> 18
		| Private -> 19
		| Try -> 20
		| Catch -> 21
		| New -> 22
		| This -> 23
		| Throw -> 24
		| Extern -> 25
		| Enum -> 26
		| In -> 27
		| Interface -> 28
		| Untyped -> 29
		| Cast -> 30
		| Override -> 31
		| Typedef -> 32
		| Dynamic -> 33
		| Package -> 34
		| Inline -> 35
		| Using -> 36
		| Null -> 37
		| True -> 38
		| False -> 39
		| Abstract -> 40
		| Macro -> 41
		| Final -> 42
		| Operator -> 43
		| Overload -> 44
	in
	MacroContext.Interp.encode_enum IKeyword tag []

let encode_token (t: Ast.token) =
	let open MacroContext in
	let tag, pl = match t with
		| Eof -> 0, []
		| Const (c: Ast.constant) -> 1, [Interp.encode_const c]
		| Kwd (k: Ast.keyword) -> 2, [encode_keyword k]
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

let encode_type_decl_completion_mode (t: Parser.type_decl_completion_mode) =
	let tag = match t with
		| TCBeforePackage -> 0
		| TCAfterImport -> 1
		| TCAfterType -> 2
	in
	MacroContext.Interp.encode_enum ITypeDeclCompletionMode tag []

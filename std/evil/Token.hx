package evil;

enum Token {
	Eof;
	Const(c: haxe.macro.Expr.Constant);
	Kwd(k: evil.Keyword);
	Comment(s: String);
	CommentLine(s: String);
	Binop(b: haxe.macro.Expr.Binop);
	Unop(u: haxe.macro.Expr.Unop);
	Semicolon;
	Comma;
	BrOpen;
	BrClose;
	BkOpen;
	BkClose;
	POpen;
	PClose;
	Dot;
	DblDot;
	QuestionDot;
	Arrow;
	IntInterval(s: String);
	Sharp(s: String);
	Question;
	At;
	Dollar(s: String);
	Spread;
}

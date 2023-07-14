open MacroContext

open EvilParser

let decode_hook_type t =
	match Interp.decode_enum t with
	| 0, [] -> OnExpr
	| 1, [] -> OnAfterExpr
	(* | 2, [] -> OnExprExpected *)
	| 2, [] -> OnTypeDeclaration
	| 3, [] -> OnClassField
	| _ -> EvalExceptions.unexpected_value t "enum"
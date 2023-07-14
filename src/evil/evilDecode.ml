open MacroContext
open Parser

open EvilParser

let decode_hook_type t =
	match Interp.decode_enum t with
	| 0, [] -> OnExpr
	| 1, [] -> OnAfterExpr
	(* | 2, [] -> OnExprExpected *)
	| 2, [] -> OnTypeDeclaration
	| 3, [] -> OnClassField
	| _ -> EvalExceptions.unexpected_value t "enum"

let decode_type_decl_completion_mode m =
	match Interp.decode_enum m with
	| 0, [] -> TCBeforePackage
	| 1, [] -> TCAfterImport
	| 2, [] -> TCAfterType
	| _ -> EvalExceptions.unexpected_value m "enum"

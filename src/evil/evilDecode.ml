open MacroContext
open Parser
open Ast

open EvilParser

let decode_hook_type t =
	match Interp.decode_enum t with
	| 0, [] -> OnExpr
	| 1, [] -> OnAfterExpr
	| 2, [] -> OnBlockStart
	| 3, [] -> OnAfterBlockExpr
	| 4, [] -> OnTypeDeclaration
	| 5, [] -> OnClassField
	| 6, [] -> TokenTransmuter
	| _ -> EvalExceptions.unexpected_value t "enum"

let decode_type_decl_completion_mode m =
	match Interp.decode_enum m with
	| 0, [] -> TCBeforePackage
	| 1, [] -> TCAfterImport
	| 2, [] -> TCAfterType
	| _ -> EvalExceptions.unexpected_value m "enum"

let decode_keyword k =
	match Interp.decode_enum k with
	| 0, [] -> Function
	| 1, [] -> Class
	| 2, [] -> Var
	| 3, [] -> If
	| 4, [] -> Else
	| 5, [] -> While
	| 6, [] -> Do
	| 7, [] -> For
	| 8, [] -> Break
	| 9, [] -> Continue
	| 10, [] -> Return
	| 11, [] -> Extends
	| 12, [] -> Implements
	| 13, [] -> Import
	| 14, [] -> Switch
	| 15, [] -> Case
	| 16, [] -> Default
	| 17, [] -> Static
	| 18, [] -> Public
	| 19, [] -> Private
	| 20, [] -> Try
	| 21, [] -> Catch
	| 22, [] -> New
	| 23, [] -> This
	| 24, [] -> Throw
	| 25, [] -> Extern
	| 26, [] -> Enum
	| 27, [] -> In
	| 28, [] -> Interface
	| 29, [] -> Untyped
	| 30, [] -> Cast
	| 31, [] -> Override
	| 32, [] -> Typedef
	| 33, [] -> Dynamic
	| 34, [] -> Package
	| 35, [] -> Inline
	| 36, [] -> Using
	| 37, [] -> Null
	| 38, [] -> True
	| 39, [] -> False
	| 40, [] -> Abstract
	| 41, [] -> Macro
	| 42, [] -> Final
	| 43, [] -> Operator
	| 44, [] -> Overload
	| _ -> EvalExceptions.unexpected_value k "enum"

let decode_token t =
	match Interp.decode_enum t with
	| 0, [] -> Eof
	| 1, [c] -> Const (Interp.decode_const c)
	| 2, [k] -> Kwd (decode_keyword k)
	| 3, [s] -> Comment (Interp.decode_string s)
	| 4, [s] -> CommentLine (Interp.decode_string s)
	| 5, [b] -> Binop (Interp.decode_op b)
	| 6, [u] -> Unop (Interp.decode_unop u)
	| 7, [] -> Semicolon
	| 8, [] -> Comma
	| 9, [] -> BrOpen
	| 10, [] -> BrClose
	| 11, [] -> BkOpen
	| 12, [] -> BkClose
	| 13, [] -> POpen
	| 14, [] -> PClose
	| 15, [] -> Dot
	| 16, [] -> DblDot
	| 17, [] -> QuestionDot
	| 18, [] -> Arrow
	| 19, [s] -> IntInterval (Interp.decode_string s)
	| 20, [s] -> Sharp (Interp.decode_string s)
	| 21, [] -> Question
	| 22, [] -> At
	| 23, [s] -> Dollar (Interp.decode_string s)
	| 24, [] -> Spread
	| _ -> EvalExceptions.unexpected_value t "enum"

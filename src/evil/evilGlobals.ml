open EvalValue

type module_attribute = bool * (Path.UniqueKey.t->(Ast.expr list)->(Ast.token option))

(**
	Stores global variables for processing macros.
**)
module EvilGlobalState = struct
	let macro_lib : (string,value) Hashtbl.t = Hashtbl.create 0
	let mods : (string,EvilParser.parser_mod) Hashtbl.t = Hashtbl.create 0
	let module_attributes : (string,module_attribute) Hashtbl.t = Hashtbl.create 0
	let evil_modules : (Path.UniqueKey.t,Ast.expr list) Hashtbl.t = Hashtbl.create 0
end

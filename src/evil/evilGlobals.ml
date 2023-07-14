open EvalValue

(**
	Stores global variables for processing macros.
**)
module EvilGlobalState = struct
	let macro_lib : (string,value) Hashtbl.t = Hashtbl.create 0
	let mods : (string,EvilParser.parser_mod) Hashtbl.t = Hashtbl.create 0
	let module_attributes : (string,unit->(Ast.token option)) Hashtbl.t = Hashtbl.create 0
end

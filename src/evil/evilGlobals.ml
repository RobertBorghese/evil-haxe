open EvalValue

(**
	Stores global variables for processing macros.
**)
module EvilGlobalState = struct
	let macro_lib : (string,value) Hashtbl.t = Hashtbl.create 0
end
open EvalValue
open EvalEncode
open EvalDecode

(**
	Stores global variables for processing macros.
**)
module EvilGlobalState = struct
	let macro_lib : (string,value) Hashtbl.t = Hashtbl.create 0
end

(**
	Given a `name` and an instance of `VFunction`, adds a
	function that can be called from Haxe using `Eval.nativeCall`.
**)
let add_macro_function name func =
	Hashtbl.replace EvilGlobalState.macro_lib name func

(**
	Sets up all the functions callable using `Eval.nativeCall`.
**)
let setup_macro_functions =
	add_macro_function "test" (
		vfun1 (fun f ->
			let f = decode_string f in
			Printf.sprintf "%s" f;
			vnull
		)
	);

	add_macro_function "test_callback" (
		vfun1 (fun callback ->
			let f = EvalMisc.prepare_callback callback 1 in
			(* (fun path -> f [encode_string path]); *)
			f [encode_string "string from ocaml"]
		)
	)

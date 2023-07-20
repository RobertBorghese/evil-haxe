open EvilGlobals
open EvilParser

open Ast

(**
	Parse the arguments after `#evil`.
**)
let parse_module_attribute_args parse_call_params s =
	match Stream.peek s with
		| Some (POpen, p) -> (
			Stream.junk s;
			let e,_ = parse_call_params (fun el p2 -> (EBlock(el)),p2) p s in
			match e with
				| EBlock(el) -> el
				| _ -> raise Not_found
		)
		| _ -> []

(**
	If the file starts with `#evil`, the file is returned.
	None otherwise.
**)
let parse_evil_header parse_call_params s =
	match Stream.peek s with
		| Some (Sharp ("evil"), (p: Globals.pos)) -> (
			Stream.junk s;
			Some (parse_module_attribute_args parse_call_params s, p.pfile)
		)
		| _ -> None

let clear_hooks () =
	if hooks.has_mods = true then (
		hooks.on_expr <- [];
		hooks.on_expr_next <- [];
		hooks.on_block <- [];
		hooks.on_block_next <- [];
		hooks.on_type_decl <- [];
		hooks.on_class_field <- [];
		hooks.token_transmuter <- [];
		hooks.has_mods <- false; 
	)

let install_mod (name,pos) =
	if Hashtbl.mem EvilGlobalState.mods name then (
		let parser_mod = Hashtbl.find EvilGlobalState.mods name in
		apply_mod parser_mod;
		if has_any_hooks() then hooks.has_mods <- true;
	) else (
		let msg = Printf.sprintf "Unknown Evil Haxe mod \"%s\"" name in
		Parser.error (Custom msg) pos;
	)

let on_parse_file_start parse_call_params s =
	let evil_attribute = parse_evil_header parse_call_params s in

	clear_hooks();

	if Option.is_some evil_attribute then
		let args,file = Option.get evil_attribute in
		(* let key = Path.UniqueKey.create file in *)
		(* List.iter (fun a -> print_endline (Ast.Printer.s_expr a)) args; *)

		let mods = if List.length args == 0 then
			List.map (fun (s: string) -> s,Globals.null_pos) hooks.defaults
		else
			List.map (fun (e: Ast.expr) -> Ast.Printer.s_expr e,snd e) args
		in

		List.iter install_mod mods

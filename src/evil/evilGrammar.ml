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
		hooks.on_type_decl <- [];
		hooks.on_class_field <- [];
		hooks.has_mods <- false; 
	)

let install_mod (name,pos) =
	if Hashtbl.mem EvilGlobalState.mods name then (
		let parser_mod = Hashtbl.find EvilGlobalState.mods name in

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr <- (h :: hooks.on_expr);
		) parser_mod.on_expr;

		EvilUtil.unwrap_opt (fun h ->
			hooks.on_expr_next <- (h :: hooks.on_expr_next);
		) parser_mod.on_expr_next;

		if (
			List.length hooks.on_expr > 0 &&
			List.length hooks.on_expr_next > 0 &&
			List.length hooks.on_type_decl > 0 &&
			List.length hooks.on_class_field > 0
		) then hooks.has_mods <- true;
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

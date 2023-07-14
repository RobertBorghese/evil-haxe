(**
	Intercepts the `Sharp` token processing to handle new # features.

	TODO: do I still needs these arguments?
**)
let check_sharp tk name (file_key: Path.UniqueKey.t) next_token =
	let module_attributes = EvilGlobals.EvilGlobalState.module_attributes in
	if Hashtbl.mem module_attributes name then
		Some tk
	else
		None

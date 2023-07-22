(**
	Same as `Option.iter`, but that function doesn't exist in this version of OCaml.
**)
let unwrap_opt callback o =
	if Option.is_some o then
		callback (Option.get o)
	else
		()
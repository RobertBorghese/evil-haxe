open EvilParser

(**
	Implementation for `--default-mods` argument.
**)
let set_default_mods (mods: string) =
	hooks.defaults <- (String.split_on_char ',' mods)

(**
	Implementation for `--conspire` argument.
**)
let add_conspire (hxpath: string) =
	hooks.conspiracies <- (hxpath :: hooks.conspiracies)

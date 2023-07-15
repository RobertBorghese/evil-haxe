open EvilParser

let set_default_mods (mods: string) =
	hooks.defaults <- (String.split_on_char ',' mods)

let add_conspire (hxpath: string) =
	hooks.conspiracies <- (hxpath :: hooks.conspiracies)

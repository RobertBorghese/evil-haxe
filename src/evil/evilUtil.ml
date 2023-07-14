let unwrap_opt callback o =
	if Option.is_some o then
		callback (Option.get o)
	else
		()
name =						"Battle Royale"
version = 					"1.2"

description =				"Version: "..version
author =					"CunningFox"

forumthread = 				""

dst_compatible 				= true
priority 					= -10000.02001958
api_version 				= 10

all_clients_require_mod = true

configuration_options =
{
	
}

game_modes = 
{
	{
		name = "battleroyale",
		label = "Battle Royale",
		description = "",
		settings = {
			level_type = "SURVIVAL",
			spawn_mode = "fixed",
			resource_renewal = false,
			ghost_sanity_drain = false,
			ghost_enabled = true,
			portal_rez = false,
			reset_time = nil,
			invalid_recipes = {
				"resurrectionstatue",
				"reviver",
			},
			hide_worldgen_loading_screen = true,
			lobbywaitforallplayers = false,
			drop_everything_on_despawn = true,
		},
	}
}
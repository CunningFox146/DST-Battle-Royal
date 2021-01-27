name =						"Battle Royale by CunningFox"
version = 					"2.0.1"

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
			hide_worldgen_loading_screen = true,
			lobbywaitforallplayers = true,
			drop_everything_on_despawn = true,
			no_avatar_popup = true,
			disable_bird_mercy_items = true,
			disable_transplanting = true,

			invalid_recipes = {
				"resurrectionstatue",
				"reviver",
				"pitchfork",
			},
		},
	}
}
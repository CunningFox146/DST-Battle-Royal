local env = env
GLOBAL.setfenv(1, GLOBAL)

require("br/constants")

local Layouts =  require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")

require("constants")
require("map/tasks")
require("map/level")

TheMapSaver = require("map_saver")(env.MODROOT)

TheMapSaver:Load()
local SELECTED_MAP = TheMapSaver:GetMap()

print("[BattleRoyale World Gen] About to generate arena:", BATTLE_ROYALE_SETPIECES[SELECTED_MAP])

Layouts["BattleRoyaleArena"] = StaticLayout.Get("map/static_layouts/battleroyale/"..BATTLE_ROYALE_SETPIECES[SELECTED_MAP],
{
	start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = LAYOUT_POSITION.CENTER,
	disable_transform = true,
	  
	defs = BATTLE_ROYALE_MAP_DEFS[SELECTED_MAP],
})	
	
env.AddStartLocation("BattleRoyaleStart", {
    name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
    location = "battleroyale",
    start_setpeice = "BattleRoyaleArena",
    start_node = "Blank",
})

env.AddTask("BattleRoyaleTask", {
	locks={},
	keys_given={},
	room_choices={
		["Blank"] = 1,
	}, 
	room_bg=GROUND.GRASS,
	--background_room="BGGrass",
	background_room = "Blank",
	colour={r=0,g=1,b=0,a=1}
}) 

env.AddLocation({
    location = "battleroyale",
    version = 2,
    overrides = {
        task_set = "battleroyale_taskset",
        start_location = "BattleRoyaleStart",
        season_start = "default",
        world_size = "default",
        layout_mode = "RestrictNodesByKey", --LinkNodesByKeys
        wormhole_prefab = nil,
        roads = "never",
        keep_disconnected_tiles = true,
		no_wormholes_to_disconnected_tiles = true,
		no_joining_islands = true,
    },
    required_prefabs = {
        --"lavaarena_portal",
    },
})

env.AddLevel(LEVELTYPE.BATTLE_ROYALE,
{
	id = "BATTLEROYALE",
	name = "Battle royale",
	desc = "",
	location = "battleroyale", -- Prefab
	version = 4,
	overrides={
		start_location = "BattleRoyaleStart",
		keep_disconnected_tiles = true,
		roads = "never",
		required_prefabs = {},
		has_ocean = false,

		boons = "never",
		touchstone = "never",
		traps = "never",
		poi = "never",
		protected = "never",
		disease_delay = "none",
		prefabswaps_start = "classic",
		petrification = "none",
		wildfires = "never",
	},
	background_node_range = {0,1},
})

env.AddTaskSet("battleroyale_taskset", {
    name = "Battle Royale",
    location = "battleroyale",
    tasks = {"BattleRoyaleTask"},
    valid_start_tasks = {"BattleRoyaleStart"},
 
	set_pieces = {},
})

function GenerateNew(debug, world_gen_data)
	printwrap("level_data", world_gen_data.level_data)
	return _GenerateNew(debug, world_gen_data)
end
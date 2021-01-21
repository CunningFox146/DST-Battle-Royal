local env = env
GLOBAL.setfenv(1, GLOBAL)

local Layouts =  require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")
require("constants")
require("map/tasks")
require("map/level")

Layouts["BattleRoyaleArena"] = StaticLayout.Get("map/static_layouts/br_arena",{
	start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = LAYOUT_POSITION.CENTER,
	disable_transform = true,
	--[[        
	defs={
		
	},]]
})	
	
env.AddStartLocation("BattleRoyaleStart", {
    name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
    location = "forest",
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

env.AddLevelPreInitAny(function(level)
	if level.location ~= "forest" then
		return
	end

	level.tasks = {"BattleRoyaleTask"}
	level.numoptionaltasks = 0
	level.optionaltasks = {}
	level.valid_start_tasks = nil
	level.set_pieces = {}

	level.random_set_pieces = {}
	level.ordered_story_setpieces = {}
	level.numrandom_set_pieces = 0

	level.overrides.start_location = "BattleRoyaleStart"
	level.overrides.keep_disconnected_tiles = true
	level.overrides.roads = "never"
	level.required_prefabs = {}
	level.overrides.has_ocean = false
end)

env.AddRoomPreInit("OceanSwell", function(room) 
	room.required_prefabs = nil
end)

env.AddRoomPreInit("OceanRough", function(room) 
	room.required_prefabs = nil
end)

env.AddRoomPreInit("MoonIsland_Baths", function(room) 
	room.required_prefabs = nil
end)
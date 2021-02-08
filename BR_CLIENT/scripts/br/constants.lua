LEVELTYPE.BATTLE_ROYALE = "BATTLEROYALE"

BATTLE_ROYALE_MAPS = {
	TEST = 0,
	CLASSIC = 1,
	WINTER = 2,
	NIGHT = 3,
}

BATTLE_ROYALE_MAP_ROTATION = {
	BATTLE_ROYALE_MAPS.CLASSIC,
	-- BATTLE_ROYALE_MAPS.WINTER,
	BATTLE_ROYALE_MAPS.NIGHT,
}

BATTLE_ROYALE_MAP_DEFS = {
    [BATTLE_ROYALE_MAPS.TEST] = {
		aggro = {"hound"},
		mob = {"beefalo"},

		resource_common = {"sapling", "grass"},
		trees = {"evergreen"},
		rocks = {"rock1", "rock2", "rock_flintless"},

		structure_1 = {"researchlab", "researchlab4"},
		structure_2 = {"researchlab2", "researchlab3"},
		structure_3 = {"ancient_altar"},

		item_1 = {"spear", "armorgrass"},
		item_2 = {"tentaclespike", "armorwood"},
		item_3 = {"nightsword", "armor_sanity"},
		item_4 = {"ruinshat", "armorruins"},

		healing_1 = {"spidergland", "tillweedsalve"},
		healing_2 = {"healingsalve", "meat_dried"},
		healing_3 = {"bandage"},
	},
	
    [BATTLE_ROYALE_MAPS.CLASSIC] = {
		aggro = {"hound", "spiderden"},
		mob = {"beefalo", "pighouse"},

		resource_common = {"sapling", "grass", "evergreen"},
		rocks = {"rock1", "rock2", "rock_flintless"},

		structure_1 = {"researchlab", "researchlab4"},
		structure_2 = {"researchlab2", "researchlab3"},
		structure_3 = {"ancient_altar"},

		item_1 = {"spear_wathgrithr", "armorgrass"},
		item_2 = {"tentaclespike", "armorwood"},
		item_3 = {"nightsword", "armor_sanity"},
		item_4 = {"ruinshat", "armorruins"},

		staff = {"icestaff", "firestaff"},
		dart = {"blowdart_pipe", "blowdart_yellow", "blowdart_fire"},

		healing_1 = {"spidergland", "tillweedsalve"},
		healing_2 = {"healingsalve", "meat_dried"},
		healing_3 = {"bandage", "trailmix"},
    },
	
    [BATTLE_ROYALE_MAPS.WINTER] = {
		aggro = {"hound", "spiderden"},
		mob = {"beefalo", "pighouse"},

		resource_common = {"sapling", "grass", "evergreen"},
		rocks = {"rock1", "rock2", "rock_flintless"},

		structure_1 = {"researchlab", "researchlab4"},
		structure_2 = {"researchlab2", "researchlab3"},
		structure_3 = {"ancient_altar"},

		item_1 = {"spear_wathgrithr", "armorgrass"},
		item_2 = {"tentaclespike", "armorwood"},
		item_3 = {"nightsword", "armor_sanity"},
		item_4 = {"ruinshat", "armorruins"},

		staff = {"icestaff", "firestaff"},
		dart = {"blowdart_pipe", "blowdart_yellow", "blowdart_fire"},

		healing_1 = {"spidergland", "tillweedsalve"},
		healing_2 = {"healingsalve", "meat_dried"},
		healing_3 = {"bandage", "trailmix"},
    },
	
    [BATTLE_ROYALE_MAPS.NIGHT] = {
		aggro = {"hound", "spiderden"},
		mob = {"beefalo", "pighouse"},

		resource_common = {"sapling", "grass", "evergreen"},
		rocks = {"rock1", "rock2", "rock_flintless"},

		structure_1 = {"researchlab", "researchlab4"},
		structure_2 = {"researchlab2", "researchlab3"},
		structure_3 = {"ancient_altar"},

		item_1 = {"spear_wathgrithr", "armorgrass"},
		item_2 = {"tentaclespike", "armorwood"},
		item_3 = {"nightsword", "armor_sanity"},
		item_4 = {"ruinshat", "armorruins"},

		staff = {"icestaff", "firestaff"},
		dart = {"blowdart_pipe", "blowdart_yellow", "blowdart_fire"},

		healing_1 = {"spidergland", "tillweedsalve"},
		healing_2 = {"healingsalve", "meat_dried"},
		healing_3 = {"bandage", "trailmix"},

		light = {"flower_cave", "flower_cave_double", "flower_cave_triple"},
		chess = {"rook", "knight"},
		ancient_parts = {"nightmarefuel", "thulecite"},
		ancient_statues = {"ruins_statue_head",  "ruins_statue_mage"},
    },
}

BATTLE_ROYALE_SETPIECES = {
	[BATTLE_ROYALE_MAPS.TEST] = "test_arena",
	[BATTLE_ROYALE_MAPS.CLASSIC] = "classic_arena",
	[BATTLE_ROYALE_MAPS.WINTER] = "classic_arena",
	[BATTLE_ROYALE_MAPS.NIGHT] = "night_arena",
}

BATTLE_ROYALE_STARTING_INVENTORY = {
	[BATTLE_ROYALE_MAPS.CLASSIC] = {
		flint = 2,
		twigs = 2,
		cutgrass = 2,
		spear = 1,
	},

	[BATTLE_ROYALE_MAPS.WINTER] = {
		flint = 2,
		twigs = 2,
		cutgrass = 6,
		log = 2,
		spear = 1,
		heatrock = 1,
		ice = 10,
	},

	[BATTLE_ROYALE_MAPS.NIGHT] = {
		flint = 6,
		twigs = 12,
		cutgrass = 12,
		log = 2,
		lantern = 1,
	},
}

BATTLE_ROYALE_OVERRIDES = {
	[BATTLE_ROYALE_MAPS.WINTER] = {
		iswinter = true,
	},
	[BATTLE_ROYALE_MAPS.NIGHT] = {
		isnight = true,
	},
}

-- Fox: ToDo make this into separate script and then save it here
PREFABS_TO_LOAD = {}
do
	local toload = {}
	local function add(val)
		if not toload[val] then
			toload[val] = true
		end
	end
	for _, defs in pairs(BATTLE_ROYALE_MAP_DEFS) do
		for _, prefs in pairs(defs) do
			for _, pref in ipairs(prefs) do
				add(pref)
			end
		end
	end
	for _, defs in pairs(BATTLE_ROYALE_STARTING_INVENTORY) do
		for pref, _ in pairs(defs) do
			add(pref)
		end
	end
	-- printwrap("toload", toload)
	for pref, _ in pairs(toload) do
		table.insert(PREFABS_TO_LOAD, pref)
	end
end

RANKS = {
	MAX_RANK = 500,
	EXP_DIFFICULTY = 75,

	DELTA = {
		DAMAGE = 1.5,
        KILL = 1250,
        WIN = 3500,
    }
}
LEVELTYPE.BATTLE_ROYALE = "BATTLEROYALE"

BATTLE_ROYALE_MAPS = {
	TEST = 0,
	CLASSIC = 1,
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
}

BATTLE_ROYALE_SETPIECES = {
	[BATTLE_ROYALE_MAPS.TEST] = "test_arena",
	[BATTLE_ROYALE_MAPS.CLASSIC] = "classic_arena",
}

RANKS = {
	MAX_RANK = 500,
	EXP_DIFFICULTY = 75,

	DELTA = {
		DAMAGE = 1.25,
        KILL = 1250,
        WIN = 3500,
    }
}
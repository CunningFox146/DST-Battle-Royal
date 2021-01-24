LEVELTYPE.BATTLE_ROYALE = "BATTLEROYALE"

BATTLE_ROYALE_MAPS = {
    TEST = 0,
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
    }
}

BATTLE_ROYALE_SETPIECES = {
	[BATTLE_ROYALE_MAPS.TEST] = "test_arena"
}

RANKS = {
	MAX_RANK = 500,
	RANK_VALUE = 1000,
	RANK_DIFFICULTY = 0.05,  -- Add 5% for every level (level 1 is RANK_VALUE, level 2 is RANK_VALUE * 1.05, etc)

	DELTA = {
		-- DEATH = -100,
		
		DAMAGE = 0.75, -- 1 damage dealt == 0.75 exp
        KILL = 1000,
        WIN = 3000,
    }
}
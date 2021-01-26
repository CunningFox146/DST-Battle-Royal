PrefabFiles = {
    "battleroyale",
    "battleroyale_network",

    "battleroyale_points",

    "debuff_lunar",
    "poison_dots",

    "debuff_poison",
    "debuff_pvp",
    
    "damagenumber",
}

Assets = {
    Asset("SOUNDPACKAGE", "sound/battleroyale.fev"),
	Asset("SOUND", "sound/battleroyale.fsb"),

    Asset("ANIM", "anim/winner_fx.zip"),
    Asset("ANIM", "anim/player_actions_twister.zip"),
    Asset("ANIM", "anim/spectator_eye.zip"),
    
    Asset("IMAGE", "images/colour_cubes/bat_vision_on_cc.tex"),
}

modimport("scripts/br/main.lua")
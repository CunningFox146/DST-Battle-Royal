require("prefabs/world")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world.lua"),

    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/night03_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snow_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snowdusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/night04_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_night_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_night_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/lunacy_regular_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"),

    Asset("ANIM", "anim/lightning.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
    Asset("SOUND", "sound/amb_stream.fsb"),    
    Asset("SOUND", "sound/turnoftides_music.fsb"),
    Asset("SOUND", "sound/turnoftides_amb.fsb"),

    Asset("IMAGE", "images/wave_shadow.tex"),

    Asset("ANIM", "anim/swimming_ripple.zip"), -- common water fx symbols
}

local prefabs =
{
    "battleroyale_network",
    "adventure_portal",
    "resurrectionstone",
    "deer",
    "deerspawningground",
    "deerclops",
    "gravestone",
    "flower",
    "animal_track",
    "dirtpile",
    "beefaloherd",
    "beefalo",
    "penguinherd",
    "penguin_ice",
    "penguin",
    "mutated_penguin",
    "koalefant_summer",
    "koalefant_winter",
    "beehive",
    "wasphive",
    "walrus_camp",
    "pighead",
    "mermhead",
    "rabbithole",
    "molehill",
    "carrot_planted",
    "tentacle",
    "wormhole",
    "cave_entrance",
    "teleportato_base",
    "teleportato_ring",
    "teleportato_box",
    "teleportato_crank",
    "teleportato_potato",
    "pond", 
    "marsh_tree", 
    "marsh_bush", 
    "burnt_marsh_bush",
    "reeds", 
    "mist",
    "snow",
    "rain",
    "pollen",
    "marblepillar",
    "marbletree",
    "statueharp",
    "statuemaxwell",
    "beemine_maxwell",
    "trap_teeth_maxwell",
    "sculpture_knight",
    "sculpture_bishop",
    "sculpture_rook",
    "statue_marble",
    "eyeplant",
    "lureplant",
    "purpleamulet",
    "monkey",
    "livingtree",
	"livingtree_halloween",
	"livingtree_root",
    "tumbleweed",
    "rock_ice",
    "catcoonden",
    "shadowmeteor",
    "meteorwarning",
    "warg",
    "claywarg",
    "spat",
    "multiplayer_portal",
    "lavae",
    "lava_pond",
    "scorchedground",
    "scorched_skeleton",
    "lavae_egg",
    "terrorbeak",
    "crawlinghorror",
    "creepyeyes",
    "shadowskittish",
    "shadowwatcher",
    "shadowhand",
    "stagehand",
    "tumbleweedspawner",
    "meteorspawner",
    "dragonfly_spawner",
    "moose",
    "mossling",
    "bearger",
    "dragonfly",
    "chester",
    "grassgekko",
    "petrify_announce",
    "moonbase",
    "moonrock_pieces",
    "shadow_rook",
    "shadow_knight",
    "shadow_bishop",
    "beequeenhive",
    "klaus_sack",
    "antlion_spawner",
    "oasislake",
    "succulent_plant",
	"fish", -- the old fish, keeping this here for mod support
}


local function common_postinit(inst)
    --Add waves
    inst.entity:AddWaveComponent()
    inst.WaveComponent:SetWaveParams(13.5, 2.5)
    inst.WaveComponent:SetWaveSize(80, 3.5)
    inst.WaveComponent:SetWaveTexture("images/wave_shadow.tex")
    --See source\game\components\WaveRegion.h
    inst.WaveComponent:SetWaveEffect("shaders/waves.ksh")

    --Initialize lua components
    inst:AddComponent("ambientlighting")

    inst.Map:SetUndergroundFadeHeight(5)

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        inst:AddComponent("dynamicmusic")
        inst:AddComponent("ambientsound")
        inst:AddComponent("dsp")
        inst:AddComponent("colourcube")
        inst:AddComponent("hallucinations")
    end
end

local function master_postinit(inst)
    --Spawners
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")

    inst:AddComponent("shadowcreaturespawner")
    inst:AddComponent("shadowhandspawner")
end

return MakeWorld("battleroyale", prefabs, assets, common_postinit, master_postinit, {"battleroyale"})

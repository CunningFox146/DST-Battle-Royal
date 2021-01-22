require("prefabs/world")
require("br/constants")

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
    Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/lunacy_regular_cc.tex"), -- So cc won't crash

    Asset("ANIM", "anim/lightning.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
    Asset("SOUND", "sound/amb_stream.fsb"),    
    Asset("SOUND", "sound/turnoftides_music.fsb"),
    Asset("SOUND", "sound/turnoftides_amb.fsb"),

    Asset("IMAGE", "images/wave_shadow.tex"),
}

local prefabs =
{
    "battleroyale_network",
    "battleroyale_spawnpoint",
}

for _, defs in pairs(BATTLE_ROYALE_MAP_DEFS) do
    for _, prefs in pairs(defs) do
        for _, pref in ipairs(prefs) do
            table.insert(prefabs, pref)
        end
    end
end

-- Fox: Since we don't have weather component, but we have lightning
local LIGHTNINGSTRIKE_CANT_TAGS = { "playerghost", "INLIMBO" }
local LIGHTNINGSTRIKE_ONEOF_TAGS = { "lightningrod", "lightningtarget" }
local function OnSendLightningStrike(src, pos)
    local target = nil
    local isrod = false
    local mindistsq = nil
    local pos0 = pos

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 40, nil, LIGHTNINGSTRIKE_CANT_TAGS, LIGHTNINGSTRIKE_ONEOF_TAGS)
    for k, v in pairs(ents) do
        local visrod = v:HasTag("lightningrod")
        local vpos = v:GetPosition()
        local vdistsq = distsq(pos0.x, pos0.z, vpos.x, vpos.z)
        --First, check if we're a valid target:
        --rods are always valid
        --playerlightning target is valid by chance (when not invincible)
        if (visrod or
            (   (v.components.health == nil or not v.components.health:IsInvincible()) and
                (v.components.playerlightningtarget == nil or math.random() <= v.components.playerlightningtarget:GetHitChance())
            ))
            --Now check for better match
            and (target == nil or
                (visrod and not isrod) or
                (visrod == isrod and vdistsq < mindistsq)) then
            target = v
            isrod = visrod
            pos = vpos
            mindistsq = vdistsq
        end
    end

    if isrod then
        target:PushEvent("lightningstrike")
    else
        if target and target.components.playerlightningtarget then
            target.components.playerlightningtarget:DoStrike()
        end
        
        for k, v in pairs(TheSim:FindEntities(pos.x, pos.y, pos.z, 3, nil, {"player", "INLIMBO"})) do
            if v.components.burnable then
                v.components.burnable:Ignite()
            end
        end
    end

    SpawnAt("lightning", pos)
end

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

    inst:AddComponent("br_progress")

    inst:AddComponent("battleroyale_statistics")
    inst:AddComponent("battleroyale")

    inst:ListenForEvent("ms_sendlightningstrike", OnSendLightningStrike)

    local progress = TheWorld.components.br_progress
    inst:ListenForEvent("player_won", function(inst, id)
        progress:PlayerWon(id)
    end)
end

return MakeWorld("battleroyale", prefabs, assets, common_postinit, master_postinit, {"battleroyale"})

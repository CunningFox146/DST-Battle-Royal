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
    Asset("ANIM", "anim/snow.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
    Asset("SOUND", "sound/amb_stream.fsb"),    
    Asset("SOUND", "sound/turnoftides_music.fsb"),
    Asset("SOUND", "sound/turnoftides_amb.fsb"),

    Asset("IMAGE", "images/wave_shadow.tex"),
    Asset("IMAGE", "levels/textures/snow.tex"),
    
}

local prefabs =
{
    "battleroyale_network",
    "battleroyale_spawnpoint",
}

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

local function SetGroundOverlay(world)
	world.Map:SetOverlayTexture("levels/textures/snow.tex")
	world.Map:SetOverlayColor0( 1, 1, 1, 1 )
	world.Map:SetOverlayColor1( 1, 1, 1, 1 )
	world.Map:SetOverlayColor2( 1, 1, 1, 1 )
    world.Map:SetOverlayLerp(1)
end

local function OnPlayerActivated(inst, player)
	if inst._snowfx then
		inst._snowfx.entity:SetParent(player.entity)
		inst._snowfx.particles_per_tick = 3
		inst._snowfx:PostInit()
	end
end

local function OnPlayerDeactivated(inst, player)
	if inst._snowfx then
		inst._snowfx.entity:SetParent(nil)
	end
end

local function Init(inst)
    local map = inst.net and inst.net.components.battleroyale_network:GetMap() or BATTLE_ROYALE_MAPS.CLASSIC
    local OVERRIDES = BATTLE_ROYALE_OVERRIDES[map]

    if not OVERRIDES then
        return
    end

    if OVERRIDES.iswinter then
        inst:PushEvent("seasontick", {
            season = "winter",
            elapseddaysinseason = 100,
            remainingdaysinseason = 100,
            progress = 0.5,
        })
        inst:PushEvent("weathertick", {
            moisture = 1,
            pop = 0,
            precipitationrate = 0,
            snowlevel = 0.2,
            wetness = 0,
            light = 1,
        })
        inst:PushEvent("precipitationchanged", "snow")
        inst:PushEvent("snowcoveredchanged", true)
        inst:PushEvent("temperaturetick", -5)

        SetGroundOverlay(inst)

        if not TheNet:IsDedicated() then
            inst._snowfx = SpawnPrefab("snow")
            inst._snowfx.particles_per_tick = 0
            
            inst:ListenForEvent("playeractivated", OnPlayerActivated, inst)
            inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, inst)
        end
    
        if OVERRIDES.isnight then
            inst:PushEvent("phasechanged", "night")
            inst:PushEvent("overrideambientlighting", Point(0, 0, 0))
        end
    end
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

    inst:DoTaskInTime(0, Init)
end

local function master_postinit(inst)
    --Spawners
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
    inst:AddComponent("shadowcreaturespawner")

    inst:AddComponent("br_progress")
    inst:AddComponent("battleroyale_statistics")
    inst:AddComponent("poisonmanager")
    inst:AddComponent("battleroyale")

    inst:ListenForEvent("ms_sendlightningstrike", OnSendLightningStrike)
end

return MakeWorld("battleroyale", JoinArrays(PREFABS_TO_LOAD, prefabs), assets, common_postinit, master_postinit, {"battleroyale"})

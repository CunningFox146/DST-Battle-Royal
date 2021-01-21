local env = env
GLOBAL.setfenv(1, GLOBAL)

if not env.MODROOT:find("workshop-") then
    CHEATS_ENABLED = true
    NetworkProxy.GetPVPEnabled = function() return true end
end

require("br/util")
require("br/strings")

env.modimport("scripts/br/recipes.lua")
env.modimport("scripts/br/ui.lua")
env.modimport("scripts/br/level_util.lua")

env.AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent("character_unlocker")
    TheWorld.character_unlocker = inst.components.character_unlocker
    
    inst:AddComponent("br_level_manager")
    inst:AddComponent("worldcharacterselectlobby")
end)

env.AddPrefabPostInit("forest", function(inst)
    inst:RemoveComponent("wavemanager")

    inst.Map:SetTransparentOcean(false)
    inst.Map:SetUndergroundFadeHeight(5)

    inst.WaveComponent:SetWaveParams(13.5, 2.5)
end)

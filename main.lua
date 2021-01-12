local env = env
GLOBAL.setfenv(1, GLOBAL)

CHEATS_ENABLED = true

require("constants")

env.AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent("character_unlocker")
    TheWorld.character_unlocker = inst.components.character_unlocker
end)

--https://discord.gg/wyEpdfBaKv
-- Lock characters from lobby
local _IsCharacterOwned = IsCharacterOwned
IsCharacterOwned = function(character, ...)
    print("IsCharacterOwned", CalledFrom())
    if TheWorld and TheWorld.character_unlocker and
    TheWorld.character_unlocker:IsLocked(TheNet:GetUserID(), character) then
        print("TheWorld != null")
        return false
    end
    return _IsCharacterOwned(character, ...)
end

if not TheNet:GetIsServer() then
    return
end

-- Despawn those who chose locked chars
local _SpawnNewPlayerOnServerFromSim = SpawnNewPlayerOnServerFromSim
SpawnNewPlayerOnServerFromSim = function(guid, ...)
    local player = Ents[guid]
    local char_unlocker = TheWorld and TheWorld.character_unlocker
    if char_unlocker and player and
    player.userid and player.prefab then
        if char_unlocker:IsLocked(player.userid, player.prefab) then
            player:DoTaskInTime(0, function(inst)
                TheWorld:PushEvent("ms_playerdespawnanddelete", player)
            end)
        end
    end
    return _SpawnNewPlayerOnServerFromSim(guid, ...)
end
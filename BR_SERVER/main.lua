local env = env
GLOBAL.setfenv(1, GLOBAL)

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

env.AddPrefabPostInit("world", function(inst)
    inst:AddComponent("br_progress")
end)

env.AddPlayerPostInit(function(inst)
    local progress = TheWorld.components.br_progress

    inst:ListenForEvent("death", function(inst, data)
        print("data.afflicter", data.afflicter)

        progress:AddDeath(inst.userid)

        if not data or not data.afflicter or not data.afflicter.userid then
            return
        end
        progress:AddDeath(data.afflicter.userid)
    end)
end)

env.modimport "scripts/character_fix.lua"
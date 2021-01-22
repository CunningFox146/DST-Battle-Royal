local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddComponentPostInit("playerspawner", function(self)
    local spawnpoints = {}
    local _masterpt = nil
    local currentspawnpoint = 0
    local worldcharacterselectlobby = TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby

    local function GetMasterPos()
        return _masterpt and _masterpt.Transform:GetWorldPosition() or 0, 0, 0
    end

    -- printwrap("", spawnpoints)
    rawset(_G, "spawnpoints", spawnpoints)

    local function GetNextSpawnPosition()
        print("GetNextSpawnPosition", CalledFrom())
        if worldcharacterselectlobby and worldcharacterselectlobby:SpectatorsEnabled() then
            return GetMasterPos()
        end

        currentspawnpoint = currentspawnpoint + 1

        if spawnpoints[currentspawnpoint] then
            return spawnpoints[currentspawnpoint].Transform:GetWorldPosition()
        end

        return GetMasterPos()
    end

    function self:SpawnAtNextLocation(inst, player)
        local x, y, z = GetNextSpawnPosition()
        self:SpawnAtLocation(inst, player, x, y, z)
    end

    function self:BR_RegisterPoint(point)
        if not table.contains(spawnpoints, point) then
            table.insert(spawnpoints, point)
        end
    end

    self.inst:ListenForEvent("ms_register_br_spawnpoint", function(_, point) self:BR_RegisterPoint(point) end)

    local function OnRegisterSpawnPoint(inst, spawnpt)
        if _masterpt == nil and spawnpt.master then
            _masterpt = spawnpt
        end
    end
end)

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

env.AddPlayerPostInit(function(inst)
    local progress = TheWorld.components.br_progress

    inst:ListenForEvent("death", function(inst, data)
        progress:AddDeath(inst.userid)

        if not data or not data.afflicter or not data.afflicter.userid then
            return
        end
        progress:AddKill(data.afflicter.userid)
    end)
end)

env.modimport "scripts/br/character_fix.lua"
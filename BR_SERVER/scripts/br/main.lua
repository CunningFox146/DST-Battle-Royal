local env = env
GLOBAL.setfenv(1, GLOBAL)

require("components/battleroyale_statistics")

require("br/tuning")

local server_states = require("br/sg_server")
for i, state in ipairs(server_states) do
	env.AddStategraphState("wilson", state)
end

env.AddComponentPostInit("playerspawner", function(self)
    local spawnpoints = {}
    local currentspawnpoints = {}

    local function GetMasterPos()
        return self.inst.components.battleroyale:GetCenter():Get()
    end

    local function GetNextSpawnPosition()
        local worldcharacterselectlobby = TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby
        if worldcharacterselectlobby and worldcharacterselectlobby:SpectatorsEnabled() then
            return GetMasterPos()
        end

        if not next(currentspawnpoints) then
            currentspawnpoints = shallowcopy(spawnpoints)
        end

        local pt = GetRandomItem(currentspawnpoints)
        local x, _, z = pt.Transform:GetWorldPosition()
        RemoveByValue(currentspawnpoints, pt)
        return x, TUNING.BATTLE_ROYALE.SPAWN_HEIGHT, z
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

    local function OnNewPlayer(_, data)
		if not data or not data.player then
			return
        end
        data.player:BR_OnNewSpawn()
    end
    
    self.inst:ListenForEvent("ms_register_br_spawnpoint", function(_, point) self:BR_RegisterPoint(point) end)
    self.inst:ListenForEvent("ms_newplayercharacterspawned", OnNewPlayer)
end)

env.AddComponentPostInit("birdspawner", function(self)
    local _map = TheWorld.Map
    local _groundcreep = TheWorld.GroundCreep
    
    function self:GetSpawnPoint(pt)
        --We have to use custom test function because birds can't land on creep
        local function TestSpawnPoint(offset)
            local spawnpoint = pt + offset
            local tile = self.inst.Map:GetTileAtPoint(spawnpoint:Get())
            return _map:IsPassableAtPoint(spawnpoint:Get()) and 
                   not _groundcreep:OnCreep(spawnpoint:Get()) and 
                   not next(TheSim:FindEntities(spawnpoint.x, 0, spawnpoint.z, 4, { "birdblocker" })) and
                   tile ~= GROUND.IMPASSABLE
        end
    
        local theta = math.random() * 2 * PI
        local radius = 6 + math.random() * 6
        local resultoffset = FindValidPositionByFan(theta, radius, 12, TestSpawnPoint)
    
        if resultoffset ~= nil then
            return pt + resultoffset
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

env.AddComponentPostInit("health", function(self)
    self.inst:ListenForEvent("healthdelta", function(inst, data)
		if not data or not data.afflicter or
		type(data.afflicter) ~= "table" or not data.afflicter:IsValid() or not
		data.afflicter:HasTag("player") then
			return
		end
		
		data.afflicter:PushEvent("applied_damage", {target = inst, amount = math.abs(data.amount), other = data})
	end)
end)

do
    local function OnDeath(inst, data)
        TheWorld.components.battleroyale:PlayerDied(inst, data)
    end

    local function OnBecameGhost(inst)
        inst:BecomeSpectator()
    end

    local function PvPSlowdown(inst, seconds, percent)
        if inst and (inst.components.rider and not inst.components.rider:IsRiding()) and 
        inst.components.debuffable and inst.components.debuffable:IsEnabled() and not inst.spectator then
            inst.components.debuffable:AddDebuff("debuff_pvp", "debuff_pvp")
        end
    end

    local function OnAppliedDamage(inst, data)
        if data then
            if data.target.userid then
                UpdateStat(data.target.userid, "damage", data.amount)
            end

            PvPSlowdown(data.target)
            
            local num = SpawnPrefab("damagenumber")
            num.entity:SetParent(inst.entity)
            num.Network:SetClassifiedTarget(inst)
            num:Set(data.target, math.floor(data.amount + 0.5))
        end
    end

    local function BecomeSpectator(inst)
        inst.spectator = true
        if inst.player_classified then
            if not inst:HasTag("playerghost") then
                inst.player_classified:DoTaskInTime(0.25, function(classified)
                    classified.isspectator:set(true)
                end)
            else
                inst.player_classified.isspectator:set(true)
            end
        end
        FullyHidePlayer(inst)
    end

    local function BR_OnNewSpawn(inst)
        local worldcharacterselectlobby = TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby
        if worldcharacterselectlobby and worldcharacterselectlobby:SpectatorsEnabled() then
            inst:BecomeSpectator()
        else
            inst.sg:GoToState("spawn_on_arena")
        end
    end

    env.AddPlayerPostInit(function(inst)
        for pref, count in pairs(BATTLE_ROYALE_STARTING_INVENTORY[TheMapSaver:GetMap()]) do
            for i = 1, count do
                table.insert(inst.starting_inventory, pref)
            end
        end

        inst:AddComponent("br_poisonable")
        inst:AddComponent("spectator")

        if inst.components.combat then
			inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.NEVER)
		end

        inst.BecomeSpectator = BecomeSpectator
        inst.BR_OnNewSpawn = BR_OnNewSpawn
        
        inst:ListenForEvent("death", OnDeath)
        inst:ListenForEvent("ms_becameghost", OnBecameGhost)
        inst:ListenForEvent("applied_damage", OnAppliedDamage)

        local _ShowHUD = inst.ShowHUD
        function inst:ShowHUD(show, ...)
            if show and inst.spectator then
                return true
            end
            return _ShowHUD(inst, show, ...)
        end
    end)
end

env.modimport "scripts/br/character_fix.lua"
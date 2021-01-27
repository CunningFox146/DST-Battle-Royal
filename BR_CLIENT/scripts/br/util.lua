require("constants")

function SetDirty(netvar, val) --Forces a netvar to be dirty regardless of value
    netvar:set_local(val)
    netvar:set(val)
end

function GetPlayersClientTable()
    local clients = TheNet:GetClientTable() or {}
    if not TheNet:GetServerIsClientHosted() then
		for i, v in ipairs(clients) do
			if v.performance ~= nil then
				table.remove(clients, i) -- remove "host" object
				break
			end
		end
    end
    return clients
end

function GetPlayerById(id)
	for _, player in ipairs(AllPlayers) do
		if player.userid == id then
			return player
		end
	end
end

function GetIsPlaying(id)
	local player = GetPlayerById(id)
	return player and not player.spectator or false
end

function BR_LockedCharacter(character)
    return TheWorld and TheWorld.character_unlocker and TheWorld.character_unlocker:IsLocked(TheNet:GetUserID(), character)
end

-- Lock characters from lobby
local _IsCharacterOwned = IsCharacterOwned
IsCharacterOwned = function(character, ...)
    if BR_LockedCharacter(character) then
        return false
    end
    return _IsCharacterOwned(character, ...)
end

function FullyHidePlayer(inst)
    inst:Hide()
	inst._mass = inst.Physics:GetMass() or 75
	
	inst.AnimState:SetErosionParams(1, 0.1, 1.0)
	inst.AnimState:SetScale(0, 0, 0)
	inst.DynamicShadow:Enable(false)
	inst.MiniMapEntity:SetEnabled(false)
	inst.SoundEmitter:SetMute(true)
    inst.Light:Enable(false)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	
	inst:AddTag("noplayerindicator")
	inst:AddTag("noattack")
	inst:AddTag("invisible")
	
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "dead", 0)
    inst.components.talker:IgnoreAll("spectator")
	
	if inst.components.petleash then
		inst.components.petleash:DespawnAllPets()
	end
	
	if inst.components.sanity then
		inst.components.sanity.ignore = false
		inst.components.sanity:SetPercent(1, true) 
		inst.components.sanity.ignore = true
	end
	
	if not inst.components.health:IsDead() then
		inst.components.health.invincible = true
		
		inst:AddTag("ignoretalking")
		
		if inst.components.frostybreather then
			inst.components.frostybreather:Disable()
		end
	end
end

function FullyShowPlayer(inst, wasalive)
	inst:Show()
    
    if not wasalive then
		inst.components.sanity:SetPercent(.75)
		inst.components.health:SetPercent(.75)
	end

	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dead")
    inst.components.talker:StopIgnoringAll("spectator")
	
	inst:RemoveTag("noplayerindicator")
	inst:RemoveTag("noattack")
	inst:RemoveTag("invisible")
	
	inst.DynamicShadow:Enable(true)
	inst.MiniMapEntity:SetEnabled(true)
    inst.SoundEmitter:SetMute(false)
    inst.AnimState:SetScale(1, 1, 1)
    inst.AnimState:SetErosionParams(0, 0, 0)
	
	local x, y, z = inst.Transform:GetWorldPosition()
	
	inst.Physics:ClearCollisionMask()
	MakeCharacterPhysics(inst, inst._mass, .5)
    inst.Physics:Teleport(x, 0, z)
end

if CHEATS_ENABLED then
	function r()
		local owner = ThePlayer
		if not (owner and owner.player_classified and owner.player_classified.MapExplorer
		and owner.player_classified.MapExplorer.RevealArea) then
			return
		end
		for x=-1600,1600,35 do
			for y=-1600,1600,35 do
				owner.player_classified.MapExplorer:RevealArea(x,0,y)
			end
		end
	end

	local NAMES = {
		"Starve gay",
		"Gimme love",
		"Foxy the pirate fox",
		"Hornet",
		"AntonRey",
		"Mufasa",
		"Sbruh",
	}

	local dummies = {}

	function spp(pref, noname)
		local player = c_spawn(pref or DST_CHARACTERLIST[math.random(1, #DST_CHARACTERLIST)])
		player.userid = tostring(math.random())
		if not noname then
			player.name = NAMES[math.random(1, #NAMES)]
		end
		table.insert(dummies, player)
		TheWorld.net.components.battleroyale_network:RebuildData()
		return player
	end

	local _GetPlayersClientTable = GetPlayersClientTable
	function GetPlayersClientTable()
		local data = _GetPlayersClientTable()

		if next(dummies) then
			local temp = data[1]
			for _, v in ipairs(dummies) do
				local thisdata = deepcopy(temp)
				if thisdata then
					thisdata.userid = v.userid
					thisdata.prefab = v.userid
					thisdata.name = temp.name
					table.insert(data, thisdata)
				end
			end
		end

		return data
	end
end
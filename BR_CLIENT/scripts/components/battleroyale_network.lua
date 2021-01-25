

local Network = Class(function(self, inst)
    self.inst = inst
    
    self._player_data = net_string(inst.GUID, "battleroyale_network._wxp", "battleroyale_playerdata_dirty")
    self._winner = net_entity(inst.GUID, "battleroyale_network._winner", "battleroyale_winner_dirty")
    self._map = net_tinybyte(inst.GUID, "battleroyale_network._map")

    self.ismastersim = TheWorld.ismastersim
	
    if not TheNet:IsDedicated() then
        self.participating = {}
        
        local function UpdateWinner() self:UpdateWinner() end
        local function UpdatePlayerData() self:UpdatePlayerData() end

        self.inst:ListenForEvent("battleroyale_playerdata_dirty", UpdatePlayerData)
        self.inst:ListenForEvent("battleroyale_winner_dirty", UpdateWinner)

        self.inst:DoTaskInTime(0, UpdateWinner)
        self.inst:DoTaskInTime(0, UpdatePlayerData)
    end
    
    if self.ismastersim then
        self.cached_ranks = {}
        self:Init()
    end
end)

function Network:Init()
    self:SetMap(TheMapSaver:GetMap())
    
    local rebuild = function() self:RebuildData() end

    self.inst:ListenForEvent("ms_clientauthenticationcomplete", rebuild, TheWorld)
    self.inst:ListenForEvent("ranks_changed", rebuild, TheWorld)
    self.inst:DoTaskInTime(0, rebuild)
end

function Network:UpdateWinner()
    local winner = self._winner:value()
    if winner and ThePlayer then
        ThePlayer.HUD:ShowReduxTitle(string.format(STRINGS.BATTLE_ROYALE.WIN_TITLE.TITLE, winner.name), STRINGS.BATTLE_ROYALE.WIN_TITLE.BODY)
    end
end

function Network:SetWinner(winner)
    self._winner:set(winner)
end

function Network:SetMap(map)
    self._map:set(map)
end

function Network:GetMap()
    return self._map:value()
end

function Network:RebuildData()
    local player_data = {}
    for _, data in pairs(GetPlayersClientTable()) do
        -- Fox: data format is (1: rank, 2: alive)
        player_data[data.userid] = {
            self:GetWxp(data.userid),
            GetIsPlaying(data.userid),
        }
    end
	self._player_data:set(json.encode(player_data))
end

function Network:UpdatePlayerData()
    self.data = json.decode(self._player_data:value())
    for id, data in pairs(self.data) do
        if data[2] then
            table.insert(self.participating, id)
        end
    end
    table.sort(self.participating) -- Fox: So we always have mostly same layout for spectators
	TheGlobalInstance:PushEvent("player_data_update", self.data)
end

function Network:GetParticipators()
    return self.participating or {}
end

function Network:GetWxp(id)
	if self.ismastersim then
		return TheWorld.components.br_progress:GetWxp(id)
	end
	return self.data[id] and (self.data[id][1] or 1) or 1
end

return Network

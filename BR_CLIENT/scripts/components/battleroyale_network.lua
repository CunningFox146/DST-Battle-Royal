local Network = Class(function(self, inst)
    self.inst = inst
    
    self._wxp = net_string(inst.GUID, "battleroyale_network._wxp", "battleroyale_wxp_dirty")
    self._winner = net_entity(inst.GUID, "battleroyale_network._winner", "battleroyale_winner_dirty")
    self._map = net_tinybyte(inst.GUID, "battleroyale_network._map")

    self.ismastersim = TheWorld.ismastersim
	
    if not TheNet:IsDedicated() then
        self.wxp = {}
        
        local function UpdateWinner() self:UpdateWinner() end
        local function UpdateWxp() self:UpdateWxp() end

        self.inst:ListenForEvent("battleroyale_wxp_dirty", UpdateWxp)
        self.inst:ListenForEvent("battleroyale_winner_dirty", UpdateWinner)

        self.inst:DoTaskInTime(0, UpdateWinner)
        self.inst:DoTaskInTime(0, UpdateWxp)
    end
    
    if self.ismastersim then
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
        ThePlayer.HUD:ShowReduxTitle(winner.name .. " won!", "The match will restart in a moment.")
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
	local levels = {}
	for _, data in ipairs(TheNet:GetClientTable()) do
		local rank = self:GetWxp(data.userid)
		if rank > 0 then
			levels[data.userid] = rank
		end
	end
	self._wxp:set(DataDumper(levels))
end

function Network:UpdateWxp()
	self.data = loadstring(self._wxp:value())()
	TheWorld:PushEvent("ms_leveldataupdated", self.data)
end

function Network:GetWxp(id)
	if self.ismastersim then
		return TheWorld.components.br_progress:GetWxp(id)
	end
	return self.data[id] or 0
end

return Network

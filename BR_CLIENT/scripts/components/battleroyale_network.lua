local Network = Class(function(self, inst)
    self.inst = inst
	
    self._winner = net_entity(inst.GUID, "battleroyale_network._winner", "battleroyale_winner_dirty")
    self._map = net_tinybyte(inst.GUID, "battleroyale_network._map")
	
    if not TheNet:IsDedicated() then
        local function UpdateWinner() self:UpdateWinner() end
        self.inst:ListenForEvent("battleroyale_winner_dirty", UpdateWinner)
        self.inst:DoTaskInTime(0, UpdateWinner) -- Fox: Maybe we just joined and a winner already is announced?
    end
    
    if TheWorld.ismastersim then
        self:Init()
    end
end)

function Network:Init()
    self:SetMap(TheMapSaver:GetMap())
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

return Network

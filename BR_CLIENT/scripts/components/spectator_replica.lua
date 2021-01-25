local function UpdateUI(player)
	if player and player.HUD then
		player.HUD.controls.hg_spectator_wgt:Update()
	end
end

local Spectator = Class(function(self, inst)
    self.inst = inst
	
	if not TheNet:IsDedicated() then
		self:AttachClassified(inst.player_classified)
		
		self._players = {}
		self.count = 0
		self.selected =
		{
			id = nil,
			index = 0,
		}
		
		if self.inst == ThePlayer then
			local function UpdateData()
				local net = TheWorld.net and TheWorld.net.components.battleroyale_network
				if net then
					self:UpdateData(net:GetParticipators())
				end
			end

			self.inst:DoTaskInTime(0, UpdateData)
			self.inst:ListenForEvent("player_data_update", UpdateData, TheGlobalInstance)
		end
	else
		self.classified = inst.player_classified
	end	
end)

function Spectator:Update()
	local target = self:GetTarget()
	
	if self.inst.HUD then
		self.inst.HUD.controls.hg_spectator_wgt:SetTarget(target)
	end
	
	if not target then
		self.selected =
		{
			id = nil,
			index = 0,
		}
		UpdateUI(self.inst)
	end
	
	if TheFocalPoint then
		TheFocalPoint.components.focalpoint:StopFocusSource(self, "spectator")
		if target then
			TheFocalPoint.components.focalpoint:StartFocusSource(self, "spectator", target, 999, 999, 5)
		end
	end
end

function Spectator:UpdateData(data)
	printwrap("UpdateData", data)
	self._players = {}
	self.count = #data
	
	if #data > 0 then
		for i, id in ipairs(data) do
			self._players[id] = i
		end
	end
	if self.selected.id then
		local newindex = self._players[self.selected.id]
		if newindex then
			self.selected.index = newindex
		else
			self.selected =
			{
				id = nil,
				index = 0,
			}
		end
	end
	
	UpdateUI(self.inst)
end

local function GetId(tbl, val)
	for i, v in pairs(tbl) do
		if v == val then
			return i
		end
	end
end

function Spectator:RequestNewTarget(delta)
	local current = self.selected.index
	local new = math.clamp(current + delta, 1, self.count)
	if new == current then
		return
	end
	
	local id = GetId(self._players, new)
	if id then
		self.selected.index = new
		self.selected.id = id
		
		UpdateUI(self.inst)
		
		SendModRPCToServer(MOD_RPC.BATTLE_ROYALE.SPECTRATE, self.selected.id)
	end
end

function Spectator:SetTarget(target, force)
	if not self.classified then
		return
	end
	if force then
		self.classified.spectator.target:set_local(target)
	end
	self.classified.spectator.target:set(target)
end

function Spectator:GetTarget()
	return self.classified and self.classified.spectator.target:value() or nil
end

function Spectator:AddSpectator()
	if self.classified then
		self.classified.spectator.spectators:set(self.classified.spectator.spectators:value() + 1)
	end
end

function Spectator:RemoveSpectator()
	if self.classified then
		self.classified.spectator.spectators:set(math.max(self.classified.spectator.spectators:value() - 1, 0))
	end
end

function Spectator:GetSpectatorsAmount()
	return self.classified and self.classified.spectator.spectators:value() or 0
end

function Spectator:UpdateCount()
	TheGlobalInstance:PushEvent("spect_amount_delta", self:GetSpectatorsAmount())
end

function Spectator:AttachClassified(classified)
	if not classified then
		return
	end

    self.classified = classified
	
	self.ontarget = function()
		self:Update()
	end
	
	self.oncount = function()
		self:UpdateCount()
	end
	
    self.ondetachclassified = function() self:DetachClassified() end
	
	self.inst:ListenForEvent("spect_target_dirty", self.ontarget, classified)
	self.inst:ListenForEvent("spect_amount_dirty", self.oncount, classified)
	self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Spectator:DetachClassified()
	self.inst:RemoveEventCallback("inpoisondirty", self.ontarget, self.classified)
	self.inst:RemoveEventCallback("spect_amount_dirty", self.oncount, self.classified)
	self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
	
    self.classified = nil
    self.ontarget = nil
    self.oncount = nil
    self.ondetachclassified = nil
end

function Spectator:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Spectator.OnRemoveEntity = Spectator.OnRemoveFromEntity

return Spectator

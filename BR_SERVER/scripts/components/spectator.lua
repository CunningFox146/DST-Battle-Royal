local function OnRez(inst)
	local self = inst.components.spectator
	
	self:SetTarget(nil)
	inst:StopUpdatingComponent(self)
end

local function TargetRes(inst)
	-- self.inst.replica.spectator:RemoveSpectator()
	self:SetTarget(nil)
end

local function ontarget(self, val)
	self.inst.replica.spectator:SetTarget(val)
	self:OnUpdate(0)
end

local function RemoveSpectator(inst)
	local target = inst.components.spectator.target
	if target and target.replica and target.replica.spectator then
		target.replica.spectator:RemoveSpectator()
	end
end

local Spectator = Class(function(self, inst)
    self.inst = inst
    self.active = false
	self.target = nil
	
	self.period = 2
	self.current = 0
	
	self.ondeath = function(target)
		if target == self.target then
			self:SetTarget(nil)
		end
	end
	self.forceupdate = function(target) self:ForceUpdate() end
	
	inst:ListenForEvent("ms_respawnedfromghost", OnRez)
end,
nil,
{
	target = ontarget
})

function Spectator:SetTarget(target)
	if target == self.inst or (target ~= nil and target.spectator) then
		return
	end
	
	if target then
		if self.target then
			self.inst:RemoveEventCallback("onremove", RemoveSpectator)
			if self.target.replica and self.target.replica.spectator then
				self.target.replica.spectator:RemoveSpectator()
			end
		end
		
		self.active = true
		self.target = target
		if self.target.replica and self.target.replica.spectator then
			self.target.replica.spectator:AddSpectator()
		end
		
		-- If player teleports then we want to teleport after them
		if target.player_classified then
			self.inst:ListenForEvent("playercamerasnap", self.forceupdate, target.player_classified)
		end
		self.inst:ListenForEvent("onremove", RemoveSpectator)
		self.inst:ListenForEvent("ms_becameghost", self.ondeath, target)
		self.inst:StartUpdatingComponent(self)
	else
		if self.target then
			if self.target.player_classified then
				self.inst:RemoveEventCallback("playercamerasnap", self.forceupdate, self.target.player_classified)
			end
			self.inst:RemoveEventCallback("ms_becameghost", self.ondeath, self.target)
			if self.target.replica and self.target.replica.spectator then
				self.target.replica.spectator:RemoveSpectator()
			end
			self.inst:RemoveEventCallback("onremove", RemoveSpectator)
		end
		
		self.target = nil
		self.active = false
		self.inst:StopUpdatingComponent(self)
	end
end

function Spectator:OnUpdate(dt)
	if not self.target or not self.target:IsValid() or not self.active then
		self.inst:StopUpdatingComponent(self)
		return
	end
	
	if dt ~= 0 and self.current < self.period then
		self.current = self.current + dt
		return
	end
	self.current = 0
	
	local x, y, z = self.target.Transform:GetWorldPosition()
	
	if not x or not z then
		return
	end
	
	if self.inst.Physics then
		self.inst.Physics:Teleport(x, 0, z)
	else
		self.inst.Transform:SetPosition(x, 0, z)
	end
end

function Spectator:ForceUpdate()
	if self.active and self.target then
		self:OnUpdate(0)
		self.inst.replica.spectator:SetTarget(self.target, true)
	end
end

function Spectator:OnRemoveFromEntity()
	self.active = false
	self:SetTarget(nil)
	self.inst:StopUpdatingComponent(self)
end

Spectator.OnRemoveEntity = Spectator.OnRemoveFromEntity

return Spectator

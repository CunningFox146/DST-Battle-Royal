local PoisonFog = Class(function(self, inst)
	self.inst = inst
    
    self.update_period = 0.15
    self.task = nil

    self.center = nil

    self.manager = TheWorld.components.poisonmanager

	self:StartUpdating()
end)

function PoisonFog:StartUpdating()
    if self.task then
        return
    end

    self.task = self.inst:DoPeriodicTask(self.update_period, function() self:OnUpdate(self.update_period) end)
end

local function ApplyDebuff(inst)
    if not inst or not inst:IsValid() then
        return
    end

    if inst.components.debuffable and inst.components.debuffable:IsEnabled() and not inst.spectator and
    not inst.components.debuffable:HasDebuff("debuff_lunar") then
        inst.components.debuffable:AddDebuff("debuff_lunar", "debuff_lunar")
    end

    if inst.player_classified then
        inst.player_classified.infog:set(true)
    end
end

local function RemoveDebuff(inst)
    if not inst or not inst:IsValid() then
        return
    end

    if inst.components.debuffable then
        inst.components.debuffable:RemoveDebuff("debuff_lunar")
    end

    -- Fox: So even if we're dead we get screen fx while spectating
    if inst.player_classified then
        inst.player_classified.infog:set(false)
    end
end

function PoisonFog:OnUpdate(dt)
    local range_sq = self.manager:GetRange()
    if not range_sq then -- Fox: We're not using fog yet!
        return
    end
    range_sq = range_sq * range_sq

    local x, _, z = self.inst.Transform:GetWorldPosition()

    if not self.center then
        self.center = TheWorld.components.battleroyale:GetCenter()
    end

    local dist_sq = distsq(x, z, self.center.x, self.center.z)
    if dist_sq >= range_sq then
        ApplyDebuff(self.inst)
    else
        RemoveDebuff(self.inst)
    end
end

return PoisonFog

local Widget = require "widgets/widget"
local Text = require "widgets/fadeable_text"
local UIAnim = require "widgets/uianim"

local SpectatorEye = Class(Widget, function(self, owner)
    Widget._ctor(self, "SpectatorEye")

    self.owner = owner
	self.max = function() return 2.5 + math.random() * 5 end
	self.count = 0
	
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetScale(0)
	
	self.eye = self.root:AddChild(UIAnim())
	self.eye:SetScale(.45)
	self.anim = self.eye:GetAnimState()
	self.anim:SetBank("spectator_eye")
	self.anim:SetBuild("spectator_eye")
	self.anim:PlayAnimation("idle")
	
	self.amnt = self.root:AddChild(Text(UIFONT, 75, "0"))
	self.amnt:SetPosition(75, 0)
	
	self:SetTooltip(STRINGS.BATTLE_ROYALE.UI.SPECTATORS_AMNT)
	self:SetTooltipPos(0, 15, 0)
	
	self:SetClickable(false)
	
	self.inst:ListenForEvent("spect_amount_delta", function(_, count) self:UpdateCount(count) end, TheGlobalInstance)
	self.inst:DoTaskInTime(0, function()
		self:UpdateCount(self.owner.replica.spectator:GetSpectatorsAmount() or 0)
	end)
end)

function SpectatorEye:UpdateCount(count)
	if count <= 0 then
		if self.count ~= 0 then
			self.root:ScaleTo(1, 0, .25, function() self:Hide() end)
			self:SetClickable(false)
		end
		self:StopBlinking()
	elseif self.count < 1 then
		self:SetClickable(true)
		self:Show()
		self.root:ScaleTo(0, 1, .25)
		self:StartBlinking()
	end
	self.count = count
	self.amnt:SetString(tostring(count))
end

function SpectatorEye:StartBlinking()
	if self.blink_task then
		return
	end
	
	local function DoBlink()
		self.anim:PlayAnimation("blink")
		self.anim:PushAnimation("idle")
		self.blink_task = self.inst:DoTaskInTime(self.max(), DoBlink)
	end
	DoBlink()
end

function SpectatorEye:StopBlinking()
	if self.blink_task then
		self.blink_task:Cancel()
		self.blink_task = nil
	end
end

return SpectatorEye

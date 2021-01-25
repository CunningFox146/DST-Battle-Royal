local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local TEMPLATES = require "widgets/redux/templates"

local SpectatorWgt = Class(Widget, function(self, owner)
	Widget._ctor(self, "SpectatorWgt")
	
	self.owner = owner
	
	self.count = 0
	self.index = 0
	
	self.str = ""
	
	self.leftimage = self:AddChild(ImageButton("images/global_redux.xml", "arrow2_left.tex", "arrow2_left_over.tex", "arrow_left_disabled.tex", "arrow2_left_down.tex", nil, {1,1}, {0,0}))
	self.rightimage = self:AddChild(ImageButton("images/global_redux.xml", "arrow2_right.tex", "arrow2_right_over.tex", "arrow_right_disabled.tex", "arrow2_right_down.tex", nil,{1,1}, {0,0}))
	self.leftimage:SetPosition(-200, 0)
	self.rightimage:SetPosition(200, 0)
	self.leftimage:SetScale(.6)
	self.rightimage:SetScale(.6)
	
	self.name = self:AddChild(Text(HEADERFONT, 40, STRINGS.BATTLE_ROYALE.UI.UNKNOWN, UICOLOURS.GREY))
	self.name:SetRegionSize(375, 250)
	
	local function RequestTraget(delta)
		if self.owner.replica and self.owner.replica.spectator then
			self.owner.replica.spectator:RequestNewTarget(delta)
		end
	end
	
	self.leftimage:SetOnClick(function()
		RequestTraget(-1)
	end)
	
	self.rightimage:SetOnClick(function()
		RequestTraget(1)
	end)
end)

function SpectatorWgt:SetTarget(target)
	if not target then
		self.name:SetColour(UICOLOURS.GREY)
		self.name:SetString(STRINGS.BATTLE_ROYALE.UI.UNKNOWN)
		return
	end
	
	self.str = target.name
	self.name:SetColour(UICOLOURS.GOLD)
	self.name:SetString(target.name)
end

function SpectatorWgt:Update()
	local spectator = self.owner.replica and self.owner.replica.spectator
	if not spectator then
		return
	end
	
	self.count = spectator.count
	self.index = spectator.selected.index
	
	if self.index == 0 then
		self.leftimage:Disable()
		if self.count == 0 then
			self.rightimage:Disable()
		else	
			self.rightimage:Enable()
		end
	elseif self.index == 1 then
		self.leftimage:Disable()
		if self.count > 1 then
			self.rightimage:Enable()
		else
			self.rightimage:Disable()
		end
	elseif self.index >= self.count then
		self.index = self.count
		self.leftimage:Enable()
		self.rightimage:Disable()
	else
		self.leftimage:Enable()
		self.rightimage:Enable()
	end
	
	-- Reset target. Just in case
	if self.index == 0 then
		self:SetTarget()
	end
end

return SpectatorWgt
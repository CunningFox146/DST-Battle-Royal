local Widget = require "widgets/widget"
local Text = require "widgets/fadeable_text"
local TEMPLATES = require "widgets/redux/templates"

local BLANK = {0, 0, 0, 0}

local TitleRedux = Class(Widget, function(self, owner, data)
    Widget._ctor(self, "EndOfMatchPopup")

    self.owner = owner

    self.proot = self:AddChild(Widget("ROOT"))
	self.proot:SetHAnchor(ANCHOR_MIDDLE)
	self.proot:SetVAnchor(ANCHOR_MIDDLE)
	self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.proot:SetPosition(0, -50)
	self.proot:MoveTo(self.proot:GetPosition(), Vector3(0, 0, 0), 0.5)
	
	local t = self.proot:AddChild(Text(TITLEFONT, 50, data.title))
	t:SetHAlign(ANCHOR_MIDDLE)
	t:SetPosition(0, 155) 
	t:SetColour(BLANK)
	t:FadeTo(BLANK, UICOLOURS.GOLD, 0.5)

	local body = self.proot:AddChild(Text(CHATFONT_OUTLINE, 20, data.body))
	body:SetHAlign(ANCHOR_MIDDLE)
	body:SetPosition(0, 120)
	body:SetColour(BLANK)
	body:FadeTo(BLANK, UICOLOURS.EGGSHELL, 0.5)

	if data.time then
		self.inst:DoTaskInTime(data.time, function()
			self.proot:MoveTo(self.proot:GetPosition(), Vector3(0, 50, 0), 0.5)
			body:FadeTo(UICOLOURS.EGGSHELL, BLANK, 0.5)
			t:FadeTo(UICOLOURS.GOLD, BLANK, 0.5, function()
				self:Kill()
			end)
		end)
	end
end)

return TitleRedux

local Widget = require "widgets/widget"
local Text = require "widgets/text"
local PlayerBadge = require "widgets/playerbadge"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"

local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"

local DEBUG = false

local max_display = 6
local item_width = 250
local button_offset = 250/2*max_display + 50

local MVPLoadingWidget = Class(Widget, function(self)
    Widget._ctor(self, "MVPLoadingWidget")

    self.list_root = self:AddChild(Widget("list_root"))
	self.buttons_root = self:AddChild(Widget("buttons_root"))
	self.buttons_root:SetPosition(0, -63)
	
	self.left_button = self.buttons_root:AddChild(ImageButton("images/global_redux.xml", "arrow2_left.tex", "arrow2_left_over.tex", "arrow_left_disabled.tex", "arrow2_left_down.tex"))
	self.right_button = self.buttons_root:AddChild(ImageButton("images/global_redux.xml", "arrow2_right.tex", "arrow2_right_over.tex", "arrow_right_disabled.tex", "arrow2_right_down.tex"))
	self.left_button:SetPosition(-button_offset, 0)
	self.right_button:SetPosition(button_offset, 0)
	
	self.left_button:SetOnClick(function() self:Offset(-1) end)
	self.right_button:SetOnClick(function() self:Offset(1) end)
	
	self.buttons_root:Hide()
	
	self.mvp_widgets = {}
	self.showing_items = nil
	
	self.offset = 1
	
    self.current_eventid = string.upper(TheNet:GetServerGameMode())
end)

local function UpdatePlayerListing(widget, data)
    local empty = data == nil or next(data) == nil

    widget.userid = not empty and data.user.userid or nil
    widget.performance = not empty and data.user.performance or nil
    
    if empty then
		widget.badge:Hide()
        widget.puppet:Hide()
    else
        local prefab = data.user.prefab or data.user.lobbycharacter or ""
        if prefab == "" then
			widget.badge:Set(prefab, DEFAULT_PLAYER_COLOUR, false, 0)
			widget.badge:Show()
			widget.puppet:Hide()
		else
			widget.badge:Hide()
			widget.puppet:SetSkins(prefab, data.user.base, data.user, true)
			widget.puppet:SetBackground(data.user.portrait)
			widget.puppet:Show()
		end
    end

    widget.playername:SetColour(unpack(not empty and data.user.colour or DEFAULT_PLAYER_COLOUR))
    widget.playername:SetTruncatedString((not empty) and data.user.name or "", 200, nil, "...")

    widget.fake_rand = not empty and data.user.colour ~= nil and (data.user.colour[1] + data.user.colour[2] + data.user.colour[3]) / 3 or .5
end

function MVPLoadingWidget:PopulateData()
	local mvp_cards = Settings.match_results.mvp_cards or TheFrontEnd.match_results.mvp_cards

	self.list_root:KillAllChildren()
	self.mvp_widgets = {}

	local card_anims = {{"emoteXL_waving1", 0.5}, {"emote_loop_sit4", 0.5}, {"emoteXL_loop_dance0", 0.5}, {"emoteXL_happycheer", 0.5}, {"emote_loop_sit1", 0.5}, {"emote_strikepose", 0.25}}

	if mvp_cards ~= nil and #mvp_cards > 0 then
		-- build the required widgets
		for i, data in ipairs(mvp_cards) do
			local widget = self.list_root:AddChild(Widget("playerwidget"))

			local backing = widget:AddChild(Image("images/global_redux.xml", "mvp_panel.tex"))
			backing:SetPosition(0, 30)
			backing:SetScale(0.85, 1)
			
			widget.badge = widget:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))

			widget.fx_root = widget:AddChild(Widget("fx_root"))
			widget.fx_root:SetPosition(0, 60)
			function widget.fx_root:StartFx()
				local function fn()
					local fx = self:AddChild(UIAnim())
					local anim = fx:GetAnimState()
					
					anim:SetBank("farm_plant_happiness")
					anim:SetBuild("winner_fx")
					anim:PlayAnimation(math.random() < 0.5 and "happy_wormwood" or "happy")

					local s = 0.85
					fx:SetScale(s * (math.random() < 0.5 and 1 or -1), s)
					
					fx.inst:ListenForEvent("animover", function() fx:Kill() end)
				end
				fn()
				self.inst:DoPeriodicTask(0.65, fn)
			end

			widget.puppet = widget:AddChild(PlayerAvatarPortrait())
			widget.puppet:SetScale(1.25)
			widget.puppet:SetPosition(0, 140)
			widget.puppet:SetClickable(false)
			widget.puppet:AlwaysHideRankBadge() -- no space and mine is shown on XP bar
			widget.puppet:DoNotAnimate()

			local random_anim = math.random(1, #card_anims)
			widget.puppet.puppet.animstate:SetBank("wilson")
			widget.puppet.inst:DoTaskInTime(0, function()
				widget.puppet.puppet.animstate:SetPercent(card_anims[random_anim][1], card_anims[random_anim][2])
			end)

			widget.playername = widget:AddChild(Text(TITLEFONT, 45))
			widget.playername:SetPosition(2, -38)
			widget.playername:SetHAlign(ANCHOR_LEFT)

			local line = widget:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
			line:SetScale(.8, .9)
			line:SetPosition(0, -67)
			local c = .6
			line:SetTint(UICOLOURS.GOLD[1]*c, UICOLOURS.GOLD[2]*c, UICOLOURS.GOLD[3]*c, UICOLOURS.GOLD[4])

			widget.title = widget:AddChild(Text(TITLEFONT, 40, STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].TITLES[data.participation and "none" or data.beststat[1]], UICOLOURS.GOLD))
			widget.title:SetPosition(0, -98)

			widget.score = widget:AddChild(Text(CHATFONT, 45, tostring(data.beststat[2] or STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].NO_STAT_VALUE), UICOLOURS.EGGSHELL))
			widget.score:SetPosition(0, -146)

			widget.description = widget:AddChild(Text(CHATFONT, 30, STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].DESCRIPTIONS[data.beststat[1] or "none"], UICOLOURS.EGGSHELL))
			widget.description:SetPosition(0, -203)
			widget.description:SetRegionSize( 200, 66 )
			widget.description:SetVAlign(ANCHOR_TOP)
			widget.description:EnableWordWrap(true)

			if data.beststat[1] == "winner" then
				widget.score:Hide()
				widget.description:SetSize(45)
				widget.description:SetPosition(0, -183)

				widget.fx_root:StartFx()
			end
			
			if DEBUG then
				widget:AddChild(Text(NUMBERFONT, 80, i))
			end
			
			UpdatePlayerListing(widget, data)
			
			widget:Hide()
			
			table.insert(self.mvp_widgets, widget)
		end
		
		if #self.mvp_widgets > max_display then
			self.buttons_root:Show()
			self.showing_items = {}
			
			for i = 1, max_display do
				table.insert(self.showing_items, self.mvp_widgets[i])
			end
		end
		
		self:Update()
	end
end

function MVPLoadingWidget:Update()
	local displaying = self.showing_items or self.mvp_widgets
	
	local space = 255
	local offset = space * ((#displaying-1)/2)
	local y_offset = 25
	local rot_spacing = 4
	local rot_offset = rot_spacing * ((#displaying-1)/2)
	for i, widget in ipairs(displaying) do
		widget:Show()
		local x = (space * (i-1)) - offset
		local y = (widget.fake_rand * y_offset + y_offset) * (i%2==0 and 1 or -1) - 25
		widget:SetPosition(x,y)
		widget:SetRotation((rot_spacing * (i-1)) - rot_offset + (widget.fake_rand * 2.5 - 1.25))
	end
	
	if self.offset == 1 then
		self.left_button:Disable()
		self.right_button:Enable()
	elseif self.offset == (#self.mvp_widgets - max_display + 1) then
		self.left_button:Enable()
		self.right_button:Disable()
	else
		self.left_button:Enable()
		self.right_button:Enable()
	end
end

function MVPLoadingWidget:Offset(i)
	local _offset = self.offset
	self.offset = math.clamp(_offset + i, 1, #self.mvp_widgets - max_display + 1)
	
	if _offset == self.offset or not self.showing_items then
		return
	end
	
	for i, wgt in ipairs(self.showing_items) do
		wgt:Hide()
	end
	self.showing_items = {}
	
	for i = self.offset, self.offset + max_display - 1 do
		table.insert(self.showing_items, self.mvp_widgets[i])
	end
	
	self:Update()
end

function MVPLoadingWidget:SetAlpha(a)
end

return MVPLoadingWidget

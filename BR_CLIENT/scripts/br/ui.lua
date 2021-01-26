local env = env
GLOBAL.setfenv(1, GLOBAL)

local Text = require("widgets/text")

local UpvalueHacker = require("tools/upvaluehacker")

-- Idk how to get it, upvaluehacker is no use here
local function StartGame(this)
	if this.startbutton then
		this.startbutton:Disable()
	end

	if this.cb then
		local skins = this.currentskins
		this.cb(this.character_for_game, skins.base, skins.body, skins.hand, skins.legs, skins.feet) --parameters are base_prefab, skin_base, clothing_body, clothing_hand, then clothing_legs
	end
end

env.AddClassPostConstruct("screens/redux/lobbyscreen", function(self)
	self.time_remeaning = self.root:AddChild(Text(CHATFONT, 35))
    self.time_remeaning:SetColour(UICOLOURS.GOLD)
	self.time_remeaning:SetPosition(175, -340)

	function self.time_remeaning:Update(data)
		local worldcharacterselectlobby = TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby

		if worldcharacterselectlobby:SpectatorsEnabled() then
			self:SetString(STRINGS.BATTLE_ROYALE.LOBBY.SPECTATOR)
			self:Show()
			return
		end

		local t = data and data.time
		if not t and worldcharacterselectlobby then
			t = TheWorld.net.components.worldcharacterselectlobby:GetCountdown()
		end
		
		if not t or t == -1 then
			self:Hide()
			return
		end
		
		local str = subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.SPAWN_DELAY, { time = math.max(0, t) })
		if str ~= self:GetString() then
			self:SetString(str)
			if data and data.active then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/WorldDeathTick")
			end
		end
		self:Show()
	end

	self.time_remeaning:Update()
	
	local _Start = self.inst.event_listening["lobbyplayerspawndelay"][TheWorld][1]
	self.inst:RemoveEventCallback("lobbyplayerspawndelay", _Start, TheWorld)

	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data)
		if not data then
			return
		end

		self.time_remeaning:Update(data)

		if data.active then
			self.back_button:Disable()
			self.back_button:Hide()

			if data.time <= 0 then
				self:ForceStart()
			end
		end
	end, TheWorld)

	local function ClearScreen()
		if TheFrontEnd:GetActiveScreen().name ~= "LobbyScreen" then
			TheFrontEnd:PopScreen()
		end
	end

	function self:ForceStart()
		print("[Lobby]: Auto-set character to Random.")
		ClearScreen()

		if not self.lobbycharacter then
			self.lobbycharacter = "random"
		end
		
		local timing = 0
		local count = #self.panels
		for i = self.current_panel_index, count do
			self.inst:DoTaskInTime(FRAMES * 2 * timing, function()
				ClearScreen()
				if i == count then
					self.inst:DoTaskInTime(FRAMES, function() _Start(TheWorld, {time = 0, active = true}) end)
				else
					if self.panel.OnNextButton ~= nil then
						self.next_button.onclick()
					else
						self:ToNextPanel(1)
					end
				end
			end)
			timing = timing + 1
		end
	end

	local _ToNextPanel = self.ToNextPanel
	function self:ToNextPanel(...)
		local val = {_ToNextPanel(self, ...)}

		if self.panel.name == "LoadoutPanel" and not self.panel.patched then
			local this = self.panel
			this.patched = true

			local _OnNextButton = this.OnNextButton

			function this.OnNextButton(this, ...)
				if TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby:SpectatorsEnabled() then
					_OnNextButton(this, ...)
					self.inst:DoTaskInTime(FRAMES, StartGame(self))
					return false
				end
				return _OnNextButton(this, ...)
			end
		end

		return unpack(val)
	end
end)


env.AddClassPostConstruct("widgets/waitingforplayers", function(self)
	local Grid = require("widgets/grid")

	self.playerready_checkbox:Disable()
	self.playerready_checkbox:Hide()
	self.playerready_checkbox:SetPosition(0, -1000)
	self.playerready_checkbox.RecenterCheckbox = function() end

	self.inst:RemoveEventCallback("lobbyplayerspawndelay", self.inst.event_listening["lobbyplayerspawndelay"][TheWorld][1], TheWorld)
	
	local DEBUG_PLAYERS
	local cached_players = 0
	local function RebuildListing()
		-- Values were found through testing
		local screen_w = 900
		local screen_h = 500
		local widget_scale = 0.45
		local widget_h = widget_scale * 325
		local widget_h = widget_scale * 510
		local off_height = 110
		local off_height = 30
		local col = 0
		local row = 1
		local scale = 3
		local scale_percent_increment = 5e-3

		local count = DEBUG_PLAYERS or #GetPlayersClientTable()

		if cached_players == count then
			return
		end

		cached_players = count

		while col*row < count do
			col = col + 1
			
			local next_scale = scale
			local n = 0
			while (col * (widget_h + off_height) - off_height) * next_scale > screen_w or ((widget_h + off_height) * row - off_height)*next_scale > screen_h do
				n = n + 1
				next_scale = scale*(1 - scale_percent_increment*n)
			end
			
			scale = next_scale
			
			if ((widget_h + off_height) * (row + 1) - off_height)*scale < screen_h then
				row = row + 1
				col = col - 1
				scale = 2 / row
			end
		end
		
		for i, widget in ipairs(self.player_listing) do
			if i <= count then
				widget:SetScale(scale)
				widget:Show()
			else
				widget:Hide()
			end
		end
		
		local _grid = self.list_root
		self.list_root = self.proot:AddChild(Grid())
		self.list_root:FillGrid(col, (widget_h + off_height) * scale, (widget_h + off_height) * scale, self.player_listing)
		self.list_root:SetPosition(-(widget_h + off_height)*scale * (col - 1)/2, (widget_h + off_height)*scale*(row - 1)/2 + 20)
		_grid:Kill()
		
		self:RefreshPlayersReady()
	end

	local _Refresh = self.Refresh
	function self:Refresh(force, ...)
		RebuildListing()

		return _Refresh(self, force, ...)
	end
	
	if CHEATS_ENABLED then
		rawset(_G, "set", function(x)
			DEBUG_PLAYERS = x
			RebuildListing()
		end)
	end
end)

local _DisplayCharacterUnownedPopup = DisplayCharacterUnownedPopup
function DisplayCharacterUnownedPopup(character, skins_subscreener, ...)
    if not BR_LockedCharacter(character) then
        return _DisplayCharacterUnownedPopup(character, skins_subscreener, ...)
    end

	local PopupDialogScreen = require "screens/redux/popupdialog"
	local body_str = subfmt(STRINGS.BATTLE_ROYALE.UNOWNED_CHARACTER_BODY, {character = STRINGS.CHARACTER_NAMES[character] })
    local unowned_popup = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.UNOWNED_CHARACTER_TITLE, body_str,
    {
        {text=STRINGS.BATTLE_ROYALE.BUY, cb = function()
            VisitURL("https://discord.gg/wyEpdfBaKv")
            TheFrontEnd:PopScreen()
        end},
        {text=STRINGS.UI.POPUPDIALOG.OK, cb = function()
            TheFrontEnd:PopScreen()
        end},
    })
    TheFrontEnd:PushScreen(unowned_popup)
end

env.AddClassPostConstruct("widgets/fumeover", function(self)
    self.inst:ListenForEvent("startpoisondebuff", function(owner, debuff)
        if not self.corrosives[debuff] then
            self.corrosives[debuff] = true
            self.inst:ListenForEvent("onremove", self._onremovecorrosive, debuff)
            self:TurnOn(self.top)
            self:TurnOff(self.over)
        end
    end, self.owner)
end)

env.AddClassPostConstruct("screens/playerhud", function(self)
	local TitleRedux = require("widgets/title_redux")

	function self:ShowReduxTitle(title, body, duration)	
		if self.title_redux then
			self.title_redux:Kill()
		end
		
		local popupdata =
		{
			title = title,
			body = body,
			time = duration
		}
		self.title_redux = self.root:AddChild(TitleRedux(self.owner, popupdata))
	end

	self.inst:DoTaskInTime(1, function()
		local map = TheWorld and TheWorld.net and TheWorld.net.components.battleroyale_network:GetMap()
		if map then
			TheFrontEnd:GetSound():PlaySound("dontstarve/music/stalker_enter_music")
			self:ShowReduxTitle(string.format(STRINGS.BATTLE_ROYALE.MAPS.NAME_INTRO, STRINGS.BATTLE_ROYALE.MAPS.NAMES[map]), STRINGS.BATTLE_ROYALE.MAPS.DESCRIPTIONS[map], 5)
		end
	end)
end)

local SpectatorWgt = require "widgets/hg_spectator_wgt"
local SpectatorEye = require "widgets/spectator_eye"

env.AddClassPostConstruct("widgets/controls", function(self)
	if self.clock then
		self.clock:Hide()
		self.clock:SetPosition(2000, 2000)

		self.status:SetPosition(0, 0)
	end

	self.hg_spectator_wgt = self.bottom_root:AddChild(SpectatorWgt(self.owner))
    self.hg_spectator_wgt:SetPosition(0, 70)
	self.hg_spectator_wgt:Hide()
	
	self.spectator_eye = self.inv:AddChild(SpectatorEye(self.owner))
	self.spectator_eye:SetPosition(-1000, 75)
	self.spectator_eye:MoveToBack()
end)

env.AddClassPostConstruct("widgets/redux/wxplobbypanel", function(self)
	if self.displayinfo then
		self.displayinfo.duration = 5
	end
end)
--------------------------------------------------------------------------
--[[ WorldCharacterSelectLobby class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------
local DEBUG = CHEATS_ENABLED

local COUNTDOWN_TIME = DEBUG and 20 or 150
local COUNTDOWN_INACTIVE = 65535
local PLAYERS_TO_START = DEBUG and 1 or 2
local LOBBY_CLOSE_TIME = 10
--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim

--Master simulation
local _countdownf = -1
local _countdown_start = nil
local _updating = false

--Network
local _countdowni = net_ushortint(inst.GUID, "worldcharacterselectlobby._countdowni", "spawncharacterdelaydirty")
local _spectators = net_bool(inst.GUID, "worldcharacterselectlobby._spectators", "spectatorsdirty")
--------------------------------------------------------------------------
--[[ Global Setup ]]
--------------------------------------------------------------------------
--[[
AddUserCommand("playerreadytostart", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {"ready"},
    vote = false,
    canstartfn = function(command, caller, targetid)
        return _countdowni:value() == COUNTDOWN_INACTIVE and not _lockedforshutdown:value()
    end,
    serverfn = function(params, caller)
		TogglePlayerReadyToStart(caller.userid)
    end,
})
]]

rawset(_G, "skip_timer", function()
	_countdownf = 10
	_countdowni:set(10)
end)

--------------------------------------------------------------------------
--[[ Private Server event handlers ]]
--------------------------------------------------------------------------
local function StarTimer(time)
	print("[WorldCharacterSelectLobby] Countdown started")

	_countdown_start = true--GetTimeRealSeconds()
	_countdownf = time
	_countdowni:set(math.ceil(time))

	_updating = true
	self.inst:StartWallUpdatingComponent(self)
end

local function StopTimer()
	print("[WorldCharacterSelectLobby] Countdown stopped")

	_countdown_start = nil
	_countdownf = -1
	_countdowni:set(COUNTDOWN_INACTIVE)
	
	_updating = false
	self.inst:StopWallUpdatingComponent(self)
end

-- Player is ready if they have a character selected
local function CountPlayersReadyToStart()
	--[[
	local invalid_prefab = ""
	local count = 0
	for _, player in ipairs(GetPlayersClientTable()) do
		if player.lobbycharacter and player.lobbycharacter ~= invalid_prefab then
			count = count + 1
		end
	end
	return count]]
	--[[
	local count = 0
	for _, player in ipairs(GetPlayersClientTable()) do
		if player.userflags and not checkbit(player.userflags, USERFLAGS.IS_LOADING) then
			count = count + 1
		end
	end]]
	return #GetPlayersClientTable()
end

local function TryStartCountdown()
	if CountPlayersReadyToStart() >= PLAYERS_TO_START and not self:SpectatorsEnabled() then
		StarTimer(COUNTDOWN_TIME)
	end
end

local function TryStoppingCountdown()
	if CountPlayersReadyToStart() < PLAYERS_TO_START then
		StopTimer()
	end
end

local function OnRequestLobbyCharacter(world, data)
	if not data then
		return
	end

	local client = TheNet:GetClientTableForUser(data.userid)
	if not client then
		return
	end

	TheNet:SetLobbyCharacter(data.userid, data.prefab_name, data.skin_base, data.clothing_body, data.clothing_hand, data.clothing_legs, data.clothing_feet)
	
	-- TryStartCountdown()
end

local function EnableSpectators()
	print("[WorldCharacterSelectLobby] Spectators enabled")
	_spectators:set(true)
end

--------------------------------------------------------------------------
--[[ Private Client event handlers ]]
--------------------------------------------------------------------------

local function OnCountdownDirty()
	if _ismastersim and _countdowni:value() == 0 then
		_updating = false
		inst:StopWallUpdatingComponent(self)
		_countdownf = 0

		inst:DoTaskInTime(5, function()
			_countdown_start = nil
			_countdownf = -1
			_countdowni:set(COUNTDOWN_INACTIVE)
			EnableSpectators()
		end)

		TheWorld.components.battleroyale:StartGame()
        print("[WorldCharacterSelectLobby] Countdown finished")
    end

	local t = _countdowni:value()

	_world:PushEvent("lobbyplayerspawndelay", { time = t == COUNTDOWN_INACTIVE and -1 or t, active = t <= LOBBY_CLOSE_TIME })
end

local function OnLobbyClientDisconnected(_, data)
	TryStoppingCountdown()
	if _updating and #GetPlayersClientTable() == 0 then
		_updating = false
		self.inst:StopWallUpdatingComponent(self)
	end
end

local function OnLobbyClientConnected()
	if not _updating and #GetPlayersClientTable() > 0 then
		_updating = true
		self.inst:StartWallUpdatingComponent(self)
	end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------
--Initialize network variables
_countdowni:set(COUNTDOWN_INACTIVE)

--Register network variable sync events
inst:ListenForEvent("spawncharacterdelaydirty", OnCountdownDirty)
inst:ListenForEvent("canchangedirty", OnCountdownDirty)

if _ismastersim then
    --Register events
	inst:ListenForEvent("ms_requestedlobbycharacter", OnRequestLobbyCharacter, _world)

	-- inst:ListenForEvent("ms_clientauthenticationcomplete", OnLobbyClientConnected, _world)
	inst:ListenForEvent("ms_clientloaded", OnLobbyClientConnected, _world)
    inst:ListenForEvent("ms_clientdisconnected", OnLobbyClientDisconnected, _world)
end

--------------------------------------------------------------------------
--[[ Public members ]]
--------------------------------------------------------------------------

function self:GetSpawnDelay()
	local delay = _countdowni:value()
	return delay ~= COUNTDOWN_INACTIVE and delay or -1
end

if _ismastersim then function self:IsAllowingCharacterSelect()
	return true --_countdowni:value() == COUNTDOWN_INACTIVE and not _lockedforshutdown:value()
end end

function self:IsServerLockedForShutdown()
	return false
end

function self:IsPlayerReadyToStart(userid) -- Fox: This is for hiding the "ready" text
	return false
end

if _ismastersim then function self:OnPostInit()
	-- Fox: Something something
end end

-- TheWorld.net.components.worldcharacterselectlobby:Dump()
function self:Dump()
	local str = ""
	for i, v in ipairs(_players_ready_to_start) do
		str = str .. ", " .. tostring(v:value())
	end
	print(str)
end

function self:GetCountdown()
	if _ismastersim then
		return _countdownf
	end
	local val = _countdowni:value()
	return val == COUNTDOWN_INACTIVE and -1 or val
end

function self:CanPlayersSpawn()
	return self:SpectatorsEnabled() or _countdownf == 0
end

function self:CanChangeCharacter()
	return _countdowni:value() > LOBBY_CLOSE_TIME
end

function self:SpectatorsEnabled()
	return _spectators:value()
end

function self:GetDebugString()
	return string.format("ready: %d, countdown: %d (%0.2f), spectators: %s ", CountPlayersReadyToStart(), _countdowni:value(), _countdownf, self:SpectatorsEnabled() and "y" or "n")
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------
-- Fox: Keep in mind that before StartWallUpdating is called we need to save start time
-- This is done for compatibility with servers with pause_when_empty = true
-- Since OnUpdate does not get called if there's not players in world (e.g. players are in lobby)
-- And OnWallUpdate gets called with dt 0 for some reason
function self:OnWallUpdate(dt)
	-- Fox: There's a listener for ms_requestedlobbycharacter event
	-- But it never gets pushed
	-- I found that it's supposed to be pushed from RequestedLobbyCharacter in networking.lua:272
	-- But this function never gets called, maybe it's an engine bug?
	-- This should fix it, at least for now, but this really needs to be looked into
	if _countdownf == -1 then
		TryStartCountdown()
	else
		TryStoppingCountdown()
	end

	if _countdown_start then
		_countdownf = math.max(0, _countdownf - dt)
		_countdowni:set(math.ceil(_countdownf))
	end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------
-- Fox: I'm not sure if we need this, but whatever
if _ismastersim then function self:OnSave()
	local data =
	{
		match_started = _countdowni:value() == 0,
	}

	return data
end end

if _ismastersim then function self:OnLoad(data)
	if data then
		if data.match_started then
			_countdownf = 0
			_countdowni:set(0)
		end
	end
end end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
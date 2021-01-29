local GAME_DURATION = TUNING.BATTLE_ROYALE.GAME_DURATION
local WIN_DELAY = TUNING.BATTLE_ROYALE.WIN_DELAY

local function GetNetwork(w)
    return w.net and w.net.components.battleroyale_network
end

local BattleRoyale = Class(function(self, inst)
    self.inst = inst

    self.player_data = {}
    self.winner = nil
    self.game_duration = 0

    self.center = nil
    self.range = nil

    if not CHEATS_ENABLED then
        local CheckWinner = function() self:CheckWinner() self:CheckIsEmpty() end
        inst:ListenForEvent("ms_playerjoined", CheckWinner)
        inst:ListenForEvent("ms_playerleft", CheckWinner)
    end

    inst:ListenForEvent("ms_register_br_center", function(_, point) self:RegisterCenter(point) end)
    inst:ListenForEvent("ms_register_br_range", function(_, point) self:RegisterRange(point) end)

    if CHEATS_ENABLED then
        rawset(_G, "win", function()
            self.GetAlivePlayers = function() return {ThePlayer} end
            self:CheckWinner()
        end)
    end
end)

function BattleRoyale:StartGame()
    self.update_task = self.inst:DoPeriodicTask(1, function() self:Update() end)

    self.inst.components.battleroyale_statistics:InitPlayers() -- Fox: Other players considired spectators

    self.fog_task = self.inst:DoTaskInTime(TUNING.BATTLE_ROYALE.FOG.START_TIME, function() self.inst.components.poisonmanager:StartFog() end)
end

function BattleRoyale:Update()
    self.game_duration = self.game_duration + 1
    self:CheckDuration()
end

function BattleRoyale:CheckIsEmpty()
    if #GetPlayersClientTable() == 0 then
        self:ResetWorld()
    end
end

function BattleRoyale:CheckDuration()
    if self.game_duration < GAME_DURATION then
        return
    end

    if self.update_task then
        self.update_task:Cancel()
        self.update_task = nil
    end

    self:ApplyEndgame()
end

function BattleRoyale:ApplyEndgame()
    for _, v in ipairs(self:GetAlivePlayers()) do
        --
    end
end

function BattleRoyale:GetAlivePlayers()
    local alive = {}
    for _, player in ipairs(AllPlayers) do
        if not player.spectator then
            table.insert(alive, player)
        end
    end
    return alive
end

function BattleRoyale:PlayerDied(player, data)
    player.spectator = true -- Ugh.... We set spectator on becomming ghost, so this has to be there I guess....

    self:CheckWinner()

    local UpdateRank = UpdateRank
    
    -- UpdateRank(player.userid, RANKS.DELTA.DEATH)

    if data and data.afflicter and data.afflicter.userid then
        UpdateRank(data.afflicter.userid, RANKS.DELTA.KILL)
        UpdateStat(data.afflicter.userid, "kills", 1)
    end

    local net = GetNetwork(self.inst)
    if net then
        net:RebuildData()
    end
end

function BattleRoyale:CheckWinner()
    if self.winner then
        return
    end

    local alive = self:GetAlivePlayers()
    local num = #alive
    if num == 1 then
        self.winner = alive[1]

        UpdateStat(self.winner.userid, "winner", nil, 1)
        UpdateRank(self.winner.userid, RANKS.DELTA.WIN)

        self:FinishGame()
    elseif num == 0 then
        self.winner = nil
        self:FinishGame(true)
    end
end

function BattleRoyale:FinishGame(nowinner)
    if not self.winner and not nowinner then
        print("[BattleRoyale Component] Error! Failed to finish game: winner is undefined!", debugstack())
        return
    end

    if self.update_task then
        self.update_task:Cancel()
        self.update_task = nil
    end

    self:AnnounceWinner()

    self.inst.components.battleroyale_statistics:PushMatchResults()
    
    self.inst:PushEvent("ms_matchover") -- Fox: Ranks + delta happeneds here

    self.win_task = self.inst:DoTaskInTime(WIN_DELAY, function()
        self:ResetWorld()
    end)
end

function BattleRoyale:AnnounceWinner()
    local net = GetNetwork(self.inst)
    if net then
        net:SetWinner(self.winner)
    end
end

function BattleRoyale:ResetWorld()
    self:SelectMap()

    local function doreset()
		StartNextInstance({
			reset_action = RESET_ACTION.LOAD_SLOT,
			save_slot = SaveGameIndex:GetCurrentSaveSlot(),
		})
	end
	ShardGameIndex:Delete(doreset, true)
end

function BattleRoyale:SelectMap()
    local selected_map = GetRandomItem(BATTLE_ROYALE_MAP_ROTATION)
    TheMapSaver:Save(selected_map)
end

function BattleRoyale:RegisterCenter(point)
    self.center = point
end

function BattleRoyale:RegisterRange(point)
    self.range = point
end

function BattleRoyale:GetCenter()
    return self.center:GetPosition()
end

function BattleRoyale:GetPoisonRange()
    local center = self.center:GetPosition()
    local range = self.range:GetPosition()
    return distsq(center.x, center.z, range.x, range.z)
end

return BattleRoyale

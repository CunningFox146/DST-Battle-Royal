local FIELDS_ORDER = {
    "winner",
    "kills",
    "damage",
}

global("UpdateStat")
UpdateStat = nil

local Statistics = Class(function(self, inst)
	self.inst = inst

    self.player_data = {}
    
    UpdateStat = function(...)
        self:UpdateStat(...)
	end
	
	if CHEATS_ENABLED then
		rawset(_G, "pdat", function()
			for k, v in pairs(self.player_data) do
				printwrap(k, v)
			end
		end)
	end
end)

function Statistics:InitPlayers()
	for i, data in ipairs(GetPlayersClientTable()) do
        self.player_data[data.userid] = {
            netid = data.netid,
            name = data.name,
            lobbycharacter = data.lobbycharacter,
            prefab = data.prefab,
            userid = data.userid,
            colour = data.colour,

            portrait = data.vanity[1],

            stats = {
                damage = 0,
                kills = 0,
                winner = 0,
            },
        }
	end
end

function Statistics:PushMatchResults()
	for id, data in pairs(self.player_data) do
		local ctable = TheNet:GetClientTableForUser(id)
		if ctable then
			data.prefab = ctable.prefab

			data.base = ctable.base_skin
			data.body = ctable.body_skin
			data.hand = ctable.hand_skin
			data.legs = ctable.legs_skin
			data.feet = ctable.feet_skin
		end
	end

	local field_order = {"userid", "netid", "character", "cardstat"}
	
	local player_stats = {}
	local field_order_established = false
	
	for userid, data in pairs(self.player_data) do
		local current_player_stats = {}
		table.insert(current_player_stats, userid)
		table.insert(current_player_stats, data.netid)
		table.insert(current_player_stats, data.prefab)
		table.insert(current_player_stats, self:GetBestStat(userid)[1] or "<nil>")
		
		for i, stat in ipairs(FIELDS_ORDER) do
			table.insert(current_player_stats, math.floor(data.stats[stat] or 0))
			if not field_order_established then
				table.insert(field_order, stat)
			end
		end
		field_order_established = true			
		table.insert(player_stats, current_player_stats)
	end
	
	TheFrontEnd.match_results.mvp_cards = self:GetMvpAwards()
	TheFrontEnd.match_results.wxp_data = self:GetAwardedWxp()
	TheFrontEnd.match_results.player_stats = {gametype = "battleroyale", session = TheWorld.meta.session_identifier, data = player_stats, fields = field_order}
	TheFrontEnd.match_results.outcome = self:GetMatchOutcome()
end

function Statistics:GetMatchStat(name)
	return self.stats[name]
end

function Statistics:GetGaveDuplicateTributed()
	for food, count in pairs(self.tributes) do
		if count > 2 then
			return true
		end
	end
	return false
end

function Statistics:GetStatTotal(stat, id)
	if id then	
		if not self.player_data[id] then
			print("ERROR: no player in self.player_data! ", CalledFrom())
		end
		return self.player_data[id] and self.player_data[id].stats[stat] or 0
	else
		local total = 0
		
		for id, data in pairs(self.player_data) do
			total = total + (data.stats[stat] or 0)
		end
		
		return total
	end
end

function Statistics:GetAwardedWxp()
	local wxp_data = {}
	local progress = TheWorld.components.br_progress
	for id, data in pairs(self.player_data) do
		local wxp = progress:GetWxp(id)
		local delta = progress:GetDelta(id)
		wxp_data[id] = {
			new_xp = wxp + delta,
			match_xp = delta,
			earned_boxes = 0,
			details = {},
		}
	end
	
	if CHEATS_ENABLED then
		printwrap("wxp_data", wxp_data)
	end

	return wxp_data
end

function Statistics:UpdateStat(userid, stat, delta, value)
    if self.player_data[userid] and self.player_data[userid].stats[stat] then
        self.player_data[userid].stats[stat] = value or (self.player_data[userid].stats[stat] + delta)
    end
end

function Statistics:GetBestStat(userid)
    local best_stat = {}

    if self.player_data[userid].stats.winner ~= 0 then
        best_stat = {"winner", self.player_data[userid].stats.winner}
    elseif self.player_data[userid].stats.kills > 0 then
        best_stat = {"killer", self.player_data[userid].stats.kills}
    elseif self.player_data[userid].stats.damage > 0 then
        best_stat = {"damager", self.player_data[userid].stats.damage}
    end
	
	self.player_data[userid].beststat = best_stat
	
	return best_stat
end

function Statistics:GetMvpAwards()
	local result = {}

	for id, data in pairs(self.player_data) do
		if TheNet:GetClientTableForUser(id) then -- Is player online
			local best_stat = self:GetBestStat(id)
			table.insert(result, {
				user = {
					base = data.base,
					body = data.body,
					hand = data.hand,
					legs = data.legs,
					feet = data.feet,
					portrait = data.portrait,

					lobbycharacter = data.lobbycharacter,
					prefab = data.prefab,

					name = data.name,
					userid = data.userid,
					colour = data.colour,
				},
				participation = not best_stat,
				beststat = best_stat or {},
			})
		end
	end
	
	return result
end

function Statistics:GetMatchOutcome()
	return {
		won = false,
		time = self:GetGameTime(),
	}
end

function Statistics:GetGameTime()
	return self.inst.components.battleroyale.game_duration
end

return Statistics

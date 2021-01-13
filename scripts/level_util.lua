local env = env
GLOBAL.setfenv(1, GLOBAL)

FESTIVAL_EVENTS.BATTLE_ROYALE = "battleroyale"
WORLD_FESTIVAL_EVENT = FESTIVAL_EVENTS.BATTLE_ROYALE

local function GetLevelManager()
	return TheWorld and TheWorld.net and TheWorld.net.components.br_level_manager
end

function BR_GetLevel(id)
	local manager = GetLevelManager()
	if manager then
		return manager:GetLevel(id)
	end
	return 0
end

local _GetSkinsDataFromClientTableData = GetSkinsDataFromClientTableData
GetSkinsDataFromClientTableData = function(data, ...)
	data = data or {}
	data.eventlevel = BR_GetLevel(TheNet:GetUserID())
	return _GetSkinsDataFromClientTableData(data, ...)
end

require("wxputils")

local _GetLevel = wxputils.GetLevel
function wxputils.GetLevel(festival_key, ...)
	local level = BR_GetLevel(TheNet:GetUserID())
	if level then
		return level
	end

    return _GetLevel(festival_key, ...)
end

function wxputils.GetLevelPercentage()
    local level = wxputils.GetLevel()
	local _, prcnt = math.modf(level)
	return prcnt
end

function wxputils.BuildProgressString()
	local current = wxputils.GetLevelPercentage() * 100
    return subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num = current, max = 100})
end

local _GetActiveLevel = wxputils.GetActiveLevel
function wxputils.GetActiveLevel(...)
	local level = BR_GetLevel(TheNet:GetUserID())
	if level then
		return level
	end
	
	return _GetActiveLevel(...)
end

local _GetSkinsDataFromClientTableData = GetSkinsDataFromClientTableData
function GetSkinsDataFromClientTableData(client, ...)
	local data = {_GetSkinsDataFromClientTableData(client, ...)}
	data[5] = BR_GetLevel(client.userid)
	return unpack(data)
end

-- Revise all Level Badge display templates
local TEMPLATES = require("widgets/redux/templates")

local _ChatFlairBadge = TEMPLATES.ChatFlairBadge
TEMPLATES.ChatFlairBadge = function(...)
	local flair = _ChatFlairBadge(...)
	
	flair.SetFestivalBackground = function(self, ...)
		self.bg:SetTexture("images/profileflair.xml", "playericon_bg_lavaarena.tex")
		-- self.bg:SetTint(0, 1, 1, 1)
	end
	
	flair:SetFestivalBackground()
	
	return flair
end

env.AddClassPostConstruct("widgets/truescrolllist", function(self)
	local _SetItemsData = self.SetItemsData
	self.SetItemsData = function(self, items, ...)
		if items and next(items) then
			for _, client in pairs(items) do
				if client.userid and client.eventlevel then
					client.eventlevel = BR_GetLevel(client.userid)
				end
			end
		end
		return _SetItemsData(self, items, ...)
	end
end)

-- local _WxpBar = TEMPLATES.WxpBar
-- TEMPLATES.WxpBar = function(...)
	-- local wxpbar = _WxpBar(...)
	-- wxpbar.SetRank = function(w_self, rank, next_level_xp, profileflair)
        -- w_self.rank:SetRank(profileflair, rank)
        -- w_self.nextrank:SetRank(rank + 1)
        -- w_self.nextlevelxp_text:SetString(next_level_xp)
	-- end
	-- return wxpbar
-- end

local _FestivalNumberBadge = TEMPLATES.FestivalNumberBadge
TEMPLATES.FestivalNumberBadge = function(festival_key, ...)
	local badge = _FestivalNumberBadge(festival_key, ...)
	
	badge.SetRank = function(self, rank_value)
		self.num:SetString(tostring(rank_value))
		self:SetHoverText(STRINGS.BATTLE_ROYALE.RANK..rank_value, {offset_x = 30})
		-- self:SetTexture("images/br_level.xml", "banner.tex")
		-- self:SetTint(0, 1, 1, 1)
    end

	return badge
end

local _RankBadge = TEMPLATES.RankBadge
TEMPLATES.RankBadge = function(...)
	local rank = _RankBadge(...)
	
	rank.SetFestivalBackground = function(self, ...)
		-- rank.bg:SetTexture("images/br_level.xml", "banner_level.tex")
		self.bg:SetTexture("images/profileflair.xml", "playericon_bg_lavaarena.tex")
		-- rank.bg:SetTint(0, 1, 1, 1)
	end

	rank:SetFestivalBackground()

	local _SetRank = rank.SetRank
	rank.SetRank = function(self, profileflair, rank_value, hide_hover_text, ...)
		_SetRank(self, profileflair, rank_value, hide_hover_text, ...)
        
        if hide_hover_text then
			self.flair:ClearHoverText()
        else
            self.flair:SetHoverText(STRINGS.BATTLE_ROYALE.RANK..rank_value, {font = UIFONT, offset_x = 0, offset_y = 40, colour = WHITE})
        end
		
		rank.num:SetString(rank_value or 0)
		
		-- self.bg:SetTexture("images/br_level.xml", "banner_level.tex")
		-- rank.bg:SetTint(0, 1, 1, 1)
    end
	
	return rank
end

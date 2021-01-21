require("constants")

function GetPlayersClientTable()
    local clients = TheNet:GetClientTable() or {}
    if not TheNet:GetServerIsClientHosted() then
		for i, v in ipairs(clients) do
			if v.performance ~= nil then
				table.remove(clients, i) -- remove "host" object
				break
			end
		end
    end
    return clients
end

function BR_LockedCharacter(character)
    return TheWorld and TheWorld.character_unlocker and TheWorld.character_unlocker:IsLocked(TheNet:GetUserID(), character)
end

-- Lock characters from lobby
local _IsCharacterOwned = IsCharacterOwned
IsCharacterOwned = function(character, ...)
    if BR_LockedCharacter(character) then
        return false
    end
    return _IsCharacterOwned(character, ...)
end
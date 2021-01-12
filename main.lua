local env = env
GLOBAL.setfenv(1, GLOBAL)

CHEATS_ENABLED = true

STRINGS.BATTLE_ROYALE = {
    BUY = "Join Discord",
    UNOWNED_CHARACTER_BODY = "You have not yet unlocked {character}.\nTo play this character, you must buy premium on this server through our discord server.",
}

require("constants")

env.AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent("character_unlocker")
    TheWorld.character_unlocker = inst.components.character_unlocker
end)

local function BR_LockedCharacter(character)
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

if not TheNet:GetIsServer() then
    return
end

-- Despawn those who chose locked chars
local _SpawnNewPlayerOnServerFromSim = SpawnNewPlayerOnServerFromSim
SpawnNewPlayerOnServerFromSim = function(guid, ...)
    local player = Ents[guid]
    local char_unlocker = TheWorld and TheWorld.character_unlocker
    if char_unlocker and player and
    player.userid and player.prefab then
        if char_unlocker:IsLocked(player.userid, player.prefab) then
            player:DoTaskInTime(0, function(inst)
                TheWorld:PushEvent("ms_playerdespawnanddelete", player)
            end)
        end
    end
    return _SpawnNewPlayerOnServerFromSim(guid, ...)
end
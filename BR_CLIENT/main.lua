PrefabFiles = {
    "debuff_poison",
}

local env = env
GLOBAL.setfenv(1, GLOBAL)

if not env.MODROOT:find("workshop-") then
    CHEATS_ENABLED = true
    NetworkProxy.GetPVPEnabled = function() return true end
end

if AllRecipes["frostmourne"] then
    AllRecipes["frostmourne"].level = TECH.LOST
end

env.AddRecipe("shusui", {Ingredient("nightsword", 1),Ingredient("goldnugget", 3)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "zorospecific").atlas = "images/inventoryimages/shusui.xml"
env.AddRecipe("sandai", {Ingredient("spear", 1), Ingredient("tentaclespike", 1)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "zorospecific").atlas = "images/inventoryimages/sandai.xml"

STRINGS.BATTLE_ROYALE = {
    BUY = "Join Discord",
    UNOWNED_CHARACTER_BODY = "You have not yet unlocked {character}.\nTo play this character, you must buy premium on this server through our discord server.",

    RANK = "Level: ",
}

STRINGS.NAMES.DEBUFF_POISON = "Poison"

require("constants")

env.AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent("character_unlocker")
    TheWorld.character_unlocker = inst.components.character_unlocker
    
    inst:AddComponent("br_level_manager")
    -- inst:AddComponent("worldcharacterselectlobby")
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

env.AddPrefabPostInit("forest", function(inst)
    inst:RemoveComponent("wavemanager")

    inst.Map:SetTransparentOcean(false)
    inst.Map:SetUndergroundFadeHeight(5)

    inst.WaveComponent:SetWaveParams(13.5, 2.5)
end)

env.modimport "scripts/level_util.lua"

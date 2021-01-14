local function ArrayToMap(array)
    if not array then
        return {}
    end

    local map = {}
    for _, val in ipairs(array) do
        map[val] = true
    end
    return map
end

local function UpdateLobbyScreen()
    local scr = TheFrontEnd:GetActiveScreen()
    if not scr or not scr.name == "LobbyScreen" then
        return
    end

    -- This is so dyrty my god
    local _panel = scr.panels[2]
    scr.panels[2] = scr.panels[1]

    scr:ToNextPanel(1)
    scr.inst:DoTaskInTime(0, function()
        scr:ToNextPanel(-1)
        scr.panels[2] = _panel
    end)
end

local CharacterUnlocker = Class(function(self, inst)
    self.inst = inst

    self.path = "premium_characters.json"
    
    self.blocked = {}
    self.premium = {}

    self._blocked = net_string(inst.GUID, "character_unlocker._blocked")
    self._premium = net_string(inst.GUID, "character_unlocker._premium")

    if not TheNet:IsDedicated() then
        self.inst:DoTaskInTime(0, function()
            self:Decode()
            -- Hack! Network syncing takes 1 frame, but widget already requests data
            -- So we just force update its
            -- UpdateLobbyScreen()
        end)
    end

    if TheWorld.ismastersim then
        self:LoadData()
    end
end)

---------Server only---------

function CharacterUnlocker:SetBlocked(chars)
    self._blocked:set(DataDumper(chars))
    self.blocked = ArrayToMap(chars)
end

function CharacterUnlocker:SetPremium(ids)
    self._premium:set(DataDumper(ids))
    self.premium = ArrayToMap(ids)
end

function CharacterUnlocker:LoadData()
    local f = io.open(self.path, "r")
    if not f then
        print("CRITICAL ERROR: Failed to read " .. self.path)
        return
    end

    local data = json.decode(f:read("*a"))
    self:SetBlocked(data.blocked)
    self:SetPremium(data.premium)

    f:close()
end

---------Client only---------

function CharacterUnlocker:Decode()
    self.blocked = ArrayToMap(loadstring(self._blocked:value())())
    self.premium = ArrayToMap(loadstring(self._premium:value())())
end

-----------Both sides---------

function CharacterUnlocker:IsLocked(id, character)
    if self.blocked[character] then
        return not self.premium[id]
    end
    return false
end

return CharacterUnlocker
require "class"

local OVERRIDE_MAP = BATTLE_ROYALE_MAPS.NIGHT

local MapSaver = Class(function(self, root)
    self.path = (root or "") .. "battleroyale_map.json"
    
    self.selected_map = nil
    self.default_map = BATTLE_ROYALE_MAPS.TEST
end)

function MapSaver:Save(map)
    map = CHEATS_ENABLED and OVERRIDE_MAP or map
    local f = io.open(self.path, "w")
    if not f then
        print("[Map Saver] Error! Failed to open file for writing: ", self.path)
        return
    end
    f:write(map)
    f:close()
end

function MapSaver:Load()
    local f = io.open(self.path, "r")
    if not f then
        print("[Map Saver] Error! Failed to open file for reading: ", self.path)
        return
    end
    for line in f:lines() do
        self.selected_map = tonumber(line)
        break
    end
    f:close()
end

function MapSaver:GetMap()
    return self.selected_map or self.default_map
end

return MapSaver

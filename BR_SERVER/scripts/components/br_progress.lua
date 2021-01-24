global("UpdateRank")
UpdateRank = nil

local LevelManager = Class(function(self, inst)
    self.inst = inst
	
    self.path = "br_ranks.json"

    self.ranks = {}
    self.delta = {} -- Fox: Add ranks only after the match is over

    UpdateRank = function(...)
        self:DoDelta(...)
    end
    
    self:LoadData()

    self.inst:ListenForEvent("ms_matchover", function() self:SaveData() end)
end)

function LevelManager:LoadData()
    local f = io.open(self.path, "r")
    if not f then
        print("CRITICAL ERROR: Failed to open file: ".. self.path)
        return
    end

    self.ranks = json.decode(f:read("*a"))

    f:close()
end

function LevelManager:SaveData()
	local f = io.open(self.path, "w")
    if not f then
        print("CRITICAL ERROR: Failed to open file: ".. self.path)
        return
    end

    for id, val in pairs(self.delta) do
        self.ranks[id] = (self.ranks[id] or 0) + val
    end
    self.delta = {}

    f:write(json.encode_compliant(self.ranks))

    f:close()
end

function LevelManager:DoDelta(id, delta)
    self.delta[id] = (self.delta[id] or 0) + delta
    
    --self.inst:PushEvent("ranks_changed", self.ranks)
end

function LevelManager:GetWxp(id)
    return self.ranks[id] or 0
end

function LevelManager:GetDelta(id)
    return self.delta[id] or 0
end

return LevelManager

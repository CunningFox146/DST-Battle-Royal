local LevelManager = Class(function(self, inst)
    self.inst = inst
	
    self.path = "br_ranks.json"

    self.ranks = {}
    
    self:LoadData()

    self.inst:ListenForEvent("ms_save", function() self:SaveData() end)
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

    f:write(json.encode_compliant(self.ranks))

    f:close()
end

function LevelManager:AddKill(id)
    self.ranks[id] = (self.ranks[id] or 0) + 1
    
    self.inst:PushEvent("ranks_changed", self.ranks)
end

function LevelManager:AddDeath(id)
    self.ranks[id] = math.max((self.ranks[id] or 0) - 0.5, 0)
    
    self.inst:PushEvent("ranks_changed", self.ranks)
end

function LevelManager:PlayerWon(id)
    self.ranks[id] = math.max((self.ranks[id] or 0) + 3, 0)
    
    self.inst:PushEvent("ranks_changed", self.ranks)
end

function LevelManager:GetRank(id)
    return math.floor(self.ranks[id] or 0)
end

return LevelManager

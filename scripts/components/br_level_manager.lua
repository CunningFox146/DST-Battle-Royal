local LevelManager = Class(function(self, inst)
    self.inst = inst
	
	self._data = net_string(inst.GUID, "hg_level_manager._data", "hg_level_dirty")
	
	self.ismastersim = TheWorld.ismastersim
	
	if self.ismastersim then
		local rebuild = function() self:RebuildData() end
		inst:ListenForEvent("ms_clientauthenticationcomplete", rebuild, TheWorld)
		inst:ListenForEvent("ranks_changed", rebuild, TheWorld)
		inst:DoTaskInTime(0, rebuild)
	end
	
	if not TheNet:IsDedicated() then
		self.data = {}
		
		local function UpdateLevel()
			self:UpdateLevel()
		end
		
		inst:ListenForEvent("hg_level_dirty", UpdateLevel)
		inst:DoTaskInTime(0, UpdateLevel)
	end
	
	if CHEATS_ENABLED then
		rawset(_G, "prdat", function()
			printwrap("data", self.data)
		end)
	end
end)

function LevelManager:RebuildData()
	local levels = {}
	for _, data in ipairs(TheNet:GetClientTable()) do
		local rank = self:GetLevel(data.userid)
		if rank ~= 0 then
			levels[data.userid] = rank
		end
	end
	self._data:set(DataDumper(levels))
end

function LevelManager:UpdateLevel()
	self.data = loadstring(self._data:value())()
	TheWorld:PushEvent("ms_leveldataupdated", self.data)
end

function LevelManager:GetLevel(id)
	if self.ismastersim then
		return TheWorld.components.br_progress:GetRank(id)
	end
	return self.data[id] or 0
end

return LevelManager

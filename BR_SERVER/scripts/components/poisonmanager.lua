local function SpawnPrefabsAround(obj, prefab, n, radius)
	local spawned = {}
	local x0, y0, z0 = 0, 0, 0
	
	if obj.Get then
		x0, y0, z0 = obj:Get()
	elseif obj.Transform then
		x0, y0, z0 = obj.Transform:GetWorldPosition()
	end
	
	local theta = math.random() * 2 * PI
	for i = 1, n do
		local a = i / n * 2 * PI + theta
		local pos = Vector3(x0 + math.cos(a)*radius, 0, z0 + math.sin(a) * radius)
		
		local sp = SpawnAt(prefab, pos)
		
		if sp then
			table.insert(spawned, sp)
		end
	end
	
	return spawned
end

local PoisonFog = Class(function(self, inst)
	self.inst = inst
	
	self.cached_dots = {}

	self.center = nil
	self.delta = nil
	
	self.min_range = TILE_SCALE * 3

	self.current_scale = nil
	self.scale_time = 50
	self.scale_num = 5
	self.scale_period = self.scale_time / self.scale_num

	self.task = nil
end)

-- Get range (GetPoisonRange), range - min_range,
-- delta = range / n

function PoisonFog:Recalculate()
	local range = math.sqrt(self.inst.components.battleroyale:GetPoisonRange())
	local total_range = range - self.min_range

	self.center = self.inst.components.battleroyale:GetCenter()
	
	self.current_scale = range
	self.delta = total_range / self.scale_num
end

function PoisonFog:StartFog() --TheWorld.components.poisonmanager:StartFog()
	self:Stop()
	self:ClearDots()
	self:Recalculate()
	
	self:CreateDots(self.current_scale)
	self:Start()
end

function PoisonFog:CreateDots(r)
	self:ClearDots()
	self.cached_dots = SpawnPrefabsAround(self.center, "poison_dot", r * 0.5, r)
end

function PoisonFog:ClearDots()
	for i, dot in ipairs(self.cached_dots) do
		dot:StopFx()
	end
end

function PoisonFog:Stop()
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function PoisonFog:Start()
	self.task = self.inst:DoPeriodicTask(self.scale_period, function() self:Update() end)
end

function PoisonFog:Update()
	self:ClearDots()

	self.current_scale = math.max(self.current_scale - self.delta, self.min_range)

	self:CreateDots(self.current_scale)

	if self.current_scale == self.min_range then
		self:Stop()
	end
end

return PoisonFog
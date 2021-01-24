local data = {}

function data:fog(inst)
	inst.persists = false
	
	function inst:StopFx()
		if inst.icon then
			inst.icon:Remove()
		end
		
		inst:Remove()
	end
	
	inst:DoTaskInTime(0, function()
		if not inst.icon then
			inst.icon = SpawnPrefab("globalmapicon")
			inst.icon:TrackEntity(inst)
		end
	end)	
end

return data
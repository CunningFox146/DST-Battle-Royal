return function(inst)
	function inst:Set(target, damage)
		inst.target:set(target)
		inst.damage:set(damage)
	end
	
	inst:DoTaskInTime(1, inst.Remove) -- Offset for client
	
	inst.persists = false
end

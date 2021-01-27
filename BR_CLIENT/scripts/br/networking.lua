local function OnEntityReplicated(inst)
    if not inst._parent then
        return
    end
    
	for i, v in ipairs({ "spectator" }) do
		if inst._parent.replica[v] then
			inst._parent.replica[v]:AttachClassified(inst)
		end
	end
end

local function OnFalling(inst)
	local parent = inst._parent
	if not parent then
		return
	end

	if inst.falling:value() then
		TheCamera:SetControllable(false)
		TheMixer:PushMix("high")
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/clouds", "falling_wind")
	else
		TheCamera:SetControllable(true)
		TheMixer:PopMix("high")
		TheFocalPoint.SoundEmitter:KillSound("falling_wind")
	end
end

local function OnFogDirty(inst)
    local parent = inst._parent
    if not parent or not parent.components.playervision then
        return
    end

    local old = parent.components.playervision.infog
    local val = inst.infog:value()
    
    parent.components.playervision.infog = val
    
    if old ~= val then
        parent.components.playervision:UpdateCCTable()
    end
end

local function OnSpectatorModeDirty(inst)
    if not inst._parent or not inst._parent.HUD then
		return
	end
	
	if inst.isspectator:value() then
		inst._parent.HUD.controls.hg_spectator_wgt:Show()
		
		inst._parent.HUD.controls.inv:Hide()
		inst._parent.HUD.controls.crafttabs:Hide()
		inst._parent.HUD.controls.status:Hide()
	else
		inst._parent.HUD.controls.hg_spectator_wgt:Hide()
        
		inst._parent.HUD.controls.inv:Show()
		inst._parent.HUD.controls.crafttabs:Show()
		inst._parent.HUD.controls.status:Show()
	end
end

local function OnCameraSnap(inst)
	if not inst._parent or not inst._parent.components.spectator then
		return
	end
	inst._parent.components.spectator:ForceUpdate()
end

return function(inst)
    inst.infog = net_bool(inst.GUID, "battleroyale._infog", "infogdirty")
	
	-- Spectators
	inst.spectator = {
		target = net_entity(inst.GUID, "spectator._target", "spect_target_dirty"),
		spectators = net_smallbyte(inst.GUID, "spectator._spectators", "spect_amount_dirty"),
    }
	inst.isspectator = net_bool(inst.GUID, "spectator._isspectator", "isspectatordirty")
	
	inst.falling = net_bool(inst.GUID, "battleroyale._falling", "fallingdirty")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("infogdirty", OnFogDirty)
		inst:ListenForEvent("isspectatordirty", OnSpectatorModeDirty)
		inst:ListenForEvent("fallingdirty", OnFalling)
	end
	
	if not TheWorld.ismastersim then
		local _OnEntityReplicated = inst.OnEntityReplicated
        function inst:OnEntityReplicated(...)
			local val = {_OnEntityReplicated(inst, ...)}
			OnEntityReplicated(inst)
			return unpack(val)
		end
	else
		inst:ListenForEvent("playercamerasnap", OnCameraSnap)
	end
end
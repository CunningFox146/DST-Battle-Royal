local RANGE = 14
local FX_HEIGHT = 10
local FX_PERIOD = 22 * FRAMES
local SCALE = .675

local assets = {
	Asset("ANIM", "anim/moonbase_fx.zip")
}

local function RotateToTarget(inst, dest)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local dz = pz - dest.z
    local dx = dest.x - px
    local angle = math.atan2(dz, dx) / DEGREES
	
	inst.Transform:SetRotation(angle - 90)
end

local function PlayPoison(proxy)
	local function DoFx(inst)
		local pos1 = inst:GetPosition()
		for _, other in ipairs(TheSim:FindEntities(pos1.x, 0, pos1.z, RANGE, {"POISON"})) do
			if other ~= inst then
				local pos2 = other:GetPosition()
				
				local fx = SpawnAt("poison_fx", Vector3(pos1.x, math.random() * FX_HEIGHT, pos1.z))
				fx.AnimState:SetScale(SCALE, SCALE * (math.random() <= 0.5 and 1 or -1))
				
				fx:ListenForEvent("onremove", function() fx:DoRemove() end, proxy)
				RotateToTarget(fx, pos2)
			end
		end
		
		inst.fx_task = inst:DoTaskInTime(FX_PERIOD, DoFx)
	end

    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("POISON")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddClientSleepable()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

	inst.AnimState:SetBank("lunar_fx")
	inst.AnimState:SetBuild("moonbase_fx")
	inst.AnimState:HideSymbol("lunar_spotlight")
	inst.AnimState:PlayAnimation("lunar_back_pre")
	inst.AnimState:PushAnimation("lunar_back_loop", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetFinalOffset(0)
	
	inst:DoTaskInTime(FX_PERIOD, DoFx)
	
    inst.OnEntitySleep = function(inst)
		if inst.fx_task then
			inst.fx_task:Cancel()
			inst.fx_task = nil
		end
	end
	
	inst.OnEntityWake = DoFx
	
	inst:DoTaskInTime(0, function()
		inst.SoundEmitter:PlaySound("HG_sounds/fog/loop", "loop")
		inst.SoundEmitter:PlaySound("HG_sounds/fog/spawn")
	end)
	
	inst:ListenForEvent("onremove", function()
		if inst.fx_task then
			inst.fx_task:Cancel()
			inst.fx_task = nil
		end
		
		inst.SoundEmitter:KillSound("loop")
		inst.SoundEmitter:PlaySound("HG_sounds/fog/despawn")
		inst.AnimState:PlayAnimation("lunar_back_pst")
		inst:DoTaskInTime(17 * FRAMES, inst.Remove)
	end, proxy)
	
    proxy.poison = inst
end

local function fn() --inst = c_spawn("poison_dot")
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("fog.tex")
	inst.MiniMapEntity:SetCanUseCache(false)
	inst.MiniMapEntity:SetDrawOverFogOfWar(true)
	
	inst:AddTag("FX")
	inst:AddTag("poison_dot")
	
	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, function()
			if not inst.poison then
				PlayPoison(inst)
			end
		end)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	local server_fn = TheServerData:GetServerData("prefabs/fog")
	if server_fn then
		server_fn:fog(inst)
	end

	return inst
end

local function fx() -- inst = c_spawn "poison_fx" inst:DoRemove()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("FX")
	
	inst.AnimState:SetBank("lunar_fx")
	inst.AnimState:SetBuild("moonbase_fx")
	inst.AnimState:PlayAnimation("lunar_front_pre")
	inst.AnimState:PushAnimation("lunar_front_loop")
	inst.AnimState:PushAnimation("lunar_front_pst")

	inst.AnimState:HideSymbol("lunar_glow")

	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetLightOverride(1)
	
	inst.persists = false
	
	inst.Task = inst:DoTaskInTime(2.268, inst.Remove)
	
	function inst:DoRemove()
		inst.AnimState:PlayAnimation("lunar_front_pst")
		inst.AnimState:SetTime(.25)
		
		inst:ListenForEvent("animover", inst.Remove)
	end
	
	return inst
end

return Prefab("poison_dot", fn, assets),
	   Prefab("poison_fx", fx, assets)
local DAMAGE = -2
local PERIOD = 1

local assets =
{
    Asset("ANIM", "anim/lavaarena_item_pickup_fx.zip"),
}

local function DoDamage(inst, target)
	if not target.spectator and
	target.components.health and
    not target.components.health:IsDead() then
        target.components.health:DoDelta(DAMAGE, "lunar_zone")
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)

    inst.task = inst:DoPeriodicTask(PERIOD, DoDamage, nil, target)
end

local function OnDetached(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	
	inst:RemoveTag("lunar_zone")
	
	inst.AnimState:PlayAnimation("pst")
	inst:ListenForEvent("animover", inst.Remove)
end

local function DoRemove(inst)
    inst.components.debuff:Stop()
end

local function OnInit(inst)
    local parent = inst.entity:GetParent()
    if parent then
        parent:PushEvent("start_lunar_zone", inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_item_pickup_fx")
    inst.AnimState:SetBuild("lavaarena_item_pickup_fx")
	inst.AnimState:PlayAnimation("pre")
	inst.AnimState:PushAnimation("loop", true)
	inst.AnimState:SetFinalOffset(3)
	inst.AnimState:SetLightOverride(1)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("lunar_zone")

    inst:DoTaskInTime(0, OnInit)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
	
	inst.DoRemove = DoRemove

    inst.entity:SetCanSleep(false)
    inst.persists = false
    
    return inst
end

return Prefab("lunar_disaster_fx", fn, assets)
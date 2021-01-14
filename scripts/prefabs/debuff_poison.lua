local DURATION = 5
local DAMAGE = -10
local PERIOD = 1
local DPS = DAMAGE / (DURATION / PERIOD)

local assets =
{
    Asset("ANIM", "anim/poison.zip"),
}

local function DoDamage(inst, target)
    if target.components.health and
    not target.components.health:IsDead() and
    not target:HasTag("playerghost") then
        target.components.health:DoDelta(DPS, nil, inst.entity:GetParent() or inst)
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
    
    inst.AnimState:PlayAnimation("level2_pst")
    inst:ListenForEvent("animover", inst.Remove)
end

local function OnExtend(inst)
    inst.components.timer:SetTimeLeft("remove", DURATION)
end

local function OnTimerDone(inst)
    inst.components.debuff:Stop()
end

local function OnInit(inst)
    local parent = inst.entity:GetParent()
    if parent then
        parent:PushEvent("startpoisondebuff", inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("poison")
    inst.AnimState:SetBuild("poison")
    inst.AnimState:PlayAnimation("level2_pre")
    inst.AnimState:PushAnimation("level2_loop", true)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst:DoTaskInTime(0, OnInit)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtend)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("remove", DURATION)
    inst:ListenForEvent("timerdone", OnTimerDone)
    
    inst.persists = false
    
    return inst
end

return Prefab("debuff_poison", fn, assets)

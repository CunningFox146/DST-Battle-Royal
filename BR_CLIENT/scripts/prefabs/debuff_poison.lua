local DURATION = 5
local DAMAGE = -10
local PERIOD = 0.5
local DPS = DAMAGE / (DURATION / PERIOD)

local assets =
{
    Asset("ANIM", "anim/poison.zip"),
}

local function IsCrownActive(inst)
    local inv = inst.components.inventory
    if not inv then
        return false
    end

    local hat = inv:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat and hat.prefab == "ruinshat" and hat._fx then
        return true
    end
    return false
end

local function DoDamage(inst, target)
    if target.components.health and
    not target.components.health:IsDead() and
    not IsCrownActive(target) then
        local parent = inst.entity:GetParent()
        local source = parent and parent.owner or inst
        
        target.components.health:DoDelta(DPS, nil, nil, nil, source, true)
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
    inst.AnimState:SetDeltaTimeMultiplier(1.5)

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

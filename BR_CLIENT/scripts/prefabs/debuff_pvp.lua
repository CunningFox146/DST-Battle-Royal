local DURATION = TheNet:GetIsServer() and TUNING.BATTLE_ROYALE.PVP_SLOWDOWN_DURATION or 0

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)

    target:AddTag("groggy")
    target.components.locomotor:SetExternalSpeedMultiplier(inst, "debuff_pvp", TUNING.BATTLE_ROYALE.PVP_SLOWDOWN)
end

local function OnDetached(inst)
    local parent = inst.entity:GetParent()
    if parent then
        parent.components.locomotor:RemoveExternalSpeedMultiplier(inst, "debuff_pvp")

        if parent.components.grogginess and not parent.components.grogginess:HasGrogginess() then
            parent:RemoveTag("groggy")
        end
    end
    inst:Remove()
end

local function OnExtend(inst)
    inst.components.timer:SetTimeLeft("remove", DURATION)
end

local function OnTimerDone(inst)
    inst.components.debuff:Stop()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")
    inst:AddTag("FX")

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

return Prefab("debuff_pvp", fn)

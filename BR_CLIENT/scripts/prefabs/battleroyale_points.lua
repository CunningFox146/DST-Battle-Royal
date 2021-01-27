local function center()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    
    TheWorld.center = inst

    inst.entity:SetCanSleep(false)
    inst.persists = false
    
    inst:AddTag("CLASSIFIED")
    inst:AddTag("center_battleroyale")

    inst.entity:SetPristine()

    TheWorld:PushEvent("ms_register_br_center", inst)

    return inst
end

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    return inst
end

local function spawnpoint()
    local inst = common()

    inst:AddTag("spawnpoint_battleroyale")

    TheWorld:PushEvent("ms_register_br_spawnpoint", inst)

    return inst
end

local function range()
    local inst = common()

    inst:AddTag("range_battleroyale")

    TheWorld:PushEvent("ms_register_br_range", inst)

    return inst
end

return Prefab("spawnpoint_battleroyale", spawnpoint),
       Prefab("center_battleroyale", center),
       Prefab("range_battleroyale", range)
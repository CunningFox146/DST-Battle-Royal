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

local function center()
    local inst = common()

    inst:AddTag("center_battleroyale")

    TheWorld:PushEvent("ms_register_br_center", inst)

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
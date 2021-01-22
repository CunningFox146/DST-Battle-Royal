local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddTag("spawnpoint_battleroyale")

    TheWorld:PushEvent("ms_register_br_spawnpoint", inst)
    print("Pushed ms_register_br_spawnpoint")

    return inst
end

return Prefab("spawnpoint_battleroyale", fn)
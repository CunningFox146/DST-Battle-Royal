local function PostInit(inst)
    inst:LongUpdate(0)
    inst.entity:FlushLocalDirtyNetVars()

    for k, v in pairs(inst.components) do
        if v.OnPostInit ~= nil then
            v:OnPostInit()
        end
    end
end

local function OnRemoveEntity(inst)
    if TheWorld ~= nil then
        assert(TheWorld.net == inst)
        TheWorld.net = nil
    end
end

local function DoPostInit(inst)
    if not TheWorld.ismastersim then
        if TheWorld.isdeactivated then
            --wow what bad timing!
            return
        end
        --master sim would have already done a proper PostInit in loading
        TheWorld:PostInit()
    end
    if not TheNet:IsDedicated() then
        if ThePlayer == nil then
            TheNet:SendResumeRequestToServer(TheNet:GetUserID())
        end
        PlayerHistory:StartListening()
    end
end

local prefabs =
{
    "thunder_close",
    "thunder_far",
    "lightning",
}

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    assert(TheWorld ~= nil and TheWorld.net == nil)
    TheWorld.net = inst

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddNetwork()
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    inst:AddComponent("autosaver")
    inst:AddComponent("worldvoter")
    inst:AddComponent("worldcharacterselectlobby")
    
    inst:AddComponent("br_level_manager")
    inst:AddComponent("character_unlocker")
    TheWorld.character_unlocker = inst.components.character_unlocker
    
    -- inst:AddComponent("clock")
    -- inst:AddComponent("worldtemperature")
    -- inst:AddComponent("seasons")
    -- inst:AddComponent("worldreset")

    inst.PostInit = PostInit
    inst.OnRemoveEntity = OnRemoveEntity

    inst:DoTaskInTime(0, DoPostInit)

    return inst
end

return Prefab("battleroyale_network", fn, nil, prefabs)

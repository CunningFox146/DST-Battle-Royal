local function PushDamageNumber(player, target, damage)
	local size = math.clamp(math.ceil(48 * damage / 70), 32, 48)
    player.HUD:ShowPopupNumber(damage, size, target:GetPosition(), 40, { 255 / 255, 80 / 255, 40 / 255, 1 }, size > 40)
end

local function OnDamageDirty(inst)
    if inst.target:value() ~= nil then
        local player = inst.entity:GetParent()
        if player ~= nil and player.HUD ~= nil then
            PushDamageNumber(player, inst.target:value(), inst.damage:value())
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:Hide()

    inst.target = net_entity(inst.GUID, "damagenumber.target")
    inst.damage = net_shortint(inst.GUID, "damagenumber.damage", "damagedirty")

    inst:AddTag("CLASSIFIED")

	if not TheNet:IsDedicated() then
        inst:ListenForEvent("damagedirty", OnDamageDirty)
	end
	
    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

	local server_fn = TheServerData:GetServerData("prefabs/damagenumber")
	if server_fn then
		server_fn(inst) 
	end

    return inst
end

return Prefab("damagenumber", fn)

local env = env
GLOBAL.setfenv(1, GLOBAL)

-- Wortox
TUNING.WORTOX_MAX_SOULS = 8
require("prefabs/wortox_soul_common").DoHeal = function() return true end

-- Wolfgang

TUNING.WOLFGANG_HEALTH_MIGHTY = 250
TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX = 1.5

-- Scout
env.AddPrefabPostInit("tf2scout", function(inst)
    inst.components.health:SetMaxHealth(200)
end)

-- Adora
if MOD_RPC_HANDLERS["adora"] then
    local _fn = MOD_RPC_HANDLERS["adora"][MOD_RPC["adora"]["SHERA"].id]
    MOD_RPC_HANDLERS["adora"][MOD_RPC["adora"]["SHERA"].id] = function(inst, ...)
        _fn(inst, ...)

        if inst:HasTag("playerghost") then return end
        if inst.sg:HasStateTag("busy") then return end
        
        if inst.shera then
            inst.components.hunger.burnratemodifiers:SetModifier(inst, 7)
        else
	        inst.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end
end

-- Zoro
env.AddPrefabPostInit("zoro", function(inst)
    inst.starting_inventory = nil
end)

-- Wort
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

env.AddPrefabPostInit("wort", function(inst)
    if inst._onattackother then
        return
    end

    inst._onattackother = function(attacker, data)
        if data.projectile then
            return
        elseif data.weapon then
            if data.weapon.components.projectile then
                return
            elseif data.weapon.components.complexprojectile then
                return
            elseif data.weapon.components.weapon:CanRangedAttack() then
                return
            end
        end
        
        local target = data.target
        if target and target:IsValid() and attacker:IsValid() and
        target.components.debuffable and target.components.debuffable:IsEnabled() and
        target.components.health and not target.components.health:IsDead() and not target.components.health:IsInvincible() and
        not IsCrownActive(target) then
            target.components.debuffable:AddDebuff("debuff_poison", "debuff_poison")
            target.components.debuffable.debuffs["debuff_poison"].owner = inst
        end
    end
    inst:ListenForEvent("onattackother", inst._onattackother)
end)

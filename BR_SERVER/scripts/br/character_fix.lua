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

-- Fox: Woby spawns in air
do
    local function SpawnWoby(inst)
        if inst.spectator or inst.woby or inst.sg:HasStateTag("falling") then
            return
        end
    
        local attempts = 0
        
        local max_attempts = 30
        local x, y, z = inst.Transform:GetWorldPosition()
    
        local woby = SpawnPrefab(TUNING.WALTER_STARTING_WOBY)
        inst.woby = woby
        woby:LinkToPlayer(inst)
        inst:ListenForEvent("onremove", inst._woby_onremove, woby)
        local fx = SpawnPrefab(woby.spawnfx)
        fx.entity:SetParent(woby.entity)
        
        while true do
            local offset = FindWalkableOffset(inst:GetPosition(), math.random() * PI, 2, 10)
    
            if offset then
                local spawn_x = x + offset.x
                local spawn_z = z + offset.z
                
                if attempts >= max_attempts then
                    woby.Transform:SetPosition(spawn_x, y, spawn_z)
                    break
                elseif not IsAnyPlayerInRange(spawn_x, 0, spawn_z, 2) then
                    woby.Transform:SetPosition(spawn_x, y, spawn_z)
                    break
                else
                    attempts = attempts + 1
                end
            elseif attempts >= max_attempts then
                woby.Transform:SetPosition(x, y, z)
                break
            else
                attempts = attempts + 1    
            end
        end
    
        return woby
    end
    
    local function OnDeath(inst)
        if inst.woby then
            inst.woby.sg:GoToState("nuzzle")
            inst.woby:DoTaskInTime(1, function()
                inst.woby:OnPlayerLinkDespawn(inst)
                inst.woby = nil
            end)
        end
    end
    
    local function OnRespawn(inst)
        inst:DoTaskInTime(4, SpawnWoby)
    end
    
    env.AddPrefabPostInit("walter", function(inst)
        inst._woby_spawntask:Cancel()
        inst._woby_spawntask = inst:DoTaskInTime(2, function() end)
        inst._woby_onremove = function(woby)
            
        end

        inst:ListenForEvent("done_falling", SpawnWoby)
        
        inst.SpawnWoby = SpawnWoby
        inst:ListenForEvent("respawnfromghost", OnRespawn)
        inst:ListenForEvent("death", OnDeath)
    end)
end
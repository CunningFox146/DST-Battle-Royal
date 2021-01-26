local function DoHurtSound(inst)
    if inst.hurtsoundoverride then
        inst.SoundEmitter:PlaySound(inst.hurtsoundoverride, nil, inst.hurtsoundvolume)
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/hurt", "player_hurt", inst.hurtsoundvolume)
    end
end

return {
	State{
        name = "spawn_on_arena",
        tags = { "busy", "nopredict", "nomorph", "nodangle", "nointerrupt" },

        onenter = function(inst, fn)
            inst.AnimState:PlayAnimation("flying_loop", true)
			
			if inst.components.health then
				inst.components.health:SetInvincible(true)
            end
            
            if inst.components.playercontroller then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.DynamicShadow:Enable(false)

            inst.sg.statemem.camera = {
                min = 15,
                max = 35,
            }
            inst.sg.statemem.maxdist = TUNING.BATTLE_ROYALE.SPAWN_HEIGHT
            inst.sg.statemem.falling = false
            inst.sg.statemem.motor_vel_active = false
            inst.sg.statemem.last_hurt = 0

            inst:SetCameraDistance(inst.sg.statemem.camera.max)
            inst:SnapCamera()

            if inst.player_classified then
                inst.player_classified.falling:set(true)
            end
        end,
		
        onupdate = function(inst, dt)
            if not inst.sg.statemem.falling then
                return
            end

            if GetTime() - inst.sg.statemem.last_hurt > 0.5 then
                DoHurtSound(inst)
                inst.SoundEmitter:SetVolume("player_hurt", 0.1)
                inst.sg.statemem.last_hurt = GetTime()
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            
            if not inst.sg.statemem.motor_vel_active then
                inst.Physics:SetMotorVel(0, TUNING.BATTLE_ROYALE.FALLING_SPEED, 0)
                inst.sg.statemem.motor_vel_active = true
            end

            local delta = inst.sg.statemem.camera.max - inst.sg.statemem.camera.min
            local prcnt = math.max(y / inst.sg.statemem.maxdist, 0)
            local dist = inst.sg.statemem.camera.min + delta * prcnt
            inst:SetCameraDistance(dist)

            if y <= .1 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)

                inst.sg:GoToState("spawn_on_arena_pst", true)
            end
		end,
		
        timeline =
        {
            TimeEvent(1, function(inst) -- So fade removes first
                inst.sg.statemem.falling = true
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            inst.DynamicShadow:Enable(true)
            inst:SetCameraDistance()
            inst.SoundEmitter:KillSound("player_hurt")

            if inst.player_classified then
                inst.player_classified.falling:set(false)
            end
        end,
    },

    State{
        name = "spawn_on_arena_pst",
        tags = { "busy", "nopredict", "nomorph", "nodangle", "nointerrupt" },

        onenter = function(inst, fn)
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            inst.AnimState:PlayAnimation("flying_land", false)
        end,
        
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.components.health then
				inst.components.health:SetInvincible(false)
            end

            if inst.components.playercontroller then
                inst.components.playercontroller:Enable(true)
                inst.components.playercontroller:EnableMapControls(true)
            end
        end,
    },
}

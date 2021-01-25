local env = env
GLOBAL.setfenv(1, GLOBAL)

if not env.MODROOT:find("workshop-") then
    CHEATS_ENABLED = true
    NetworkProxy.GetPVPEnabled = function() return true end
end

env.AddReplicableComponent("spectator")

require("server_data")

require("br/constants")
require("br/util")
require("br/strings")
require("br/rpc")

env.modimport("scripts/br/recipes.lua")
env.modimport("scripts/br/ui.lua")
env.modimport("scripts/br/level_util.lua")

env.AddComponentPostInit("playervision", function(self)
    self.SetGhostVision = function() end

    self.infog = false
	
	local texture = resolvefilepath("images/colour_cubes/bat_vision_on_cc.tex")
	local FOG_COLOURCUBES =
	{
		day = texture,
		dusk = texture,
		night = texture,
		full_moon = texture,
	}
	
	local FOG_PHASEFN =
	{
		blendtime = .5,
		events = {},
		fn = nil,
    }

	local _UpdateCCTable = self.UpdateCCTable
    function self:UpdateCCTable(...)
		if self.infog then
			if FOG_COLOURCUBES ~= self.currentcctable then
				self.currentcctable = FOG_COLOURCUBES
				self.currentccphasefn = FOG_PHASEFN
				self.inst:PushEvent("ccoverrides", FOG_COLOURCUBES)
				self.inst:PushEvent("ccphasefn", FOG_PHASEFN)
			end
		else
			_UpdateCCTable(self, ...)
		end
	end
end)

env.AddPrefabPostInit("player_classified", require("br/networking"))
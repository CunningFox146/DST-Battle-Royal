local env = env
GLOBAL.setfenv(1, GLOBAL)

if not env.MODROOT:find("workshop-") then
    CHEATS_ENABLED = true
    NetworkProxy.GetPVPEnabled = function() return true end
end

require("server_data")

require("br/constants")
require("br/util")
require("br/strings")

env.modimport("scripts/br/recipes.lua")
env.modimport("scripts/br/ui.lua")
env.modimport("scripts/br/level_util.lua")

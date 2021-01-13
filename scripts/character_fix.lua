local env = env
GLOBAL.setfenv(1, GLOBAL)

-- Wortox
TUNING.WORTOX_MAX_SOULS = 8
require("prefabs/wortox_soul_common").DoHeal = function() return true end

-- Wolfgang

TUNING.WOLFGANG_HEALTH_MIGHTY = 250
TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX = 1.5
-- Fox: Game  duration is about 10 minutes
local GAME_DURATION = 10 * 60

if CHEATS_ENABLED then
    TUNING.BATTLE_ROYALE = {
        SPAWN_HEIGHT = 35,
        FALLING_SPEED = -15,
    
        GAME_DURATION = GAME_DURATION,
        WIN_DELAY = 10,
    
        FOG = { 
            START_TIME = 10,--120,
            SCALE_TIME = 50,--6 * 60,
            SCALE_NUMS = 5,--6,
            MIN_RANGE =  TILE_SCALE * 5.5,
        }
    }
else
    TUNING.BATTLE_ROYALE = {
        SPAWN_HEIGHT = 50,
        FALLING_SPEED = -15,
    
        GAME_DURATION = GAME_DURATION,
        WIN_DELAY = 10,
    
        FOG = { 
            START_TIME = 0.2 * GAME_DURATION,
            SCALE_TIME = 0.6 * GAME_DURATION,
            SCALE_NUMS = 6,
            MIN_RANGE =  TILE_SCALE * 5.5,
        }
    }
end
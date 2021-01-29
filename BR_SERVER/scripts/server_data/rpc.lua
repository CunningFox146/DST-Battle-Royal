local RPC = {}

RPC.SPECTRATE = function(inst, userid)
    if not inst or not inst.spectator then 
        return
    end
    
    local player = GetPlayerById(userid)
    if player then
        inst.components.spectator:SetTarget(player)
    end
end

return RPC
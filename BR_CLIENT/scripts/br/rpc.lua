local RPC_DATA = {
	"SPECTRATE",
}

for i, namespace in pairs(RPC_DATA) do
	AddModRPCHandler("BATTLE_ROYALE", namespace, function(...)
		if not TheNet:GetIsServer() then 
			return
		end
		
		local SERVER_FN = TheServerData:GetServerData("rpc")
		if SERVER_FN and SERVER_FN[namespace] then
			SERVER_FN[namespace](...)
		else
			print(string.format("ERROR:Tried to call invalid RPC \"%s\"", namespace))
		end
	end)
end

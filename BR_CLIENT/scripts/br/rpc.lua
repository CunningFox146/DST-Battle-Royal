local RPC_DATA = {
	"SPECTRATE",
}

for _, namespace in ipairs(RPC_DATA) do
	AddModRPCHandler("BATTLE_ROYALE", namespace, function(...)
		print("BATTLE_ROYALE RPC called")
		local SERVER_FN = TheServerData:GetServerData("rpc")
		if SERVER_FN and SERVER_FN[namespace] then
			SERVER_FN[namespace](...)
		else
			print(string.format("ERROR:Tried to call invalid RPC \"%s\"", namespace))
		end
	end)
end

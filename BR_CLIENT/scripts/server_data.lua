--Copyright (c) CunningFox. All rights reserved.
--Originaly made for Multi taste starvation server.

local ServerData = {
	version = 0.20,
	Cache = {},
	debug = false,
}

local function Print(...)
	if not ServerData.debug then return end
	print(...)
end

function ServerData:GetServerData(path)
	if not TheNet:GetIsServer() then
		print(
			string.format(
				"[Server Data]: Error! Tried to load data on client (%s) from\n%s",
				tostring(TheNet:GetIsServer()),
				CalledFrom()
			)
		)
		
		return
	end
	
	local fullpath = "server_data/"..path
	
    if ServerData.Cache[fullpath] == nil then
		Print("[Server Data]: About to load "..fullpath..". Request from "..CalledFrom())
		local res = softresolvefilepath("scripts/"..fullpath..".lua")
		
		if res ~= nil then
			Print("[Server Data]: Loaded "..fullpath)
			ServerData.Cache[fullpath] = require(fullpath)
		else
			print("[Server Data]: ERROR!\nFrom: "..CalledFrom())
			return
		end
    end
	
    return ServerData.Cache[fullpath]
end

function ServerData:ClearCache()
	ServerData.Cache = nil
	ServerData.Cache = {}
	print("[Server Data]: ServerData.Cache cleared!")
end
	
function ServerData:Debug() -- TheServerData:Debug()
	print("[Server Data]: ServerData.Cache contains:\n{")
	
	for k,v in pairs(ServerData.Cache) do
		print("\t"..tostring(k)..",")
	end
	
	print("}")
end
	
TheServerData = ServerData


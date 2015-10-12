os.loadAPI("ws/Client.lua"); local Client = _G["Client.lua"]

if select("#", ...) == 0 then
	print("Usage UpdateSafeZone [start|end]")
	return
end

local cmd = select(1, ...)

local x, y, z = gps.locate()
if cmd == "start" then
	sendMessage("setSafeStart " .. x .. ", " .. z)
elseif cmd == "end" then
	sendMessage("setSafeEnd " .. x .. ", " .. z)
end

--print(response.x .. ", " .. response.y)
--
--local response = Client.sendMessage("getSafeEnd")
--print(response.x .. ", " .. response.y)
os.loadAPI("ws/Client.lua"); local Client = _G["Client.lua"]

local response = Client.sendMessage("getSafeStart")
print(response.x .. ", " .. response.z)

local response = Client.sendMessage("getSafeEnd")
print(response.x .. ", " .. response.z)
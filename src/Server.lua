os.loadAPI("ws/log.lua"); local log = _G["log.lua"]
os.loadAPI("ws/Constants.lua"); local Constants = _G["Constants.lua"]
os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]

if not os.getComputerLabel() then
	os.setComputerLabel("Unnamed"..os.getComputerID())
end

local x, y, z = gps.locate(5, false)
local label = os.computerLabel()
local id = os.computerID()
local day = os.day()

log.info("Running CraftOS: "..os.version())
log.info("Computer ["..label.."] ID: "..id)
log.info("World days: "..os.day())

local startTime = os.clock()

Peripherals.modem.open(Constants.GLOBAL_CHANNEL)
Peripherals.modem.open(Constants.COMMAND_CHANNEL)

local senderChannel, message = nil
while senderChannel ~= Constants.COMMAND_CHANNEL and message ~= Constants.COMMAND_MSG_STOP do
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

	if not (Constants.GLOBAL_MESSAGES[message] or Constants.COMMAND_MESSAGES[message]) then
		log.error("Unrecognized message ["..message.."] on channel: "..senderChannel.." reply channel: "..replyChannel.." at distance: "..senderDistance)
	else
		log.info("Message ["..message.."] on channel: "..senderChannel.." reply channel: "..replyChannel.." at distance: "..senderDistance)
	end

	if message == Constants.GLOBAL_MSG_ORIGIN then
		Peripherals.modem.transmit(replyChannel, Constants.GLOBAL_CHANNEL, {x, y, z})
	end
end

log.info("Server stopped, up time was "..(os.clock() - startTime));
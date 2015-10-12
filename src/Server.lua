os.loadAPI("ws/log.lua"); local log = _G["log.lua"]
os.loadAPI("ws/Constants.lua"); local Constants = _G["Constants.lua"]
os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]
os.loadAPI("ws/Utils.lua"); local Utils = _G["Utils.lua"]

if not os.getComputerLabel() then
	os.setComputerLabel("Unnamed"..os.getComputerID())
end

local x, y, z = gps.locate(5, false)
local label = os.computerLabel()
local id = os.computerID()
local day = os.day()

local World = {
	safeStartPos = {},
	safeEndPos = {}
}

log.info("Running CraftOS: "..os.version())
log.info("Computer ["..label.."] ID: "..id)
log.info("World days: "..os.day())

local startTime = os.clock()

Peripherals.modem.open(Constants.GLOBAL_CHANNEL)
Peripherals.modem.open(Constants.COMMAND_CHANNEL)

local senderChannel, message = nil
while senderChannel ~= Constants.COMMAND_CHANNEL and message ~= Constants.COMMAND_MSG_STOP do
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

	if message == nil then
		message = "Undefined"
	end

	local command = string.match(message, "^(%w+)")
	log.info("Command "..command)
	local params = string.sub(message, string.len(command) + 1)

	if not (Constants.GLOBAL_MESSAGES[command] or Constants.COMMAND_MESSAGES[command]) then
		log.error("Unrecognized command ["..command.."] on channel: "..senderChannel.." reply channel: "..replyChannel.." at distance: "..senderDistance)
	else
		log.info("Message ["..command.."] on channel: "..senderChannel.." reply channel: "..replyChannel.." at distance: "..senderDistance)
	end

	if command == Constants.GLOBAL_MSG_ORIGIN then
		Peripherals.modem.transmit(replyChannel, Constants.GLOBAL_CHANNEL, {x, y, z})
	elseif command == Constants.GLOBAL_MSG_SET_SAFE_POS_START then
		local x, y = string.match(params, "(%d+), ?(%d+)")
		World.safeStartPos = {x, y}
		Utils.print_r(World, log.info)
		log.info("Setting safe start: ("..x..", "..y..")")
	elseif command == Constants.GLOBAL_MSG_SET_SAFE_POS_END then
		local x, y = string.match(params, "(%d+), ?(%d+)")
		World.safeEndPos = {x, y}
		Utils.print_r(World, log.info)
		log.info("Setting safe end: ("..x..", "..y..")")
	end
end

log.info("Server stopped, up time was "..(os.clock() - startTime));
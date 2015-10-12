os.loadAPI("ws/log.lua"); local log = _G["log.lua"]
os.loadAPI("ws/Constants.lua"); local Constants = _G["Constants.lua"]
os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]
os.loadAPI("ws/Utils.lua"); local Utils = _G["Utils.lua"]

local serverPos = gps.locate(5, false)
local label = os.computerLabel()
local id = os.computerID()
local day = os.day()

local World = {}

function World:setSafeStart(pos)
	self.safeStartPos = pos
end

function World:setSafeEnd(pos)
	self.safeEndPos = pos
end

function World:getSafeStart()
	return self.safeStartPos
end

function World:getSafeEnd()
	return self.safeEndPos
end

function readWorld()
	local worldFile = io.open(Constants.WORLD_FILE, "r")
	local startStr = worldFile.read("*|")
	local endStr = worldFile.read("*|")
	io.close(worldFile)

	local sx, sz = string.match(startStr, "(%d+), ?(%d+)")
	local ex, ez = string.match(endStr, "(%d+), ?(%d+)")

	local world = {
		safeStartPos = {x=sx, z=sz},
		safeEndPos = {x=ex, z=ez},
		setSafeStart = World.setSafeStart,
		setSafeEnd = World.setSafeEnd,
		getSafeStart = World.getSafeStart,
		getSafeEnd = World.getSafeEnd
	}

	return world
end

local world = readWorld()

function writeWorld()
	fs.delete(Constants.WORLD_FILE)
	local worldFile = fs.open(Constants.WORLD_FILE, "w")
	local safeStart = world:getSafeStart()
	local safeEnd = world:getSafeEnd()

	worldFile.write("safeStartPos = " .. safeStart.x .. ", " .. safeStart.z .. "\n")
	worldFile.write("safeStartPos = " .. safeEnd.x .. ", " .. safeEnd.z .. "\n")

	io.close(worldFile)
end

local Commands = {}

Commands[Constants.GLOBAL_MSG_ORIGIN] = function()
	return serverPos;
end

Commands[Constants.GLOBAL_MSG_SET_SAFE_START] = function(params)
	local x, z = string.match(params, "(%d+), ?(%d+)")
	local pos = {x=x, z=z}
	world:setSafeStart(pos)
	log.info("Setting safe start: ("..x..", "..z..")")
	writeWorld()
	return pos
end

Commands[Constants.GLOBAL_MSG_SET_SAFE_END] = function(params)
	local x, z = string.match(params, "(%d+), ?(%d+)")
	local pos = {x=x, z=z}
	world:setSafeEnd(pos)
	log.info("Setting safe end: ("..x..", "..z..")")
	writeWorld()
	return pos
end

Commands[Constants.GLOBAL_MSG_GET_SAFE_START] = function()
	log.info("Getting safe start")
	return world:getSafeStart()
end

Commands[Constants.GLOBAL_MSG_GET_SAFE_END] = function()
	log.info("Getting safe end")
	return world:getSafeEnd()
end

log.info("Running CraftOS: "..os.version())
log.info("Computer ["..label.."] ID: "..id)
log.info("World days: "..os.day())

local startTime = os.clock()

Peripherals.modem.open(Constants.GLOBAL_CHANNEL)
Peripherals.modem.open(Constants.COMMAND_CHANNEL)

local senderChannel, message = nil
while senderChannel ~= Constants.COMMAND_CHANNEL and message ~= Constants.COMMAND_MSG_STOP do
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

	-- prevent null ptr
	if message == nil then
		message = "Undefined"
	end

	local command = string.match(message, "^(%w+)")
	local params = string.sub(message, string.len(command) + 1)

	log.info("Command "..command.." on channel: "..senderChannel.." reply channel: "..replyChannel.." at distance: "..senderDistance)
	log.info("  Params: ".. (params and params or "nil"))

	if type(Commands[command]) == "function" then
		local result = Commands[command](params)

		if result then
			Peripherals.modem.transmit(replyChannel, Constants.GLOBAL_CHANNEL, result)
		end
	else
		log.error("Unrecognized command ["..command.."]")
	end
end

log.info("Server stopped, up time was "..(os.clock() - startTime));
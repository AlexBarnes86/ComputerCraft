os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]

--TODO: Move this to a better place
if not os.getComputerLabel() then
	os.setComputerLabel("Unnamed"..os.getComputerID())
end

local LEVEL_TRACE = 1
local LEVEL_DEBUG = 2
local LEVEL_INFO = 3
local LEVEL_WARN = 4
local LEVEL_ERROR = 5

local LEVEL_NAMES = {
	[LEVEL_TRACE] = "TRACE",
	[LEVEL_DEBUG] = "DEBUG",
	[LEVEL_INFO] = "INFO",
	[LEVEL_WARN] = "WARN",
	[LEVEL_ERROR] = "ERROR"
}

local LEVEL_COLORS = {
	[LEVEL_TRACE] = colors.gray,
	[LEVEL_DEBUG] = colors.lightGray,
	[LEVEL_INFO] = colors.white,
	[LEVEL_WARN] = colors.yellow,
	[LEVEL_ERROR] = colors.red
}

local LOG_LEVEL = LEVEL_DEBUG

local LOG_DIR = "ws/logs/"
local res = http.get("http://www.timeapi.org/utc/now")
local date = string.match(res.readAll(), "^(%d%d%d%d%-%d%d%-%d%d)")
local LOG_FILE = LOG_DIR..os.computerLabel().."_"..date..".log"
local LOG_FD = fs.open(LOG_FILE, "a")

function log(level, message)
	if level >= LOG_LEVEL and level <= LEVEL_ERROR then
		local time = os.clock()
		local msg = message
		if(not message) then
			msg = "nil"
		end
		local msg = LEVEL_NAMES[level].." ["..time.."]: "..msg
		LOG_FD.writeLine(msg)
		LOG_FD.flush()
		print(msg)
		if Peripherals.monitor ~= nil then
			local prevColor = Peripherals.monitor.getTextColor()
			Peripherals.monitor.setTextColor(LEVEL_COLORS[level])
			Peripherals.monitorWrite(msg)
			Peripherals.monitor.setTextColor(prevColor)
		end
	end
end

function trace(message)
	log(LEVEL_TRACE, message)
end

function debug(message)
	log(LEVEL_DEBUG, message)
end

function info(message)
	log(LEVEL_INFO, message)
end

function warn(message)
	log(LEVEL_WARN, message)
end

function error(message)
	log(LEVEL_ERROR, message)
end
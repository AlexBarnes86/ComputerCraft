os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]

local LEVEL_TRACE = 1
local LEVEL_DEBUG = 2
local LEVEL_INFO = 3
local LEVEL_WARN = 4
local LEVEL_ERROR = 5

local LEVEL_NAMES = {}
LEVEL_NAMES[LEVEL_TRACE] = "TRACE"
LEVEL_NAMES[LEVEL_DEBUG] = "DEBUG"
LEVEL_NAMES[LEVEL_INFO] = "INFO"
LEVEL_NAMES[LEVEL_WARN] = "WARN"
LEVEL_NAMES[LEVEL_ERROR] = "ERROR"

local LEVEL_COLORS = {}
LEVEL_COLORS[LEVEL_TRACE] = colors.gray
LEVEL_COLORS[LEVEL_DEBUG] = colors.lightGray
LEVEL_COLORS[LEVEL_INFO] = colors.white
LEVEL_COLORS[LEVEL_WARN] = colors.yellow
LEVEL_COLORS[LEVEL_ERROR] = colors.red

local LOG_LEVEL = LEVEL_DEBUG

local LOG_DIR = "logs/"
local res = http.get("http://www.timeapi.org/utc/now")
local LOG_FILE = LOG_DIR..os.computerLabel().."_"..res.readAll()..".log"
local LOG_FD = fs.open(LOG_FILE, "a")

function log(level, message)
	if level >= LOG_LEVEL and level <= LEVEL_ERROR then
		local time = os.clock()
		local msg = LEVEL_NAMES[level].." ["..time.."]: "..message
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
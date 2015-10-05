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

local LOG_LEVEL = LEVEL_DEBUG

function log(level, message)
	if level >= LOG_LEVEL and level <= LEVEL_ERROR then
		local time = os.clock()
		local msg = LEVEL_NAMES[level].." ["..time.."]: "..message
		print(msg)
		if Peripherals.monitor ~= nil then
			Peripherals.monitorWrite(msg)
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
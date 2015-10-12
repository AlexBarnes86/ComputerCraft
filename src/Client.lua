os.loadAPI("ws/log.lua"); local log = _G["log.lua"]
os.loadAPI("ws/Constants.lua"); local Constants = _G["Constants.lua"]
os.loadAPI("ws/Peripherals.lua"); local Peripherals = _G["Peripherals.lua"]
os.loadAPI("ws/Utils.lua"); local Utils = _G["Utils.lua"]

Peripherals.modem.open(Constants.GLOBAL_CHANNEL)
Peripherals.modem.open(Constants.POCKET_CHANNEL)

function pullMessage()
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
	return message;
end

function sendMessage(message, noResponse)
	Peripherals.modem.transmit(Constants.GLOBAL_CHANNEL, Constants.POCKET_CHANNEL, message)
	if not noResponse then
		return pullMessage();
	end
end
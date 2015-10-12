modem = peripheral.wrap("back")
monitor = peripheral.wrap("top")

monitor.clear()
monitor.setTextScale(1)
monitor.setCursorPos(1, 1)

function monitorWrite(message)
	local x, y = monitor.getCursorPos()
	local width, height = monitor.getSize()

	monitor.setCursorPos(1, y);
	for startIdx = 1, #message, width do
		local msg = string.sub(message, startIdx, width)
		monitor.write(msg)

		if y >= height then
			monitor.scroll((y - height) + 1)
			y = height;
		else
			y = y + 1
		end

		monitor.setCursorPos(1, y);
	end
end
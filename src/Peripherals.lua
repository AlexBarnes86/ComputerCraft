modem = peripheral.wrap("back")
monitor = peripheral.wrap("top")

monitor.clear()
monitor.setTextScale(1)
monitor.setCursorPos(1, 1)

function monitorWrite(message)
	local x, y = monitor.getCursorPos()
	local width, height = monitor.getSize()

	--Reset to beginning of line
	monitor.setCursorPos(1, y);
	monitor.write(message)

	if y >= height then
		monitor.scroll((y - height) + 1)
		y = height;
	else
		y = y + 1
	end

	monitor.setCursorPos(1, y);
end
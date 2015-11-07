local InventoryItem = {}

function InventoryItem:print()
	print("Item: {name: "..self.name..", total: "..self.total..", slots: ["..table.concat(self.slots, ", ").."]}")
end

function newInventoryItem(name, total, slots)
	local item = {
		name = name,
		total = total,
		slots = slots
	}
	for k, v in pairs(InventoryItem) do
		item[k] = v
	end
	return item
end

local HEADING_FORWARD = 0
local HEADING_LEFT = 1
local HEADING_BACK = 2
local HEADING_RIGHT = 3

local Agent = {}

function Agent:turnLeft(n)
	n = n or 1
	for i = 1, n do
		self.heading = (self.heading + 1) % 4
		turtle.turnLeft()
	end
end

function Agent:turnRight(n)
	n = n or 1
	for i = 1, n do
		self.heading = (self.heading - 1) % 4
		turtle.turnRight()
	end
end

function Agent:forward(n)
	n = n or 1
	for i = 1, n do
		while not turtle.forward() do
			if turtle.detect() then
				turtle.dig()
			else
				turtle.attack()
			end
		end

		if self.heading == 0 then
			self.dy = self.dy + 1
		elseif self.heading == 1 then
			self.dx = self.dx - 1
		elseif self.heading == 2 then
			self.dy = self.dy - 1
		elseif self.heading == 3 then
			self.dx = self.dx + 1
		end
	end
end

function Agent:down(n)
	n = n or 1
	for i = 1, n do
		while not turtle.down() do
			if turtle.detectDown() then
				turtle.digDown()
			else
				turtle.attackDown()
			end
		end
		self.dz = self.dz - 1
	end
end

function Agent:up(n)
	n = n or 1
	for i = 1, n do
		while not turtle.up() do
			if turtle.detectUp() then
				turtle.digUp()
			else
				turtle.attackUp()
			end
		end
		self.dz = self.dz + 1
	end
end

function Agent:back(n)
	n = n or 1
	for i = 1, n do
		if not turtle.back() then
			self:turnLeft()
			self:turnLeft()
			self:forward()
			self:turnLeft()
			self:turnLeft()
		end

		if self.heading == 0 then
			self.dy = self.dy - 1
		elseif self.heading == 1 then
			self.dx = self.dx + 1
		elseif self.heading == 2 then
			self.dy = self.dy + 1
		elseif self.heading == 3 then
			self.dx = self.dx - 1
		end
	end
end

function Agent:placeDown()
	if turtle.detectDown() then
		turtle.digDown()
	end
	turtle.placeDown()
end

function Agent:uTurnRight()
	self:turnRight()
	self:forward()
	self:turnRight()
end

function Agent:uTurnLeft()
	self:turnLeft()
	self:forward()
	self:turnLeft()
end

function Agent:faceStartHeading()
	while self.heading ~= 0 do
		self:turnLeft()
	end
end

function Agent:faceHeading(heading)
	while self.heading ~= (heading % 4) do
		self:turnLeft()
	end
end

function Agent:build(map)
	self:up()

	for r = 1, #map do
		local startIdx = 1
		local endIdx = #map[r]
		local inc = 1
		
		if r % 2 == 0 then
			startIdx = #map[r]
			endIdx = 1
			inc = -1
		end

		for c = startIdx, endIdx, inc do
			if map[r][c] ~= 0 then
				self:placeDown()
			end

			if c ~= endIdx then
				self:forward()
			end
		end

		if r % 2 == 0 then
			self:uTurnRight()
		else
			self:uTurnLeft()
		end
	end
end

function Agent:moveTo(x, y, z)
	local origHeading = self.heading
	self:faceStartHeading()

	self:move(x - self.dx, y - self.dy, z - self.dz)

	while self.heading ~= origHeading do
		self:turnLeft()
	end
end

function Agent:move(x, y, z)
	if y < 0 then
		self:turnRight()
		self:turnRight()
		self:forward(-y)
		self:turnRight()
		self:turnRight()
	elseif y > 0 then
		self:forward(y)
	end

	if x < 0 then
		self:turnLeft()
		self:forward(-x)
		self:turnRight()
	elseif x > 0 then
		self:turnRight()
		self:forward(x)
		self:turnLeft()
	end

	if z < 0 then
		self:down(-z)
	elseif z > 0 then
		self:up(z)
	end
end

function Agent:digSquare(width, length)
	for w = 1, width do
		self:forward(length - 1)

		if w ~= width then
			if w % 2 == 0 then
				self:uTurnLeft()
			else
				self:uTurnRight()
			end
		end
	end
end

function Agent:digCube(width, length, height)
	local sx, sy, sz = gps.locate()

	for h = 1, height do
		self:down()
		self:digSquare(width, length)
		self:moveTo(0, 0, self.dz)
		self:faceStartHeading()
	end
end

function Agent:buildStockpile(depth, width, length, height)
	self:digCube(3, 3, depth)
	self:digCube(width, length, height)

	if self:selectItemByName("minecraft:ladder") >= -self.dz then
		self:moveTo(1, 1, self.dz)
		self:faceHeading(HEADING_BACK)
		while self.dz ~= 0 do
			self:place("minecraft:ladder")
			self:up()
		end
	end

	self:moveTo(0, 0, 0)
	self:faceHeading(HEADING_FORWARD)
end

function Agent:selectItemByName(name)
	local item = self.inventory[name]
	if item ~= nil then
		turtle.select(item.slots[1])
		return item.total
	end
	return 0
end

function Agent:refreshInventory()
	self.inventory = {}
	for i = 1, 16 do
		local detail = turtle.getItemDetail(i)
		if detail then
			local item = self.inventory[detail.name]
			if item then
				item.total = item.total + detail.count
				item.slots[#item.slots+1] = i
			else
				self.inventory[detail.name] = newInventoryItem(detail.name, detail.count, {i})
			end
		end
	end
end

function Agent:printInventory()
	for _, item in pairs(self.inventory) do
		item:print();
	end
end

function Agent:printLocation()
	print("Location: ("..self.dx..", "..self.dy..", "..self.dz..")")
end

function Agent:printHeading()
	local heading = "Unkown"
	if self.heading == HEADING_FORWARD then
		heading = "Forward"
	elseif self.heading == HEADING_RIGHT then
		heading = "Right"
	elseif self.heading == HEADING_BACK then
		heading = "Back"
	elseif self.heading == HEADING_LEFT then
		heading = "Left"
	end
	print("Heading: "..heading)
end

--description: Guarantees we only place items of a particular type that we intend to place
--params: name - example: "minecraft:dirt"
--returns: item count remaining, -1 if item is not available to be placed
function Agent:place(name)
	local item = self.inventory[name]
	if item ~= nil then
		turtle.select(item.slots[1])
		turtle.place()

		item.total = item.total - 1

		--Move on to the next available slot if possible when we run out of an item
		--Check detail name instead of item count for edge case when the turtle immediately
		--picks up a new item to fill the current slot
		local detail = turtle.getItemDetail()
		if detail == nil or detail.name ~= name then
			if #item.slots == 1 then
				self.inventory[name] = nil
			else
				table.remove(item.slots, 1)
			end
		end

		return item.total
	end
	return -1
end

function newAgent()
	local agent = {
		heading = 0,
		dx = 0,
		dy = 0,
		dz = 0,
		inventory = {}
	}
	for k, v in pairs(Agent) do
		agent[k] = v
	end
	agent:refreshInventory()
	return agent;
end
local Agent = {
	heading = 0,
	dx = 0,
	dy = 0,
	dz = 0
}

function Agent:turnLeft(n)
	n = n or 1
	for i = 0, n do
		self.heading = (self.heading + 1) % 4
		turtle.turnLeft()
	end
end

function Agent:turnRight(n)
	n = n or 1
	for i = 0, n do
		self.heading = (self.heading - 1) % 4
		turtle.turnRight()
	end
end

function Agent:forward(n)
	n = n or 1
	for i = 0, n do
		while not turtle.forward() do
			if turtle.detect() then
				turtle.dig()
			else
				turtle.attack()
			end
		end

		if self.heading % 2 == 0 then
			self.dy = self.dy + 1
		else
			self.dx = self.dx + 1
		end
	end
end

function Agent:down(n)
	n = n or 1
	for i = 0, n do
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
	for i = 0, n do
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
	for i = 0, n do
		if not turtle.back() then
			self:turnLeft()
			self:turnLeft()
			self:forward()
			self:turnLeft()
			self:turnLeft()
		end

		if self.heading % 2 == 0 then
			self.dy = self.dy - 1
		else
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
	if self.dy > y then
		self:turnRight()
		self:turnRight()
		self:forward(self.dy - y)
		self:turnRight()
		self:turnRight()
	else
		self:forward(y - self.dy)
	end

	if self.dx > x then
		self:turnLeft()
		self:forward(self.dx - x)
		self:turnRight()
	else
		self:turnRight()
		self:forward(x - self.dx)
		self:turnLeft()
	end

	if self.dz > z then
		self:down(self.dz - z)
	else
		self:up(z - self.dz)
	end
	
	while self.heading ~= origHeading do
		self:turnLeft()
	end
end

function Agent:digSquare(width, length)
	for w = 1, width do
		self:forward(length - 1)

		if w % 2 == 0 then
			self:uTurnLeft()
		else
			self:uTurnRight()
		end
	end
end

function Agent:digCube(width, length, height)
	local sx, sy, sz = gps.locate()

	for h = 1, height do
		self:digSquare(width, length)
		self:moveTo(0, 0, self.dz)
		self:faceStartHeading()
		self:down()
	end
end

function newAgent()
	local agent = {}
	for k, v in pairs(Agent) do
		agent[k] = v
	end
	return agent
end
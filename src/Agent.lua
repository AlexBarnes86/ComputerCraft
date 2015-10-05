local map = {{1, 1, 1, 0, 0},
			 {1, 1, 1, 0, 0},
			 {1, 1, 1, 0, 0},
			 {0, 1, 1, 0, 1},
			 {0, 0, 0, 1, 1}}

function forward()
	while not turtle.forward() do
		if turtle.detect() then
			turtle.dig()
		else
			turtle.attack()
		end
	end
end

function down()
	while not turtle.down() do
		if turtle.detectDown() then
			turtle.digDown()
		else
			turtle.attackDown()
		end
	end
end

function up()
	while not turtle.up() do
		if turtle.detectUp() then
			turtle.digUp()
		else
			turtle.attackUp()
		end
	end
end

function back()
	if not turtle.back() then
		turtle.turnLeft()
		turtle.turnLeft()
		forward()
		turtle.turnLeft()
		turtle.turnLeft()
	end
end

function placeDown()
	if turtle.detectDown() then
		turtle.digDown()
	end
	turtle.placeDown()
end

function uTurnRight()
	turtle.turnRight()
	forward()
	turtle.turnRight()
end

function uTurnLeft()
	turtle.turnLeft()
	forward()
	turtle.turnLeft()
end

function build()
	up()

	for y = 1, table.getn(map) do
		local startIdx = 1
		local endIdx = table.getn(map[y])
		local inc = 1
		
		if y % 2 == 0 then
			startIdx = table.getn(map[y])
			endIdx = 1
			inc = -1
		end

		for x = startIdx, endIdx, inc do
			if map[y][x] ~= 0 then
				placeDown()
			end

			if x ~= endIdx then
				forward()
			end
		end

		if y % 2 == 0 then
			uTurnRight()
		else
			uTurnLeft()
		end
	end
end
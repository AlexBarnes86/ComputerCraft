local depth = 10

local width = 20 * 2 --20 chests, make room for walls
local length = 5
local height = 3

function digStockpile()
	for i = 1, depth do
		turtle.digDown()
	end

	digCube(width, length, height)
end
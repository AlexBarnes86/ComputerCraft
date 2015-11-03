local World = {}

function World:setSafeStart(pos)
	self.safeStartPos = pos
end

function World:setSafeEnd(pos)
	self.safeEndPos = pos
end

function World:getSafeStart()
	return self.safeStartPos
end

function World:getSafeEnd()
	return self.safeEndPos
end

function World:read(file)
	local worldFile = io.open(file, "r")
	local startStr = worldFile.read("*|")
	local endStr = worldFile.read("*|")
	io.close(worldFile)

	local sx, sz = string.match(startStr, "(%d+), ?(%d+)")
	local ex, ez = string.match(endStr, "(%d+), ?(%d+)")

	self.safeStartPos = {x=sx, z=sz}
	self.safeEndPos = {x=ex, z=ez}
end

function World:write()
	fs.delete(Constants.WORLD_FILE)
	local worldFile = fs.open(Constants.WORLD_FILE, "w")
	local safeStart = world:getSafeStart()
	local safeEnd = world:getSafeEnd()

	worldFile.write("safeStartPos = " .. safeStart.x .. ", " .. safeStart.z .. "\n")
	worldFile.write("safeStartPos = " .. safeEnd.x .. ", " .. safeEnd.z .. "\n")

	io.close(worldFile)
end

function newWorld()
	local world = {
		safeStartPos = {},
		safeEndPos = {},
	}
	for k, v in pairs(World) do
		world[k] = v
	end
	return world;
end
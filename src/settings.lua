local settings = {}
settings.miningCursorColor = {r = 75, g = 255, b = 75}
settings.hoverCursorColor = {r = 75, g = 75, b = 255}
settings.playerReach = 7

settings.binds = {
	inventory = 'e',
	right = 'd',
	left = 'a',
	up = 'w',
	down = 's',
	jump = 'space',
	breakPlaceMode = 'p',
	fly = 'f',
	pause = 'escape'
}

function settings:load()
	if not love.filesystem.isFile("voxel2d.settings") then
		return false
	end
	
	local file, size = love.filesystem.read("voxel2d.settings")
	for k,v in pairs(Tserial.unpack(file)) do
		self[k] = v
	end
end

function settings:save()
	love.filesystem.write("voxel2d.settings", Tserial.pack(self, true, true))
end

return settings
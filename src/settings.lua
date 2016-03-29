local settings = {}
settings.miningCursorColor = {r = 75, g = 255, b = 75}
settings.hoverCursorColor = {r = 75, g = 75, b = 255}
settings.playerReach = 7

settings.binds = {
	instaMine = 'b',
	inventory = 'e',
	right = 'd',
	left = 'a',
	up = 'w',
	down = 's',
	jump = 'space',
	breakPlaceMode = 'p',
	fly = 'f',
	pause = 'escape',
	chat = 't',
}

function settings:load()
	if not love.filesystem.isFile("voxel2d.settings") then
		return false
	end
	
	local file, size = love.filesystem.read("voxel2d.settings")
	for k,v in pairs(Tserial.unpack(file)) do
		if type(v) == "table" then
			if not self[k] then
				self[k] = v
			else
				for key,val in pairs(v) do
					self[k][key] = val
				end
			end
		else
			self[k] = v
		end
	end
	
	debug:print("Loaded voxel2d.settings")
end

function settings:save()
	love.filesystem.write("voxel2d.settings", Tserial.pack(self, true, true))
end

return settings
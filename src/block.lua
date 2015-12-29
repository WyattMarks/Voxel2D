local block = {}
block.id = 0
block.name = "air"
block.bg = false
block.transparent = false

function block:new(name, id, args)
	name = name or self.name
	id = id or self.id 
	local new = {}
	args = args or {}
	for k,v in pairs(self) do new[k] = v end
	
	new.id = id
	new.name = name
	
	for k,v in pairs(args) do new[k] = v end
	
	local x = math.floor( id * blockManager.size - (math.floor( id / 4) * blockManager.size * 4)) 
	local y = math.floor( math.floor( id / 4) * blockManager.size) * 2
	new.quad = love.graphics.newQuad(x, y, blockManager.size, blockManager.size, blockManager.textureWidth, blockManager.textureHeight )

	return new
end

function block:updateQuad()
	if self.bg then
		local id = self.id
		local x, y, width, height = self.quad:getViewport()
		self.quad:setViewport(x, y + blockManager.size, blockManager.size, blockManager.size)
	else
		local id = self.id
		local x = math.floor( id * blockManager.size - (math.floor( id / 4) * blockManager.size * 4)) 
		local y = math.floor( math.floor( id / 4) * blockManager.size) * 2
		self.quad:setViewport(x, y, blockManager.size, blockManager.size)
	end
end

return block
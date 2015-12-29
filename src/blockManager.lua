local blockManager = {}
blockManager.blocks = {}
blockManager.quads = {}
blockManager.texture = {}
blockManager.textureWidth = 1
blockManager.textureHeight = 1
blockManager.size = 16

function blockManager:load()
	self.texture = love.graphics.newImage("assets/tiles.png")
	self.texture:setFilter("nearest", "nearest")
	self.textureWidth, self.textureHeight = self.texture:getDimensions()
	self:add(block:new("air", 0, {transparent = true}))
	self:add(block:new("dirt", 1, {delay = .01}))
	self:add(block:new("stone", 2, {delay = 1.12}))
	self:add(block:new("grass", 3, {delay = .75}))
	self:add(block:new("gravel", 4))
	self:add(block:new("ironOre", 5, {delay = 1.75}))
	self:add(block:new("coalOre", 6, {delay = 1.45}))
	self:add(block:new("sapling", 7, {transparent = true}))
	self:add(block:new("bedrock", 8, {delay = 9999}))
end


function blockManager:add(block)
	self.blocks[block.name] = block
end

function blockManager:getBlocks()
	return self.blocks
end

return blockManager
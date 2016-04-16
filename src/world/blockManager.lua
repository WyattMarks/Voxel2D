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
	self:add(block:new("air", 0, {canBG = true, transparent = true, dropID = 0}))
	self:add(block:new("dirt", 1, {delay = .75, canBG = true, dropID = 1}))
	self:add(block:new("stone", 2, {delay = 1.12, canBG = true, dropID = 2}))
	self:add(block:new("grass", 3, {delay = .75, canBG = false, dropID = 1}))
	self:add(block:new("gravel", 4, {delay = 1, canBG = true, dropID = 4}))
	self:add(block:new("ironOre", 5, {delay = 1.75, canBG = false, dropID = 5}))
	self:add(block:new("coalOre", 6, {delay = 1.45, canBG = false, dropID = 6}))
	self:add(block:new("sapling", 7, {delay = 1, canBG = false, transparent = true, dropID = 7}))
	self:add(block:new("bedrock", 8, {delay = 9999, canBG = false, dropID = 8}))
end


function blockManager:add(block)
	self.blocks[block.name] = block
end

function blockManager:getBlocks()
	return self.blocks
end

function blockManager:getBlock(name)
	return self.blocks[name]
end

function blockManager:getByID(id)
	for k,v in pairs(self.blocks) do
		if v.id == id then
			return v
		end
	end
	
	return false
end

return blockManager
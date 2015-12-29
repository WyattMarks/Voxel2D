local level = {}
level.offset = 0
level.chunkWidth = 16
level.worldHeight = 128
level.chunks = {}


function level:getChunk(x) --get the chunk from the x coordinate
	return math.floor(x * camera.sx / (self.chunkWidth * blockManager.size * camera.sx)) --+ ( x > 0 and 1 or 0)
end


function level:screenToWorld(x, y)
	x = camera.x + x * camera.sx
	y = camera.y + y * camera.sy
	local chunk = self:getChunk(x)
	x = x - chunk * self.chunkWidth * (blockManager.size / camera.sx)
	
	x = math.floor(x / blockManager.size) + chunk * self.chunkWidth
	y = math.floor(y / blockManager.size)
	
	if x == 0 then			--I don't know why the fuck this happens or how to fix it, but after 12 hours of frustration I'm gonna make a hack for it
		chunk = chunk - 1
		x = 16
	end
	
	return x, y, chunk
end

function level:worldToCoords(x, y, chunk)
	x = x * blockManager.size + chunk * level.chunkWidth  * blockManager.size
	y = y * blockManager.size

	return x,y
end

function level:worldToScreen(x, y, chunk)
	x = x * blockManager.size
	y = y * blockManager.size
	
	x = x / camera.sx - camera.x / camera.sx
	y = y / camera.sy - camera.y / camera.sy
	x = x + chunk * self.chunkWidth * blockManager.size / camera.sx

	return x,y
end


function level:generateWorld(num)
	local curChunk = self:getChunk(player.x)
	if not self.chunks[curChunk + num] then
		self.chunks[curChunk + num] = chunk:generate(curChunk + num)
		print("Generated chunk <"..tostring(curChunk + num)..">")
	end
	
	if not self.chunks[curChunk - num - 1] then
		self.chunks[curChunk - num - 1] = chunk:generate(curChunk - num - 1)
		print("Generated chunk <"..tostring(curChunk - num - 1)..">")
	end
	
	if num > 0 then
		self:generateWorld(num-1)
	end
end


function level:unloadWorld(num)
	local curChunk = self:getChunk(player.x)
	
	for k,v in pairs(self.chunks) do
		if math.abs(curChunk - k) > 10 then
			for x, col in pairs(self.chunks[k][1]) do
				for y, block in pairs(col) do
					if not block.transparent then
						world:remove(block)
					end
				end
			end
			self.chunks[k] = nil
			print("Unloaded chunk <"..tostring(k)..">")
		end
	end
end


function level:update(dt)
	self:generateWorld(3)
	
	self:unloadWorld(6)
end


function level:draw()
	love.graphics.setColor(255,255,255)
	for chunkIndex,chunk in pairs(self.chunks) do
		love.graphics.draw(chunk[3], chunkIndex * level.chunkWidth * blockManager.size, 0)
	end
end


function level:deleteBlock(x, y, chunk, bg)
	local layer = 1
	if bg then layer = 2 end
	
	local oldBlock = self.chunks[chunk][layer][x][y]
	
	if oldBlock.bg and self.chunks[chunk][1][x][y].name ~= "air" then
		--return false --Can't remove bg blocks with fg blocks in the way
	end
	
	if not oldBlock.transparent and not bg then
		world:remove(oldBlock) --Remove the block from the physics
	end
	
	local newBlock = blocks.air:new()
	newBlock.bg = bg
	newBlock:updateQuad()
	
	if bg then
		if self.chunks[chunk][1][x][y].id == 0 then
			if oldBlock.spriteID then
				self.chunks[chunk][3]:set(oldBlock.spriteID, newBlock.quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) ) --Update spritebatch
			else
				self.chunks[chunk][3]:add(newBlock.quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) )
			end
		end
	else
		if oldBlock.spriteID then
			self.chunks[chunk][3]:set(oldBlock.spriteID, self.chunks[chunk][2][x][y].quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) ) --Update spritebatch
		else
			self.chunks[chunk][3]:add(self.chunks[chunk][2][x][y].quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) )
		end
	end
	
	self.chunks[chunk][layer][x][y] = newBlock;
end

function level:placeBlock(block, x, y, chunk, bg)
	local layer = 1
	if bg then layer = 2 end
	
	local oldBlock = self.chunks[chunk][layer][x][y]
	
	if not oldBlock.transparent and not bg then
		world:remove(oldBlock) --Remove the block from the physics
	end
	
	self.chunks[chunk][layer][x][y] = block
	
	if not block.transparent and not bg then
		local screenX, screenY = self:worldToCoords(x, y, chunk)
		world:add(block, screenX, screenY, blockManager.size, blockManager.size)
	end
	
	if self.chunks[chunk][1][x][y].transparent or not bg then
		if oldBlock.spriteID then
			self.chunks[chunk][3]:set(oldBlock.spriteID, block.quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) ) --Update spritebatch
		else
			self.chunks[chunk][3]:add(block.quad, math.floor(x * blockManager.size), math.floor(y * blockManager.size) )
		end
	end
end



























return level
local level = {}
level.offset = 0
level.chunkWidth = 16
level.worldHeight = 128
level.chunks = {}
level.name = "world"

function level:getChunk(x) --get the chunk from the x coordinate
	return math.floor(x * camera.sx / (self.chunkWidth * blockManager.size * camera.sx)) --+ ( x > 0 and 1 or 0)
end

function level:load()
	self.offset = math.random(-10000,100000)
	self:loadData()
	self:generateWorld(3)
end

function level:screenToWorld(x, y, actuallyScreen)
	local cameraX = camera.x
	local cameraY = camera.y
	
	if not actuallyScreen then
		cameraX = cameraX + camera.xOffset
		cameraY = cameraY + camera.yOffset
	end
	
	x = cameraX + x * camera.sx
	y = cameraY + y * camera.sy
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
	local curChunk = self:getChunk(game:getLocalPlayer().x)
	
	if not self.chunks[curChunk + num] then
		if not self:loadChunk(curChunk + num) then
			self.chunks[curChunk + num] = chunk:generate(curChunk + num)
		end
	end
	
	if not self.chunks[curChunk - num - 1] then
		if not self:loadChunk(curChunk - num - 1) then
			self.chunks[curChunk - num - 1] = chunk:generate(curChunk - num - 1)
		end
	end
	
	if type(self.chunks[curChunk - num - 1]) == "table" and not self.chunks[curChunk - num - 1].visible then
		self.chunks[curChunk - num - 1].visible = true
	end
	
	if type(self.chunks[curChunk + num]) == "table" and not self.chunks[curChunk + num].visible then
		self.chunks[curChunk + num].visible = true
	end
	
	
	if num > 0 then
		self:generateWorld(num-1)
	end
end


function level:unloadWorld(num)
	local toKeep = {}
	
	for index, player in pairs(game.players) do
		local curChunk = self:getChunk(player.x)
		
		for k,v in pairs(self.chunks) do
			if math.abs(curChunk - k) <= 10 then
				toKeep[k] = v
			end
		end
	end

	
	for k,v in pairs(self.chunks) do
		if toKeep[k] then return end
		
		if server.hosting then
			self:save(self.chunks[k], k )
		end
				
		for x, col in pairs(self.chunks[k][1]) do
			for y, block in pairs(col) do
				if not block.transparent and block.id >= 0 then
					world:remove(block)
				end
			end
		end 
		self.chunks[k] = nil
		debug:print("Unloaded chunk <"..tostring(k)..">")
	end
end


function level:update(dt)
	self:generateWorld(3)
	
	self:unloadWorld(3)
end


function level:draw()
	love.graphics.setColor(255,255,255)
	for chunkIndex,chunk in pairs(self.chunks) do
		if chunk ~= "requested" and chunk.visible then
			love.graphics.draw(chunk[3], chunkIndex * level.chunkWidth * blockManager.size, 0)
		end
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
	
	local newBlock = blockManager:getBlock('air'):new()
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


function level:getSurrounding(x, y, chunk, layer)
	local function safe(x) return math.min(16, math.max(1, x)) end

	
	local blocks = {}
	blocks[1] = self.chunks[chunk][layer][safe(x-1)][y] 
	blocks[2] = self.chunks[chunk][layer][x][y-1]
	blocks[3] = self.chunks[chunk][layer][safe(x+1)][y]
	blocks[4] = self.chunks[chunk][layer][x][y+1]
	
	
	if x == 1 then
		blocks[1] = self.chunks[chunk-1][layer][16][y]
	elseif x == 16 then
		blocks[3] = self.chunks[chunk+1][layer][1][y]
	end
	
	return blocks
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

function level:saveData()
	if not love.filesystem.isDirectory(self.name) then
		love.filesystem.createDirectory(self.name)
	end
	
	local data = {}
	
	if love.filesystem.isFile(self.name.."/"..self.name..".data") then
		local file, size = love.filesystem.read(self.name.."/"..self.name..".data")
		local savedData = Tserial.unpack(file)
		for k,v in pairs(savedData) do
			data[k] = v
		end
	end
	
	data.seed = self.offset
	
	for k,v in pairs(game.players) do
		data[v.name] = {
			x = v.x,
			y = v.y,
		}
	end
	
	local save = Tserial.pack(data, false, false)
	love.filesystem.write(self.name.."/"..self.name..".data", save)

end

function level:createSaveFile(chunk, chunkNum)
	local function makeSave(layer)
		local newLayer = {}
		local layNum = 1
		if layer == 2 then
			layNum = 2
		end
		
		layer = chunk[layer]
		
		for x=1, self.chunkWidth do
			if not newLayer[x] then
				newLayer[x] = {}
			end
			
			local y=1
			while y <= self.worldHeight do
				local index = #newLayer[x] + 1
				
				if not newLayer[x][index] then
					newLayer[x][index] = {id=0,len=1,y=1}
				end
				
				newLayer[x][index].id = layer[x][y].id

				local nextBlock = y + newLayer[x][index].len

				if nextBlock < 129 then
					while layer[x][nextBlock].id == newLayer[x][index].id do
						newLayer[x][index].len = newLayer[x][index].len + 1
						nextBlock = y + newLayer[x][index].len
						
						if nextBlock >= 128 then
							break
						end
					end
				end
				
				newLayer[x][index].y = y
				
				y = y + newLayer[x][index].len
			end
		end
		
		return newLayer
	end
	
	
	local fgBlocks = makeSave(1)
	local bgBlocks = makeSave(2)
	
	local final = Tserial.pack({fgBlocks, bgBlocks}, false, true)
	
	return final
end


function level:save(chunk, chunkNum)
	if not love.filesystem.isDirectory(self.name) then
		love.filesystem.createDirectory(self.name)
	end
	
	local final = self:createSaveFile(chunk, chunkNum)
	
	love.filesystem.write(self.name.."/"..tostring(chunkNum)..".chunk", final)
	
	debug:print("Saved chunk <"..tostring(chunkNum)..">")
end

function level:loadSaveFile(chunkNum, saveFile)
	local saved = Tserial.unpack(saveFile)
	local spriteBatch = love.graphics.newSpriteBatch(blockManager.texture, level.chunkWidth * level.worldHeight * 2)
	
	local fgBlocks = {}
	local bgBlocks = {}
	
	for x, col in pairs(saved[1]) do
		if fgBlocks[x] == nil then
			fgBlocks[x] = {}
		end
		for k, block in pairs(col) do
			for i=1, block.len do
				local y = block.y + i - 1
				local fgBlock = blockManager:getByID(block.id):new()
				
				if not fgBlock.transparent then
					local screenX, screenY = self:worldToCoords(x, y, chunkNum)
					world:add(fgBlock, screenX, screenY, blockManager.size, blockManager.size)
					fgBlock.spriteID = spriteBatch:add(fgBlock.quad, math.floor( x * blockManager.size ), math.floor( y * blockManager.size) )
				end
				
				fgBlock.x = 1 + self.offset + chunkNum * self.chunkWidth
				fgBlock.y = y
				
				fgBlocks[x][y] = fgBlock
			end
		end
	end
	
	for x=1, self.chunkWidth do
		for y=1, self.worldHeight do
			if not fgBlocks[x][y] then
				local fgBlock = blockManager:getBlocks().air:new()
				fgBlock.x = 1 + self.offset + chunkNum * self.chunkWidth
				fgBlock.y = y
				
				fgBlocks[x][y] = fgBlock
			end
		end
	end
	
	for x, col in pairs(saved[2]) do
		if bgBlocks[x] == nil then
			bgBlocks[x] = {}
		end
		for k, block in pairs(col) do
			for i=0, block.len do
				local y = math.min(128,block.y + i)
				local bgBlock = blockManager:getByID(block.id):new()

				bgBlock.bg = true
				bgBlock:updateQuad()
				if fgBlocks[x][y].transparent then
					bgBlock.spriteID = spriteBatch:add(bgBlock.quad, math.floor( x * blockManager.size ), math.floor( y * blockManager.size) )
					fgBlocks[x][y].spriteID = spriteBatch:add(fgBlocks[x][y].quad, math.floor( x * blockManager.size ), math.floor( y * blockManager.size) )
				end
				bgBlock.x = 1 + self.offset + chunkNum * self.chunkWidth
				bgBlock.y = y
				
				
				bgBlocks[x][y] = bgBlock
			end
		end
	end
	
	self.chunks[chunkNum] = {fgBlocks, bgBlocks, spriteBatch}
	debug:print("Loaded chunk <"..tostring(chunkNum)..">")
end

function level:loadChunk(chunkNum)
	if not server.hosting then
		client:send("LOAD"..tostring(chunkNum))
		self.chunks[chunkNum] = "requested"
		return true
	end
	
	
	if not love.filesystem.isDirectory(self.name) then
		return false
	end
	
	if not love.filesystem.isFile(self.name.."/"..tostring(chunkNum)..".chunk") then
		return false
	end
	
	local file, size = love.filesystem.read(self.name.."/"..tostring(chunkNum)..".chunk")
	
	self:loadSaveFile(chunkNum, file)
	
	return true
end

function level:loadData()
	if not server.hosting then
		return false
	end
	if not love.filesystem.isDirectory(self.name) then
		return false
	end
	
	if not love.filesystem.isFile(self.name.."/"..self.name..".data") then
		return false
	end
	
	local file, size = love.filesystem.read(self.name.."/"..self.name..".data")
	
	local data = Tserial.unpack(file)
	self.levelData = data
	self.offset = data.seed
	
	for k,v in pairs(game.players) do
		if data[v.name] then
			v.x = data[v.name].x
			v.y = data[v.name].y
		end
	end
	
	return true
end
	

























return level
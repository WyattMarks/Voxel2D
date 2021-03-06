local chunk = {}

function chunk:noise(x, y, scale, magnitude, exponent)
	return love.math.noise(x / scale, y / scale) * magnitude ^ exponent;
end

function chunk:round(num)
  return math.floor(num + 0.5)
end

function chunk:reGenerateSpriteBatch()
	
end


function chunk:generate(index)
	local fgBlocks = {}
	local bgBlocks = {}
	
	self.offset = level.offset + index * level.chunkWidth
	
	local x,y
	local spriteBatch = love.graphics.newSpriteBatch(blockManager.texture, level.chunkWidth * level.worldHeight * 2)
	for x=1 + self.offset, level.chunkWidth + self.offset do
		fgBlocks[x-self.offset] = {}
		bgBlocks[x-self.offset] = {}
		local dirtHeight = self:round( self:noise(x, 0, 80, 2, 1) + self:noise(x, 0, 50, 30, 1) + self:noise(x, 0, 10, 10, 0.75) + 45 )
		local stoneHeight = self:round( self:noise(x, 0, 80, 2, 1) + self:noise(x, 0, 50, 30, 1) + 60 )
		
		
		for y=1, level.worldHeight do
			local fgBlock = blockManager:getBlock('air'):new()
			local bgBlock = blockManager:getBlock('air'):new()
			
			if y == dirtHeight - 1 then
				if self:noise(x, y, 2, 30, 1) <= 6 then --If we're on top of the grass and there is some air, perhaps make a tree?
					fgBlock = blockManager:getBlock('sapling'):new()
					bgBlock = blockManager:getBlock('air'):new()
				end
			elseif y == dirtHeight then --Top of the first should be grass
				fgBlock = blockManager:getBlock('grass'):new()
				bgBlock = blockManager:getBlock('dirt'):new()
			elseif y > dirtHeight and y < stoneHeight then --Below grass and above stone? Dirt
				if self:noise(x, y, 3, 30, 1) <= 4 then --Add some gravel for variation
					fgBlock = blockManager:getBlock('gravel'):new()
					bgBlock = blockManager:getBlock('gravel'):new()
				else
					fgBlock = blockManager:getBlock('dirt'):new()
					bgBlock = blockManager:getBlock('dirt'):new()
				end
			elseif y >= stoneHeight then
				if self:noise(x, y, 8, 30, 1) > 5 + (y - stoneHeight) / level.worldHeight * 15 then --Caves!
					if self:noise(x, y, 3, 30, 1) <= 4 then --Same as the gravel spawning in dirt				
						fgBlock = blockManager:getBlock('gravel'):new()
					elseif self:noise(x, y, 6, 30, 1) <= 3 then		
						fgBlock = blockManager:getBlock('coalOre'):new()
					elseif self:noise(x + 1000, y, 6, 30, 1) <= 3 then		
						fgBlock = blockManager:getBlock('ironOre'):new()
					else
						fgBlock = blockManager:getBlock('stone'):new()
					end
				else
					fgBlock = blockManager:getBlock('air'):new()
				end
				
				if y == level.worldHeight then
					fgBlock = blockManager:getBlock('bedrock'):new()
				end
				
				bgBlock = blockManager:getBlock('stone'):new()
			end
			
			bgBlock.bg = true
			bgBlock:updateQuad()
			
			if fgBlock.transparent then
				bgBlock.spriteID = spriteBatch:add(bgBlock.quad, math.floor( (x-self.offset) * blockManager.size ), math.floor( y * blockManager.size) )
			else
				local screenX, screenY = level:worldToCoords(x - self.offset, y, index)
				world:add(fgBlock, screenX, screenY, blockManager.size, blockManager.size)
			end
			
			fgBlock.spriteID = spriteBatch:add(fgBlock.quad, math.floor( (x-self.offset) * blockManager.size ), math.floor( y * blockManager.size) )
			
			
			fgBlock.x = x
			fgBlock.y = y
			
			bgBlock.x = x
			bgBlock.y = y
			
			fgBlocks[x-self.offset][y] = fgBlock
			bgBlocks[x-self.offset][y] = bgBlock
		end
	end
	
	debug:print("Generated chunk <"..tostring(index)..">")
	
	return {fgBlocks, bgBlocks, spriteBatch}
end









return chunk
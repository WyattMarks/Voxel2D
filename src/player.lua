local player = {}
player.name = "player"
player.x = 0
player.y = 700
player.speed = 128
player.up = false
player.right = false
player.left = false
player.down = false
player.width = 16
player.height = 32
player.flying = false
player.instaBreak = false
player.yvel = 0
player.mode = "break"
player.breaking = {}
player.sameActive = 0
player.onGround = false
player.activeSlot = 1
player.lastPlace = {1,1}

function player:wheelmoved(x,y)
	self.activeSlot = self.activeSlot - y
	
	if self.activeSlot > 10 then
		self.activeSlot = 1
	elseif self.activeSlot < 1 then
		self.activeSlot = 10
	end
end

function player:getWorldCoords()
	return level:screenToWorld((self.x + self.width / 2)/camera.sx - camera.x/camera.sx, (self.y + self.height)/camera.sy - camera.y/camera.sy, true)
end

function player:canPlace(x,y,chunk,layer)
	if level.chunks[chunk][layer][x][y].id ~= 0 then
		return false
	end
	
	local hasSolid = false
	for k, block in pairs(level:getSurrounding(x, y, chunk, layer)) do
		if not block.transparent then
			hasSolid = true
		end
	end
	
	if not level.chunks[chunk][2][x][y].transparent then
		hasSolid = true
	end
	
	if not hasSolid then
		return false
	end
	
	local playerX, playerY = level:worldToScreen(self:getWorldCoords())
	local mouseX, mouseY = love.mouse.getPosition()

	playerX = playerX + blockManager.size / camera.sx / 2
	playerY = playerY - blockManager.size / camera.sy
	
	local distance = math.floor(math.sqrt( (mouseX - playerX)^2 + (mouseY - playerY)^2 ) / blockManager.size)
	if distance >= settings.playerReach and not self.instaBreak then
		return false
	end
	
	return true
end


function player:checkPlace(dt)
	local x,y = love.mouse.getPosition()
	
	local down = 0
	if love.mouse.isDown(1) then
		down = 1
	elseif love.mouse.isDown(2) then
		down = 2
	end
	
	local lastPlace = self.lastPlace
	if down ~= 0 then
		local item = inventory.inventory[self.activeSlot][inventory.height]
		if item.delay then
			local x, y, chunk = level:screenToWorld(x, y, true)
			
			if (lastPlace[1] ~= x or lastPlace[2] ~= y) and self:canPlace(x, y, chunk, down) then
				local block = blocks[item.name]:new()
				block.bg = down == 2
				block:updateQuad()
				
				level:placeBlock(block, x, y, chunk, block.bg)
				
				if item.quantity <= 1 then
					inventory.inventory[self.activeSlot][inventory.height] = {}
				else
					inventory.inventory[self.activeSlot][inventory.height].quantity = item.quantity - 1
				end
			end
		end
	end
end

function player:canMine()
	local playerX, playerY = level:worldToScreen(self:getWorldCoords())
	local mouseX, mouseY = love.mouse.getPosition()

	playerX = playerX + blockManager.size / camera.sx / 2
	playerY = playerY - blockManager.size / camera.sy
	
	local distance = math.floor(math.sqrt( (mouseX - playerX)^2 + (mouseY - playerY)^2 ) / blockManager.size)
	if distance >= settings.playerReach and not self.instaBreak then
		return false
	end
	
	return true
end

function player:checkMine(dt)
	local x,y = love.mouse.getPosition()
	
	local down = 0
	if love.mouse.isDown(1) then
		down = 1
	elseif love.mouse.isDown(2) then
		down = 2
	end
	
	local oldBreaking = self.breaking
	if self.mode == "break" and down ~= 0 then
		local x, y, chunk = level:screenToWorld(x, y, true)
		self.breaking = level.chunks[chunk][down][x][y]
	end
	
	if self.breaking.id ~= 0 and self.breaking == oldBreaking then
		local oldDown = 0
		if oldBreaking.bg then
			oldDown = 2
		else
			oldDown = 1
		end
		
		if down == oldDown and self:canMine() then
			self.mining = true
			
			self.sameActive = self.sameActive + dt
			
			local delay = self.breaking.delay or 1
			if self.instaBreak then
				delay = 0
			end
			
			if self.sameActive > delay then
				local x, y, chunk = level:screenToWorld(x, y, true)
				local toAdd = blockManager:getByID(blocks[self.breaking.name].dropID):new()
				
				if inventory:add(toAdd, 1) then
					level:deleteBlock(x, y, chunk, self.breaking.bg)
					self.mining = false
				end
			end
		end
	else
		self.sameActive = 0
	end
end

function player:load()
	world:add(self, self.x - .5, self.y, self.width - 1, self.height)
	
	camera:move(player.x - screenWidth / 3, player.y - screenHeight / 3)
end

function player:mousepressed(x, y, button)
end

function player:mousereleased(x, y, button)
	self.sameActive = 0
end

function player:draw()
	love.graphics.setColor(50,255,50)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function player:update(dt)
	local x,y,chunk = self:getWorldCoords()
	debug:add("Chunk", chunk)
	debug:add("Coords", "("..tostring(x)..","..tostring(y)..")")
	debug:add("Mode", self.mode)
	local distance = math.floor( self.speed * dt )
	local camDist = math.floor( camera.speed * dt )
	
	
	local oldXOff = camera.xOffset
	local oldYOff = camera.yOffset
	
	if self.x - camera.x > (screenWidth - camera.horizontalBorder - self.width) * camera.sx then
		camera:move(camDist)
		camera.xOffset = (self.x - camera.x) - (screenWidth - camera.horizontalBorder - self.width) * camera.sx
	end
	
	if self.x - camera.x < camera.horizontalBorder * camera.sx then
		camera:move(-camDist)
		camera.xOffset = (self.x - camera.x) - camera.horizontalBorder * camera.sx
	end
	
	if self.y - camera.y > (screenHeight - camera.bottomBorder - self.height) * camera.sy then
		camera:move(0, camDist)
		camera.yOffset = (self.y - camera.y) - (screenHeight - camera.bottomBorder - self.height) * camera.sy
	end
	
	if self.y - camera.y < camera.topBorder * camera.sy then
		camera:move(0, -camDist)
		camera.yOffset = (self.y - camera.y) - camera.topBorder * camera.sy
	end
	
	if oldXOff == camera.xOffset then
		camera.xOffset = 0 
	end
	if oldYOff == camera.yOffset then
		camera.yOffset = 0 
	end
	
	local xMove = self.x
	local yMove = self.y
	
	if not( self.right and self.left ) then
		if self.right then
			xMove = xMove + distance
		elseif self.left then
			xMove = xMove - distance
		end
	end
	
	if self.up and self.flying then
		yMove = yMove - distance
	elseif self.down and self.flying then
		yMove = yMove + distance
	elseif not self.flying then
		if not love.keyboard.isDown('space') then
			self.yvel = math.min(0, self.yvel)
		end
		
		
		local gravity = 512
		self.yvel = math.max(-512, self.yvel - gravity * dt)
		yMove = yMove - self.yvel * dt
	end
	
	self.x, self.y, cols, len= world:move(self, xMove, yMove)
	
	local onGround = false
	
	if yMove ~= self.y then
		self.yvel = 0
		
		if self.yvel <= 0 then
			onGround = true
		end
	end
	
	for i=1, len do
		local other = cols[i].other
	end
	
	self.onGround = onGround
	
	if self.mode == "break" then
		self:checkMine(dt)
	else
		self:checkPlace()
	end
end

return player
local player = {}
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
player.yvel = 0
player.mode = "break"
player.breaking = {}
player.sameActive = 0
player.onGround = false

function player:checkMine(dt)
	local x,y = love.mouse.getPosition()
	
	local down = 0
	if love.mouse.isDown(1) then
		down = 1
	elseif love.mouse.isDown(2) then
		down = 2
	end
	
	local oldBreaking = self.breaking
	if self.mode == "break" then
		if down == 1 then
			local x, y, chunk = level:screenToWorld(x, y)
			self.breaking = level.chunks[chunk][1][x][y]
		elseif down == 2 then
			local x, y, chunk = level:screenToWorld(x, y)
			self.breaking = level.chunks[chunk][2][x][y]
		end
	end
	
	if self.breaking.id ~= 0 and self.breaking == oldBreaking then
		local oldDown = 0
		if oldBreaking.bg then
			oldDown = 2
		else
			oldDown = 1
		end
		
		if down == oldDown then
			self.mining = true
			
			self.sameActive = self.sameActive + dt
			
			if self.sameActive > (self.breaking.delay or 1) then
				local x, y, chunk = level:screenToWorld(x, y)
				local toAdd = blocks[self.breaking.name]:new()
				
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
	local distance = math.floor( self.speed * dt )
	local camDist = math.floor( camera.speed * dt )
	
	
	if self.x - camera.x > (screenWidth - camera.horizontalBorder - self.width) * camera.sx then
		camera:move(camDist)
	end
	
	if self.x - camera.x < camera.horizontalBorder * camera.sx then
		camera:move(-camDist)
	end
	
	if self.y - camera.y > (screenHeight - camera.bottomBorder - self.height) * camera.sy then
		camera:move(0, camDist)
	end
	
	if self.y - camera.y < camera.topBorder * camera.sy then
		camera:move(0, -camDist)
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


input:addBind("pRight", "d", function(down)
	player.right = down
end)
input:addBind("pLeft", "a", function(down)
	player.left = down
end)
input:addBind("pUp", "w", function(down)
	player.up = down
end)
input:addBind("pDown", "s", function(down)
	player.down = down
end)
input:addBind("pJump", "space", function(down)
	if down and player.onGround then
		player.yvel = 256
	end
end)
input:addBind("pSwitch", "p", function(down)
	if down then
		if player.mode == "break" then
			player.mode = "place"
		else
			player.mode = "break"
		end
	end
end)
input:addBind("pFly", "f", function(down)
	if down then
		player.flying = not player.flying
	end
end)

return player
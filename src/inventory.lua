local inventory = {}
inventory.width = 10
inventory.height = 5
inventory.inventory = {}
inventory.open = false
inventory.activeItem = {}
inventory.previousPos = {}
inventory.vWidth = 400
inventory.vHeight = 600
inventory.font = {}

function inventory:load()
	
	if not self:loadSave() then
		for w=1, self.width do
			self.inventory[w] = {}
			for h=1, self.height do
				self.inventory[w][h] = {}
			end
		end
	end
	
	self.font = font.small
end

function inventory:createSaveFile()
	local toSave = {}
	for w,col in pairs(self.inventory) do
		if not toSave[w] then
			toSave[w] = {}
		end
		
		for h,block in pairs(col) do
			toSave[w][h] = {id = block.id, quantity = block.quantity}
		end
	end
	
	return Tserial.pack(toSave, false, false)
end

function inventory:save()
	if not love.filesystem.isDirectory(level.name) then
		love.filesystem.createDirectory(level.name)
	end
	
	local playerName = self.owner
	
	local final = self:createSaveFile()
	
	love.filesystem.write(level.name.."/"..playerName..".inventory", final)
	
	debug:print("Saved "..playerName.."'s inventory")
end

function inventory:loadSaveFile(file)
	local saved = Tserial.unpack(file)
	
	for w, col in pairs(saved) do
		if not self.inventory[w] then
			self.inventory[w] = {}
		end
		
		for h, block in pairs(col) do
			if block.id then
				self.inventory[w][h] = blockManager:getByID(block.id):new()
				self.inventory[w][h].quantity = block.quantity
			else
				self.inventory[w][h] = block
			end
		end
	end
	
	if self.owner ~= game:getLocalPlayer().name and server.hosting then
		server:send(game:getPlayer(self.owner), "INVENTORY"..file)
	end
end

function inventory:loadSave()
	if not server.hosting then
		return false
	end
	if not love.filesystem.isDirectory(level.name) then
		return false
	end
	
	
	local playerName = self.owner
	
	if not love.filesystem.isFile(level.name.."/"..playerName..".inventory") then
		return false
	end
	
	local file, size = love.filesystem.read(level.name.."/"..playerName..".inventory")
	self:loadSaveFile(file)
	
	debug:print("Loaded "..playerName.."'s inventory")
	return true
end

function inventory:add(block, quantity)
	for h=1, self.height do
		for w=1, self.width do
			if (self.inventory[w][h].id or 0) == block.id and (self.inventory[w][h].quantity or 0) < 64 then
				local oldAmount = (self.inventory[w][h].quantity or 0)
				self.inventory[w][h] = {id = block.id}
				self.inventory[w][h].quantity = oldAmount + quantity

				return true
			end
		end
	end
	
	for w=1, self.width do
		if (self.inventory[w][self.height].id or block.id) == block.id and (self.inventory[w][self.height].quantity or 0) < 64 then
			local oldAmount = (self.inventory[w][self.height].quantity or 0)
			self.inventory[w][self.height] = {id = block.id}
			self.inventory[w][self.height].quantity = oldAmount + quantity

			return true
		end
	end
	
	for h=1, self.height do
		for w=1, self.width do
			if (self.inventory[w][h].id or block.id) == block.id and (self.inventory[w][h].quantity or 0) < 64 then
				local oldAmount = (self.inventory[w][h].quantity or 0)
				self.inventory[w][h] = {id = block.id}
				self.inventory[w][h].quantity = oldAmount + quantity

				return true
			end
		end
	end
end

function inventory:draw()
	if not self.open then return end
	
	local height = self.vHeight
	local width = self.vWidth
	local x = screenWidth / 2 - width / 2
	local y = screenHeight / 2 - height / 2
	local mouseX, mouseY = love.mouse.getPosition()
	love.graphics.setColor(200,200,200)
	love.graphics.rectangle('fill', x, y, width, height)
	
	
	for w=1, self.width do
		for h=1, self.height do
			local offset = 0
			if h == self.height then
				offset = 8
			end
			
			local x = x + w * 34 - 6
			local y = y + h * 34 + 360 + offset
			
			love.graphics.setColor(50,50,50)
			love.graphics.rectangle('fill', x, y, 32, 32)
		end
	end
	
	
	for w=1, self.width do
		for h=1, self.height do
			local offset = 0
			if h == self.height then
				offset = 8
			end
			
			local x = x + w * 34 - 6
			local y = y + h * 34 + 360 + offset
			
			if self.inventory[w][h].id then
				local block = blockManager:getByID(self.inventory[w][h].id)
				love.graphics.setColor(255,255,255)
				if self.activeItem ~= self.inventory[w][h] then
					love.graphics.draw(blockManager.texture, block.quad, x + 1, y + 1, 0, 1.875, 1.875)
				end
				
				if self.inventory[w][h].quantity > 1 then
					love.graphics.setColor(255,255,255)
					love.graphics.setFont( self.font )
					if self.activeItem ~= self.inventory[w][h] then
						local y = y + 32 - self.font:getHeight()
						local x = x + 32 - self.font:getWidth(tostring(self.inventory[w][h].quantity))
						love.graphics.print(tostring(self.inventory[w][h].quantity), x, y)
					end
				end
			end
		end
	end
	
	if #self.previousPos == 4 then
		local w = self.previousPos[1]
		local h = self.previousPos[2]
		
		x = x + w * 34 - 6 + 1 + (mouseX - self.previousPos[3])
		y = y + h * 34 + 360 + 1 + (mouseY - self.previousPos[4])
		if h == self.height then
			y = y + 8
		end
		love.graphics.setColor(255,255,255)
		local block = blockManager:getByID(self.inventory[w][h].id)
		love.graphics.draw(blockManager.texture, block.quad, x, y, 0, 1.875, 1.875)
		if self.inventory[w][h].quantity > 1 then
			love.graphics.setFont( self.font )
			local y = y + 32 - self.font:getHeight()
			local x = x + 32 - self.font:getWidth(tostring(self.inventory[w][h].quantity))
			love.graphics.print(tostring(self.inventory[w][h].quantity), x, y)
		end
	end
end

function inventory:mousepressed(x, y, button)
	if self.open and button == 1 then
		self:setActiveItem(x, y)
	end
end

function inventory:mousereleased(x, y, button)
	if self.open and button == 1 then
		if self.activeItem.id then
			self:moveActiveItem(x,y)
		else
			self.activeItem = {}
			self.previousPos = {}
		end
	end
end

function inventory:slotFromScreen(screenX, screenY)
	for w=1, self.width do
		for h=1, self.height do
			local offset = 0
			if h == self.height then
				offset = 8
			end
			
			local x = screenWidth / 2 - self.vWidth / 2 + w * 34 - 6 + 1
			local y = screenHeight / 2 - self.vHeight / 2 + h * 34 + 360 + offset + 1		
			
			if screenX - x >= 0 and screenX - x <= 31  then
				if screenY - y >= 0 and screenY - y <= 31 then
					return w,h
				end
			end
		end
	end
end

function inventory:setActiveItem(mouseX, mouseY)
	local w,h = self:slotFromScreen(mouseX, mouseY)
	if not w then return end
	
	if self.inventory[w][h].id then
		self.activeItem = self.inventory[w][h]
		self.previousPos = {w,h,mouseX,mouseY}
		return true
	else
		return false
	end
	
	self.activeItem = {}
	self.previousPos = {}
end

function inventory:moveActiveItem(mouseX, mouseY)
	local w,h = self:slotFromScreen(mouseX, mouseY)
	if not w then
		self.activeItem = {}
		self.previousPos = {}
		return
	end
	
	if self.inventory[w][h].id then
		local oldW = self.previousPos[1]
		local oldH = self.previousPos[2]
		local replacing = self.inventory[w][h]
		
		if replacing.id == self.inventory[oldW][oldH].id then
			if not (oldW == w and oldH == h) then
				self.inventory[w][h].quantity = replacing.quantity + self.inventory[oldW][oldH].quantity
				if self.inventory[w][h].quantity > 64 then
					self.inventory[oldW][oldH].quantity = self.inventory[w][h].quantity - 64
					self.inventory[w][h].quantity = 64
				else
					self.inventory[oldW][oldH] = {}
				end
			end
		else
			self.inventory[w][h] = self.inventory[oldW][oldH]
			self.inventory[oldW][oldH] = replacing
		end
	else
		self.inventory[w][h] = self.inventory[self.previousPos[1]][self.previousPos[2]]
		self.inventory[self.previousPos[1]][self.previousPos[2]] = {}
	end
	
	self.activeItem = {}
	self.previousPos = {}
end

function inventory:update(dt)
	if not self.open then return end
	
	if love.mouse.isDown(1) then
		
		
		
	end
end

function inventory:new()
	local function copy(tbl)
		local new = {}
		for k,v in pairs(tbl) do
			if type(v) == "table" then
				new[k] = copy(v)
			else
				new[k] = v
			end
		end
		
		return new
	end

	return copy(self)
end









return inventory
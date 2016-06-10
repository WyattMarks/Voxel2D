local join = {}

function join:load()
	self.bgImage = love.graphics.newImage('assets/background.png')
	self.addressBox = textbox:new()
	self.addressBox.width = 250
	self.addressBox.font = font.medium
	self.addressBox.x = screenWidth / 2 - self.addressBox.width / 2
	self.addressBox.y = screenHeight / 3 + self.addressBox.font:getHeight() / 2 * 6
	self.addressBox.text = "localhost"
	
	self.nameBox = textbox:new()
	self.nameBox.width = 250
	self.nameBox.font = font.medium
	self.nameBox.x = screenWidth / 2 - self.nameBox.width / 2
	self.nameBox.y = screenHeight / 3 + self.nameBox.font:getHeight() / 2 * 9
	self.nameBox.text = "Player"..math.random(1,10)
	
	self.nameBox.textinput = function(nameBox, t)
		if nameBox.active then
			if not nameBox.firstInput then
				nameBox.text = nameBox.text..t
			else
				nameBox.text = t
				nameBox.firstInput = false
			end
		end
	end
	
	self.addressBox.textinput = self.nameBox.textinput
	
	self.nameBox.keypressed = function(nameBox, key, isrepeat)
		if key == "backspace" and nameBox.active then
			if nameBox.firstInput then
				nameBox.text = ''
				nameBox.firstInput = false
			else
				local byteoffset = utf8.offset(nameBox.text, -1)
			 
				if byteoffset then
					nameBox.text = string.sub(nameBox.text, 1, byteoffset - 1)
				end
			end
		end
	end
	
	self.addressBox.keypressed = self.nameBox.keypressed
	
	self.backButton = button:new({text = "Back", font = font.large, width = 220, height = 50, x = screenWidth / 2 - 220 - 220/4, y = screenHeight / 2 + 30})
	self.backButton.highlightColor = {r = 90, g = 90, b = 90}
	self.backButton.clickColor = {r = 50, g = 50, b = 50}
	
	self.joinButton = button:new({text = "Join Game", font = font.large, width = 220, height = 50, x = screenWidth / 2 + 220/4, y = screenHeight / 2 + 30})
	self.joinButton.highlightColor = {r = 90, g = 90, b = 90}
	self.joinButton.clickColor = {r = 50, g = 50, b = 50}
	
	function self.joinButton.onClick(btn)
		game.name = self.nameBox.text
		menu:setScreen('main')
		game:load()
		local ip = self.addressBox.text
		local port = 1337
		
		if ip:find(":") then
			local index = ip:find(":")
			ip = ip:sub(1, index - 1)
			port = tonumber(ip:sub(index + 1))
		end
		client.address = ip
		client.port = port
		client:load()
	end
		
	function self.backButton.onClick(btn)
		menu:setScreen('main')
	end
end


function join:draw()
	love.graphics.setColor(200,200,200)
	love.graphics.draw(self.bgImage, 0,0)
	love.graphics.setColor(255,255,255)
	
	
	love.graphics.setFont(font.large)
	love.graphics.print("Join Game", screenWidth / 2 - font.large:getWidth("Join Game") / 2, screenHeight / 3)
	
	love.graphics.setFont(font.medium)
	love.graphics.print("Host:", self.addressBox.x - font.medium:getWidth("Host:"), self.addressBox.y)
	
	love.graphics.print("Name:", self.nameBox.x - font.medium:getWidth("Name:"), self.nameBox.y)
	
	self.addressBox:draw()
	self.nameBox:draw()
	self.backButton:draw()
	self.joinButton:draw()
end

function join:update(dt)
	self.addressBox:update(dt)
	self.joinButton:update(dt)
	self.backButton:update(dt)
	self.nameBox:update(dt)
end

function join:keypressed(key,isrepeat)
	self.addressBox:keypressed(key, isrepeat)
	self.nameBox:keypressed(key, isrepeat)
end

function join:textinput(text)
	self.addressBox:textinput(text)
	self.nameBox:textinput(text)
end



return join
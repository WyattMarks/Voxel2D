local host = {}

function host:load()
	self.bgImage = love.graphics.newImage('assets/background.png')
	self.portBox = textbox:new()
	self.portBox.width = 100
	self.portBox.font = font.medium
	self.portBox.x = screenWidth / 2 - self.portBox.width / 2
	self.portBox.y = screenHeight / 3 + self.portBox.font:getHeight() / 2 * 6
	self.portBox.y = screenHeight / 3 + self.portBox.font:getHeight() / 2 * 6
	self.portBox.text = '1337'
	
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
	
	self.portBox.textinput = self.nameBox.textinput
	
	self.nameBox.keypressed = function(nameBox, key, isrepeat)
		if key == "backspace" and nameBox.active then
			if nameBox.firstInput then
				nameBox.text = ''
				nameBox.firstInput = false
			else
				local byteoffset = utf8.offset(self.text, -1)
			 
				if byteoffset then
					nameBox.text = string.sub(nameBox.text, 1, byteoffset - 1)
				end
			end
		end
	end
	
	self.portBox.keypressed = self.nameBox.keypressed

	
	self.backButton = button:new({text = "Back", font = font.large, width = 220, height = 50, x = screenWidth / 2 - 220 - 220/4, y = screenHeight / 2 + 30})
	self.backButton.highlightColor = {r = 90, g = 90, b = 90}
	self.backButton.clickColor = {r = 50, g = 50, b = 50}
	
	self.hostButton = button:new({text = "Host Game", font = font.large, width = 220, height = 50, x = screenWidth / 2 + 220/4, y = screenHeight / 2 + 30})
	self.hostButton.highlightColor = {r = 90, g = 90, b = 90}
	self.hostButton.clickColor = {r = 50, g = 50, b = 50}
	
	function self.hostButton.onClick(btn)
		game.name = self.nameBox.text
		local port = 1337
		
		port = tonumber(self.portBox.text)

	
		client.port = port
		server.port = port
		menu:setScreen('main')
		server:load()
		game:load()
		client:load()
	end
		
	function self.backButton.onClick(btn)
		menu:setScreen('main')
	end
end


function host:draw()
	love.graphics.setColor(200,200,200)
	love.graphics.draw(self.bgImage, 0,0)
	love.graphics.setColor(255,255,255)
	
	
	love.graphics.setFont(font.large)
	love.graphics.print("Host Game", screenWidth / 2 - font.large:getWidth("Host Game") / 2, screenHeight / 3)
	
	love.graphics.setFont(font.medium)
	love.graphics.print("Port:", self.portBox.x - font.medium:getWidth("Port:"), self.portBox.y)
	
	love.graphics.print("Name:", self.nameBox.x - font.medium:getWidth("Name:"), self.nameBox.y)
	
	self.portBox:draw()
	self.nameBox:draw()
	self.backButton:draw()
	self.hostButton:draw()
end

function host:update(dt)
	self.portBox:update(dt)
	self.hostButton:update(dt)
	self.backButton:update(dt)
	self.nameBox:update(dt)
end

function host:keypressed(key,isrepeat)
	self.portBox:keypressed(key, isrepeat)
	self.nameBox:keypressed(key, isrepeat)
end

function host:textinput(text)
	self.portBox:textinput(text)
	self.nameBox:textinput(text)
end



return host
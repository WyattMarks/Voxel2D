local join = {}

function join:load()
	self.bgImage = love.graphics.newImage('assets/background.png')
	self.textbox = textbox:new()
	self.textbox.width = 250
	self.textbox.font = font.medium
	self.textbox.firstInput = false
	self.textbox.x = screenWidth / 2 - self.textbox.width / 2
	self.textbox.y = screenHeight / 3 + self.textbox.font:getHeight() / 2 * 6
	
	
	self.backButton = button:new({text = "Back", font = font.large, width = 220, height = 50, x = screenWidth / 2 - 220 - 220/4, y = screenHeight / 2})
	self.backButton.highlightColor = {r = 90, g = 90, b = 90}
	self.backButton.clickColor = {r = 50, g = 50, b = 50}
	
	self.joinButton = button:new({text = "Join Game", font = font.large, width = 220, height = 50, x = screenWidth / 2 + 220/4, y = screenHeight / 2})
	self.joinButton.highlightColor = {r = 90, g = 90, b = 90}
	self.joinButton.clickColor = {r = 50, g = 50, b = 50}
	
	function self.joinButton.onClick(btn)
		game:load()
		local ip = self.textbox.text
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
	
	self.textbox:draw()
	self.backButton:draw()
	self.joinButton:draw()
end

function join:update(dt)
	self.textbox:update(dt)
	self.joinButton:update(dt)
	self.backButton:update(dt)
end

function join:keypressed(key,isrepeat)
	self.textbox:keypressed(key, isrepeat)
end

function join:textinput(text)
	self.textbox:textinput(text)
end



return join
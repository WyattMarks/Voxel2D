local main = {}
main.gameName = "Voxel2D"

function main:load()
	self.bgImage = love.graphics.newImage('assets/background.png')
	self.hostButton = button:new({text = "Host Game", font = font.large, width = 275, height = 50, x = screenWidth / 2 - 300, y = screenHeight / 2})
	self.hostButton.highlightColor = {r = 90, g = 90, b = 90}
	self.hostButton.clickColor = {r = 50, g = 50, b = 50}
	
	self.joinButton = button:new({text = "Join Game", font = font.large, width = 275, height = 50, x = screenWidth / 2, y = screenHeight / 2})
	self.joinButton.highlightColor = {r = 90, g = 90, b = 90}
	self.joinButton.clickColor = {r = 50, g = 50, b = 50}
		
		
	function self.hostButton.onClick(btn)
		menu:setScreen('host')
	end
		
	function self.joinButton.onClick(btn)
		menu:setScreen('join')
	end
end

function main:draw()
	love.graphics.setColor(200,200,200)
	love.graphics.draw(self.bgImage, 0,0)
	love.graphics.setColor(255,255,255)
	
	
	love.graphics.setFont(font.large)
	love.graphics.print(self.gameName, screenWidth / 2 - font.large:getWidth(self.gameName) / 2, screenHeight / 3)
	
	
	self.joinButton:draw()
	self.hostButton:draw()
end


function main:update(dt)
	self.hostButton:update(dt)
	self.joinButton:update(dt)
end

function main:keypressed(key,isrepeat)
	
end

function main:textinput(text)
	
end


return main
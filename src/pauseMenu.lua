local menu = {}
menu.gameName = "Voxel2D"


function menu:open()
	level.paused = true
	if not self.exitButton then
		self.exitButton = button:new({text = "Exit", font = font.large, width = 150, height = 50, x = screenWidth / 2 - 250, y = screenHeight / 2})
		self.exitButton.highlightColor = {r = 90, g = 90, b = 90}
		self.exitButton.clickColor = {r = 50, g = 50, b = 50}
		
		self.resumeButton = button:new({text = "Resume", font = font.large, width = 150, height = 50, x = screenWidth / 2 + 100, y = screenHeight / 2})
		self.resumeButton.highlightColor = {r = 90, g = 90, b = 90}
		self.resumeButton.clickColor = {r = 50, g = 50, b = 50}
		
		
		function self.exitButton.onClick(btn)
			for k,v in pairs(level.chunks) do
				level:save(v, k)
			end
			
			love.event.quit()
		end
		
		function self.resumeButton.onClick(btn)
			self:close()
		end
	end
end

function menu:close()
	level.paused = false
end

function menu:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight)
	
	love.graphics.setFont(font.large)
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.gameName, screenWidth / 2 - font.large:getWidth(self.gameName) / 2, screenHeight / 3)
	
	self.exitButton:draw()
	self.resumeButton:draw()
end


function menu:update(dt)
	self.exitButton:update(dt)
	self.resumeButton:update(dt)
end














return menu
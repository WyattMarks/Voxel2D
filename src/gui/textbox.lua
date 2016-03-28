local textbox = {}
textbox.width = 400
textbox.font = font.small
textbox.x = 200
textbox.y = 200
textbox.active = false
textbox.canClick = true
textbox.firstInput = true

textbox.text = ''
textbox.drawText = ''
utf8 = require("utf8")


function textbox:textinput(t)
	if self.active then
		if not self.firstInput then
			self.text = self.text..t
		else
			self.firstInput = false
		end
	end
end

function textbox:keypressed(key, isrepeat)
	if key == "backspace" and self.active then
		local byteoffset = utf8.offset(self.text, -1)
	 
	    if byteoffset then
	        self.text = string.sub(self.text, 1, byteoffset - 1)
	    end
	end
end

function textbox:update(dt)
	local mousePos = {love.mouse.getPosition()}
	local mouseOver = false
	
	if mousePos[1] > self.x and mousePos[1] < self.x + self.width and mousePos[2] > self.y and mousePos[2] < self.y + self.font:getHeight() then
		mouseOver = true
	end
	
	if mouseOver and self.wasMouseDown and not love.mouse.isDown(1) and not self.runOnce and self.canClick then 
		self.active = true
		self.runOnce = true
	else
		self.runOnce = false
	end
	
	self.wasMouseDown = love.mouse.isDown(1)
	
	if self.wasMouseDown and not mouseOver then
		self.active = false
	end
	
	if self.font:getWidth(self.text) > self.width then
		local i = 1
		while (self.font:getWidth(self.drawText) < self.width) do
			local text = self.text
			self.drawText = text:sub(#text - i)
			i = i + 1
		end
		
		self.drawText = self.drawText:sub(2)
	else
		self.drawText = self.text
	end
end


function textbox:draw()
	love.graphics.setColor(70,70,70,140)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.font:getHeight())
	
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.drawText, self.x, self.y)
end





return textbox
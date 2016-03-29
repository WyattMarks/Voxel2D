local chatbox = {}
chatbox.text = {}
chatbox.textbox = textbox:new()
chatbox.width = 400
chatbox.x = 10
chatbox.textbox.x = chatbox.x
chatbox.textbox.canClick = false
chatbox.showMessageTime = 10

function chatbox:addMessage(sender, text)
	self.text[#self.text + 1] = {0, {{50,50,255}, sender, {255,255,255}, text}}
end

function chatbox:update(dt)
	self.textbox:update(dt)
	
	for k,v in pairs(self.text) do
		v[1] = math.min(self.showMessageTime, v[1] + dt)
	end
end

function chatbox:draw()
	local y = self.textbox.y - 2
	if self.textbox.active then
		self.textbox:draw()
	end
	
	for i=#self.text,1,-1 do
		local alpha = 140
		if not self.textbox.active then
			alpha = math.min(140, (self.showMessageTime / self.text[i][1] - 1) * 140)
		end
		
		if #self.text > 10 and #self.text - i > 10 then
			alpha = 0
		end
		
		local message = self.text[i][2]
		love.graphics.setColor(70,70,70,alpha)
		local width, wrappedText = self.font:getWrap(message[2]..message[4], self.width)
		y = y - #wrappedText * self.font:getHeight()
		
		love.graphics.rectangle('fill', self.x, y, self.width, #wrappedText * self.font:getHeight())
		
		alpha = alpha / 140 * 255
		
		love.graphics.setColor(255,255,255, alpha)
		love.graphics.printf(message, self.x, y, self.width)
	end
end

function chatbox:keypressed(key, isrepeat)
	self.textbox:keypressed(key, isrepeat)
	if key == "return" and self.textbox.active then
		self.textbox.active = false
		if self.textbox.text ~= '' then
			client:send("CHAT"..game:getLocalPlayer().name.." "..self.textbox.text)
		end
		
		if self.textbox.text:sub(1,1) == '/' then
			loadstring(self.textbox.text:sub(2))()
		end
		self.textbox.text = ''
		self.textbox.drawText = ''
		self.textbox.firstInput = true
		game.input:load()
	end
end

function chatbox:textinput(text)
	self.textbox:textinput(text)
end

function chatbox:new()
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end
	return new
end






















return chatbox
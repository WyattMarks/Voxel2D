local debug = {}
debug.on = true
debug.variables = {}
debug.log = {}
debug.font = {}
debug.offset = 20

function debug:add(key, value)
	for k,v in pairs(self.variables) do
		if v[1] == key then
			self.variables[k] = {key, value}
			return
		end
	end
	
	self.variables[#self.variables + 1] = {key, value}
end

function debug:print(str)
	print(str)
	self.log[#self.log + 1] = os.date("%c", os.time()) .. tostring(str)
end


function debug:draw()
	local y = 10
	
	if type(self.font) == "table" then
		self.font = love.graphics.newImageFont("assets/font.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(self.font)
	
	
	for i=1, #self.variables do
		
		
		love.graphics.print(tostring(self.variables[i][1])..":", 10, y)
		love.graphics.print(tostring(self.variables[i][2]), self.font:getWidth(tostring(self.variables[i][1])..":") + 10 + self.offset, y)
		
		y = y + 10
	end
end


function debug:update(dt)
end




return debug
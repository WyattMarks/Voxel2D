local debug = {}
debug.on = true
debug.variables = {}
debug.log = {}

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
	local font = love.graphics.newFont(15)
	
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(font)
	
	
	for i=1, #self.variables do
		love.graphics.print(tostring(self.variables[i][1])..":", 10, y)
		love.graphics.print(tostring(self.variables[i][2]), 50, y)
	end
end


function debug:update(dt)
end




return debug
local menu = {}
menu.currentScreen = {}

function menu:load()
	self:setScreen('main')
end

function menu:draw()
	self.currentScreen:draw()
end

function menu:update(dt)
	self.currentScreen:update(dt)
end

function menu:setScreen(name)
	self.currentScreen = require('src/menu/'..name)
	self.currentScreen:load()
end

function menu:keypressed(key,isrepeat)
	self.currentScreen:keypressed(key,isrepeat)
end

function menu:textinput(text)
	self.currentScreen:textinput(text)
end


























return menu
local game = {}
game.players = {}


function game:load()
	self.input = require("src/input/gameInput")
	blockManager:load()
	self.input:load()
	
	camera:scale(.5,.5)
	--camera:scale(3,3)
	camera.speed = 128
	camera.horizontalBorder = 256
	camera.topBorder = 192
	camera.bottomBorder = 256
	camera.xOffset = 0
	camera.yOffset = 0
	
	world = bump.newWorld(64)
	
	self:addPlayer('player', true)
	
	camera:follow(self:getLocalPlayer())
	
	level:load()
	self:getLocalPlayer():load()
	self.running = true
end

function game:addPlayer(name, isLocal)
	local player = require("src/player")
	player.name = name
	player.localPlayer = isLocal
	player.inventory = require("src/inventory")
	player.inventory.owner = player.name
	player.inventory:load()
	self.players[#self.players + 1] = player
end

function game:getLocalPlayer()
	for k,v in pairs(self.players) do
		if v.localPlayer then
			return v
		end
	end
end

function game:getPlayer(name)
	for k,v in pairs(self.players) do
		if v.name == name then
			return v
		end
	end
end

function game:update(dt)
	level:update(dt)
	camera:update(dt)
	for k,player in pairs(self.players) do
		player:update(dt)
	end
end

function game:draw()
	camera:set()
		level:draw()
		for k,player in pairs(self.players) do
			player:draw()
		end
	camera:unset()
	
	hud:draw()
	self:getLocalPlayer().inventory:draw()
	debug:draw()
	
	if game.paused then
		pauseMenu:draw()
	end
end

function game:unload()
	self.input:unload()
	
	for k,v in pairs(level.chunks) do
		level:save(v, k)
	end
	
	for k,v in pairs(self.players) do
		v.inventory:save()
	end
	
	level:saveData()
	settings:save()
	
	love.event.quit()
end

function game:mousepressed(x, y, button, istouch)
	self:getLocalPlayer():mousepressed(x, y, button)
end

function game:mousereleased(x, y, button, istouch)
	self:getLocalPlayer():mousereleased(x, y, button)
end

function game:wheelmoved(x,y)
	self:getLocalPlayer():wheelmoved(x,y)
end






return game
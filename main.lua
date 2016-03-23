io.stdout:setvbuf("no")

debug = require("src/debug")
bump = require("src/bump")
chunk = require("src/chunk")
input = require("src/input")
level = require("src/level")
blockManager = require("src/blockManager")
block = require("src/block")
player = require("src/player")
hud = require("src/hud")
settings = require("src/settings")
inventory = require("src/inventory")
pauseMenu = require("src/pauseMenu")
font = require("src/font")
button = require("src/button")
require("src/camera")
require("src/Tserial")

function PrintTable(tbl, tabs)
	tabs = tabs or 0;
	for k,v in pairs(tbl) do
		if type(v) ~= "table" then
			local temp;
			for i=1, tabs do
				temp = temp or {};
				temp[i] = '';
			end
			if temp then
				temp[#temp + 1] = tostring(k)..":";
				temp[#temp + 1] = v;
				print(unpack(temp));
			else
				print(tostring(k)..":", v);
			end
		else
			local temp;
			for i=1, tabs do
				temp = temp or {};
				temp[i] = '';
			end
			if temp then
				temp[#temp + 1] = tostring(k)..":";
				print(unpack(temp));
			else
				print(tostring(k)..":");
			end
			temp = nil;
			
			PrintTable(v, tabs + 1)
		end
	end
end


function love.load()
	math.randomseed(os.time())
	level.offset = math.random(-10000,100000)
	font:load()
	blockManager:load()
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	blocks = blockManager:getBlocks()
	
	camera:scale(.5,.5)
	--camera:scale(3,3)
	camera.speed = 128
	camera:move(0, 400)
	camera.horizontalBorder = 256
	camera.topBorder = 192
	camera.bottomBorder = 256
	
	world = bump.newWorld(64)
	
	player:load()
	inventory:load()
end


function love.update(dt) 
	if not level.paused then
		level:update(dt)
		player:update(dt)
	else
		pauseMenu:update(dt)
	end
	
	debug:update(dt)
end


function love.draw()
	camera:set()
		level:draw()
		player:draw()
	camera:unset()
	
	hud:draw()
	inventory:draw()
	debug:draw()
	
	if level.paused then
		pauseMenu:draw()
	end
end

function love.keypressed(key, isrepeat)
	input:keypressed(key, isrepeat)
end

function love.keyreleased(key)
	input:keyreleased(key)
end

function love.mousepressed( x, y, button, istouch )
	player:mousepressed(x, y, button)
	inventory:mousepressed(x,y,button)
end

function love.mousereleased(x, y, button, istouch)
	player:mousereleased(x, y, button)
	inventory:mousereleased(x, y, button)
end

function love.wheelmoved(x,y)
	player:wheelmoved(x,y)
end
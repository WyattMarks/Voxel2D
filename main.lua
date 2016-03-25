io.stdout:setvbuf("no")



--Third Party
bump = require("src/thirdparty/bump")
require("src/thirdparty/camera")
require("src/thirdparty/Tserial")

--World related
chunk = require("src/world/chunk")
level = require("src/world/level")
blockManager = require("src/world/blockManager")
block = require("src/world/block")

--GUI related
debug = require("src/gui/debug")
hud = require("src/gui/hud")
pauseMenu = require("src/gui/pauseMenu")
button = require("src/gui/button")
font = require("src/gui/font")


bind = require("src/bind")
input = require("src/input")
settings = require("src/settings")
player = require("src/player")
inventory = require("src/inventory")


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
	input:load()
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	blocks = blockManager:getBlocks()
	
	camera:scale(.5,.5)
	--camera:scale(3,3)
	camera.speed = 128
	camera.horizontalBorder = 256
	camera.topBorder = 192
	camera.bottomBorder = 256
	camera.xOffset = 0
	camera.yOffset = 0
	
	world = bump.newWorld(64)
	
	level:loadData()
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
	bind:keypressed(key, isrepeat)
end

function love.keyreleased(key)
	bind:keyreleased(key)
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
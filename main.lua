io.stdout:setvbuf("no")



--Third Party
bump = require("src/thirdparty/bump")
require("src/thirdparty/camera")
require("src/thirdparty/Tserial")

--Networking related
require("enet")
server = require("src/networking/server") 
client = require("src/networking/client")

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
textbox = require("src/gui/textbox")
chatbox = require("src/gui/chatbox")

--Input related
bind = require("src/input/bind")

menu = require('src/menu')
inventory = require("src/inventory")
player = require("src/player")
game = require("src/game")
settings = require("src/settings")


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
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	math.randomseed(os.time())
	font:load()
	settings:load()
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	menu:load()
end


function love.update(dt)
	if game.running then
		if not game.paused then
			game:update(dt)
		else
			pauseMenu:update(dt)
		end
		
		if server.hosting then
			server:update(dt)
		end
		client:update(dt)
		debug:update(dt)
	else
		menu:update(dt)
	end
end


function love.draw()
	if game.running then
		game:draw()
	else
		menu:draw()
	end
end

function love.keypressed(key, isrepeat)
	bind:keypressed(key, isrepeat)
	if game.running then
		game:keypressed(key, isrepeat)
	else
		menu:keypressed(key, isrepeat)
	end
end

function love.keyreleased(key)
	bind:keyreleased(key)
end

function love.textinput(text)
	if game.running then
		game:textinput(text)
	else
		menu:textinput(text)
	end
end

function love.mousepressed( x, y, button, istouch )
	if game.running then
		game:mousepressed(x,y,button,istouch)
	end
end

function love.mousereleased(x, y, button, istouch)
	if game.running then
		game:mousereleased(x,y,button,istouch)
	end
end

function love.wheelmoved(x,y)
	if game.running then
		game:wheelmoved(x,y)
	end
end
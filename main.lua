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

--Input related
bind = require("src/input/bind")



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
	math.randomseed(os.time())
	font:load()
	settings:load()
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	game:load()
end


function love.update(dt) 
	if game.running then
		if not game.paused then
			game:update(dt)
		else
			pauseMenu:update(dt)
		end
	end
	
	debug:update(dt)
end


function love.draw()
	if game.running then
		game:draw()
	end
	
	--[[love.graphics.setColor(120,120,120,120)
	love.graphics.setFont(font.small)
	local text = "Meow this is a test. I am text, maybe I'll wrap. Who knows. I am so bored, my stomach hurts and I don't know why and I am sad about it. I miss Shreya"
	local width, wrappedText = font.small:getWrap(text, 400)
	
	love.graphics.rectangle('fill', 300, 50, 400, #wrappedText * font.small:getHeight())
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 300 + font.small:getWidth(wrappedText[#wrappedText]), 50 + (#wrappedText-1) * font.small:getHeight(), font.small:getWidth(" "), font.small:getHeight())
	love.graphics.printf(text, 300,50,400)]]
end

function love.keypressed(key, isrepeat)
	bind:keypressed(key, isrepeat)
	game:keypressed(key, isrepeat)
end

function love.keyreleased(key)
	bind:keyreleased(key)
end

function love.textinput(text)
	game:textinput(text)
end

function love.mousepressed( x, y, button, istouch )
	game:mousepressed(x,y,button,istouch)
end

function love.mousereleased(x, y, button, istouch)
	game:mousereleased(x,y,button,istouch)
end

function love.wheelmoved(x,y)
	game:wheelmoved(x,y)
end
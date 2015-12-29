local hud = {}

function hud:draw()
	debug:add("FPS", love.timer.getFPS())
	
	
	local mouseX, mouseY = love.mouse.getPosition()
	local x, y, chunk = level:screenToWorld(mouseX, mouseY)
	
	
	x, y = level:worldToScreen(x, y, chunk)
	
	if (love.mouse.isDown(1) or love.mouse.isDown(2)) and player.mining then
		local alpha = 100
		alpha = player.sameActive / (player.breaking.delay or 1) * 255
		local color = settings.miningCursorColor
		
		love.graphics.setColor(color.r, color.g, color.b, alpha)
		love.graphics.rectangle('fill', x, y, blockManager.size / camera.sx, blockManager.size / camera.sy)
		love.graphics.setColor(color.r, color.g, color.b, 255)
		love.graphics.rectangle('line', x, y, blockManager.size / camera.sx, blockManager.size / camera.sy)
	end
end


return hud
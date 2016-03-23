local hud = {}
hud.hotbar = {}
hud.hotbar.width = 340
hud.hotbar.height = 34

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
	else
		local color = settings.hoverCursorColor

		love.graphics.setColor(color.r, color.g, color.b, 255)
		love.graphics.rectangle('line', x, y, blockManager.size / camera.sx, blockManager.size / camera.sy)
	end
	
	
	
	local x = screenWidth / 2 - self.hotbar.width / 2
	local y = screenHeight - self.hotbar.height - 10
	
	love.graphics.setColor(200,200,200)
	love.graphics.rectangle('fill', x, y, self.hotbar.width, self.hotbar.height)
	
	
	for w=1, inventory.width do
		local x = x + w * 34 - 33
		love.graphics.setColor(50,50,50)
		love.graphics.rectangle('fill', x, y + 1, 32, 32)
		
		if inventory.inventory[w][inventory.height].id then
			love.graphics.setColor(255,255,255)
			local item = inventory.inventory[w][inventory.height]
			love.graphics.draw(blockManager.texture, item.quad, x + 1, y + 2, 0, 1.875, 1.875)

				
			if item.quantity > 1 then
				love.graphics.setColor(255,255,255)
				love.graphics.setFont( inventory.font )
				local y = y + 32 - inventory.font:getHeight()
				local x = x + 31 - inventory.font:getWidth(tostring(item.quantity))
				love.graphics.print(tostring(item.quantity), x, y)
			end
		end
	end
	
	
	local x = x + player.activeSlot * 34 - 33
	love.graphics.setColor(200,200,200,255/2)
	love.graphics.rectangle('fill', x, y + 1, 32, 32)
end


return hud
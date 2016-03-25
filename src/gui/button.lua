local button = {}; --Button class by Wyatt Marks
button.width = 100; --Width and height of the button
button.height = 100;
button.x = 100;	--Button location
button.y = 100;
button.text = 'Text';--What the button says
button.font = love.graphics.newFont(12);
button.color = {r = 80, g = 80, b = 80};
button.textColor = {r = 255, g = 255, b = 255};
button.mouseOver = false; --Used internally in this class
button.button = 1; --Which mouse button should click it
button.wasMouseDown = false; --Used to make sure it doesnt get clicked 999 times when you only are holding the mouse down
button.visible = true;
button.allowTransparency = true;

function button:new(args) --button class 'contructor' (note, classes aren't actually possible in Lua. This is really just a table that has fancy duplication abilities)
	args = args or {}; --args table is most useful so I can change or add anything to the class without messing with the contructor

	local tbl = {};

	for k,v in pairs(self) do --We don't just do local tbl = self because lua uses references so if you messed with tbl it would mess with self too
		tbl[k] = v;
	end

	for k,v in pairs(args) do
		tbl[k] = v;
	end

	return tbl;
end

function button:update(dt)
	local mousePos = {love.mouse.getPosition()};

	if mousePos[1] >= self.x and mousePos[1] <= self.x + self.width and mousePos[2] >= self.y and mousePos[2] <= self.y + self.height then
		self.mouseOver = true; --The above if statement is just to check if the mouse location is inside the button
	else
		self.mouseOver = false;
	end

	if self.wasMouseDown and self.mouseOver and not love.mouse.isDown(self.button) then
		self:onClick();
	end
	
	self.wasMouseDown = love.mouse.isDown(self.button)
end

function button:onClick() --This will normally be overrided but we need to define it so in case they don't override it it doesn't error 

end

function button:draw()
	if not self.visible then return end --dont draw if not visible
	
	if self.mouseOver then
		if love.mouse.isDown(self.button) then
			local color = self.clickColor or self.color; --Set the color to the special color for when it is clicked
			if self.allowTransparency then
				love.graphics.setColor(color.r, color.g, color.b, color.a or 255); 
			else
				love.graphics.setColor(color.r, color.g, color.b);
			end
		else
			local color = self.highlightColor or self.color; --Mouse over color since we're not clicking but the mouse is over
			love.graphics.setColor(color.r, color.g, color.b);
		end
	else
		if self.allowTransparency then
			love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a or 255); --default color
		else
			love.graphics.setColor(self.color.r, self.color.g, self.color.b);
		end
	end

	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height); --Draw the buttn with the predetermined color

	if self.allowTransparency then
		love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a or 255);
	else
		love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b, 255);
	end
	love.graphics.setFont(self.font); --Draw the text on top of the button bg

	love.graphics.print(self.text, self.x + self.width / 2 - self.font:getWidth(self.text) / 2, self.y + self.height / 2 - self.font:getHeight() / 2)
end

return button;
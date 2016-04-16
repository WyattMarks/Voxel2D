local client = {}
client.address = "localhost"
client.port = 1337
client.queue = {}
client.updateRate = .02
client.lastUpdate = 0

function client:send(message) 
	if self.ready then
		self.server:send(message)
	else
		self.queue[#self.queue + 1] = message
	end
end

function client:load()
	self.host = enet.host_create()
	self.server = self.host:connect(self.address..":"..tostring(self.port))
	--self.udp:settimeout(0)
	
	local player = game:getLocalPlayer()
	local toSend = {player.name, player.x, player.y}
	self:send("JOIN"..Tserial.pack(toSend, false, false))
end

function client:updatePlayerInfo(data)
	if server.hosting then return end
	data = Tserial.unpack(data)
	local player = game:getLocalPlayer()
	for name, info in pairs(data) do
		if name ~= player.name then
			local ply = game:getPlayer(name)
			if ply then
				ply.x = info[1]
				ply.y = info[2]
				ply.yvel = info[3]
			end
		end
	end
end

function client:sendPlayerInfo()
	if server.hosting then return end
	local player = game:getLocalPlayer()
	local toSend = {player.x, player.y, player.yvel}
	
	local message = Tserial.pack(toSend,false,false)
	self:send('UPDATE'..message)
end


function client:update(dt)
	if self.ready then
		for k,v in pairs(self.queue) do
			self.server:send(v)
			self.queue[k] = nil
		end
	end
	
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate > self.updateRate then
		self.lastUpdate = self.lastUpdate - dt
		
		self:sendPlayerInfo()
	end
	
	local event = self.host:service()
	repeat
		if event and event.type == "receive" then
			local data = event.data
			if data == "READY" then
				self.ready = true
			elseif data:sub(1,4) == "JOIN" then
				data = Tserial.unpack( data:sub(5) )
				local name = data[1]
				local x = data[2]
				local y = data[3]
					
				local player = game:getLocalPlayer()
				if name == player.name or server.hosting then
					return
				end
				game:addPlayer(name, false)
				player = game:getPlayer(name)
				player.x = tonumber(x)
				player.y = tonumber(y)
				player.inventory:loadSaveFile(data[4])
			elseif data:sub(1,4) == "CHAT" then
				data = data:sub(5)
				local name = data:match("^(%-?[%a|%d.e]*) ")
				data = data:sub(name:len()+1)
				
				game.chatbox:addMessage(name, data)
			elseif data:sub(1,5) == "CHUNK" then
				data = data:sub(6)
				local space = data:find(" ")
				local chunkNum = tonumber(data:sub(1,space))
				local saveFile = data:sub(space + 1)
				
				level:loadSaveFile(chunkNum, saveFile)
				level.chunks[chunkNum].visible = true
			elseif data:sub(1,6) == "UPDATE" then
				data = data:sub(7)
				self:updatePlayerInfo(data)
			elseif data:sub(1,5) == "BREAK" then
				print(data)
				self:breakBlock(data:sub(6))
			elseif data:sub(1,5) == "PLACE" then
				self:placeBlock(data:sub(6))
			elseif data:sub(1,9) == "INVENTORY" then
				game:getLocalPlayer().inventory:loadSaveFile(data:sub(10))
			elseif data:sub(1,4) == "MOVE" then
				local player = game:getLocalPlayer()
				local coords = Tserial.unpack(data:sub(5))
				player.x = coords[1]
				player.y = coords[2]
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

function client:breakBlock(breakInfo)
	breakInfo = Tserial.unpack(breakInfo)
	local player = game:getPlayer(breakInfo[1])
	breakInfo = Tserial.unpack(breakInfo[2])
	
	local toAdd = blockManager:getByID(breakInfo[1])
	local x = breakInfo[2]
	local y = breakInfo[3]
	local chunk = breakInfo[4]
	local bg = breakInfo[5]
	
	if player.inventory:add(toAdd, 1) then
		level:deleteBlock(x, y, chunk, bg)
	end
end

function client:placeBlock(placeInfo)
	placeInfo = Tserial.unpack(placeInfo)
	local player = game:getPlayer(placeInfo[1])
	placeInfo = Tserial.unpack(placeInfo[2])
	
	--{item.name, x, y, chunk, bg, self.activeSlot}
	local block = blockManager.blocks[placeInfo[1]]:new()
	block.bg = placeInfo[5]
	block:updateQuad()
	
	level:placeBlock(block, placeInfo[2], placeInfo[3], placeInfo[4], block.bg)
	
	if not player.localPlayer then
		local item = player.inventory.inventory[placeInfo[6]][player.inventory.height]
		if item.quantity <= 1 then
			player.inventory.inventory[placeInfo[6]][player.inventory.height] = {}
		else
			player.inventory.inventory[placeInfo[6]][player.inventory.height].quantity = item.quantity - 1
		end
	end
end



























return client
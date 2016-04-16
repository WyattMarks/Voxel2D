local server = {}
server.port = 1337
server.updateRate = .02
server.lastUpdate = 0

function server:load()
	self.host = enet.host_create("*:"..tostring(self.port))
	--self.udp:settimeout(0)
	self.hosting = true
end

function server:getPlayer(peer)
	for k,v in pairs(game.players) do
		if v.peer and v.peer == peer then
			return v
		end
	end
	return false
end

function server:broadcast(message)
	for k,v in pairs(game.players) do
		if v.peer then
			v.peer:send(message)
		end
	end
end

function server:processPlayerInfo(data, player)
	data = Tserial.unpack(data)
	player.x = data[1]
	player.y = data[2]
	player.yvel = data[3]
end

function server:broadcastPlayerInfo()
	local toSend = {}
	for k,v in pairs(game.players) do
		toSend[v.name] = {v.x,v.y,v.yvel}
	end
	local message = Tserial.pack(toSend,false,false)
	self:broadcast('UPDATE'..message)
end

function server:send(player, data)
	player.peer:send(data)
end

function server:playerJoin(data, peer)
	local info = Tserial.unpack( data:sub(5) )
	local name = info[1]
	local x = info[2]
	local y = info[3]

	
	game:network(name, peer)
	if name ~= game:getLocalPlayer().name then
		game:addPlayer(name, false)
	end
	info[4] = game:getPlayer(name).inventory:createSaveFile()
	self:broadcast(Tserial.pack(info, false, false))
					
	for k,v in pairs(game.players) do
		if v.peer ~= peer then
			peer:send("JOIN"..Tserial.pack( {v.name, v.x, v.y, v.inventory:createSaveFile()}, false, false ))
		end
	end
end

function server:update(dt)
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate >= self.updateRate then
		self.lastUpdate = self.lastUpdate - self.updateRate
		
		self:broadcastPlayerInfo()
	end
	
	local event = self.host:service()
	repeat
		if event then
			if event.type == "receive" then
				local data = event.data
				if data:sub(1,4) == "JOIN" then
					self:playerJoin(data, event.peer)
				elseif data:sub(1,4) == "CHAT" then	
					self:broadcast(data)
				elseif data:sub(1,4) == "LOAD" then
					self:sendChunk(tonumber(data:sub(5)), event.peer)
				elseif data:sub(1,6) == "UPDATE" then
					self:processPlayerInfo(data:sub(7), self:getPlayer(event.peer))
				elseif data:sub(1,5) == "BREAK" then
					self:breakBlock(data:sub(6), self:getPlayer(event.peer))
				elseif data:sub(1,5) == "PLACE" then
					self:placeBlock(data:sub(6), self:getPlayer(event.peer))
				end
			elseif event.type == "connect" then
				event.peer:send("READY")
			elseif event.type == "disconnect" then
				--TODO: remove from game and broadcast the problem
			end
		end
		event = self.host:service()
	until not event
end

function server:breakBlock(breakInfo, player)
	self:broadcast("BREAK"..Tserial.pack({player.name, breakInfo}))
end

function server:placeBlock(placeInfo, player)
	self:broadcast("PLACE"..Tserial.pack({player.name, placeInfo}))
end

function server:sendChunk(chunkNum, peer)
	if not level.chunks[chunkNum] then
		if not level:loadChunk(chunkNum) then
			level.chunks[chunkNum] = chunk:generate(chunkNum)
		end
	end
	
	local final = level:createSaveFile(level.chunks[chunkNum], chunkNum)
	
	peer:send("CHUNK"..tostring(chunkNum).." "..final)
end
























return server
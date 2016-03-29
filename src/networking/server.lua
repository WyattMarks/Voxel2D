local server = {}
server.address = "localhost"
server.port = 1337

function server:load()
	self.host = enet.host_create(self.address..":"..tostring(self.port))
	--self.udp:settimeout(0)
	self.hosting = true
end

function server:getPlayer(peer)
	for k,v in pairs(game.players) do
		print("MEOW",v.peer, peer)
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

function server:update()
	local event = self.host:service()
	repeat
		if event then
			debug:print("server - "..event.type..": "..tostring(event.peer)..": "..event.data)
			if event.type == "receive" then
				local data = event.data
				if data:sub(1,4) == "JOIN" then
					data = data:sub(5)
					local name, x, y = data:match("^(%-?[%a|%d.e]*) (%-?[%d.e]*) (%-?[%d.e]*)$") --jesus this is some crazy stuff
					
					game:network(name, event.peer)
					self:broadcast("JOIN"..name.." "..x.." "..y)
					
					for k,v in pairs(game.players) do
						if v.peer ~= event.peer then
							event.peer:send("JOIN"..v.name.." "..v.x.." "..v.y)
						end
					end
				elseif data:sub(1,4) == "CHAT" then	
					self:broadcast(data)
				elseif data:sub(1,4) == "LOAD" then
					self:sendChunk(tonumber(data:sub(5)), event.peer)
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
local client = {}
client.address = "localhost"
client.port = 1337
client.queue = {}


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
	self:send("JOIN"..player.name.." "..player.x.." "..player.y)
end

function client:update(dt)
	if self.ready then
		for k,v in pairs(self.queue) do
			self.server:send(v)
			self.queue[k] = nil
		end
	end
	
	local event = self.host:service()
	repeat
		if event and event.type == "receive" then
			local data = event.data
			if data == "READY" then
				self.ready = true
			elseif data:sub(1,4) == "JOIN" then
				data = data:sub(5)
				local name, x, y = data:match("^(%-?[%a|%d.e]*) (%-?[%d.e]*) (%-?[%d.e]*)$") --jesus this is some crazy stuff
					
				local player = game:getLocalPlayer()
				if name == player.name then
					return
				end
				game:addPlayer(name, false)
				player = game:getPlayer(name)
				player.x = tonumber(x)
				player.y = tonumber(y)
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
					
				love.filesystem.write("fuck", saveFile)
				
				level:loadSaveFile(chunkNum, saveFile)
				level.chunks[chunkNum].visible = true
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

































return client
local input = {}


function input:load()
	bind:addBind("inventory", settings.binds.inventory, function(down)
		if down then
			local player = game:getLocalPlayer()
			player.inventory.open = not player.inventory.open
		end
	end)

	bind:addBind("pRight", settings.binds.right, function(down)
		game:getLocalPlayer().right = down
	end)
	bind:addBind("pLeft", settings.binds.left, function(down)
		game:getLocalPlayer().left = down
	end)
	bind:addBind("pUp", settings.binds.up, function(down)
		game:getLocalPlayer().up = down
	end)
	bind:addBind("pDown", settings.binds.down, function(down)
		game:getLocalPlayer().down = down
	end)
	bind:addBind("pJump", settings.binds.jump, function(down)
		if down and game:getLocalPlayer().onGround then
			game:getLocalPlayer().yvel = 256
		end
	end)
	bind:addBind("pSwitch", settings.binds.breakPlaceMode, function(down)
		if down then
			if game:getLocalPlayer().mode == "break" then
				game:getLocalPlayer().mode = "place"
			else
				game:getLocalPlayer().mode = "break"
			end
		end
	end)
	bind:addBind("pFly", settings.binds.fly, function(down)
		if down then
			game:getLocalPlayer().flying = not game:getLocalPlayer().flying
			if game:getLocalPlayer().flying then
				debug:add("Flying", '')
			else
				debug:remove("Flying")
			end
		end
	end)

	bind:addBind("pause", settings.binds.pause, function(down)
		if down then
			if not game.paused then
				pauseMenu:open()
			else
				pauseMenu:close()
			end
		end
	end)

	bind:addBind("instaBreak", settings.binds.instaMine, function(down)
		if down then
			game:getLocalPlayer().instaBreak = not game:getLocalPlayer().instaBreak
			if game:getLocalPlayer().instaBreak then
				debug:add("InstaBreak", '')
			else
				debug:remove("InstaBreak")
			end
		end
	end)

	bind:addBind("debug", "g", function(down)
		if down then
			game:getLocalPlayer().inventory:add(blockManager:getBlock('dirt'), 1)
		end
	end)

	bind:addBind("chat", settings.binds.chat, function(down)
		if down then
			game.chatbox.textbox.active = true
			game.input:unload()
		end
	end)
end

function input:unload()
	bind:removeBind("inventory")

	bind:removeBind("pRight")
	bind:removeBind("pLeft")
	bind:removeBind("pUp")
	bind:removeBind("pDown")
	bind:removeBind("pJump")
	bind:removeBind("pSwitch")
	bind:removeBind("pFly")

	bind:removeBind("pause")
	bind:removeBind("chat")
	
	bind:removeBind("instaBreak")

	bind:removeBind("debug")
end











return input
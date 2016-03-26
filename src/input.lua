local input = {}


function input:load()
	bind:addBind("inventory", settings.binds.inventory, function(down)
		if down then
			inventory.open = not inventory.open
		end
	end)

	bind:addBind("pRight", settings.binds.right, function(down)
		player.right = down
	end)
	bind:addBind("pLeft", settings.binds.left, function(down)
		player.left = down
	end)
	bind:addBind("pUp", settings.binds.up, function(down)
		player.up = down
	end)
	bind:addBind("pDown", settings.binds.down, function(down)
		player.down = down
	end)
	bind:addBind("pJump", settings.binds.jump, function(down)
		if down and player.onGround then
			player.yvel = 256
		end
	end)
	bind:addBind("pSwitch", settings.binds.breakPlaceMode, function(down)
		if down then
			if player.mode == "break" then
				player.mode = "place"
			else
				player.mode = "break"
			end
		end
	end)
	bind:addBind("pFly", settings.binds.fly, function(down)
		if down then
			player.flying = not player.flying
			if player.flying then
				debug:add("Flying", '')
			else
				debug:remove("Flying")
			end
		end
	end)

	bind:addBind("pause", settings.binds.pause, function(down)
		if down then
			if not level.paused then
				pauseMenu:open()
			else
				pauseMenu:close()
			end
		end
	end)

	bind:addBind("instaBreak", settings.binds.instaMine, function(down)
		if down then
			player.instaBreak = not player.instaBreak
			if player.instaBreak then
				debug:add("InstaBreak", '')
			else
				debug:remove("InstaBreak")
			end
		end
	end)

	bind:addBind("debug", "g", function(down)
		if down then
			debug:print(settings.binds.instaMine)
		end
	end)
end











return input
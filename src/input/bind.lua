local input = {
    binds = {}
}

--[[Bind function setup:
    function bind(bool down, (optional bool isrepeat)
    
    end
]]

function input:addBind(identifier, key, func)
    self.binds[identifier] = {key, func};
end

function input:removeBind(identifier)
	self.binds[identifier] = nil;
end


function input:update(dt)
    
end

function input:keyreleased(key)
    for k,v in pairs(self.binds) do
        if v[1] == key then
            v[2](false);
        end
    end
end

function input:keypressed(key, isrepeat)
    for k,v in pairs(self.binds) do
        if v[1] == key then
            v[2](true, isrepeat);
        end
    end
end

return input;
local Stack = {}
Stack.__index = Stack

function Stack:new()
    return setmetatable({}, self)
end

function Stack:push(val)
	table.insert(self, val)
end

function Stack:pop()
    return table.remove(self)
end

function Stack:peek()
    return self[#self]
end

function Stack:is_empty()
    return #self == 0
end

return Stack

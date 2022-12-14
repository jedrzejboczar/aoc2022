local Fifo = {}
Fifo.__index = Fifo

function Fifo:new()
    return setmetatable({
        head = 1,
        tail = 1,
    }, self)
end

function Fifo:count()
    return self.tail - self.head
end

function Fifo:push(val)
    self[self.tail] = val
    self.tail = self.tail + 1
end

function Fifo:pop()
    if self:count() == 0 then return end
    local val = self[self.head]
    self.head = self.head + 1
    return val
end

function Fifo:peek()
    return self[self.head]
end

function Fifo:is_empty()
    return self:count() == 0
end

return Fifo

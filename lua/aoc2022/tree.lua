local Stack = require('aoc2022.stack')
local Fifo = require('aoc2022.fifo')

---@class Tree
---@field parent Tree?
---@field children Tree[]
local Tree = {}
Tree.__index = Tree

function Tree:new(value)
    return setmetatable({
        value = value,
        parent = nil,
        children = {},
    }, self)
end

---@param value any
function Tree:add(value)
    local child = Tree:new(value)
    child.parent = self
    table.insert(self.children, child)
end

function Tree:is_root()
    return self.parent ~= nil
end

function Tree:iter_preorder()
    local stack = Stack:new()
    stack:push(self)
    return function()
        if stack:is_empty() then return end
        local node = stack:pop()
        for _, child in ipairs(node.children) do
            stack:push(child)
        end
        return node
    end
end

function Tree:iter_bfs()
    local fifo = Fifo:new()
    fifo:push(self)
    return function()
        if fifo:is_empty() then return end
        local node = assert(fifo:pop()) -- disable nil warning
        for _, child in ipairs(node.children) do
            fifo:push(child)
        end
        return node
    end
end

-- function Tree:iter_postorder()
--     local stack = Stack:new()
--     local node = self
--     local last_visited
--     local child_i = 1
--     return function()
--         while not stack:is_empty() and node ~= nil do
--             if node then
--                 stack:push(node)
--                 node = node.children[1]
--             else
--                 peeked = stack:peek()
--                 -- if peeked.children[]
--             end
--         end
--     end
-- end

-- TODO: use iterative approach
function Tree:iter_postorder()
    local postorder
    postorder = function(node)
        for _, child in ipairs(node.children) do
            postorder(child)
        end
        coroutine.yield(node)
    end
    return coroutine.wrap(function()
        local node = self
        postorder(node)
    end)
end

return Tree

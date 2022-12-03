local M = {}

function M.ltrim(line)
    return line:gsub('^%s+', '')
end

function M.rtrim(line)
    return line:gsub('%s+$', '')
end

-- apply fn(k, v) for all (k, v) pairs, returning list-table
function M.tbl_tolist(fn, t)
    local list = {}
    for k, v in pairs(t) do
        list[#list + 1] = fn(k, v)
    end
    return list
end

-- Convert list-like table to a set. Uses true or value_fn(val) as set values.
function M.list_toset(t, value_fn)
    local set = {}
    for _, val in ipairs(t) do
        set[val] = value_fn and value_fn(val) or true
    end
    return set
end


--- Remove duplicate elements from a list
---@generic T
---@param list T[]
---@return T[]
function M.unique(list)
    local set = {}
    return vim.tbl_filter(function(val)
        if not set[val] then
            set[val] = true
            return true
        else
            return false
        end
    end, list)
end

function M.identity(v)
    return v
end

--- Perform reduce operation on a list
---@generic T
---@generic A
---@param tbl T[] Input list
---@param reduce fun(acc: A, val: T): A
---@param initial T? If not supplied than first element is used
---@return A The result of list reduction
function M.reduce(tbl, reduce, initial)
    local start = 1
    local result = initial
    if not initial then
        result = tbl[1]
        start = 2
    end
    for i = start, #tbl do
        result = reduce(result, tbl[i])
    end
    return result
end

--- Return sum by key
---@generic T
---@param tbl T[]
---@param key? fun(T): number
---@return number
function M.sum(tbl, key)
    key = key or M.identity
    local sum = 0
    for _, item in ipairs(tbl) do
        sum = sum + key(item)
    end
    return sum
end

--- Get max element (and index)
---@generic T
---@param list T[]
---@param key? fun(T): any
---@return T Max element
---@return integer Index of max element
function M.max(list, key)
    key = key or M.identity
    local maxi = 1
    local maxv = key(list[maxi])
    for i, item in ipairs(list) do
        if key(item) > maxv then
            maxv = key(item)
            maxi = i
        end
    end
    return maxv, maxi
end

return M

local M = {}

---Assert a condition or raise an error with formatted message
---@param val any Value treated as assertion condition
---@param err string Error message with optional format string placeholders
---@param ... any Arguments to the format string
---@return any Value if it was true-ish
function M.assert(val, err, ...)
    if not val then
        -- Use level 2 to show the error at caller location
        error(string.format(err, ...), 2)
    end
    return val
end

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

-- Create a list with reversed order of elements
function M.list_reverse(l)
    local new = {}
    for i = #l, 1, -1 do
        table.insert(new, l[i])
    end
    return new
end

---@param str string
---@param initial? { [string]: integer }
---@return { [string]: integer }
function M.count_chars(str, initial)
    initial = initial or {}
    local counts = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        counts[char] = (counts[char] or initial[char] or 0) + 1
    end
    return counts
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

---@generic T
---@alias IteratorFn fun(): (T, integer) | nil
---@generic T
---@alias Iterable ((T[]) | IteratorFn)


--- Convert list to an iterator
---@generic T
---@param it Iterable<T>
---@param start? integer
---@return IteratorFn<T>
function M.to_iter(it, start)
    if type(it) == 'function' then
        return it
    end
    local i = start and (start - 1) or 0
    return function()
        i = i + 1
        return it[i], i
    end
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
---@param it Iterable<T>
---@param key? fun(T): number
---@return number
function M.sum(it, key)
    key = key or M.identity
    local sum = 0
    for item, i in M.to_iter(it) do
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

--- Returns an iterator over list items grouped in chunks
---@generic T
---@param list T[]
---@param len integer
---@return IteratorFn<T[]>
function M.chunks(list, len)
    local head = 1
    local tail = len
    return function()
        if head > #list then return end
        local chunk = vim.list_slice(list, head, tail)
        head = head + len
        tail = tail + len
        return chunk
    end
end

--- Return new list, containing only items that match condition
---@generic T
---@param list Iterable<T>
---@param cond fun(item: T): boolean
---@return T[]
function M.filter(list, cond)
    local new = {}
    for item in M.to_iter(list) do
        if cond(item) then
            table.insert(new, item)
        end
    end
    return new
end

--- Find position of an element in iterable
---@generic T
---@param it Iterable<T>
---@param val_or_cond T | (fun(item: T): boolean)
---@return integer | nil
function M.find(it, val_or_cond)
    if type(val_or_cond) ~= 'function' then
        local val = val_or_cond
        val_or_cond = function(item) return item == val end
    end
    for item, i in M.to_iter(it) do
        if val_or_cond(item) then
            return i
        end
    end
end

--- Create a function that indexes into given table
---@generic T
---@generic V
---@param tbl table<T, V>
---@return fun(T): V
function M.getitem(tbl)
    return function(key)
        return tbl[key]
    end
end

--- Apply a function to all values of a table.
---
--- Like vim.tbl_map, but iterates over list-table (or an iterator)
--- and preserves type information on returned type.
---
---@generic T
---@generic V
---@param it Iterable<T>
---@param fn fun(val: T, i: integer): V
---@return V[]
function M.map(it, fn)
    vim.validate { fn = { fn, 'f' }, it = { it, {'t', 'f'} } }
    local ret = {}
    for val, i in M.to_iter(it) do
        table.insert(ret, fn(val, i))
    end
    return ret
end

return M

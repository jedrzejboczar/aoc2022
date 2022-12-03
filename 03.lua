local aoc = require('aoc2022')

---@param line string
---@return string
---@return string
local function parse_rucksack(line)
    assert(#line > 0, 'Empty rucksack')
    assert(#line % 2 == 0, 'Uneven number of items')
    local first_compartment = line:sub(1, #line / 2)
    local second_compartment = line:sub(#line / 2 + 1)
    return first_compartment, second_compartment
end

---@param item string
---@return integer
local function item_priority(item)
    assert(#item == 1)
    local a, z, A, Z = string.byte('azAZ', 1, 4)
    local b = item:byte()
    assert((b >= a and b <= z) or (b >= A and b <= Z), item)
    if b >= a and b <= z then
        return b - a + 1
    else
        return b - A + 27
    end
end

---@param str string
---@param initial? { [string]: integer }
---@return { [string]: integer }
local function count_chars(str, initial)
    initial = initial or {}
    local counts = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        counts[char] = (counts[char] or initial[char] or 0) + 1
    end
    return counts
end

--- Keys of set1 such that set2[key] exists
---@generic T
---@param set1 { [T]: any }
---@param set2 { [T]: any }
---@return T[]
local function find_duplicates(set1, set2)
    return aoc.utils.filter(vim.tbl_keys(set1), aoc.utils.getitem(set2))
end

local function part1(lines)
    return aoc.utils.sum(lines, function(line)
        local first, second = parse_rucksack(line)
        local duplicates = find_duplicates(count_chars(first), count_chars(second))
        local total_prioriy = aoc.utils.sum(duplicates, item_priority)
        return total_prioriy
    end)
end

local function part2(lines)
    return aoc.utils.sum(aoc.utils.chunks(lines, 3), function(chunk)
        local counts = vim.tbl_map(count_chars, chunk)
        -- Duplicates between 1 and 2
        local duplicates = aoc.utils.list_toset(find_duplicates(counts[1], counts[2]))
        -- Duplicates between 1-2 and 3
        duplicates = find_duplicates(duplicates, counts[3])
        return aoc.utils.sum(duplicates, item_priority)
    end)
end

aoc.inputs.with_input_file(3, function(lines)
    print('Part 1:', part1(lines))
    print('Part 2:', part2(lines))
end)

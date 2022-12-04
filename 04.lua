local aoc = require('aoc2022')

---@class Section
---@field start integer
---@field end_ integer

---@param line string
---@return { [1]: Section, [2]: Section }
local function parse_section_pair(line)
    local s1, e1, s2, e2 = line:match('^%s*(%d+)-(%d+),(%d+)-(%d+)%s*$')
    assert(s1, line)
    return {
        { start = tonumber(s1), end_ = tonumber(e1) },
        { start = tonumber(s2), end_ = tonumber(e2) }
    }
end

---@param section Section
---@param other Section
---@return boolean
local function contains_other(section, other)
    return section.start <= other.start and section.end_ >= other.end_
end

local function part1(lines)
    local section_pairs = aoc.utils.map(lines, parse_section_pair)
    local fully_contained = aoc.utils.filter(section_pairs, function(pair)
        return contains_other(pair[1], pair[2]) or contains_other(pair[2], pair[1])
    end)
    return #fully_contained
end

---@param s1 Section
---@param s2 Section
---@return boolean
local function sections_overlap(s1, s2)
    return s1.end_ >= s2.start and s1.start <= s2.end_
end

local function part2(lines)
    local section_pairs = aoc.utils.map(lines, parse_section_pair)
    local overlapping = aoc.utils.filter(section_pairs, function(pair)
        return sections_overlap(pair[1], pair[2])
    end)
    return #overlapping
end

aoc.inputs.with_input_file(4, function(lines)
    print('Part 1:', part1(lines))
    print('Part 2:', part2(lines))
end)


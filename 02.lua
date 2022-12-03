local aoc = require('aoc2022')

---@alias Shape 'rock' | 'paper' | 'scissors'
---@alias Outcome 'won' | 'draw' | 'lost'

local scores = {
    ---@type table<Shape, integer>
    shape = {
        rock = 1,
        paper = 2,
        scissors = 3,
    },
    ---@type table<Outcome, integer>
    outcome = {
        lost = 0,
        draw = 3,
        won = 6,
    },
}

---@type table<Shape, Shape>
local defeats = {
    rock = 'scissors',
    scissors = 'paper',
    paper = 'rock',
}

---@param opponent Shape
---@param response Shape
---@return Outcome
local function round_outcome(opponent, response)
    if defeats[response] == opponent then
        return 'won'
    elseif defeats[opponent] == response then
        return 'lost'
    else
        return 'draw'
    end
end

---@param opponent Shape
---@param response Shape
---@return integer
local function round_score(opponent, response)
    local outcome = round_outcome(opponent, response)
    return scores.outcome[outcome] + scores.shape[response]
end

local parse = {
    ---@type table<string, Shape>
    opponent = { A = 'rock', B = 'paper', C = 'scissors' },
    -- Part 1
    ---@type table<string, Shape>
    response = { X = 'rock', Y = 'paper', Z = 'scissors' },
    -- Part 2
    ---@type table<string, Outcome>
    outcome = { X = 'lost', Y = 'draw', Z = 'won' },
}

---@param line string
---@return 'A' | 'B' |' C'
---@return 'X' | 'Y' |' Z'
local function parse_line(line)
    local tokens = vim.split(line, '%s+', { trimempty = true })
    assert(#tokens == 2, line)
    return unpack(tokens)
end

local function part1(lines)
    local total_score = 0
    for _, line in ipairs(lines) do
        local opponent, response = parse_line(line)
        local score = round_score(parse.opponent[opponent], parse.response[response])
        total_score = total_score + score
    end
    return total_score
end

-- Reverse lookup
local defeated_by = {}
for winning, loosing in pairs(defeats) do
    defeated_by[loosing] = winning
end

---@param opponent Shape
---@param required_outcome Outcome
local function shape_to_choose(opponent, required_outcome)
    if required_outcome == 'won' then
        return defeated_by[opponent]
    elseif required_outcome == 'lost' then
        return defeats[opponent]
    else
        return opponent
    end
end

local function part2(lines)
    local total_score = 0
    for _, line in ipairs(lines) do
        local opponent, outcome = parse_line(line)
        local response = shape_to_choose(parse.opponent[opponent], parse.outcome[outcome])
        local score = round_score(parse.opponent[opponent], response)
        total_score = total_score + score
    end
    return total_score
end

aoc.inputs.with_input_file(2, function(lines)
    print('Part 1:', part1(lines))
    print('Part 2:', part2(lines))
end)

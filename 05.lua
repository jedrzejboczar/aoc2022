local aoc = require('aoc2022')

local function parse_input(lines)
    local empty_line_i = aoc.utils.find(lines, '')

    local stack_numbers = vim.tbl_map(tonumber,
        vim.split(lines[empty_line_i - 1], '%s+', { trimempty = true }))

    local stacks = aoc.utils.map(stack_numbers, function(num, num_i)
        -- Assuming numbers start from 1 and increase
        assert(num == num_i, tostring(num) .. 'vs' .. tostring(num_i))

        local stack = aoc.Stack:new()

        -- Collect items from lines on the column corresponding to this stack
        local start_line = empty_line_i - 2
        local col = 4 * (num - 1) + 2
        local no_more = false

        for i = start_line, 1, -1 do
            local char = function(pos)
                return lines[i]:sub(pos, pos)
            end
            local item = char(col)
            -- Check for '' if line was shorter than `pos`
            if item == '' or item == ' ' then
                no_more = true
            else
                assert(not no_more)
                aoc.utils.assert(char(col - 1) == '[', 'Missing [ at col %d in line %d "%s"', col - 1, i, lines[i])
                aoc.utils.assert(char(col + 1) == ']', 'Missing ] at col %d in line %d "%s"', col + 1, i, lines[i])
                stack:push(item)
            end
        end

        return stack
    end)

    local instruction_lines = aoc.utils.to_iter(lines, empty_line_i + 1)
    local instructions = aoc.utils.map(instruction_lines, function(line)
        local n, from, to = line:match('move (%d+) from (%d+) to (%d+)')
        assert(n, line)
        return {
            n = tonumber(n),
            from = tonumber(from),
            to = tonumber(to),
        }
    end)

    return stacks, instructions
end

local function display_stacks(stacks)
    local max_len = aoc.utils.max(stacks, function(stack) return #stack end)

    local lines = {}
    for lnum = 0, max_len do
        local tokens = aoc.utils.map(stacks, function(stack, i)
            if lnum == 0 then -- stack numbers
                return string.format(' %d ', i)
            elseif #stack >= lnum then
                return string.format('[%s]', stack[lnum])
            else
                return '   '
            end
        end)
        table.insert(lines, table.concat(tokens, ' '))
    end

    return aoc.utils.list_reverse(lines)
end

local ANIMATE = true

---@alias Stack string[]

---@class InstructionContext
---@field stacks Stack[]
---@field instruction { n: integer, from: integer, to: integer }
---@field step_done fun(step: integer, elem: string)

--- [TODO:description]
---@param lines Iterable<string>
---@param execute_instruction fun(ctx: InstructionContext)
local function solve(lines, execute_instruction)
    local stacks, instructions = parse_input(lines)

    local num_elems = aoc.utils.sum(stacks, function(s) return #s end)
    local delays = {
        initial = 1000,
        per_instruction = math.floor(1000 / #instructions),
        per_step = math.floor(2000 / aoc.utils.sum(instructions, function(instr) return instr.n end)),
    }

    local anim = aoc.Animation:new {
        width = math.max(#stacks * 4, 80),
        height = num_elems + 1 + 2,
        off = not ANIMATE,
    }

    anim:show_with_msg(display_stacks(stacks), 'Initial position')
    anim:wait(delays.initial)

    for i, instr in ipairs(instructions) do
        anim:wait(delays.per_instruction)

        execute_instruction({
            stacks = stacks,
            instruction = instr,
            step_done = function(step, elem)
                local msg = string.format('%d:%d. Moving %s from stack %d to stack %d', i, step, elem, instr.from, instr.to)
                anim:show_with_msg(display_stacks(stacks), msg)
                anim:wait(delays.per_step)
            end
        })
    end

    local solution = table.concat(aoc.utils.map(stacks, aoc.Stack.peek), '')
    anim:show_with_msg(display_stacks(stacks), 'Solution: ' .. solution)

    return solution, anim
end

---@param state InstructionContext
local function execute_part1(state)
    for step = 1, state.instruction.n do
        local from = state.stacks[state.instruction.from]
        local to = state.stacks[state.instruction.to]
        local elem = from:pop()
        to:push(elem)

        state.step_done(step, elem)
    end
end

local function execute_part2(state)
    local intermediate = aoc.Stack:new()

    for step = 1, state.instruction.n do
        local from = state.stacks[state.instruction.from]
        intermediate:push(from:pop())
    end

    local all = table.concat(intermediate)

    for step = 1, state.instruction.n do
        local to = state.stacks[state.instruction.to]
        to:push(intermediate:pop())
    end

    state.step_done(0, all)
end

aoc.inputs.with_input_file(5, function(lines)
    coroutine.wrap(function()
        local p1, anim = solve(lines, execute_part1)
        print('Part 1:', p1)

        anim:wait_closed()

        local p2 = solve(lines, execute_part2)
        print('Part 2:', p2)
    end)()
end)

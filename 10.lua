local aoc = require('aoc2022')

---@class Instruction
---@field name 'noop' | 'addx'
---@field arg number?

---@class Cpu
---@field cycle number
---@field x number

---@param lines string[]
---@return Instruction[]
local function parse_lines(lines)
    return aoc.utils.map(lines, function(line)
        local tokens = vim.split(line, '%s+', { trimempty = true })
        assert(#tokens == 1 or #tokens == 2, line)
        local instr, arg = tokens[1], tokens[2]
        assert(instr == 'noop' or instr == 'addx')
        return { name = instr, arg = arg and tonumber(arg) }
    end)
end

---@param cpu Cpu
---@param i Instruction
local function exec_instruction(cpu, i)
    if i.name == 'noop' then
        cpu.cycle = cpu.cycle + 1
    else
        assert(i.name == 'addx', i.name)
        cpu.cycle = cpu.cycle + 2
        cpu.x = cpu.x + i.arg
    end
end

---@param instructions Instruction[]
---@param before_exec? fun(cpu: Cpu)
---@param after_exec? fun(cpu: Cpu)
local function cpu_execute(instructions, before_exec, after_exec)
    before_exec = before_exec or aoc.utils.identity
    after_exec = after_exec or aoc.utils.identity

    local next_instr = aoc.utils.to_iter(instructions)

    local cpu = {
        x = 1,
        cycle = 1,
        instr = nil,
        instr_wait = nil,
    }
    local set_next_instr = function()
        local i = next_instr()
        cpu.instr = i
        cpu.instr_wait = i and (i.name == 'addx' and 1 or 0)
    end
    set_next_instr()

    while cpu.instr do
        before_exec { cycle = cpu.cycle, x = cpu.x }

        if cpu.instr_wait > 0 then
            cpu.instr_wait = cpu.instr_wait - 1
        else -- execute the instruction
            if cpu.instr.name == 'addx' then
                cpu.x = cpu.x + cpu.instr.arg
            else
                -- noop
            end
            set_next_instr()
        end

        after_exec { cycle = cpu.cycle, x = cpu.x }

        cpu.cycle = cpu.cycle + 1
    end
end

local function part1(lines)
    local instructions = parse_lines(lines)
    local signal_strengths = {}
    cpu_execute(instructions, function(cpu)
        if (cpu.cycle - 20) % 40 == 0 then
            table.insert(signal_strengths, cpu.cycle * cpu.x)
        end
    end)
    return aoc.utils.sum(signal_strengths)
end

local function part2(lines)
    local instructions = parse_lines(lines)

    local screen = {}
    for _ = 1, 6 do
        local screen_line = {}
        for _ = 1, 40 do
            table.insert(screen_line, ' ')
        end
        table.insert(screen, screen_line)
    end
    local screen_lines = function()
        return aoc.utils.map(screen, function(chars)
            return table.concat(chars, '')
        end)
    end

    local anim = aoc.Animation:new {
        width = 40,
        height = 6,
        off = false,
    }

    anim:show(screen_lines())
    anim:wait(200)

    cpu_execute(instructions, function(cpu)
        -- adjust to 1-indexing
        local pixel = ((cpu.cycle - 1) % 40) + 1
        local line = math.floor((cpu.cycle - 1) / 40) + 1
        -- X is 0-indexed so compare pixel-1
        local lit = cpu.x - 1 <= (pixel - 1) and (pixel - 1) <= cpu.x + 1
        screen[line][pixel] = lit and '#' or '.'

        anim:show(screen_lines())
        anim:wait(10)
    end)

    return '\n' .. table.concat(screen_lines(), '\n')
end

aoc.inputs.with_input_file(10, function(lines)
    coroutine.wrap(function()
        print('Part 1:', part1(lines))
        print('Part 2:', part2(lines))
    end)()
end)

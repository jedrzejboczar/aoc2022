local aoc = require('aoc2022')

local function parse_lines(lines)
    return vim.tbl_map(function(cluster)
        local food = vim.tbl_map(tonumber, cluster)
        return {
            calories = food,
            total_calories = aoc.utils.sum(food)
        }
    end, aoc.inputs.line_clusters(lines))
end

local function part1(lines)
    local elves = parse_lines(lines)
    local max_calories, elf_i = aoc.utils.max(elves, function(elf)
        return elf.total_calories
    end)
    -- print(string.format('Elf %d carries most calories: %d', elf_i, max_calories))
    return max_calories
end


local function part2(lines)
    local elves = parse_lines(lines)

    table.sort(elves, function(a, b)
        return a.total_calories > b.total_calories
    end)

    local total = aoc.utils.sum(vim.list_slice(elves, 1, 3), function(elf)
        return elf.total_calories
    end)

    -- print('Top 3 elves:')
    -- for i = 1, 3 do
    --     print(string.format('%d. Elf with %d calories', i, elves[i].total_calories))
    -- end
    -- print('Sum:', total)

    return total
end

aoc.inputs.with_input_file(1, function(lines)
    print('Part 1:', part1(lines))
    print('Part 2:', part2(lines))
end)

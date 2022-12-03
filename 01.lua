local aoc = require('aoc2022')

aoc.inputs.with_input_file(1, function(lines)
    local elves = vim.tbl_map(function(cluster)
        local food = vim.tbl_map(tonumber, cluster)
        return {
            calories = food,
            total_calories = aoc.utils.sum(food)
        }
    end, aoc.inputs.line_clusters(lines))

    local max_calories, elf_i = aoc.utils.max(elves, function(elf)
        return elf.total_calories
    end)

    print(string.format('Elf %d carries most calories: %d', elf_i, max_calories))

    -- Part 2

    table.sort(elves, function(a, b)
        return a.total_calories > b.total_calories
    end)

    print('Top 3 elves:')
    for i = 1, 3 do
        print(string.format('%d. Elf with %d calories', i, elves[i].total_calories))
    end
    print('Sum:', aoc.utils.sum(vim.list_slice(elves, 1, 3), function(elf)
        return elf.total_calories
    end))
end)

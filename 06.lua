local aoc = require('aoc2022')

local function detect_marker(line, marker_len)
    for i = 1, (#line - marker_len + 1) do
        local window = line:sub(i, i + marker_len - 1)
        local chars = aoc.utils.count_chars(window)
        if vim.tbl_count(chars) == marker_len then
            return i + marker_len - 1
        end
    end
end

local function part1(line)
    return detect_marker(line, 4)
end

local function part2(line)
    return detect_marker(line, 14)
end

aoc.inputs.with_input_file(6, function(lines)
    for _, line in ipairs(lines) do
        print('Part 1:', part1(line))
        print('Part 2:', part2(line))
    end
end)

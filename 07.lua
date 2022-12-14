local aoc = require('aoc2022')

local function cd(cwd, args)
    assert(#args == 1, args[1])
    if args[1] == '/' then
        return '/'
    elseif args[1] == '..' then
        return vim.fn.fnamemodify(args[1], ':p')
    else
        return (cwd == '/') and (cwd .. args[1]) or (cwd .. '/' .. args[1])
    end
end

local function is_cmd_line(line)
    return vim.startswith(line, '$ ')
end

local function parse_terminal_output(lines)
    local commands = {}

    local i = 1
    while i <= #lines do
        local line = lines[i]
        assert(is_cmd_line(line), line)

        local output = {}
        while i + 1 <= #lines and not is_cmd_line(lines[i + 1]) do
            table.insert(output, lines[i + 1])
            i = i + 1
        end

        local tokens = vim.split(line:sub(2), '%s+', { plain = false, trimempty = true })
        table.insert(commands, {
            cmd = tokens[1],
            args = vim.list_slice(tokens, 2),
            output = output,
        })

        i = i + 1
    end

    return commands
end

local function tree_path(node)
    local parts = {}
    while node.parent do
        table.insert(parts, node.value.name)
        node = node.parent
    end
    return '/' .. table.concat(aoc.utils.list_reverse(parts), '/')
end

local function find_child(node, name)
    return aoc.utils.find(node.children, function(child)
        return child.value.name == name
    end)
end

local function print_tree(root)
    local indent = function(node)
        local i = 0
        while node.parent do
            i = i + 2
            node = node.parent
        end
        return string.rep(' ', i)
    end

    for node in root:iter_preorder() do
        if node.value.type == 'dir' then
            print(indent(node) .. string.format('%s/ (dir, size=%d)', node.value.name, node.value.size or 0))
        else
            print(indent(node) .. string.format('%s (file, size=%d)', node.value.name, node.value.size))
        end
    end
end

local function sort_tree(root)
    for node in root:iter_preorder() do
        table.sort(node.children, function(a, b)
            return a.value.name > b.value.name
        end)
    end
end

local function accumulate_sizes(root)
    for node in root:iter_postorder() do
        if node.parent then
            node.parent.value.size = (node.parent.value.size or 0) + (node.value.size or 0)
        end
    end
end

local function parse(lines)
    local root = aoc.Tree:new { type = 'dir', name = '' }
    local cwd = root

    local commands = parse_terminal_output(lines)

    for _, c in ipairs(commands) do
        if c.cmd == 'cd' then
            if c.args[1] == '/' then
                cwd = root
            elseif c.args[1] == '..' then
                cwd = cwd.parent or root
            else -- moving down the tree
                local dir = find_child(cwd, c.args[1])
                if dir then
                    cwd = cwd.children[dir]
                else -- new directory
                    cwd:add { type = 'dir', name = c.args[1] }
                    cwd = cwd.children[#cwd.children]
                end
            end
        elseif c.cmd == 'ls' then
            for _, line in ipairs(c.output) do
                local tokens = vim.split(line, '%s+', { trimempty = true })
                assert(#tokens == 2, line)

                -- do not add more than once
                if not find_child(cwd, tokens[2]) then
                    if tokens[1] == 'dir' then
                        cwd:add { type = 'dir', name = tokens[2] }
                    else -- file
                        cwd:add { type = 'file', name = tokens[2], size = tonumber(tokens[1]) }
                    end
                end

            end
        end
    end

    sort_tree(root)

    return root
end

local function part1(lines)
    local tree = parse(lines)
    accumulate_sizes(tree)
    -- print_tree(tree)
    return aoc.utils.sum(tree:iter_preorder(), function(node)
        return (node.value.type == 'dir' and node.value.size <= 100000) and node.value.size or 0
    end)
end

local function part2(lines)
    local tree = parse(lines)
    accumulate_sizes(tree)

    local total_space = 70000000
    local needed_space = 30000000
    local unused_space = total_space - tree.value.size
    local needed_to_delete = needed_space - unused_space

    local candidates = aoc.utils.filter(tree:iter_preorder(), function(node)
        return node.value.type == 'dir' and node.value.size >= needed_to_delete
    end)

    aoc.utils.sort_by(candidates, function(node)
        return node.value.size
    end)

    return candidates[1].value.size
end

aoc.inputs.with_input_file(7, function(lines)
    print('Part 1:', part1(lines))
    print('Part 2:', part2(lines))
end)


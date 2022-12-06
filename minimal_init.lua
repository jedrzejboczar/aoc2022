vim.opt.runtimepath:append('.')

-- Reload packages
local function reload_modules(pattern)
    for pack, _ in pairs(package.loaded) do
        if pack:match(pattern) then
            package.loaded[pack] = nil
        end
    end
end

--- Run code from current buffer
local function run()
    reload_modules('^aoc2022.*')
    vim.cmd('luafile %')
end

vim.keymap.set('n', '<leader>`', run, { desc = 'Run aoc2022 task' })
vim.api.nvim_create_user_command('AocRun', run, { desc = 'Run aoc2022 task' })

--
-- Test-harness mode
--

local function wrapped_call(before, after, fn)
    before()
    local ok, val = pcall(fn)
    after()
    if not ok then
        error(val, 2)
    end
    return ok and val
end

local function is_headless()
    return #vim.api.nvim_list_uis() == 0
end

local function fake_ui_select(selected)
    return function(items, _opts, on_choice)
        assert(vim.tbl_contains(items, selected))
        on_choice(selected)
    end
end

local print_stdout = vim.schedule_wrap(function(...)
    local str = table.concat(vim.tbl_map(tostring, {...}), ' ')
    io.stdout:write(str)
    io.stdout:write('\r\n')
end)

local function run_all()
    -- Monkey-patch io
    local old_select, old_print
    local before = function()
        old_select = vim.ui.select
        vim.ui.select = fake_ui_select('task')

        old_print = print
        if is_headless() then
            print = print_stdout
        end
    end
    local after = function()
        vim.ui.select = old_select
        print = old_print
    end

    wrapped_call(before, after, function()
        for path, typ in vim.fs.dir('.') do
            if typ == 'file' and path:match('^%d+.lua$') then
                print('### ' .. path .. ' ###')
                reload_modules('^aoc2022.*')
                vim.cmd('luafile ' .. path)
            end
        end
    end)
end

vim.api.nvim_create_user_command('AocRunAll', run_all, { desc = 'Run all aoc2022 tasks' })

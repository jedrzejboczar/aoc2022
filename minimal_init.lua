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

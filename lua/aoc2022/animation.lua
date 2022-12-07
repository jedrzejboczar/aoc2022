local async = require('aoc2022.async')

local Animation = {}
Animation.__index = Animation

local function is_headless()
    return #vim.api.nvim_list_uis() == 0
end

function Animation:new(opts)
    local co = assert(coroutine.running(), 'Must be used in coroutine')

    opts = vim.tbl_extend('force', {
        width = 80,
        height = 40,
        enter = true,
        off = false,
        top_gravity = false,
        delete_on_leave = true,
    }, opts or {})

    -- Always disable in headless mode
    opts.off = opts.off or is_headless()

    local obj = setmetatable({
        coroutine = co,
        off = opts.off,
        height = opts.height,
        width = opts.width,
        top_gravity = opts.top_gravity,
    }, self)

    if obj.off then
        return obj
    end

    local prev_win = vim.api.nvim_get_current_win()
    local prev_cursor = vim.api.nvim_win_get_cursor(prev_win)

    -- create display buffer
    local buf = vim.api.nvim_create_buf(false, true)  -- unlisted, scratch
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.keymap.set('n', 'q', '<cmd>quit!<cr>', { buffer = buf })
    vim.keymap.set('n', '<esc>', '<cmd>quit!<cr>', { buffer = buf })
    vim.keymap.set('n', '<cr>', function()
        if coroutine.running() ~= co then
            coroutine.resume(co)
        end
    end, { buffer = buf })

    -- Open floating window
    local fopts = vim.lsp.util.make_floating_popup_options(
        opts.width, opts.height, { border = 'rounded' })
    local win = vim.api.nvim_open_win(buf, opts.enter, fopts)

    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = buf,
        once = true,
        callback = function()
            -- Restore cursor position
            vim.api.nvim_win_set_cursor(prev_win, prev_cursor)
            vim.api.nvim_set_current_win(prev_win)

            if opts.delete_on_leave  and vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    })

    obj.buf = buf
    obj.win = win

    return obj
end

function Animation:show(lines)
    if self:is_off() then return end

    -- Add top padding
    if not self.top_gravity then
        local new_lines = {}
        for i = 1, self.height - #lines do
            table.insert(new_lines, '')
        end
        vim.list_extend(new_lines, lines)
        lines = new_lines
    end

    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(self.win, { #lines, 0 })
end

function Animation:show_with_msg(lines, msg)
    if self:is_off() then return end
    table.insert(lines, msg or '')
    return self:show(lines)
end

function Animation:valid(quiet)
    local valid = vim.api.nvim_buf_is_valid(self.buf) and vim.api.nvim_win_is_valid(self.win)
    if not quiet and not valid and not self._notified then
        self._notified = true
        vim.notify('Animation buf/win not valid', vim.log.levels.WARN)
    end
    return valid
end

function Animation:is_off()
    return self.off or not self:valid()
end

function Animation:wait(ms)
    if self:is_off() then return end
    self:_check_coroutine()
    async.wait(ms)
end

function Animation:wait_cr()
    if self:is_off() then return end
    self:_check_coroutine()
    coroutine.yield()
end

function Animation:_check_coroutine()
    assert(coroutine.running() == self.coroutine, 'Must be called from animation coroutine')
end

function Animation:wait_closed()
    if self:is_off() then return end
    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = self.buf,
        once = true,
        callback = async.resume_self(),
    })
    vim.notify('Waiting until Animation is closed')
    coroutine.yield()
end

return Animation

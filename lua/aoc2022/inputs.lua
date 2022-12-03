local M = {}

--- Get the path to currently invoked script
function M.script_path()
    local info = debug.getinfo(2, "S")
    return vim.fn.fnamemodify(info.source:sub(2), ':p:h')
end

M.path_separator = (vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1) and '\\' or '/'

function M.path_join(...)
    return table.concat({...}, M.path_separator)
end

--- Read a file from disk
function M.sync_read_file(fname)
    local fd = assert(vim.loop.fs_open(fname, "r", 438))
    local stat = assert(vim.loop.fs_fstat(fd))
    local data = assert(vim.loop.fs_read(fd, stat.size, 0))
    assert(vim.loop.fs_close(fd))
    return data
end

--- Get path to intputs directory for given task number
function M.inputs_dir(num)
    return M.path_join(M.script_path(), '..', '..', 'data', string.format('%02d', num))
end

--- Read input lines from task input file
---@param num integer Task number
---@param cb fun(lines: string[]) Callback
function M.with_input_file(num, cb)
    local files = {}
    local dir = M.inputs_dir(num)
    for fname, typ in vim.fs.dir(dir) do
        if typ == 'file' then
            table.insert(files, fname)
        end
    end
    local on_select = function(fname)
        if fname then
            local path = M.path_join(dir, fname)
            local content = M.sync_read_file(path)
            local lines = vim.split(content, '\n', { plain = true, trimempty = true })
            cb(lines)
        end
    end
    vim.ui.select(files, {
        prompt = string.format('Select input file for task %d:', num),
    }, on_select)
end

--- Group lines into clusters by empty lines
---@param lines string[]
---@return string[][]
function M.line_clusters(lines)
    local clusters = {}
    local cluster = {}
    for _, line in ipairs(lines) do
        if vim.trim(line) == '' then
            table.insert(clusters, cluster)
            cluster = {}
        else
            table.insert(cluster, line)
        end
    end
    if #cluster > 0 then
        table.insert(clusters, cluster)
    end
    return clusters
end

return M

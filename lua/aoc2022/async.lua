local M = {}

--- Create a callback that will resume currently running coroutine
---@return function
function M.resume_self(...)
    local co = assert(coroutine.running(), 'Must be called from coroutine')
    local args = {...}
    return function()
        return coroutine.resume(co, unpack(args))
    end
end

-- Start a timer that will resume current coroutine after given time, requires yield!
function M.resume_after(delay_ms)
    vim.defer_fn(M.resume_self(), delay_ms)
end

-- Start a timer and yield until it resumes this coroutine
function M.wait(delay_ms)
    M.resume_after(delay_ms)
    coroutine.yield()
end

-- Call vim api function that cannot be used from fast event
function M.api(fn, ...)
    local args = {...}
    vim.schedule(function()
        fn(unpack(args))
    end)
end

return M

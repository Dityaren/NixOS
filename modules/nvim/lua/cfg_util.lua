-- Tiny helpers for keeping startup fast.
--   defer(name, fn): run fn shortly AFTER the first screen is drawn, one item per event-loop
--                    tick (so the UI never blocks), each wrapped so one failure can't break the rest.
--   once(fn):        wrap fn so it only ever runs a single time (for on-demand plugin setup).

local M = {}

local queue = {}
local done_cbs = {}

function M.defer(name, fn)
	queue[#queue + 1] = { name = name, fn = fn }
end

function M.after_queue(fn)
	done_cbs[#done_cbs + 1] = fn
end

function M.once(fn)
	local done = false
	return function()
		if done then
			return
		end
		done = true
		fn()
	end
end

local function run_from(i)
	local item = queue[i]
	if not item then
		for _, cb in ipairs(done_cbs) do
			pcall(cb)
		end
		return
	end
	local ok, err = xpcall(item.fn, debug.traceback)
	if not ok then
		vim.notify(("config: setup of '%s' failed:\n%s"):format(item.name, err), vim.log.levels.ERROR)
	end
	vim.defer_fn(function()
		run_from(i + 1)
	end, 1)
end

function M.start()
	local function go()
		vim.defer_fn(function()
			run_from(1)
		end, 1)
	end
	if vim.v.vim_did_enter == 1 then
		go()
	else
		vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = go })
	end
end

return M

-- :StripComments — delete every comment in the buffer (or a range) using treesitter.
-- Works in any language that has a treesitter parser, including embedded ones
-- (CSS/JS inside HTML, code blocks, ...), because it asks the parser what a comment is
-- instead of guessing with a regex.

local M = {}

-- Pure core, kept free of any vim API so it can be tested on its own.
-- `lines`  : list of strings (modified in place)
-- `ranges` : list of { start_row, start_col, end_row, end_col }, 0-based, end-exclusive,
--            byte columns (exactly what node:range() returns)
-- Returns the number of comments removed.
function M.strip_ranges(lines, ranges)
	-- Some grammars (e.g. line comments that swallow their newline) end at column 0 of the
	-- next row. Pull those back to the end of the previous row.
	for _, r in ipairs(ranges) do
		if r[4] == 0 and r[3] > r[1] then
			r[3] = r[3] - 1
			r[4] = #(lines[r[3] + 1] or "")
		end
	end

	-- Keep only outermost, non-overlapping ranges (injected parsers can report duplicates
	-- or comments nested inside comments).
	table.sort(ranges, function(a, b)
		if a[1] ~= b[1] then
			return a[1] < b[1]
		end
		if a[2] ~= b[2] then
			return a[2] < b[2]
		end
		if a[3] ~= b[3] then
			return a[3] > b[3]
		end
		return a[4] > b[4]
	end)
	local kept = {}
	for _, r in ipairs(ranges) do
		local p = kept[#kept]
		if not p or r[1] > p[3] or (r[1] == p[3] and r[2] >= p[4]) then
			kept[#kept + 1] = r
		end
	end

	-- Apply from the bottom up so earlier positions stay valid.
	for i = #kept, 1, -1 do
		local srow, scol, erow, ecol = kept[i][1], kept[i][2], kept[i][3], kept[i][4]
		local prefix = (lines[srow + 1] or ""):sub(1, scol)
		local suffix = (lines[erow + 1] or ""):sub(ecol + 1)
		if prefix:match("^%s*$") and suffix:match("^%s*$") then
			-- the comment was alone on its line(s): drop the whole line(s)
			for _ = srow + 1, erow + 1 do
				table.remove(lines, srow + 1)
			end
		else
			if suffix:match("^%s*$") then
				-- trailing comment: also drop the whitespace in front of it
				prefix = prefix:gsub("%s+$", "")
				suffix = ""
			end
			lines[srow + 1] = prefix .. suffix
			for _ = srow + 2, erow + 1 do
				table.remove(lines, srow + 2)
			end
		end
	end
	return #kept
end

-- Remove comments from `buf`. `line1`/`line2` (1-based, inclusive) restrict it to a range;
-- comments that start inside the range are removed.
function M.run(buf, line1, line2)
	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok or not parser then
		vim.notify("StripComments: no treesitter parser for this buffer", vim.log.levels.WARN)
		return 0
	end
	parser:parse(true) -- true = parse injected languages too

	local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
	local ranges = {}
	local function walk(node)
		if node:type():find("comment", 1, true) then
			local sr, sc, er, ec = node:range()
			local is_shebang = sr == 0 and first_line:sub(sc + 1, sc + 2) == "#!"
			local in_range = (not line1) or (sr + 1 >= line1 and sr + 1 <= line2)
			if in_range and not is_shebang then
				ranges[#ranges + 1] = { sr, sc, er, ec }
			end
			return -- do not look inside a comment (doc-comment children etc.)
		end
		for child in node:iter_children() do
			walk(child)
		end
	end
	parser:for_each_tree(function(tree)
		walk(tree:root())
	end)

	if #ranges == 0 then
		vim.notify("StripComments: no comments found")
		return 0
	end

	-- only touch the span that actually contains comments
	local min_row, max_row = math.huge, -1
	for _, r in ipairs(ranges) do
		min_row = math.min(min_row, r[1])
		max_row = math.max(max_row, r[3])
	end
	local lines = vim.api.nvim_buf_get_lines(buf, min_row, max_row + 1, false)
	for _, r in ipairs(ranges) do
		r[1], r[3] = r[1] - min_row, r[3] - min_row
	end

	local count = M.strip_ranges(lines, ranges)
	vim.api.nvim_buf_set_lines(buf, min_row, max_row + 1, false, lines)
	vim.notify(("StripComments: removed %d comment%s"):format(count, count == 1 and "" or "s"))
	return count
end

function M.setup()
	vim.api.nvim_create_user_command("StripComments", function(opts)
		if opts.range > 0 then
			M.run(0, opts.line1, opts.line2)
		else
			M.run(0)
		end
	end, { range = true, desc = "Delete all comments in the buffer (or the given range) via treesitter" })
end

return M

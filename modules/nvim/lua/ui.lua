-- Transparent, colourless UI. Only code highlighting (Vim syntax groups, treesitter `@*` captures,
-- LSP semantic tokens) keeps its colour from the colourscheme. Every other highlight group in the
-- editor, including ones defined later by plugins, is flattened to "normal foreground, no
-- background" and distinguished only by bold / italic / underline / reverse.

local M = {}

local code_groups = {}
for _, g in ipairs({
	"Comment", "Constant", "String", "Character", "Number", "Boolean", "Float", "Identifier",
	"Function", "Statement", "Conditional", "Repeat", "Label", "Operator", "Keyword", "Exception",
	"PreProc", "Include", "Define", "Macro", "PreCondit", "Type", "StorageClass", "Structure",
	"Typedef", "Special", "SpecialChar", "Tag", "Delimiter", "SpecialComment", "Debug",
	"Underlined", "Error", "Todo",
}) do
	code_groups[g] = true
end

-- The cursor itself is drawn by the terminal; leave it alone.
local skip = { Cursor = true, lCursor = true, CursorIM = true, TermCursor = true, TermCursorNC = true }

local style_keys = {
	"bold", "italic", "underline", "undercurl", "underdouble", "underdotted", "underdashed",
	"strikethrough", "reverse", "standout", "nocombine",
}

local function is_code(name)
	return code_groups[name] or name:sub(1, 1) == "@" or name:find("^Treesitter") ~= nil
end

function M.apply()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local fg = normal.fg

	for name in pairs(vim.api.nvim_get_hl(0, {})) do
		if not skip[name] then
			local d = vim.api.nvim_get_hl(0, { name = name, link = false })
			local new = {}
			if is_code(name) then
				new.fg, new.sp = d.fg, d.sp -- keep code colours, drop any background
			else
				new.fg = fg
			end
			for _, k in ipairs(style_keys) do
				new[k] = d[k]
			end
			vim.api.nvim_set_hl(0, name, new)
		end
	end

	local function set(group, attrs)
		attrs = attrs or {}
		attrs.fg = attrs.fg or fg
		vim.api.nvim_set_hl(0, group, attrs)
	end

	vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = "NONE" })

	-- Things that used to be told apart by colour now use attributes.
	for _, g in ipairs({ "Visual", "VisualNOS", "Search", "Substitute", "PmenuSel", "WildMenu",
		"QuickFixLine", "BlinkCmpMenuSelection", "FzfLuaCursorLine", "DiffText" }) do
		set(g, { reverse = true })
	end
	for _, g in ipairs({ "IncSearch", "CurSearch" }) do
		set(g, { reverse = true, bold = true })
	end
	set("MatchParen", { bold = true, underline = true })
	set("CursorLineNr", { bold = true })
	set("TabLineSel", { bold = true })
	set("Folded", { italic = true })
	for _, g in ipairs({ "PmenuMatch", "PmenuMatchSel", "BlinkCmpLabelMatch", "FzfLuaSearch" }) do
		set(g, { bold = true, underline = true })
	end

	set("DiffAdd", { bold = true })
	set("DiffChange", { italic = true })
	set("DiffDelete", { strikethrough = true })
	set("Added", { bold = true })
	set("Changed", { italic = true })
	set("Removed", { strikethrough = true })

	local sev = {
		Error = { bold = true },
		Warn = { bold = true, italic = true },
		Info = {},
		Hint = { italic = true },
	}
	for s, attrs in pairs(sev) do
		for _, prefix in ipairs({ "Diagnostic", "DiagnosticSign", "DiagnosticVirtualText", "DiagnosticFloating",
			"TinyInlineDiagnosticVirtualText", "TinyInlineDiagnosticVirtualTextArrow" }) do
			set(prefix .. s, vim.deepcopy(attrs))
		end
	end
	set("DiagnosticUnderlineError", { undercurl = true })
	set("DiagnosticUnderlineWarn", { underdashed = true })
	set("DiagnosticUnderlineInfo", { underdotted = true })
	set("DiagnosticUnderlineHint", { underdotted = true })
	set("DiagnosticUnnecessary", {})
	set("DiagnosticDeprecated", { strikethrough = true })

	for _, g in ipairs({ "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite",
		"LspReferenceText", "LspReferenceRead", "LspReferenceWrite" }) do
		set(g, { underline = true })
	end

	-- Indent guides: dim grey (the comment colour) so they don't compete with the code.
	local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
	set("IblIndent", { fg = comment_fg })
	set("IblWhitespace", { fg = comment_fg })

	set("SpellBad", { undercurl = true })
	set("SpellCap", { underdashed = true })
	set("SpellLocal", { underdotted = true })
	set("SpellRare", { underdotted = true })
end

function M.setup()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("user_ui", { clear = true }),
		callback = M.apply,
	})
	M.apply()
	-- Plugins define their highlight groups when they are set up, so flatten again once the
	-- deferred setup queue has finished.
	require("cfg_util").after_queue(M.apply)
end

return M

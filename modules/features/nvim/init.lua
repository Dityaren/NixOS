-- make lua/ next to this init.lua requirable
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
vim.opt.runtimepath:prepend(config_dir)
package.path = config_dir .. "/lua/?.lua;" .. config_dir .. "/lua/?/init.lua;" .. package.path

-- globals (must be set before plugins / keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- options
local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "both"
o.signcolumn = "yes:1"
o.scrolloff = 8
o.sidescrolloff = 8
o.smoothscroll = true
o.wrap = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.termguicolors = true
o.cmdheight = 0
o.laststatus = 3
o.showmode = false
o.showcmd = false
o.pumheight = 10
o.ruler = true
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen"
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.updatetime = 250
o.timeoutlen = 300
o.foldlevel = 99
o.foldlevelstart = 99
o.fillchars = { eob = " " }

-- colorscheme
require("kanagawa").setup({
	theme = "lotus",
	transparent = false,
	terminalColors = true,
	dimInactive = false,
	commentStyle = { italic = true },
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	undercurl = true,
})
vim.cmd.colorscheme("kanagawa")

-- highlight overrides (applied after colorscheme; re-applied on ColorScheme)
local function apply_highlights()
	local hl = {
		Normal = { bg = "none" },
		NormalNC = { bg = "none" },
		NormalFloat = { bg = "none" },
		FloatBorder = { fg = "#666666", bg = "none" },
		CursorLine = { bg = "#1f1f1f" },
		LineNr = { fg = "#555555" },
		CursorLineNr = { fg = "#aaaaaa", bold = true },
		SignColumn = { bg = "none" },
		StatusLine = { fg = "#aaaaaa", bg = "none" },
		StatusLineNC = { fg = "#555555", bg = "none" },
		WinSeparator = { fg = "#333333" },
		Pmenu = { fg = "#aaaaaa", bg = "#151515" },
		PmenuSel = { fg = "#ffffff", bg = "#333333", bold = true },
		Visual = { bg = "#333333" },
	}
	for group, spec in pairs(hl) do
		vim.api.nvim_set_hl(0, group, spec)
	end
end
apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_highlights })

-- diagnostics
vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many" },
})

-- gf: LSP definition for TS/JS (vtsls), builtin gf otherwise
_G.typescript_goto_file = function()
	local ts_fts = {
		javascript = true,
		javascriptreact = true,
		typescript = true,
		typescriptreact = true,
	}
	if not ts_fts[vim.bo.filetype] then
		vim.cmd("normal! gf")
		return
	end
	if #vim.lsp.get_clients({ bufnr = 0, name = "vtsls" }) == 0 then
		vim.cmd("normal! gf")
		return
	end
	vim.lsp.buf.definition({ reuse_win = true })
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "<Esc>", "<cmd>bd<CR>", { buffer = true, silent = true })
	end,
})

-- treesitter highlight + indent
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			local ok, ts = pcall(require, "nvim-treesitter")
			if ok and ts.indentexpr then
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end
	end,
})

-- keymaps
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gf", _G.typescript_goto_file, "Go to file or import")
map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
map("n", "gr", vim.lsp.buf.references, "Find references")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "K", vim.lsp.buf.hover, "Hover documentation")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, "Format buffer")
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Previous diagnostic")
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", "Toggle diagnostics")
map("n", "<leader>e", "<cmd>Explore<CR>", "Open file explorer")
map("n", "<leader>E", "<cmd>Lexplore<CR>", "Open file explorer sidebar")

-- telescope
map("n", "<leader><space>", "<cmd>Telescope find_files<CR>", "Find files")
map("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", "Search project")
map("n", "<leader>ff", "<cmd>Telescope live_grep<CR>", "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", "Find buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", "Help tags")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", "Recent files")

-- harpoon
map("n", "<leader>a", function()
	require("harpoon"):list():add()
end, "Harpoon add file")
map("n", "<leader>h", function()
	local h = require("harpoon")
	h.ui:toggle_quick_menu(h:list())
end, "Harpoon menu")
for i = 1, 4 do
	map("n", "<leader>" .. i, function()
		require("harpoon"):list():select(i)
	end, "Harpoon file " .. i)
end

map("n", "<leader>sn", "<cmd>Noice<CR>", "Noice message history")
map("n", "<leader>nl", "<cmd>Noice last<CR>", "Show last message")
map("n", "<leader>st", "<cmd>TodoTelescope<CR>", "Search TODOs")
map("n", "<leader>m", "<cmd>RenderMarkdown toggle<CR>", "Toggle Markdown rendering")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- plugins & LSP
require("plugins")
require("lsp")

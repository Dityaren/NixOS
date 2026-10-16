local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
vim.opt.runtimepath:prepend(config_dir)
package.path = config_dir .. "/lua/?.lua;" .. config_dir .. "/lua/?/init.lua;" .. package.path

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
o.inccommand = "split"
o.undofile = true
o.confirm = true
o.updatetime = 250
o.timeoutlen = 300
o.fillchars = { eob = " " }
o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldlevelstart = 99

require("kanagawa").setup({
	theme = "dragon",
	transparent = false,
	terminalColors = true,
	dimInactive = false,
	commentStyle = { italic = true },
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	undercurl = true,
})
vim.cmd.colorscheme("kanagawa")

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

vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many" },
})

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
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			local ok, ts = pcall(require, "nvim-treesitter")
			if ok and ts.indentexpr then
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local lines = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= lines then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gf", _G.typescript_goto_file, "Go to file or import")
map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
map("n", "gr", vim.lsp.buf.references, "Find references")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
map("n", "K", vim.lsp.buf.hover, "Hover documentation")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>cl", vim.lsp.codelens.run, "Run code lens")
map("n", "<leader>ci", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, "Toggle inlay hints")
map({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format buffer")
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Previous diagnostic")
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", "Toggle diagnostics")
map("n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", "Buffer diagnostics")
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", "Quickfix list")

map("n", "<leader>e", "<cmd>Oil<CR>", "File explorer (current dir)")
map("n", "<leader>E", "<cmd>Oil --float<CR>", "File explorer (float)")
map("n", "-", "<cmd>Oil<CR>", "Open parent directory")
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")
map("n", "<S-h>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "[b", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "]b", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bd", function()
	require("mini.bufremove").delete(0, false)
end, "Delete buffer")
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", "Delete other buffers")
map("v", "<", "<gv", "Indent left (keep selection)")
map("v", ">", ">gv", "Indent right (keep selection)")

map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, "Flash jump")
map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, "Flash treesitter")
map("o", "r", function()
	require("flash").remote()
end, "Flash remote")
map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, "Flash treesitter search")
map("c", "<C-s>", function()
	require("flash").toggle()
end, "Toggle flash search")

map("n", "<leader><space>", "<cmd>Telescope find_files<CR>", "Find files")
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", "Find files")
map("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", "Search project")
map("n", "<leader>sw", "<cmd>Telescope grep_string<CR>", "Search word under cursor")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", "Find buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", "Help tags")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", "Recent files")
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", "Diagnostics")
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", "Keymaps")
map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<CR>", "Document symbols")
map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace symbols")
map("n", "<leader>sr", function()
	require("grug-far").open()
end, "Search and replace (project)")
map({ "n", "v" }, "<leader>sR", function()
	require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, "Search and replace (file)")

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

map("n", "<leader>gg", "<cmd>Neogit<CR>", "Neogit")
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", "Diff view")
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", "File history")
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", "Repo history")
map("n", "<leader>gq", "<cmd>DiffviewClose<CR>", "Close diff view")
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", "Blame line")
map("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle inline blame")
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk")
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", "Stage hunk")
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", "Reset hunk")
map("n", "]h", "<cmd>Gitsigns next_hunk<CR>", "Next hunk")
map("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", "Previous hunk")

local lazygit_term
map("n", "<leader>gl", function()
	lazygit_term = lazygit_term
		or require("toggleterm.terminal").Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
	lazygit_term:toggle()
end, "Lazygit")
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("n", "<leader>cs", "<cmd>AerialToggle! right<CR>", "Symbol outline")
map("n", "<leader>qs", function()
	require("persistence").load()
end, "Restore session")
map("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, "Restore last session")
map("n", "<leader>qd", function()
	require("persistence").stop()
end, "Don't save current session")

map("n", "<leader>sn", "<cmd>Noice<CR>", "Noice message history")
map("n", "<leader>nl", "<cmd>Noice last<CR>", "Show last message")
map("n", "<leader>st", "<cmd>TodoTelescope<CR>", "Search TODOs")
map("n", "<leader>m", "<cmd>RenderMarkdown toggle<CR>", "Toggle Markdown rendering")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

require("plugins")
require("dev")
require("lsp")

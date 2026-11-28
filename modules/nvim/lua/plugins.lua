local util = require("cfg_util")
local defer = util.defer

-- ───────── Eager: needed for the very first frame / first buffer ─────────

vim.g.undotree_WindowLayout = 2
vim.g.undotree_SetFocusWhenToggle = 1

require("alpha").setup({
	layout = {
		{ type = "padding", val = 2 },
		{
			type = "text",
			val = { [[/\_/\ ]], "( o.o )", "> ^ <" },
			opts = { hl = "Title", position = "center" },
		},
		{ type = "padding", val = 2 },
		{
			type = "text",
			val = "  Neovim",
			opts = { hl = "Comment", position = "center" },
		},
	},
})

require("oil").setup({
	default_file_explorer = true,
	skip_confirm_for_simple_edits = true,
	view_options = { show_hidden = true },
	keymaps = {
		["q"] = "actions.close",
		["<Esc>"] = "actions.close",
	},
})

require("image").setup({
	backend = "ueberzug",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = false,
			-- was `true`: fetched every remote image over the network each time a markdown file was opened
			download_remote_images = false,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "inline",
			floating_windows = false,
			filetypes = { "markdown", "vimwiki" },
		},
	},
})

require("render-markdown").setup({
	enabled = true,
	render_modes = { "n", "c", "t" },
	debounce = 100,
	signs = { enabled = false },
	code = { border = "thin" },
})

require("illuminate").configure({
	delay = 200,
	min_count_to_highlight = 2,
	providers = { "lsp", "treesitter" },
	under_cursor = true,
})

-- Monochrome statusline: terminal-transparent, normal foreground, bold mode letter.
local nfg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
local fg = nfg and string.format("#%06x", nfg) or "NONE"
local plain = { fg = fg, bg = "NONE" }
local mode_theme = { a = { fg = fg, bg = "NONE", gui = "bold" }, b = plain, c = plain }
local lualine_theme = { inactive = mode_theme }
for _, m in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
	lualine_theme[m] = mode_theme
end

require("nvim-web-devicons").setup({ color_icons = false })

require("lualine").setup({
	options = {
		theme = lualine_theme,
		globalstatus = true,
		icons_enabled = true,
		component_separators = { left = "│", right = "│" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { statusline = { "dashboard", "alpha" } },
	},
	sections = {
		lualine_a = { {
			"mode",
			fmt = function(str)
				return str:sub(1, 1)
			end,
		} },
		lualine_b = { { "branch", icon = "󰘬" } },
		lualine_c = {
			{
				"filename",
				path = 1,
				symbols = { modified = " ●", readonly = " 󰌾", unnamed = "[No Name]" },
			},
		},
		lualine_x = {
			{ "diagnostics", colored = false, symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌵 " } },
		},
		lualine_y = { { "filetype", icon_only = true, colored = false } },
		lualine_z = { { "location", padding = 1 } },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
})

-- nvim-lint: only nix has linters; register the autocmd only for *.nix so every other
-- buffer pays nothing, and load nvim-lint on first use.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
	pattern = "*.nix",
	callback = function()
		local lint = require("lint")
		lint.linters_by_ft.nix = { "statix", "deadnix" }
		lint.try_lint()
	end,
})

-- ───────── Deferred: set up right after the first screen is drawn ─────────

defer("blink.cmp", function()
	require("blink.cmp").setup({
		completion = {
			documentation = { auto_show = true, window = { border = "rounded" } },
			accept = { auto_brackets = { enabled = true } },
			menu = {
				border = "rounded",
				draw = { treesitter = { "lsp", "path", "snippets", "buffer" } },
			},
		},
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			-- The default preset binds <Tab> to snippet jumping; overriding it with only
			-- select_next silently broke snippet navigation. Keep both.
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				-- lazydev only makes sense in Lua buffers; it used to run for every filetype
				lua = { inherit_defaults = true, "lazydev" },
			},
			providers = {
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
	})
end)

defer("luasnip", function()
	require("luasnip.loaders.from_vscode").lazy_load()
end)

defer("fzf-lua", function()
	local fzf = require("fzf-lua")
	fzf.setup({
		-- bottom pane, like the old telescope layout
		winopts = {
			height = 0.4,
			width = 1.0,
			row = 1,
			col = 0,
			border = "rounded",
			preview = { layout = "horizontal", horizontal = "right:50%", border = "rounded" },
		},
		-- colours come from the (colourless) highlight groups; mark the selected row with reverse video
		fzf_colors = { true, ["fg+"] = "reverse" },
	})
	fzf.register_ui_select() -- vim.ui.select (code actions etc.) through fzf-lua
end)

defer("git-conflict+bqf+dropbar", function()
	require("git-conflict").setup({ default_mappings = false })
	require("bqf").setup({ preview = { border = "rounded", winblend = 0 } })
	require("dropbar").setup({ menu = { win_configs = { border = "rounded" } } })
end)

defer("conform", function()
	local prettier = { "prettierd", "prettier", stop_after_first = true }
	require("conform").setup({
		formatters_by_ft = {
			nix = { "nixfmt" },
			lua = { "stylua" },
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			json = prettier,
			jsonc = prettier,
			yaml = prettier,
			markdown = prettier,
			["markdown.mdx"] = prettier,
			html = prettier,
			css = prettier,
			scss = prettier,
			less = prettier,
			graphql = prettier,
			rust = { "rustfmt" },
			toml = { "taplo" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			cmake = { "gersemi" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			objc = { "clang-format" },
			objcpp = { "clang-format" },
		},
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat or vim.b[bufnr].bigfile then
				return
			end
			-- 1000ms was too tight for a cold (non-daemon) prettier and caused timeouts
			return { lsp_format = "fallback", timeout_ms = 2000 }
		end,
	})
	vim.api.nvim_create_user_command("FormatDisable", function(opts)
		if opts.bang then
			vim.b.disable_autoformat = true
		else
			vim.g.disable_autoformat = true
		end
	end, { bang = true, desc = "Disable format-on-save (! = this buffer only)" })
	vim.api.nvim_create_user_command("FormatEnable", function()
		vim.b.disable_autoformat = false
		vim.g.disable_autoformat = false
	end, { desc = "Re-enable format-on-save" })
end)

defer("noice", function()
	require("noice").setup({
		cmdline = {
			enabled = true,
			view = "cmdline",
			format = {
				cmdline = { pattern = "^:", icon = ">", lang = "vim" },
				search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex" },
				search_up = { kind = "search", pattern = "^%?", icon = "?", lang = "regex" },
				filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
				lua = {
					pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
					icon = ">",
					lang = "lua",
				},
				help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
				input = { view = "cmdline", icon = ">" },
			},
		},
		messages = {
			enabled = false,
			view = "notify",
			view_error = "notify",
			view_warn = "notify",
			view_history = "messages",
			view_search = "virtualtext",
		},
		popupmenu = { enabled = true, backend = "nui" },
		lsp = {
			progress = { enabled = false },
			hover = { enabled = true },
			signature = { enabled = true },
		},
		notify = { enabled = false },
		documentation = {
			view = "hover",
			opts = {
				lang = "markdown",
				replace = true,
				render = "plain",
				format = { "{message}" },
				win_options = { concealcursor = "n", conceallevel = 3 },
			},
		},
		presets = {
			bottom_search = true,
			command_palette = false,
			long_message_to_split = true,
			lsp_doc_border = true,
		},
	})
end)

defer("mini", function()
	require("ts_context_commentstring").setup({ enable_autocmd = false })
	require("mini.comment").setup({
		-- gc / gcc / gc-textobject stay on their defaults; <leader>/ is aliased in init.lua.
		-- (Previously all four mappings were <leader>/, so the `gc{motion}` operator and `gcc` were lost.)
		options = {
			ignore_blank_line = false,
			pad_comment_parts = true,
			start_of_line = false,
			custom_commentstring = function()
				return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
			end,
		},
	})
	require("mini.bufremove").setup({})
	require("mini.move").setup({})
	require("mini.surround").setup({
		mappings = {
			add = "gsa",
			delete = "gsd",
			find = "gsf",
			find_left = "gsF",
			highlight = "gsh",
			replace = "gsr",
			update_n_lines = "gsn",
		},
	})
	local ai = require("mini.ai")
	ai.setup({
		n_lines = 500,
		-- These @function.outer etc. captures come from nvim-treesitter-textobjects (now in nixcats.nix);
		-- without it af/if/ac/ic/aa/ia/ao/io silently did nothing.
		custom_textobjects = {
			f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
			o = ai.gen_spec.treesitter({
				a = { "@conditional.outer", "@loop.outer" },
				i = { "@conditional.inner", "@loop.inner" },
			}),
		},
	})
end)

defer("autopairs+autotag+escape", function()
	require("nvim-autopairs").setup({ check_ts = true })
	require("nvim-ts-autotag").setup()
	require("better_escape").setup()
end)

defer("flash", function()
	require("flash").setup({
		labels = "asdfghjklqwertyuiopzxcvbnm",
		modes = {
			search = { enabled = true },
			char = { enabled = true, jump_labels = true, multi_line = false },
			treesitter = { labels = "abcdefghijklmnopqrstuvwxyz" },
		},
	})
end)

defer("gitsigns", function()
	require("gitsigns").setup({
		current_line_blame = false,
		signs = {
			-- no colours, so the sign shape carries the meaning
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
	})
end)

defer("which-key", function()
	require("which-key").setup({
		preset = "modern",
		delay = 300,
		win = { border = "rounded" },
	})
	require("which-key").add({
		{ "<leader>b", group = "buffer" },
		{ "<leader>c", group = "code" },
		{ "<leader>d", group = "debug" },
		{ "<leader>f", group = "find" },
		{ "<leader>g", group = "git" },
		{ "<leader>gx", group = "conflict" },
		{ "<leader>k", group = "cmake" },
		{ "<leader>n", group = "noice" },
		{ "<leader>o", group = "overseer" },
		{ "<leader>q", group = "session" },
		{ "<leader>r", group = "rename / rust" },
		{ "<leader>s", group = "search" },
		{ "<leader>t", group = "test" },
		{ "<leader>x", group = "diagnostics" },
		{ "gs", group = "surround" },
	})
end)

defer("trouble+harpoon+todo", function()
	require("trouble").setup()
	require("harpoon"):setup({
		settings = { save_on_toggle = true, sync_on_ui_close = true },
	})
	require("todo-comments").setup({ signs = false })
end)

defer("ibl", function()
	require("ibl").setup({
		indent = { char = "│" },
		scope = { enabled = false },
		exclude = {
			filetypes = { "help", "dashboard", "alpha", "TelescopePrompt", "TelescopeResults", "oil" },
		},
	})
end)

defer("lazydev", function()
	require("lazydev").setup({})
end)

defer("git ui", function()
	require("neogit").setup({ integrations = { diffview = true, fzf_lua = true } })
	require("diffview").setup({})
end)

defer("aerial+context", function()
	require("aerial").setup({
		backends = { "lsp", "treesitter" },
		layout = { min_width = 30 },
		show_guides = true,
	})
	require("treesitter-context").setup({ max_lines = 3, trim_scope = "outer", separator = "─" })
end)

defer("toggleterm+persistence+grug", function()
	require("toggleterm").setup({
		open_mapping = [[<M-i>]],
		direction = "float",
		float_opts = { border = "curved" },
	})
	require("persistence").setup({})
	require("grug-far").setup({})
end)

defer("tiny-inline-diagnostic", function()
	require("tiny-inline-diagnostic").setup({
		preset = "modern",
		options = { show_source = { enabled = true }, multilines = { enabled = true } },
	})
end)

-- cord must be configured BEFORE VimEnter: the plugin starts itself with its defaults at startup,
-- so a setup() call from the deferred queue (which runs after VimEnter) is ignored.
do
	local lang_names = {
		javascript = "JavaScript",
		javascriptreact = "JavaScript React",
		typescript = "TypeScript",
		typescriptreact = "TypeScript React",
		nix = "Nix",
		lua = "Lua",
		rust = "Rust",
		c = "C",
		cpp = "C++",
		python = "Python",
		html = "HTML",
		css = "CSS",
		scss = "SCSS",
		sass = "Sass",
		less = "Less",
		json = "JSON",
		jsonc = "JSONC",
		yaml = "YAML",
		toml = "TOML",
		markdown = "Markdown",
		bash = "Bash",
		sh = "Shell",
		zsh = "Shell",
		vim = "Vim Script",
		cmake = "CMake",
		sql = "SQL",
		java = "Java",
		go = "Go",
		php = "PHP",
	}

	local function activity(verb)
		return function(opts)
			local ft = lang_names[opts.filetype] or opts.filetype
			if not ft or ft == "" then
				return verb
			end
			return verb .. " " .. ft
		end
	end

	require("cord").setup({
		editor = {
			tooltip = "Not THAT kind of Water Imp! ",
			icon = "https://c.tenor.com/HbxHKsa2TPsAAAAd/tenor.gif",
		},
		display = { theme = "catppuccin", flavor = "accent", view = "editor", swap_icons = true },
		buttons = nil,
		text = {
			workspace = function(opts)
				if opts.workspace and opts.workspace ~= "" then
					return "In " .. opts.workspace
				end
				return "In Neovim"
			end,
			editing = activity("Editing"),
			viewing = activity("Viewing"),
			file_browser = "Browsing files",
			plugin_manager = "Managing plugins",
			lsp = "Configuring LSP",
			docs = "Reading documentation",
			vcs = "Working with version control",
			notes = "Taking notes",
			debug = "Debugging",
			test = "Running tests",
			diagnostics = "Checking diagnostics",
			terminal = "Using terminal",
			dashboard = "Home",
		},
		timestamp = { enabled = true },
		idle = {
			enabled = true,
			timeout = 300000,
			show_status = true,
			ignore_focus = true,
			unidle_on_focus = true,
			smart_idle = true,
			details = "Idling",
		},
		advanced = { discord = { reconnect = { enabled = true, interval = 5000, initial = true } } },
	})
end

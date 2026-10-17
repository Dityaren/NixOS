require("ts_context_commentstring").setup({ enable_autocmd = false })
require("mini.comment").setup({
	mappings = {
		comment = "<leader>/",
		comment_line = "<leader>/",
		comment_visual = "<leader>/",
		textobject = "<leader>/",
	},
	options = {
		ignore_blank_line = false,
		pad_comment_parts = true,
		start_of_line = false,
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})
require("mini.icons").setup({})
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
do
	local ai = require("mini.ai")
	ai.setup({
		n_lines = 500,
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
end

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

require("image").setup({
	backend = "ueberzug",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = false,
			download_remote_images = true,
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
})

require("nvim-autopairs").setup({ check_ts = true })
require("luasnip.loaders.from_vscode").lazy_load()
require("nvim-ts-autotag").setup()
require("better_escape").setup()

require("flash").setup({
	labels = "asdfghjklqwertyuiopzxcvbnm",
	modes = {
		search = { enabled = true },
		char = { enabled = true, jump_labels = true, multi_line = false },
		treesitter = { labels = "abcdefghijklmnopqrstuvwxyz" },
	},
})

require("smear_cursor").setup({
	stiffness = 0.8,
	trailing_stiffness = 0.5,
	distance_stop_animating = 0.5,
	hide_target_hack = false,
})

require("gitsigns").setup({
	current_line_blame = false,
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
})

require("which-key").setup({ preset = "modern", delay = 300 })
require("which-key").add({
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "code" },
	{ "<leader>d", group = "debug" },
	{ "<leader>f", group = "find" },
	{ "<leader>g", group = "git" },
	{ "<leader>gs", desc = "Stage hunk" },
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
require("trouble").setup()

require("harpoon"):setup({
	settings = { save_on_toggle = true, sync_on_ui_close = true },
})

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
		lsp_doc_border = false,
	},
})

require("todo-comments").setup()

require("illuminate").configure({
	delay = 200,
	min_count_to_highlight = 2,
	providers = { "lsp", "treesitter" },
	under_cursor = true,
})

require("colorizer").setup({
	filetypes = {
		"css",
		"scss",
		"sass",
		"less",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	user_default_options = {
		mode = "virtualtext",
		names = false,
		virtualtext = "■ ",
	},
})

require("minuet").setup({
	provider = "openai_fim_compatible",
	n_completions = 1,
	context_window = 512,
	request_timeout = 3,
	provider_options = {
		openai_fim_compatible = {
			api_key = "TERM",
			name = "llama.cpp",
			end_point = "http://127.0.0.1:8012/v1/completions",
			model = "PLACEHOLDER",
			optional = { max_tokens = 56, top_p = 0.9 },
			template = {
				prompt = function(context_before_cursor, context_after_cursor)
					return "<|fim_prefix|>"
						.. context_before_cursor
						.. "<|fim_suffix|>"
						.. context_after_cursor
						.. "<|fim_middle|>"
				end,
				suffix = false,
			},
		},
	},
	virtualtext = {
		auto_trigger_ft = { "typescript" },
		keymap = {
			accept = "<A-A>",
			accept_line = "<A-a>",
			dismiss = "<A-e>",
			prev = "<A-[>",
			next = "<A-]>",
		},
	},
})

require("blink.cmp").setup({
	completion = {
		documentation = { auto_show = true },
		accept = { auto_brackets = { enabled = true } },
		menu = {
			border = "rounded",
			draw = { treesitter = { "lsp", "path", "snippets", "buffer" } },
		},
	},
	keymap = {
		preset = "default",
		["<CR>"] = { "accept", "fallback" },
		["<C-m>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<A-y>"] = require("minuet").make_blink_map(),
	},
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		providers = {
			lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
			minuet = {
				name = "minuet",
				module = "minuet.blink",
				async = true,
				timeout_ms = 3000,
				score_offset = 50,
			},
		},
	},
})

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
		tooltip = "0x0",
		icon = "https://c.tenor.com/VDX5Ss2Hks0AAAAd/tenor.gif",
	},
	display = { theme = "minecraft", flavor = "light", view = "editor", swap_icons = true },
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

local mode_theme = {
	a = { fg = "#111111", bg = "#aaaaaa", gui = "bold" },
	b = { fg = "#aaaaaa", bg = "#222222" },
	c = { fg = "#888888", bg = "#111111" },
}
local lualine_theme = {
	inactive = {
		a = { fg = "#666666", bg = "#111111" },
		b = { fg = "#555555", bg = "#111111" },
		c = { fg = "#444444", bg = "#111111" },
	},
}
for _, m in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
	lualine_theme[m] = mode_theme
end

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
			{ "diagnostics", symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌵 " } },
		},
		lualine_y = { { "filetype", icon_only = true } },
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

local telescope = require("telescope")
telescope.setup({
	defaults = {
		prompt_prefix = "   ",
		selection_caret = " > ",
		path_display = { "truncate" },
		sorting_strategy = "ascending",
		border = false,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		layout_strategy = "bottom_pane",
		layout_config = { height = 0.35, width = 1.0, prompt_position = "top" },
		file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/", ".next/", "target/" },
	},
})
pcall(telescope.load_extension, "fzf")

require("ibl").setup({
	indent = { char = "┊" },
	scope = { enabled = true, char = "┃" },
	exclude = {
		filetypes = { "help", "dashboard", "NvimTree", "TelescopePrompt", "TelescopeResults", "netrw" },
	},
})

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
	format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
})

local lint = require("lint")
lint.linters_by_ft = {
	nix = { "statix", "deadnix" },
}
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
	callback = function()
		lint.try_lint()
	end,
})

require("lazydev").setup({})

require("oil").setup({
	default_file_explorer = true,
	skip_confirm_for_simple_edits = true,
	view_options = { show_hidden = true },
	keymaps = {
		["q"] = "actions.close",
		["<Esc>"] = "actions.close",
	},
})

require("neogit").setup({ integrations = { diffview = true, telescope = true } })
require("diffview").setup({})

require("aerial").setup({
	backends = { "lsp", "treesitter" },
	layout = { min_width = 30 },
	show_guides = true,
})
require("treesitter-context").setup({ max_lines = 3, trim_scope = "outer" })

require("toggleterm").setup({
	open_mapping = [[<M-i>]],
	direction = "float",
	float_opts = { border = "curved" },
})

require("persistence").setup({})
require("grug-far").setup({})
require("tiny-inline-diagnostic").setup({
	preset = "modern",
	options = { show_source = { enabled = true }, multilines = { enabled = true } },
})

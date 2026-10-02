-- mini
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
	},
})
require("mini.icons").setup({})

-- alpha
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

-- image
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

-- blink.cmp
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
	},
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
})

-- cord (Discord presence)
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
		tooltip = "HOVER CURREN CHAN == DEATH!!!",
		icon = "https://c.tenor.com/Ag1mcxevv8UAAAAd/tenor.gif",
	},
	display = { theme = "atom", flavor = "accent", view = "editor", swap_icons = true },
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

-- lualine (same grey theme for every mode)
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

-- telescope
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

-- indent-blankline
require("ibl").setup({
	indent = { char = "┊" },
	scope = { enabled = true, char = "┃" },
	exclude = {
		filetypes = { "help", "dashboard", "NvimTree", "TelescopePrompt", "TelescopeResults", "netrw" },
	},
})

-- conform
require("conform").setup({
	formatters_by_ft = {
		nix = { "nixfmt" },
		lua = { "stylua" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		markdown_inline = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		rust = { "rustfmt" },
		toml = { "taplo" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		objc = { "clang-format" },
		objcpp = { "clang-format" },
	},
	format_on_save = { lsp_fallback = true, timeout_ms = 1000 },
})

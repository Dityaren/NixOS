vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end
		if client:supports_method("textDocument/inlayHint", args.buf) then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
		if client:supports_method("textDocument/codeLens", args.buf) then
			if vim.lsp.codelens.enable then
				vim.lsp.codelens.enable(true, { bufnr = args.buf })
			else
				vim.lsp.codelens.refresh({ bufnr = args.buf })
				vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
					buffer = args.buf,
					callback = function()
						vim.lsp.codelens.refresh({ bufnr = args.buf })
					end,
				})
			end
		end
		if client.name == "clangd" then
			vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<CR>", {
				buffer = args.buf,
				desc = "Switch source/header",
			})
		end
	end,
})

local ts_prefs = {
	suggest = { autoImports = true, paths = true },
	preferences = {
		importModuleSpecifier = "shortest",
		includePackageJsonAutoImports = "on",
	},
	updateImportsOnFileMove = { enabled = "always" },
}

local servers = {
	nil_ls = {
		settings = {
			["nil"] = {
				formatting = { command = { "nixfmt" } },
				nix = { flake = { autoArchive = true } },
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
				hint = { enable = true },
			},
		},
	},

	vtsls = {
		root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		settings = { typescript = ts_prefs, javascript = ts_prefs },
	},
	html = {},
	cssls = {},
	tailwindcss = {},
	eslint = {},
	emmet_language_server = {
		filetypes = { "html", "css", "scss", "sass", "less", "javascriptreact", "typescriptreact" },
	},
	-- SchemaStore's catalogs are large; build them only when a json/yaml server actually starts,
	-- not on every nvim launch.
	jsonls = {
		settings = { json = { validate = { enable = true } } },
		before_init = function(_, config)
			config.settings.json.schemas = require("schemastore").json.schemas()
		end,
	},
	yamlls = {
		settings = { yaml = { schemaStore = { enable = false, url = "" } } },
		before_init = function(_, config)
			config.settings.yaml.schemas = require("schemastore").yaml.schemas()
		end,
	},

	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders=false",
			"--fallback-style=llvm",
			"--pch-storage=memory",
			"--malloc-trim",
		},
		init_options = { fallbackFlags = { "-std=c++20" } },
	},
	neocmake = {},

	taplo = {},
	bashls = {},
	marksman = {},
}

for name, cfg in pairs(servers) do
	if next(cfg) ~= nil then
		vim.lsp.config(name, cfg)
	end
	vim.lsp.enable(name)
end

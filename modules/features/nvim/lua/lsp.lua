-- Uses Neovim 0.11+ native vim.lsp.config/enable; nvim-lspconfig supplies the default server definitions.

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
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
	lua_ls = {},
	vtsls = {
		root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		settings = { typescript = ts_prefs, javascript = ts_prefs },
	},
	tailwindcss = {},
	eslint = {},
	jsonls = {},
	yamlls = {},
	clangd = {
		cmd = { "clangd", "--fallback-style=llvm" },
		init_options = { fallbackFlags = { "-std=c++20" } },
	},
	taplo = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true, buildScripts = { enable = true } },
				procMacro = { enable = true },
				checkOnSave = true,
				check = { command = "clippy" },
				inlayHints = {
					bindingModeHints = { enable = true },
					closureCaptureHints = { enable = true },
					closureReturnTypeHints = { enable = "always" },
					lifetimeElisionHints = { enable = "always" },
					typeHints = { enable = true },
				},
			},
		},
	},
	emmet_ls = {
		filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
	},
}

for name, cfg in pairs(servers) do
	if next(cfg) ~= nil then
		vim.lsp.config(name, cfg)
	end
	vim.lsp.enable(name)
end

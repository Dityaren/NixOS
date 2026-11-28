local util = require("cfg_util")
local once, defer = util.once, util.defer

local function map(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

-- ───────── Rust ─────────

vim.g.rustaceanvim = {
	server = {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
		default_settings = {
			["rust-analyzer"] = {
				cargo = { features = "all", buildScripts = { enable = true } },
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
	dap = {
		adapter = { type = "executable", command = "lldb-dap", name = "lldb" },
	},
}

local ensure_dap -- defined below

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function(args)
		local function rust(lhs, cmd, desc, mode, before)
			map(mode or "n", lhs, function()
				if before then
					before()
				end
				vim.cmd.RustLsp(type(cmd) == "table" and cmd or { cmd })
			end, desc, { buffer = args.buf })
		end
		rust("K", { "hover", "actions" }, "Hover actions")
		rust("<leader>ca", "codeAction", "Code action (grouped)")
		rust("<leader>rr", "runnables", "Runnables")
		rust("<leader>rt", "testables", "Testables")
		rust("<leader>rd", "debuggables", "Debuggables", nil, function()
			ensure_dap() -- so the dap-ui open/close listeners are registered
		end)
		rust("<leader>re", "expandMacro", "Expand macro")
		rust("<leader>rc", "openCargo", "Open Cargo.toml")
		rust("<leader>rp", "parentModule", "Parent module")
		rust("<leader>rx", "explainError", "Explain error")
		rust("<leader>rD", "renderDiagnostic", "Render diagnostic")
		rust("<leader>rj", "joinLines", "Join lines", { "n", "v" })
	end,
})

local ensure_crates = once(function()
	require("crates").setup({
		lsp = { enabled = true, actions = true, completion = true, hover = true },
	})
end)
defer("crates", ensure_crates)
-- `nvim Cargo.toml`: that buffer is read before the deferred queue runs, so set up now.
local first_arg = vim.fn.argv(0)
if type(first_arg) == "string" and first_arg:match("Cargo%.toml$") then
	ensure_crates()
end

defer("clangd_extensions", function()
	require("clangd_extensions").setup({})
end)

-- ───────── Debugging (loaded on first use) ─────────

ensure_dap = once(function()
	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup()
	require("nvim-dap-virtual-text").setup({})

	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
	vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
	vim.fn.sign_define("DapLogPoint", { text = "◇", texthl = "DiagnosticInfo" })
	vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine" })

	dap.adapters.lldb = { type = "executable", command = "lldb-dap", name = "lldb" }
	dap.configurations.cpp = {
		{
			name = "Launch executable",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
		},
		{
			name = "Attach to process",
			type = "lldb",
			request = "attach",
			pid = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
	}
	dap.configurations.c = dap.configurations.cpp

	dap.adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = { command = "js-debug", args = { "${port}" } },
	}
	for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
		dap.configurations[ft] = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch current file",
				program = "${file}",
				cwd = "${workspaceFolder}",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to process",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
		}
	end
end)

local function with_dap(fn)
	return function()
		ensure_dap()
		fn(require("dap"))
	end
end

map("n", "<leader>db", with_dap(function(dap)
	dap.toggle_breakpoint()
end), "Toggle breakpoint")
map("n", "<leader>dB", with_dap(function(dap)
	dap.set_breakpoint(vim.fn.input("Condition: "))
end), "Conditional breakpoint")
map("n", "<leader>dc", with_dap(function(dap)
	dap.continue()
end), "Continue / start")
map("n", "<leader>di", with_dap(function(dap)
	dap.step_into()
end), "Step into")
map("n", "<leader>do", with_dap(function(dap)
	dap.step_over()
end), "Step over")
map("n", "<leader>dO", with_dap(function(dap)
	dap.step_out()
end), "Step out")
map("n", "<leader>dr", with_dap(function(dap)
	dap.repl.toggle()
end), "Toggle REPL")
map("n", "<leader>dl", with_dap(function(dap)
	dap.run_last()
end), "Run last")
map("n", "<leader>dt", with_dap(function(dap)
	dap.terminate()
end), "Terminate")
map("n", "<leader>du", function()
	ensure_dap()
	require("dapui").toggle()
end, "Toggle debug UI")
map({ "n", "v" }, "<leader>de", function()
	ensure_dap()
	require("dapui").eval()
end, "Evaluate expression")
map("n", "<F5>", with_dap(function(dap)
	dap.continue()
end), "Debug: continue")
map("n", "<F9>", with_dap(function(dap)
	dap.toggle_breakpoint()
end), "Debug: toggle breakpoint")
map("n", "<F10>", with_dap(function(dap)
	dap.step_over()
end), "Debug: step over")
map("n", "<F11>", with_dap(function(dap)
	dap.step_into()
end), "Debug: step into")
map("n", "<S-F11>", with_dap(function(dap)
	dap.step_out()
end), "Debug: step out")

-- ───────── Tests (loaded on first use) ─────────

local ensure_neotest = once(function()
	require("neotest").setup({
		adapters = {
			require("rustaceanvim.neotest"),
			require("neotest-vitest"),
			require("neotest-jest")({ jestCommand = "npx jest" }),
			require("neotest-gtest").setup({}),
		},
		status = { virtual_text = true },
		output = { open_on_run = false },
	})
end)

local function neotest()
	ensure_neotest()
	return require("neotest")
end

map("n", "<leader>tr", function()
	neotest().run.run()
end, "Run nearest test")
map("n", "<leader>tf", function()
	neotest().run.run(vim.fn.expand("%"))
end, "Run file tests")
map("n", "<leader>ta", function()
	neotest().run.run(vim.fn.getcwd())
end, "Run all tests")
map("n", "<leader>tl", function()
	neotest().run.run_last()
end, "Run last test")
map("n", "<leader>td", function()
	ensure_dap()
	neotest().run.run({ strategy = "dap" })
end, "Debug nearest test")
map("n", "<leader>ts", function()
	neotest().summary.toggle()
end, "Toggle test summary")
map("n", "<leader>to", function()
	neotest().output.open({ enter = true })
end, "Test output")
map("n", "<leader>tO", function()
	neotest().output_panel.toggle()
end, "Test output panel")
map("n", "<leader>tx", function()
	neotest().run.stop()
end, "Stop test")

-- ───────── Overseer (loaded on first use) ─────────

local ensure_overseer = once(function()
	require("overseer").setup({})
end)
local function overseer(cmd)
	return function()
		ensure_overseer()
		vim.cmd(cmd)
	end
end
map("n", "<leader>oo", overseer("OverseerToggle"), "Task list")
map("n", "<leader>or", overseer("OverseerRun"), "Run task")
map("n", "<leader>oa", overseer("OverseerTaskAction"), "Task action")

-- ───────── CMake (loaded when a CMake project is opened, or on first use) ─────────

local ensure_cmake = once(function()
	require("cmake-tools").setup({
		cmake_regenerate_on_save = true,
		cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
		cmake_build_directory = "build/${variant:buildType}",
		cmake_soft_link_compile_commands = true,
		cmake_executor = {
			name = "quickfix",
			default_opts = {
				quickfix = { show = "always", position = "belowright", size = 10, auto_close_when_success = true },
			},
		},
		cmake_runner = { name = "terminal" },
		cmake_dap_configuration = {
			name = "cpp",
			type = "lldb",
			request = "launch",
			stopOnEntry = false,
			runInTerminal = true,
			console = "integratedTerminal",
		},
	})
end)

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "cmake" },
	callback = function(args)
		if vim.fs.root(args.buf, { "CMakeLists.txt", "CMakePresets.json" }) then
			ensure_cmake()
			return true -- remove this autocmd; setup only needs to happen once
		end
	end,
})

local function cmake(cmd)
	return function()
		ensure_cmake()
		if cmd == "CMakeDebug" then
			ensure_dap()
		end
		vim.cmd(cmd)
	end
end
map("n", "<leader>kg", cmake("CMakeGenerate"), "CMake generate")
map("n", "<leader>kb", cmake("CMakeBuild"), "CMake build")
map("n", "<leader>kr", cmake("CMakeRun"), "CMake run")
map("n", "<leader>kd", cmake("CMakeDebug"), "CMake debug")
map("n", "<leader>kt", cmake("CMakeSelectBuildTarget"), "Select build target")
map("n", "<leader>kl", cmake("CMakeSelectLaunchTarget"), "Select launch target")
map("n", "<leader>kc", cmake("CMakeSelectBuildType"), "Select build type")
map("n", "<leader>kp", cmake("CMakeSelectConfigurePreset"), "Select configure preset")
map("n", "<leader>ks", cmake("CMakeStopExecutor"), "Stop build")
map("n", "<leader>kx", cmake("CMakeStopRunner"), "Stop running target")

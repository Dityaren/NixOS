local function map(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function(args)
		local function rust(lhs, cmd, desc, mode)
			map(mode or "n", lhs, function()
				vim.cmd.RustLsp(type(cmd) == "table" and cmd or { cmd })
			end, desc, { buffer = args.buf })
		end
		rust("K", { "hover", "actions" }, "Hover actions")
		rust("<leader>ca", "codeAction", "Code action (grouped)")
		rust("<leader>rr", "runnables", "Runnables")
		rust("<leader>rt", "testables", "Testables")
		rust("<leader>rd", "debuggables", "Debuggables")
		rust("<leader>re", "expandMacro", "Expand macro")
		rust("<leader>rc", "openCargo", "Open Cargo.toml")
		rust("<leader>rp", "parentModule", "Parent module")
		rust("<leader>rx", "explainError", "Explain error")
		rust("<leader>rD", "renderDiagnostic", "Render diagnostic")
		rust("<leader>rj", "joinLines", "Join lines", { "n", "v" })
	end,
})

require("crates").setup({
	lsp = { enabled = true, actions = true, completion = true, hover = true },
})

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

map("n", "<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, "Conditional breakpoint")
map("n", "<leader>dc", dap.continue, "Continue / start")
map("n", "<leader>di", dap.step_into, "Step into")
map("n", "<leader>do", dap.step_over, "Step over")
map("n", "<leader>dO", dap.step_out, "Step out")
map("n", "<leader>dr", dap.repl.toggle, "Toggle REPL")
map("n", "<leader>dl", dap.run_last, "Run last")
map("n", "<leader>dt", dap.terminate, "Terminate")
map("n", "<leader>du", dapui.toggle, "Toggle debug UI")
map({ "n", "v" }, "<leader>de", dapui.eval, "Evaluate expression")
map("n", "<F5>", dap.continue, "Debug: continue")
map("n", "<F9>", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("n", "<F10>", dap.step_over, "Debug: step over")
map("n", "<F11>", dap.step_into, "Debug: step into")
map("n", "<S-F11>", dap.step_out, "Debug: step out")

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

map("n", "<leader>tr", function()
	require("neotest").run.run()
end, "Run nearest test")
map("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, "Run file tests")
map("n", "<leader>ta", function()
	require("neotest").run.run(vim.fn.getcwd())
end, "Run all tests")
map("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, "Run last test")
map("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end, "Debug nearest test")
map("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, "Toggle test summary")
map("n", "<leader>to", function()
	require("neotest").output.open({ enter = true })
end, "Test output")
map("n", "<leader>tO", function()
	require("neotest").output_panel.toggle()
end, "Test output panel")
map("n", "<leader>tx", function()
	require("neotest").run.stop()
end, "Stop test")

require("overseer").setup({})
map("n", "<leader>oo", "<cmd>OverseerToggle<CR>", "Task list")
map("n", "<leader>or", "<cmd>OverseerRun<CR>", "Run task")
map("n", "<leader>oa", "<cmd>OverseerTaskAction<CR>", "Task action")

require("clangd_extensions").setup({})

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

map("n", "<leader>kg", "<cmd>CMakeGenerate<CR>", "CMake generate")
map("n", "<leader>kb", "<cmd>CMakeBuild<CR>", "CMake build")
map("n", "<leader>kr", "<cmd>CMakeRun<CR>", "CMake run")
map("n", "<leader>kd", "<cmd>CMakeDebug<CR>", "CMake debug")
map("n", "<leader>kt", "<cmd>CMakeSelectBuildTarget<CR>", "Select build target")
map("n", "<leader>kl", "<cmd>CMakeSelectLaunchTarget<CR>", "Select launch target")
map("n", "<leader>kc", "<cmd>CMakeSelectBuildType<CR>", "Select build type")
map("n", "<leader>kp", "<cmd>CMakeSelectConfigurePreset<CR>", "Select configure preset")
map("n", "<leader>ks", "<cmd>CMakeStopExecutor<CR>", "Stop build")
map("n", "<leader>kx", "<cmd>CMakeStopRunner<CR>", "Stop running target")

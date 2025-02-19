local dap, dapui, dap_go = require("dap"), require("dapui"), require("dap-go")
local composer = require("composer")

require("nvim-dap-virtual-text").setup({})
-- dap.set_log_level('TRACE')

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸" },
	layouts = {
		{
			elements = {
				"scopes",
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 80,
			position = "left",
		},
		{
			elements = {
				"repl",
				"console",
			},
			size = 10,
			position = "bottom",
		},
	},
})

dap_go.setup()

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "❓", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "💬", texthl = "", linehl = "", numhl = "" })

-- vim.cmd("au FileType dap-repl lua require('dap.ext.autocompl').attach()")

-- the binary does not work
local ok, php_debug_adapter = pcall(require("mason-registry").get_package, "php_debug_adapter")

-- TODO: choose action in case adapter is not installed with `mason.nvim`.
-- For example:
-- if not ok then
	-- the binary is not installed.
	-- vim.notify("the php_debug_adapter is not installed with mason.nvim")
    	-- return
-- end

dap.adapters.php = {
	type = "executable",
	command = "node",
	args = { php_debug_adapter:get_install_path() .. "/extension/out/phpDebug.js" },
}
dap.configurations.php = {
	{
		type = "php",
		request = "launch",
		name = "Listen for Xdebug",
		port = 9003,
		pathMappings = function()
			if composer.query({"require-dev", "laravel/sali"}) == nil then
				return { ["/app"] = "${workspaceFolder}" }
			end
			return { ["/var/www/html"] = "${workspaceFolder}" }
		end,
	},
}

-- Events Listeners
-- dap.listeners.after.event_initialized["dapui_config"] = function()
-- 	dapui.open({})
-- end

local hydra = require("hydra")
local hint = [[
 Nvim DAP
 _d_: Start/Continue  _j_: StepOver _k_: StepOut _l_: StepInto ^
 _bp_: Toogle Breakpoint  _bc_: Conditional Breakpoint ^
 _c_: Run To Cursor  _tt_: Go Debug Test
 _h_: Show information of the variable under the cursor _?_ log point
 _s_: Start         _x_: Stop Debbuging
 ^^                                                      _<Esc>_
]]
hydra({
	name = "dap",
	hint = hint,
	mode = "n",
	config = {
		color = "blue",
		invoke_on_body = true,
		hint = {
			border = "rounded",
			position = "bottom",
		},
	},
	body = "<leader>d",
	heads = {
		{ "d", dap.continue },
		{
			"s",
			function()
				dap.continue()
				dapui.open({})
			end,
		},
		{ "bp", dap.toggle_breakpoint },
		{ "l", dap.step_into },
		{ "j", dap.step_over },
		{ "k", dap.step_out },
		{ "h", dapui.eval },
		{ "c", dap.run_to_cursor },
		{ "tt", dap_go.debug_test },
		{
			"bc",
			function()
				vim.ui.input({ prompt = "Condition: " }, function(condition)
					dap.set_breakpoint(condition)
				end)
			end,
		},
		{
			"?",
			function()
				vim.ui.input({ prompt = "Log: " }, function(log)
					dap.set_breakpoint(nil, nil, log)
				end)
			end,
		},
		{
			"x",
			function()
				dap.terminate()
				dapui.close({})
				dap.clear_breakpoints()
			end,
		},

		{ "<Esc>", nil, { exit = true } },
	},
})

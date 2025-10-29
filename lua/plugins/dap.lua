return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"mfussenegger/nvim-jdtls",
		"nvim-neotest/nvim-nio", -- required by dap-ui
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local jdtls = require("jdtls")

		require("nvim-dap-virtual-text").setup()
		dapui.setup()

		jdtls.setup_dap({ hotcodereplace = "auto" })

		-- UI auto open/close behavior
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- mykeymaps
		vim.keymap.set("n", "<leader>bc", function()
			dap.continue()
		end, { desc = "DAP Continue" })

		vim.keymap.set("n", "<leader>bo", function()
			dap.step_over()
		end, { desc = "DAP Step Over" })

		vim.keymap.set("n", "<leader>bi", function()
			dap.step_into()
		end, { desc = "DAP Step Into" })

		vim.keymap.set("n", "<leader>bu", function()
			dap.step_out()
		end, { desc = "DAP Step Out" })

		vim.keymap.set("n", "<leader>bt", function()
			dap.toggle_breakpoint()
		end, { desc = "Toggle Breakpoint" })

		vim.keymap.set("n", "<leader>bs", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Conditional Breakpoint" })

		vim.keymap.set("n", "<leader>bl", function()
			dap.repl.toggle()
		end, { desc = "Toggle DAP REPL" })

		vim.keymap.set("n", "<leader>bg", function()
			dapui.toggle()
		end, { desc = "Toggle DAP UI" })

		-------------------------------------------------------------------------
		-- ▶ Dynamic DAP keymaps (active only while debugging)
		-------------------------------------------------------------------------
		local opts = { noremap = true, silent = true }

		-- When a debug session starts → add temporary keymaps
		dap.listeners.after.event_initialized["keymaps"] = function()
			vim.keymap.set("n", "<C-Right>", dap.step_into, opts)
			vim.keymap.set("n", "<C-Up>", dap.step_out, opts)
			vim.keymap.set("n", "<C-Down>", dap.step_over, opts)
			vim.keymap.set("n", "<C-Left>", dap.continue, opts)
			vim.keymap.set("n", "<C-b>", dap.toggle_breakpoint, opts)
		end

		local function safe_del(mode, lhs)
			local ok = pcall(vim.keymap.del, mode, lhs)
			if not ok then
				-- optional: print("⚠️ Tried to delete unmapped key: " .. lhs)
			end
		end

		dap.listeners.before.event_terminated["keymaps"] = function()
			safe_del("n", "<C-Right>")
			safe_del("n", "<C-Up>")
			safe_del("n", "<C-Down>")
			safe_del("n", "<C-Left>")
			safe_del("n", "<C-b>")
		end
		dap.listeners.before.event_exited["keymaps"] = dap.listeners.before.event_terminated["keymaps"]

		-- Optional remote attach (for JVMs started with JDWP)
		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Attach to Remote JVM (192.168.56.101)",
				hostName = "192.168.56.101",
				port = 5005,
			},
		}

		vim.schedule(function()
			-- icons
			vim.fn.sign_define("DapBreakpoint", {
				text = "⏺",
				texthl = "DapBreakpoint",
				linehl = "",
				numhl = "",
			})
			vim.fn.sign_define("DapBreakpointCondition", {
				text = "◆",
				texthl = "DapBreakpointCondition",
				linehl = "",
				numhl = "",
			})
			vim.fn.sign_define("DapLogPoint", {
				text = "◆",
				texthl = "DapLogPoint",
				linehl = "",
				numhl = "",
			})
			vim.fn.sign_define("DapStopped", {
				text = "▶",
				texthl = "DapStopped",
				linehl = "DapStoppedLine",
				numhl = "",
			})

			-- highlight colors (TokyoNight style)
			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#f7768e" }) -- red
			vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e0af68" }) -- gold
			vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#7aa2f7" }) -- blue
			vim.api.nvim_set_hl(0, "DapStopped", { fg = "#7aa2f7", bold = true })
			vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#3d2f1f" })
		end)
	end,
}

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

		vim.keymap.set("n", "<leader>bc", function()
			dap.repl.toggle()
		end, { desc = "Toggle DAP REPL" })

		vim.keymap.set("n", "<leader>bg", function()
			dapui.toggle()
		end, { desc = "Toggle DAP UI" })

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
	end,
}

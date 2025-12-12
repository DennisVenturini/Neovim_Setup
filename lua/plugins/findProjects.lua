return {
	"ahmedkhalf/project.nvim",
	event = "VeryLazy",
	config = function()
		-- Setup project.nvim
		require("project_nvim").setup({
			detection_methods = { "pattern" },
			patterns = {
				".git",
			},
			manual_mode = true,
			datapath = vim.fn.stdpath("data"),
			ignore_lsp = false,
		})

		-- Load Telescope integration
		require("telescope").load_extension("projects")

		-- Keymap to open project list
		vim.keymap.set("n", "<leader>sp", "<cmd>Telescope projects<cr>", { desc = "Find project" })
	end,
}

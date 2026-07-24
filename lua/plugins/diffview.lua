return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional, for file icons
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
	keys = {
		{ "<leader>gi", "<cmd>DiffviewOpen development<cr>", desc = "Diff against development" },
		{ "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
	},
	config = true,
}

return {
	"Shatur/neovim-session-manager",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local Path = require("plenary.path")
		require("session_manager").setup({
			sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"),
			autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,
		})
	end,
}

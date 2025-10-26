return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<A-a>]],
				shade_terminals = true,
				direction = "float",
			})

			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

			function _lazygit_toggle()
				lazygit:toggle()
			end

			-- mykeymaps
			vim.keymap.set("n", "<leader>gg", _lazygit_toggle, { noremap = true, silent = true, desc = "Lazy[G]it" })
		end,
	},
}

return {
	-- You can easily change to a different colorscheme.
	-- Change the name of the colorscheme plugin below, and then
	-- change the command in the config to whatever the name of that colorscheme is.
	--
	-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
	"folke/tokyonight.nvim",
	lazy = false, -- will lazily load itself
	priority = 1000, -- Make sure to load this before all the other start plugins.
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("tokyonight").setup({
			styles = {
				comments = { italic = false }, -- Disable italics in comments
			},
		})

		-- Load the colorscheme here.
		-- Like many other themes, this one has different styles, and you could load
		-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
		vim.cmd.colorscheme("tokyonight-night")

		-- 💡 override flash.nvim label color here
		vim.api.nvim_set_hl(0, "FlashLabel", {
			bg = "#f7768e", -- pick any color you like
			fg = "#1a1b26", -- usually your editor background or a contrasting fg
			bold = true,
		})
	end,
}

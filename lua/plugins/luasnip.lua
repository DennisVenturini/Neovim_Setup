return {
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter", -- load when you start typing
		build = (function()
			if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				return
			end
			return "make install_jsregexp"
		end)(),
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					-- load VSCode-style snippets lazily
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		config = function()
			local ls = require("luasnip")
			ls.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = false,
			})
			-- optional: your custom snippet paths
			-- require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/snippets" } })
		end,
	},
}

return {
	-- lua/plugins/luasnip.lua
	"L3MON4D3/LuaSnip",
	build = "make install_jsregexp",
	event = "InsertEnter",
	config = function()
		local ls = require("luasnip")
		local types = require("luasnip.util.types")
		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			delete_check_events = "TextChanged",
			enable_autosnippets = false,

			keep_roots = true,
			link_roots = true,
			link_children = true,

			-- Update more often, :h events for more info.
			update_events = "TextChanged,TextChangedI",
			-- Snippets aren't automatically removed if their text is deleted.
			-- `delete_check_events` determines on which events (:h events) a check for
			-- deleted snippets is performed.
			-- This can be especially useful when `history` is enabled.
			ext_opts = {
				[types.choiceNode] = {
					active = {
						virt_text = { { "choiceNode", "Comment" } },
					},
				},
			},
			-- treesitter-hl has 100, use something higher (default is 200).
			ext_base_prio = 300,
			-- minimal increase in priority.
			ext_prio_increase = 1,
			-- mapping for cutting selected text so it's usable as SELECT_DEDENT,
			-- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
			store_selection_keys = "<Tab>",
			-- luasnip uses this function to get the currently active filetype. This
			-- is the (rather uninteresting) default, but it's possible to use
			-- eg. treesitter for getting the current filetype by setting ft_func to
			-- require("luasnip.extras.filetype_functions").from_cursor (requires
			-- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
			-- the current filetype in eg. a markdown-code block or `vim.cmd()`.
			ft_func = function()
				return vim.split(vim.bo.filetype, ".", true)
			end,
		})

		-- Load snippet files from ~/.config/nvim/lua/snippets/
		require("luasnip.loaders.from_lua").lazy_load({
			paths = vim.fn.stdpath("config") .. "/lua/snippets",
		})

		-- Optional: load VSCode packs if you add friendly-snippets
		-- require("luasnip.loaders.from_vscode").lazy_load()

		-- Choice node navigation
		vim.keymap.set({ "i", "s" }, "<C-l>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { desc = "LuaSnip: next choice" })

		vim.keymap.set({ "i", "s" }, "<C-h>", function()
			if ls.choice_active() then
				ls.change_choice(-1)
			end
		end, { desc = "LuaSnip: prev choice" })
	end,
}

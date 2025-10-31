return {
	"chentoast/marks.nvim",
	event = "BufReadPre",
	config = function()
		require("marks").setup({
			-- Enable built-in keymaps (`m[a-zA-Z]`, `']`, etc.)
			default_mappings = true,

			-- Show built-in marks like . < > ^
			builtin_marks = { ".", "<", ">", "^" },

			-- Cycle through marks when navigating
			cyclic = true,

			-- Don’t constantly write marks to shada (session file)
			force_write_shada = false,

			-- Update mark positions every 250ms (good balance)
			refresh_interval = 250,

			-- Sign priorities — higher = drawn on top
			sign_priority = {
				lower = 10, -- a-z
				upper = 15, -- A-Z
				builtin = 8, -- . < > ^
				bookmark = 20, -- custom bookmark groups
			},

			-- Don’t track marks in these contexts
			excluded_filetypes = { "help", "neo-tree", "lazy", "NvimTree" },
			excluded_buftypes = { "terminal" },

			--------------------------------------------------------------------
			-- Custom bookmark groups (you can have up to 10)
			--------------------------------------------------------------------
			bookmark_0 = {
				sign = "⚑",
				virt_text = "Todo",
				annotate = true, -- prompt for message when setting
			},
			bookmark_1 = {
				sign = "",
				virt_text = "Important",
				annotate = false,
			},
			bookmark_2 = {
				sign = "★",
				virt_text = "Refactor",
				annotate = false,
			},

			-- mykeymaps
			mappings = {
				set_next = "<leader>m,", -- set next available mark
				toggle = "<leader>m;", -- toggle mark at cursor
				delete_line = "<leader>md-", -- delete marks on current line
				delete_buf = "<leader>md<Space>", -- delete all marks in buffer
				next = "<leader>m]", -- jump to next mark
				prev = "<leader>m[", -- jump to previous mark
				preview = "<leader>m:", -- preview mark in a popup
				list_buf = "<leader>m/", -- list marks in buffer
			},
		})
	end,
}

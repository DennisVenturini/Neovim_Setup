return {
	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Easily comment visual regions/lines
	{
		"numToStr/Comment.nvim",
		opts = {},
		config = function()
			local opts = { noremap = true, silent = true }
			-- vim.keymap.set("n", "<C-_>", require("Comment.api").toggle.linewise.current, opts)
			-- vim.keymap.set("n", "<C-c>", require("Comment.api").toggle.linewise.current, opts)
			-- mykeymaps
			vim.keymap.set("n", "<C-p>", require("Comment.api").toggle.linewise.current, opts)
			-- vim.keymap.set(
			-- 	"v",
			-- 	"<C-_>",
			-- 	"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
			-- 	opts
			-- )
			-- vim.keymap.set(
			-- 	"v",
			-- 	"<C-c>",
			-- 	"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
			-- 	opts
			-- )
			vim.keymap.set(
				"v",
				"<C-p>",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				opts
			)
		end,
	},

	-- Standalone plugins with less than 10 lines of config go here
	{
		{ -- Adds git related signs to the gutter, as well as utilities for managing changes
			"lewis6991/gitsigns.nvim",
			opts = {
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			},
		},
		{
			-- Tmux & split window navigation
			--"christoomey/vim-tmux-navigator",
		},
		{
			-- Detect tabstop and shiftwidth automatically
			-- "tpope/vim-sleuth",
		},
		{
			-- Powerful Git integration for Vim
			"tpope/vim-fugitive",
		},
		{
			-- GitHub integration for vim-fugitive
			"tpope/vim-rhubarb",
		},
		{
			-- Hints keybinds
			"folke/which-key.nvim",
			event = "VimEnter",
			opts = {
				delay = 0,
				icons = {
					mappings = vim.g.have_nerd_font,
					keys = vim.g.have_nerd_font or {},
				},

				-- Document existing key chains
				spec = {
					{ "<leader>s", group = "[S]earch" },
					{ "gs", group = "[S]urround" },
					{ "<leader>t", group = "[T]abs & [T]oggle" },
					{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
					{ "<leader>w", group = "[W]rite", mode = { "n", "v" } },
					{ "<leader>l", group = "[L]sp", mode = { "n", "v" } },
					{ "<leader>g", group = "[G]it", mode = { "n", "v" } },
					{ "<leader>u", group = "[U]ndotree", mode = { "n", "v" } },
					{ "<leader>n", group = "[N]oice", mode = { "n", "v" } },
					{ "<leader>j", group = "[J]ava", mode = { "n", "v" } },
					{ "<leader>y", group = "[Y]jump", mode = { "n", "v" } },
					{ "<leader>v", group = "[V]indow Management", mode = { "n", "v" } },
				},
			},
		},
		{
			-- Autoclose parentheses, brackets, quotes, etc.
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
			opts = {},
		},
		{
			-- Highlight todo, notes, etc in comments
			"folke/todo-comments.nvim",
			event = "VimEnter",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = { signs = false },
		},
		{
			"kylechui/nvim-surround",
			version = "*",
			-- Lazy-load on first use and give which-key labels
			-- mykeymaps
			keys = {
				{ "gsa", mode = "n", desc = "Surround [A]dd (operator)" },
				{ "gsl", mode = "n", desc = "Surround current [L]ine" },
				{ "gsb", mode = "n", desc = "Surround line (block)" },
				{ "gsd", mode = "n", desc = "Surround [Delete" },
				{ "gsc", mode = "n", desc = "Surround change" },
				{ "gs", mode = "x", desc = "Surround selection" },
				{ "gs", mode = "x", desc = "Surround selection (line)" },
			},
			config = function()
				require("nvim-surround").setup({
					keymaps = {
						-- normal mode
						normal = "gsa", -- add: gsa + textobject (e.g. gsa iw -> add around inner word)
						normal_cur = "gsl", -- add around current line
						normal_line = "gsb", -- add around line with newlines
						delete = "gsd",
						change = "gsc",
						normal_cur_line = "gsc", -- (you can use a different one if you like)
						-- visual mode
						visual = "gs", -- surround selection
						visual_line = "gs", -- surround selection (line)
						-- delete/change
					},
				})
			end,
		},
		{
			-- High-performance color highlighter
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup()
			end,
		},
	},
}

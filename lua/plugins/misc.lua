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
			"tpope/vim-sleuth",
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
					{ "<leader>t", group = "[T]oggle" },
					{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
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
			-- High-performance color highlighter
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup()
			end,
		},
	},
}

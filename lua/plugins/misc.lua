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
			-- mykeymaps
			vim.keymap.set("n", "<C-p>", require("Comment.api").toggle.linewise.current, opts)
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
			cmd = { "Git", "G", "Gdiffsplit", "Gblame" },
			keys = {
				{ "<leader>gs", "<cmd>Git<CR>", desc = "Git status (Fugitive)" },
				{ "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame" },
				{ "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git diff split" },
			},
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
					{ "<leader>b", group = "De[B]ugger", mode = { "n", "v" } },
					{ "<leader>m", group = "[M]arks", mode = "n" },
				},
			},
		},
		{
			"wurli/visimatch.nvim",
			-- Pass this to require("visimatch").setup() or use it as the `opts` field
			-- in the Lazy.nvim plugin spec above
			opts = {
				-- The highlight group to apply to matched text
				hl_group = "Search",
				-- The minimum number of selected characters required to trigger highlighting
				chars_lower_limit = 6,
				-- The maximum number of selected lines to trigger highlighting for
				lines_upper_limit = 30,
				-- By default, visimatch will highlight text even if it doesn't have exactly
				-- the same spacing as the selected region. You can set this to `true` if
				-- you're not a fan of this behaviour :)
				strict_spacing = false,
				-- Visible buffers which should be highlighted. Valid options:
				-- * `"filetype"` (the default): highlight buffers with the same filetype
				-- * `"current"`: highlight matches in the current buffer only
				-- * `"all"`: highlight matches in all visible buffers
				-- * A function. This will be passed a buffer number and should return
				--   `true`/`false` to indicate whether the buffer should be highlighted.
				buffers = "filetype",
				-- Case-(in)nsitivity for matches. Valid options:
				-- * `true`: matches will never be case-sensitive
				-- * `false`/`{}`: matches will always be case-sensitive
				-- * a table of filetypes to use use case-insensitive matching for.
				case_insensitive = { "markdown", "text", "help" },
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

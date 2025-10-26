return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",

	build = function()
		require("nvim-treesitter").install({
			"lua",
			"python",
			"javascript",
			"typescript",
			"vimdoc",
			"vim",
			"regex",
			"terraform",
			"sql",
			"dockerfile",
			"toml",
			"json",
			"java",
			"groovy",
			"go",
			"gitignore",
			"graphql",
			"yaml",
			"make",
			"cmake",
			"markdown",
			"markdown_inline",
			"bash",
			"tsx",
			"css",
			"html",
			"c",
			"cpp",
		})
		vim.cmd("TSUpdate")
	end,

	config = function()
		-- Optional: call setup if you want to override defaults
		require("nvim-treesitter").setup({
			-- install_dir = vim.fn.stdpath("data") .. "/site",
			auto_install = true,
		})

		-- Optional: auto-start Tree-sitter for every buffer
		local grp = vim.api.nvim_create_augroup("TSMainAutostart", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
			group = grp,
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true, -- enable by default
			max_lines = 6, -- how many lines of context to show (0 = no limit)
			multiline_threshold = 20, -- collapse multiline nodes if over this
			trim_scope = "outer", -- which scope to trim first
			mode = "cursor", -- show context for scope under cursor
			-- separator = "─", -- visual separator below the context header (nil to disable)
			zindex = 40, -- draw above folds/signcolumn
			on_attach = nil, -- function(bufnr) end  to filter filetypes if you like
		},
		config = function(_, opts)
			require("treesitter-context").setup(opts)

			-- mykeymaps
			vim.keymap.set("n", "<leader>yc", function()
				require("treesitter-context").go_to_context()
			end, { desc = "TSContext: jump to parent context" })
			vim.api.nvim_create_user_command("TSContextToggle", function()
				require("treesitter-context").toggle()
			end, { desc = "Toggle Treesitter Context" })
		end,
	},
}

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
}

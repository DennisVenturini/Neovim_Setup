return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format", "ruff_organize_imports", "black" },
				javascript = { "prettierd", "prettier", "biome" },
				typescript = { "prettierd", "prettier", "biome" },
				javascriptreact = { "prettierd", "prettier", "biome" },
				typescriptreact = { "prettierd", "prettier", "biome" },
				json = { "prettierd", "prettier" },
				yaml = { "yamlfmt" },
				go = { "gofumpt", "goimports" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				java = { "astyle" },
				xml = { "xmlformatter" },
				-- ["*"] = { "lsp_format" },
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500, lsp_fallback = false },
			-- Customize formatters
			formatters = {
				shfmt = {
					append_args = { "-i", "2" },
				},
				stylua = {
					command = "stylua",
					args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
					stdin = true,
				},
				astyle = {
					command = "astyle",
					args = { "--options=" .. vim.fn.expand("~/.config/nvim/java_style/astylerc") },
					stdin = true,
				},
				xmlformatter = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/xmlformat"),
					args = { "--indent", "4", "-" }, -- note the trailing '-' for stdin
					stdin = true,
				},
			},
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}

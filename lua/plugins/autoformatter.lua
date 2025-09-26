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
				javascript = { "prettierd", "prettier", "biome" },
				typescript = { "prettierd", "prettier", "biome" },
				javascriptreact = { "prettierd", "prettier", "biome" },
				typescriptreact = { "prettierd", "prettier", "biome" },
				html = { "prettierd", "prettier" },
				css = { "prettierd", "prettier" },

				lua = { "stylua" },
				json = { "prettierd", "prettier" },
				yaml = { "yamlfmt" },
				xml = { "xmlformatter" },
				sh = { "shfmt" },

				python = { "ruff_format", "ruff_organize_imports", "black" },
				go = { "gofumpt", "goimports" },
				rust = { "rustfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				java = { "astyle" },
				-- ["*"] = { "lsp_format" },
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500, lsp_fallback = false },
			-- Customize formatters
			formatters = {
				shfmt = {
					append_args = { "-i", "2" },
				},
				prettier = {
					-- fallback if prettierd is missing
					prepend_args = {
						"--parser",
						"html",
						"--embedded-language-formatting",
						"auto",
						"--tab-width",
						"4",
						"--use-tabs",
						"false",
					},
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

		format_on_save = function(buf)
			local ft = vim.bo[buf].filetype
			if ft == "html" or ft == "css" then
				return { lsp_fallback = false, timeout_ms = 500 }
			end
			return { lsp_fallback = true, timeout_ms = 500 }
		end,
	},
}

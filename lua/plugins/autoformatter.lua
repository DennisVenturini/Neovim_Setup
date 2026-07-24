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
				html = { "prettier" },
				css = { "prettierd", "prettier" },

				lua = { "stylua" },
				json = { "jq" },
				yaml = { "yamlfmt" },
				xml = { "xmlformatter" },
				sh = { "shfmt" },

				python = { "ruff_format", "ruff_organize_imports", "black" },
				go = { "gofumpt", "goimports" },
				rust = { "rustfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },

				-- java = { "astyle" },

				-- ["*"] = { "lsp_format" },
			},
			-- Customize formatters
			formatters = {
				shfmt = {
					append_args = { "-i", "2" },
				},
				jq = {
					command = "jq",
					args = {
						".",
						"--indent",
						"4",
					},
					stdin = true,
				},
				prettier = {
					-- fallback if prettierd is missing
					prepend_args = {
						"--embedded-language-formatting",
						"auto",
						"--tab-width",
						"4",
						"--use-tabs",
						"false",
						"--print-width",
						"160",
						"--single-quote",
						"true",
					},
				},
				prettierd = {
					prepend_args = {
						"--print-width",
						"160",
						"--tab-width",
						"4",
						"--use-tabs",
						"false",
						"--single-quote",
						"true",
						"--embedded-language-formatting",
						"auto",
					},
				},
				stylua = {
					command = "stylua",
					args = {
						"--search-parent-directories", -- still respect project configs
						"--stdin-filepath",
						"$FILENAME", -- for context (used in diagnostics)
						"--config-path",
						"/dev/null", -- ignore on-disk stylua.toml
						"--column-width",
						"160", -- enforce max line length
						"-", -- read from stdin
					},
					stdin = true,
				},
				xmlformatter = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/xmlformat"),
					args = { "--indent", "4", "--blanks", "-" }, -- note the trailing '-' for stdin
					stdin = true,
				},
				-- astyle = {
				-- 	command = "astyle",
				-- 	args = { "--options=" .. vim.fn.expand("~/.config/nvim/java_style/astylerc") },
				-- 	stdin = true,
				-- },

				-- lsp_format = {
				-- 	-- This configuration is minimal, simply tells conform to use LSP formatting.
				-- 	-- You don't need a command or args here.
				-- },
			},
		},

		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			-- Helper function to format ONLY git-modified lines/hunks
			local function format_git_changes()
				local hunks = require("gitsigns").get_hunks()
				if not hunks then
					return
				end

				local format = require("conform").format
				for i = #hunks, 1, -1 do
					local hunk = hunks[i]
					if hunk.type ~= "delete" then
						local start_line = hunk.added.start
						local end_line = start_line + hunk.added.count
						if hunk.added.count == 0 then
							end_line = start_line
						else
							end_line = end_line - 1
						end
						format({
							lsp_fallback = true,
							range = {
								["start"] = { start_line, 0 },
								["end"] = { end_line, 0 },
							},
						})
					end
				end
			end

			-- Keymap 1: `<leader>cf` to Format the ENTIRE file (Normal Mode)
			vim.keymap.set("n", "<leader>cf", function()
				conform.format({ async = true, lsp_fallback = true })
			end, { desc = "Conform: Format whole file" })

			-- Keymap 2: `<leader>cf` to Format ONLY highlighted selection (Visual Mode)
			vim.keymap.set("v", "<leader>cf", function()
				conform.format({ async = true, lsp_fallback = true })
			end, { desc = "Conform: Format selected range" })

			-- Keymap 3: `<leader>cg` to Format ONLY git-modified lines (Normal Mode)
			-- Requires 'lewis6991/gitsigns.nvim' to be installed in your setup!
			vim.keymap.set("n", "<leader>cg", format_git_changes, { desc = "Conform: Format git changes only" })
		end,

		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}

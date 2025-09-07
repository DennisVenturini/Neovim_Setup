return {
	{
		"stevearc/conform.nvim",
		opts = function()
			-- detect google-java-format
			local has_gjf_bin = vim.fn.executable("google-java-format") == 1
			local gjf_jar = vim.fn.expand("~/.local/share/java/google-java-format-1.23.0-all-deps.jar")
			local has_gjf_jar = vim.loop.fs_stat(gjf_jar) ~= nil

			local gjf_fmt
			if has_gjf_bin then
				gjf_fmt = {
					command = "google-java-format",
					args = { "-" },
					stdin = true,
				}
			elseif has_gjf_jar then
				gjf_fmt = {
					command = "java",
					args = { "-jar", gjf_jar, "-" },
					stdin = true,
				}
			else
				-- placeholder: will show unavailable in :ConformInfo
				gjf_fmt = {
					command = "google-java-format",
					args = { "-" },
					stdin = true,
				}
			end

			return {
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
					java = { "google-java-format" }, -- will resolve to gjf_fmt
					["*"] = { "lsp_format" },
				},

				format_on_save = function(bufnr)
					if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
						return
					end
					return { lsp_fallback = true, timeout_ms = 2000 }
				end,

				notify_on_error = true,

				formatters = {
					["google-java-format"] = gjf_fmt,
				},
			}
		end,
	},
}

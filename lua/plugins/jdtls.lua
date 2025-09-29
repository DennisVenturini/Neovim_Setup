-- lua/plugins/jdtls.lua
return {
	"mfussenegger/nvim-jdtls",
	config = function()
		local jdtls = require("jdtls")

		-- Run for EVERY Java buffer
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function(args)
				-- Get path of this buffer
				local bufname = vim.api.nvim_buf_get_name(args.buf)
				if bufname == "" then
					return
				end

				-- Find root based on the buffer's directory (not CWD)
				local dirname = vim.fn.fnamemodify(bufname, ":h")
				local root_dir = require("jdtls.setup").find_root({
					"mvnw",
					"gradlew",
					"pom.xml",
					"build.gradle",
					".git",
				}, dirname) or dirname

				-- Unique workspace per project root
				local project_name = vim.fn.fnamemodify(root_dir, ":t")
				local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspaces/" .. project_name)

				-- Optional: per-buffer on_attach (keys, codelens, etc.)
				local function on_attach(_, bufnr)
					-- helper
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
					end

					-- mykeybinds
					map("<leader>ji", jdtls.organize_imports, "Java: Organize Imports")
					map("<leader>jv", jdtls.extract_variable, "Java: Extract Variable")
					map("<leader>jc", jdtls.extract_constant, "Java: Extract Constant")
					map("<leader>jm", jdtls.extract_method, "Java: Extract Method")

					-- Code lens / test support
					map("<leader>jt", jdtls.test_class, "Java: Test Class")
					map("<leader>jn", jdtls.test_nearest_method, "Java: Test Nearest")

					jdtls.setup_dap({ hotcodereplace = "auto" })
					jdtls.setup.add_commands()
					vim.lsp.codelens.refresh()
					vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
						buffer = bufnr,
						callback = vim.lsp.codelens.refresh,
					})
				end

				-- Start or attach for THIS buffer's project
				jdtls.start_or_attach({
					cmd = { vim.fn.expand("~/.local/bin/jdtls"), workspace_dir },
					root_dir = root_dir,
					on_attach = on_attach,
					settings = {
						java = {
							signatureHelp = { enabled = true },
							eclipse = { downloadSources = true },
							maven = { downloadSources = true },
							import = { gradle = { downloadSources = true } },
							references = { includeDecompiledSources = true },
							format = { enabled = false },
							configuration = {
								runtimes = {
									{ name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk-amd64" },
									{ name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk-amd64", default = true },
								},
							},
						},
					},
					init_options = { bundles = {} },
				})
			end,
		})
	end,
}

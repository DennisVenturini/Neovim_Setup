return {
	"mfussenegger/nvim-jdtls",
	config = function()
		-- absolute path to your shared code style config
		local CODE_STYLE_PATH = "/home/dventurini/IdeaProjects/code-style/"

		-- Helper: read .importorder from global code-style repo
		function read_import_order()
			local order = {}
			local file = io.open(CODE_STYLE_PATH .. "/blackned.importorder", "r")
			if not file then
				vim.notify("⚠️ Could not find .importorder at " .. CODE_STYLE_PATH, vim.log.levels.WARN)
				return { "java", "jakarta", "javax", "org", "com", "com.vaadin", "de.blackned", "*" }
			end
			for line in file:lines() do
				local value = line:match("^%d+=(.*)$")
				if value then
					table.insert(order, value)
				end
			end
			file:close()
			return order
		end

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
					".git",
					"gradlew",
					"pom.xml",
					"build.gradle",
				}, dirname) or dirname

				-- Unique workspace per project root
				local project_name = vim.fn.fnamemodify(root_dir, ":t")
				local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspaces/" .. project_name)

				local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

				local test_bundles = vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar", true), "\n")
				local debug_bundle = vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true)

				-- Filter out the jars that cause OSGi bundleInfo errors
				local filtered_test_bundles = vim.tbl_filter(function(path)
					return not string.find(path, "jacocoagent") and not string.find(path, "jar%-with%-dependencies")
				end, test_bundles)

				local bundles = { debug_bundle }
				vim.list_extend(bundles, filtered_test_bundles)

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
					cmd = {
						"/usr/lib/jvm/java-21-openjdk-amd64/bin/java",
						"-Declipse.application=org.eclipse.jdt.ls.core.id1",
						"-Dosgi.bundles.defaultStartLevel=4",
						"-Declipse.product=org.eclipse.jdt.ls.core.product",
						"-Dlog.protocol=true",
						"-Dlog.level=ALL",
						"-Dlog.protocol=true",
						"-Xms1g",
						"--add-modules=ALL-SYSTEM",
						"--add-opens",
						"java.base/java.util=ALL-UNNAMED",
						"--add-opens",
						"java.base/java.lang=ALL-UNNAMED",
						"-jar",
						vim.fn.glob("~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
						"-configuration",
						vim.fn.glob("~/.local/share/nvim/mason/packages/jdtls/config_linux"),
						"-data",
						workspace_dir,
					},
					root_dir = root_dir,
					on_attach = on_attach,
					settings = {
						java = {
							signatureHelp = { enabled = true },
							eclipse = { downloadSources = true },
							maven = { downloadSources = true },
							import = { gradle = { downloadSources = true } },
							references = { includeDecompiledSources = true },
							format = {
								enabled = true,
								settings = {
									url = "file:///home/dventurini/IdeaProjects/code-style/BlacknedJavaCodeStyle.xml",
								},
							},
							completion = {
								importOrder = read_import_order(),
							},
							imports = {
								separateStaticImports = true,
								organizeImports = true,
							},
							saveActions = {
								organizeImports = true,
							},
							configuration = {
								runtimes = {
									{ name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk-amd64" },
									{ name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk-amd64", default = true },
								},
							},
						},
					},
					init_options = { -- Path to java-debug JAR
						bundles = bundles,
					},
				})
			end,
		})
	end,
}

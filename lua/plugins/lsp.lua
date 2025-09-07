return {
	{
		-- Core LSP client
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			{
				"mason-org/mason-lspconfig.nvim",
				-- v2 style: no handlers; use automatic_enable + optional excludes
				opts = {
					ensure_installed = {
						"clangd",
						"pylsp",
						"html",
						"cssls",
						"jsonls",
						"yamlls",
						"lua_ls",
					},
					automatic_enable = {
						-- auto-enable everything installed by Mason EXCEPT jdtls (we’ll handle Java separately)
						exclude = { "jdtls", "clangd" },
					},
				},
			},
			-- ensure extra tools/formatters via Mason if you like
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", opts = {} },

			-- optional LSP status
			{ "j-hui/fidget.nvim", opts = {} },

			-- blink for capabilities
			"saghen/blink.cmp",
		},

		config = function()
			------------------------------------------------------------------------
			-- LSPAttach: your Kickstart-style keymaps + UX bits
			------------------------------------------------------------------------
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Your mappings
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "[R]eferences")
					map("gri", require("telescope.builtin").lsp_implementations, "[I]mplementation")
					map("grd", require("telescope.builtin").lsp_definitions, "[D]efinition")
					map("grD", vim.lsp.buf.declaration, "[D]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "[T]ype Definition")

					-- Nice diagnostics helpers
					map("[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
					map("<leader>e", function()
						vim.diagnostic.open_float(nil, { border = "rounded" })
					end, "Line Diagnostics")

					-- 0.10 vs 0.11 capability check shim
					local function supports(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- Highlight references on CursorHold
					if
						client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
					then
						local grp = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = grp,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = grp,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = true }),
							callback = function(ev)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "user-lsp-highlight", buffer = ev.buf })
							end,
						})
					end

					-- Toggle inlay hints if supported
					if client and supports(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			------------------------------------------------------------------------
			-- Diagnostic UI
			------------------------------------------------------------------------
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(d)
						return d.message
					end,
				},
			})

			------------------------------------------------------------------------
			-- Capabilities from blink.cmp
			------------------------------------------------------------------------
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			------------------------------------------------------------------------
			-- Manual per-server tweaks (only where you need overrides)
			-- mason-lspconfig v2 auto-enables servers, but we can still call lspconfig
			-- again to add settings/cmd/etc. The last setup wins.
			------------------------------------------------------------------------
			local lspconfig = require("lspconfig")

			-- TypeScript (new name ts_ls)
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})
			-- C/C++
			lspconfig.clangd.setup({
				capabilities = vim.tbl_deep_extend("force", {}, capabilities, { offsetEncoding = { "utf-16" } }),
				keys = {
					{ "grh", "<cmd>ClangdSwitchSourceHeader<CR>", desc = "LSP: Switch Source/Header" },
				},
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.find_git_ancestor(fname)
						or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname)
						or util.path.dirname(fname)
				end,
			})

			-- Python: pylsp (navigation/completion)
			lspconfig.pylsp.setup({
				capabilities = capabilities,
				settings = {
					pylsp = {
						plugins = {
							-- keep pylsp lean; let Ruff handle linting/formatting
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							mccabe = { enabled = false },
							autopep8 = { enabled = false },
							yapf = { enabled = false },
							pylsp_mypy = { enabled = false },
							pylsp_black = { enabled = false },
							pylsp_isort = { enabled = false },
							jedi_completion = { include_params = true },
						},
					},
				},
			})

			-- Web
			lspconfig.html.setup({ capabilities = capabilities })
			lspconfig.cssls.setup({ capabilities = capabilities })
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })

			-- Lua (let conform handle formatting)
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
						diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
						completion = { callSnippet = "Replace" },
						format = { enable = false },
					},
				},
			})

			------------------------------------------------------------------------
			-- Ensure tools are installed (Mason Tool Installer)
			------------------------------------------------------------------------
			local ensure = {
				-- LSPs (Mason package names may differ from lspconfig names; this is fine)
				"clangd",
				"pylsp",
				"lua-language-server",
				"json-lsp",
				"yaml-language-server",
				"html-lsp",
				"css-lsp",
				-- formatters you use with conform
				"stylua",
				"clang-format",
				"ruff",
				-- add more as you like (e.g. "prettierd", "shfmt", "black", "ruff")
			}
			require("mason-tool-installer").setup({ ensure_installed = ensure })
		end,
	},
}

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
						"lemminx",
						"bashls",
						"dockerls",
						"gopls",
						"jdtls",
						"pyright",
						"rust_analyzer",
						"sqlls",
						"tailwindcss",
						"terraformls",
						"ts_ls",
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
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
					end

					local nmode = "n"
					local nxmode = { "n", "x" }
					local nximode = { "n", "x", "i" }
					local telescope = require("telescope.builtin")

					-- mykeymaps
					map(nmode, "<leader>ln", vim.lsp.buf.rename, "Re[n]ame")
					map(nxmode, "<leader>la", vim.lsp.buf.code_action, "Code [A]ction")
					map(nmode, "<leader>lr", telescope.lsp_references, "[R]eferences")
					map(nmode, "<leader>li", telescope.lsp_implementations, "[I]mplementation")
					map(nmode, "<leader>ld", telescope.lsp_definitions, "[D]efinition")
					map(nmode, "<leader>lD", vim.lsp.buf.declaration, "[D]eclaration")
					map(nmode, "<leader>ls", telescope.lsp_document_symbols, "Document [S]ymbols")
					map(nmode, "<leader>lw", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace Symbols")
					map(nmode, "<leader>lt", telescope.lsp_type_definitions, "[T]ype Definition")

					-- Nice diagnostics helpers
					map(nximode, "<C-m>", vim.lsp.buf.signature_help, "Open float signature help")
					map(nmode, "<leader>dp", vim.diagnostic.goto_prev, "[P]rev Diagnostic")
					map(nmode, "<leader>dn", vim.diagnostic.goto_next, "[N]ext Diagnostic")
					map(nmode, "<leader>df", function()
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
						map(nmode, "<leader>th", function()
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

			---------------------------------------------------------------------------------------------------------------------------------------------------------
			-- TypeScript (new name ts_ls)
			vim.lsp.config.ts_ls = {
				capabilities = capabilities,
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				init_options = {
					hostInfo = "neovim",
				},
			}
			vim.lsp.enable("ts_ls")

			-- Web
			vim.lsp.config.html = {
				capabilities = capabilities,
				filetypes = { "html" },
				init_options = {
					provideFormatter = true,
					embeddedLanguages = {
						css = true,
						javascript = true,
					},
				},
			}
			vim.lsp.enable("html")
			vim.lsp.config.cssls = { capabilities = capabilities }
			vim.lsp.enable("cssls")
			vim.lsp.config.jsonls = { capabilities = capabilities }
			vim.lsp.enable("jsonls")
			vim.lsp.config.yamlls = { capabilities = capabilities }
			vim.lsp.enable("yamlls")
			---------------------------------------------------------------------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------------------------------------------------------------------
			-- C/C++
			vim.lsp.config.clangd = {
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
			}
			vim.lsp.enable("clangd")
			---------------------------------------------------------------------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Python: pylsp (navigation/completion)
			vim.lsp.config.pylsp = {
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
			}
			vim.lsp.enable("pylsp")
			---------------------------------------------------------------------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Lua (let conform handle formatting)
			vim.lsp.config.lua_ls = {
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
			}
			vim.lsp.enable("lua_ls")
			---------------------------------------------------------------------------------------------------------------------------------------------------------

			------------------------------------------------------------------------
			-- Ensure tools are installed (Mason Tool Installer)
			------------------------------------------------------------------------
			local ensure = {
				-- LSPs (Mason package names may differ from lspconfig names; this is fine)
				-- "clangd",
				-- "pylsp",
				-- "html-lsp",
				-- "css-lsp",
				-- "json-lsp",
				-- "yaml-language-server",
				-- "lua-language-server",

				-- formatters you use with conform
				"stylua",
				"clang-format",
				"ruff",
				"prettierd",
				"prettier",
				"xmlformatter",
				"checkmake",
				"yamlfmt",
				"shfmt",
				-- add more as you like (e.g. "prettierd", "shfmt", "black", "ruff")
			}
			require("mason-tool-installer").setup({ ensure_installed = ensure })
		end,
	},
}

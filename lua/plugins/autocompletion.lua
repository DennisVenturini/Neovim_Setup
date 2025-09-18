return {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
				event = "InsertEnter", -- load when you start typing
				config = function()
					local ls = require("luasnip")
					ls.config.set_config({
						history = true,
						updateevents = "TextChanged,TextChangedI",
						enable_autosnippets = false,
					})
					-- optional: your custom snippet paths
					require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/snippets" } })
					--
					vim.keymap.set({ "i" }, "<C-n>", function()
						ls.expand()
					end, { silent = true })

					vim.keymap.set({ "i", "s" }, "<C-L>", function()
						ls.jump(1)
					end, { silent = true })

					vim.keymap.set({ "i", "s" }, "<C-J>", function()
						ls.jump(-1)
					end, { silent = true })

					vim.keymap.set({ "i", "s" }, "<C-E>", function()
						if ls.choice_active() then
							ls.change_choice(1)
						end
					end, { silent = true })
				end,
			},
		},
		opts = {
			-- sources like before

			snippets = { preset = "luasnip" },

			sources = {
				default = { "lsp", "path", "buffer", "snippets" },
			},

			signature = { enabled = true },

			-- Kind icons similar to your cmp icons (optional; tweak to taste)
			appearance = {
				kind_icons = {
					Text = "󰉿",
					Method = "m",
					Function = "󰊕",
					Constructor = "",
					Field = "",
					Variable = "󰆧",
					Class = "󰌗",
					Interface = "",
					Module = "",
					Property = "",
					Unit = "",
					Value = "󰎠",
					Enum = "",
					Keyword = "󰌋",
					Snippet = "",
					Color = "󰏘",
					File = "󰈙",
					Reference = "",
					Folder = "󰉋",
					EnumMember = "",
					Constant = "󰇽",
					Struct = "",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "󰊄",
				},
			},

			-- Make the popup show: [icon] label  |  [LSP]/[Snippet]/[Buffer]/[Path]
			completion = {
				menu = {
					border = "rounded",
					draw = {
						-- three “columns”: kind icon, the label (+ optional description), and the source tag
						columns = {
							{ "kind_icon" },
							{ "label", "label_description" },
							{ "source_name" },
						},
						-- customize how the columns render
						components = {
							-- right-aligned source label like your old `menu`
							source_name = {
								text = function(ctx)
									local map = {
										lsp = "[LSP]",
										snippets = "[Snippet]",
										buffer = "[Buffer]",
										path = "[Path]",
									}
									return map[ctx.source_id] or ("[" .. ctx.source_id .. "]")
								end,
								highlight = "Comment", -- dim like a menu tag
							},
						},
					},
				},
				documentation = { window = { border = "single" } },
			},

			-- mykeymaps
			keymap = {
				preset = "none",
				["<C-n>"] = { "select_next" },
				["<C-p>"] = { "select_prev" },
				["<C-b>"] = { "scroll_documentation_up" },
				["<C-f>"] = { "scroll_documentation_down" },
				["<C-i>"] = { "accept" }, -- like cmp.confirm({ select = true })
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

				-- ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				-- ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
				-- ["<C-j>"] = { "snippet_forward", "fallback" },
				-- ["<C-k>"] = { "snippet_backward", "fallback" },
			},
		},
	},
}

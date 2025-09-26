return {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
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

				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-j>"] = { "snippet_forward", "fallback" },
				["<C-k>"] = { "snippet_backward", "fallback" },
			},
		},
	},
}

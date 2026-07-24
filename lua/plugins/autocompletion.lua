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

			cmdline = {
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
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

			fuzzy = {
				implementation = "prefer_rust_with_warning",

				max_typos = function(keyword)
					return math.floor(#keyword / 10)
				end,
				prebuilt_binaries = {
					-- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`,
					-- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
					-- Disabled by default when `fuzzy.implementation = 'lua'`
					download = true,
				},
			},

			-- Make the popup show: [icon] label  |  [LSP]/[Snippet]/[Buffer]/[Path]
			completion = {
				keyword = {
					range = "full",
				},
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
				documentation = { auto_show = true, auto_show_delay_ms = 100, window = { border = "single" } },
				ghost_text = { enabled = true },
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

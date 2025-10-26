return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = { -- or "cmdline"
				enabled = true,
				view = "cmdline_popup",
			},
			messages = { -- shows things like “recording @q”
				enabled = true,
				view = "mini",
				view_error = "mini",
				view_warn = "mini",
			},
			notify = {
				enabled = true,
				view = "mini", -- route vim.notify(*) here too
			},
			views = {
				mini = {
					timeout = 2500,
				},
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					view = "notify",
					filter = {
						event = "msg_showmode",
						any = {
							{ event = "msg_show" },
							{ event = "msg_showmode" }, -- e.g. "recording @a"
							{ event = "notify" },
							{ event = "lsp", kind = "message" },
						},
					},
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = false,
			},
		},
        -- stylua: ignore
        keys = {
            -- mykeymaps
        { "<leader>n", "", desc = "+noice"},
        { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
        { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
        { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },
        { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
        { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
        { "<leader>nt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
        { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
        { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
        },
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},
}

return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,

	config = function()
		require("tokyonight").setup({
			styles = {
				comments = { italic = false },
			},

			on_highlights = function(hl, colors)
				-- 🟦 make relative line numbers a soft blue
				hl.LineNr = { fg = colors.blue }

				-- 🟧 make current line number pop (orange, bold)
				hl.CursorLineNr = { fg = colors.orange, bold = true }

				-- Optional: subtle background highlight for current line
				hl.CursorLine = { bg = "#1f2335" }

				-- (Keep your custom label color override here too)
				hl.FlashLabel = {
					bg = "#f7768e",
					fg = colors.bg,
					bold = true,
				}
			end,
		})

		vim.cmd.colorscheme("tokyonight-night")

		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy", -- fires when Lazy.nvim has finished loading every plugin
			callback = function()
				-- relative line numbers (Neovim ≥ 0.10)
				vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#73daca" })
				vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#73daca" })
				vim.api.nvim_set_hl(0, "LineNr", { fg = "#73daca" })
				vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bold = true })
				vim.api.nvim_set_hl(0, "SignColumn", { fg = "#73daca" })

				-- gitsigns + diagnostics so they survive reloads
				vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#7dcfff" })
				vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e0af68" })
				vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f7768e" })
				vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#73daca" })
				vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#7dcfff" })
				vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e0af68" })
				vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#f7768e" })
			end,
		})
	end,
}

---@type luasnip
local lua_Snip = require("luasnip")
local helper = require("snippets.helpers")
-- some shorthands...
local snippet = require("luasnip").snippet
local snippet_Node = require("luasnip").snippet_node
local text_Node = require("luasnip").text_node
local insert_Node = require("luasnip").insert_node
local function_Node = require("luasnip").function_node
local choice_Node = require("luasnip").choice_node
local dynamic_Node = require("luasnip").dynamic_node
local restore_Node = require("luasnip").restore_node
local lambda = require("luasnip.extras").lambda
local extras = require("luasnip.extras")
local rep = require("luasnip.extras").rep
local partial = require("luasnip.extras").partial
local match = require("luasnip.extras").match
local non_Empty = require("luasnip.extras").nonempty
local dynamic_Lambda = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

return {
	snippet("space_with_line", {
		text_Node({
			"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
			"",
			"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
		}),
	}),

	snippet("wrap_snippet_node", {
		text_Node("snippet_Node(nil, {"),
		text_Node({ "", "\t" }),

		-- Insert node before selection
		insert_Node(1, ""),

		-- Put the visual selection here
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "})" }),
	}),

	snippet("snippet", {
		text_Node('snippet("'),
		insert_Node(1, "name"),

		text_Node({ '", {', "\t" }),

		insert_Node(2, ""),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		snippet_Node(nil, {
			text_Node({ "", "})," }),
		}),
	}),

	snippet("snippet_node", {
		text_Node("snippet_Node("),

		choice_Node(1, {
			snippet_Node(nil, {
				insert_Node(1, "nil"),
			}),

			snippet_Node(nil, {
				insert_Node(1, "position"),
			}),
		}),

		text_Node({ ", {", "\t" }),

		insert_Node(2, ""),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "})," }),
	}),

	-- snip function
	snippet("function", {
		insert_Node(1, "name"),
		text_Node({ " = function()", "\t" }),
		insert_Node(2),
		choice_Node(3, {
			text_Node({ "", "end" }),
			text_Node({ "", "end," }),
		}),
	}),

	-- snip return plugins
	snippet("return", {
		text_Node({ "return {", "\t" }),

		insert_Node(1),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "}" }),
	}),
}

local lua_Snip = require("luasnip")
local helper = require("snippets.helpers")
-- some shorthands...
local snippet = lua_Snip.snippet
local snippet_Node = lua_Snip.snippet_node
local text_Node = lua_Snip.text_node
local insert_Node = lua_Snip.insert_node
local function_Node = lua_Snip.function_node
local choice_Node = lua_Snip.choice_node
local dynamic_Node = lua_Snip.dynamic_node
local restore_Node = lua_Snip.restore_node
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
	snippet("wrap", {
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

	snippet("sni", {
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

	snippet("snode", {
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
	snippet("fn", {
		insert_Node(1, "name"),
		text_Node({ " = function()", "\t" }),
		insert_Node(2),
		choice_Node(3, {
			text_Node({ "", "end" }),
			text_Node({ "", "end," }),
		}),
	}),

	-- snip return plugins
	snippet("ret", {
		text_Node({ "return {", "\t" }),

		insert_Node(1),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "}" }),
	}),
}

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

	snippet("annotation", {
		text_Node("@"),
		insert_Node(1, "name"),

		choice_Node(2, {
			snippet_Node(nil, {
				text_Node("("),
				insert_Node(1, "single"),

				text_Node(")"),
			}),

			snippet_Node(nil, {
				insert_Node(1, ""),
			}),
		}),
	}),

	snippet("var", {
		choice_Node(1, {
			text_Node(""),
			text_Node("final "),
		}),

		insert_Node(2, ""),
		text_Node(" "),
		insert_Node(3, ""),
		text_Node(" = "),

		insert_Node(4, ""),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),
		text_Node({ ";", "" }),
	}),

	snippet("switch", {
		text_Node("switch ("),
		insert_Node(1, "expression"),

		text_Node(") {"),

		snippet_Node(2, {
			dynamic_Node(1, helper.switch_body, {}),
			dynamic_Node(2, helper.recursive_switch_body, {}),
		}),

		text_Node({ "", "}", "" }),
		insert_Node(0, ""),
	}),

	snippet("if", {
		text_Node("if ("),

		dynamic_Node(1, helper.if_conditionals, {}),

		choice_Node(2, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				dynamic_Node(1, helper.recursive_if_conditionals, {}),
			}),
		}),

		text_Node({ ") {", "\t" }),

		insert_Node(3, ""),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "}" }),

		choice_Node(4, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node(" else if("),
			}),
		}),
	}),

	snippet("class", {
		choice_Node(1, {
			text_Node("public "),
			text_Node("private "),
			text_Node("protected "),
		}),

		choice_Node(2, {
			text_Node(""),
			text_Node("static "),
		}),

		text_Node("class "),
		insert_Node(3, "name"),
		text_Node(" "),

		choice_Node(4, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node("extends "),
				insert_Node(1, "name"),
				text_Node(" "),
			}),
		}),

		choice_Node(5, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node("implements "),
				insert_Node(1, "name"),
				dynamic_Node(2, helper.recursive_insert_with_comma, {}),
			}),
		}),

		text_Node({ "{", "\t" }),

		insert_Node(6, "body"),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node({ "", "}" }),
	}),

	-- Snip Public private protected static final String
	snippet("pfss", {
		choice_Node(1, {
			text_Node("public "),
			text_Node("private "),
			text_Node("protected "),
		}),
		choice_Node(2, {
			text_Node(""),
			text_Node("static "),
		}),
		choice_Node(3, {
			text_Node(""),
			text_Node("final "),
		}),
		choice_Node(4, {
			text_Node(""),
			text_Node("String "),
		}),
	}),

	-- Snip Public private protected static final
	snippet("pfs", {
		choice_Node(1, {
			text_Node("public "),
			text_Node("private "),
			text_Node("protected "),
		}),
		choice_Node(2, {
			text_Node(""),
			text_Node("static "),
		}),
		choice_Node(3, {
			text_Node(""),
			text_Node("final "),
		}),
	}),

	-- Snip ArrayList
	snippet("lar", {
		text_Node("ArrayList<"),
		insert_Node(1, "class"),
		function_Node(function(_, snip)
			return snip.env.SELECT_DEDENT or ""
		end, {}),

		text_Node("> "),
		insert_Node(2, "name"),

		choice_Node(3, {
			snippet_Node(nil, {
				text_Node(";"),
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node(" = "),
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node(" = new ArrayList<>();"),
				insert_Node(1, ""),
			}),
		}),
	}),
}

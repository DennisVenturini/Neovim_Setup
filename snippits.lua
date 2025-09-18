local lua_Snip = require("luasnip")
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

-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.

-- Every unspecified option will be set to the default.
lua_Snip.setup({
	keep_roots = true,
	link_roots = true,
	link_children = true,

	-- Update more often, :h events for more info.
	update_events = "TextChanged,TextChangedI",
	-- Snippets aren't automatically removed if their text is deleted.
	-- `delete_check_events` determines on which events (:h events) a check for
	-- deleted snippets is performed.
	-- This can be especially useful when `history` is enabled.
	delete_check_events = "TextChanged",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
	enable_autosnippets = true,
	-- mapping for cutting selected text so it's usable as SELECT_DEDENT,
	-- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
	store_selection_keys = "<Tab>",
	-- luasnip uses this function to get the currently active filetype. This
	-- is the (rather uninteresting) default, but it's possible to use
	-- eg. treesitter for getting the current filetype by setting ft_func to
	-- require("luasnip.extras.filetype_functions").from_cursor (requires
	-- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
	-- the current filetype in eg. a markdown-code block or `vim.cmd()`.
	ft_func = function()
		return vim.split(vim.bo.filetype, ".", true)
	end,
})

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
	return args[1]
end

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
	return snippet_Node(
		nil,
		choice_Node(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			text_Node(""),
			snippet_Node(nil, { text_Node({ "", "\t\\item " }), insert_Node(1), dynamic_Node(2, rec_ls, {}) }),
		})
	)
end

-- complicated function for dynamicNode.
local function jdocsnip(args, _, old_state)
	-- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
	-- Using a restoreNode instead is much easier.
	-- View this only as an example on how old_state functions.
	local nodes = {
		text_Node({ "/**", " * " }),
		insert_Node(1, "A short Description"),
		text_Node({ "", "" }),
	}

	-- These will be merged with the snippet; that way, should the snippet be updated,
	-- some user input eg. text can be referred to in the new snippet.
	local param_nodes = {}

	if old_state then
		nodes[2] = insert_Node(1, old_state.descr:get_text())
	end
	param_nodes.descr = nodes[2]

	-- At least one param.
	if string.find(args[2][1], ", ") then
		vim.list_extend(nodes, { text_Node({ " * ", "" }) })
	end

	local insert = 2
	for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
		-- Get actual name parameter.
		arg = vim.split(arg, " ", true)[2]
		if arg then
			local inode
			-- if there was some text in this parameter, use it as static_text for this new snippet.
			if old_state and old_state[arg] then
				inode = insert_Node(insert, old_state["arg" .. arg]:get_text())
			else
				inode = insert_Node(insert)
			end
			vim.list_extend(nodes, { text_Node({ " * @param " .. arg .. " " }), inode, text_Node({ "", "" }) })
			param_nodes["arg" .. arg] = inode

			insert = insert + 1
		end
	end

	if args[1][1] ~= "void" then
		local inode
		if old_state and old_state.ret then
			inode = insert_Node(insert, old_state.ret:get_text())
		else
			inode = insert_Node(insert)
		end

		vim.list_extend(nodes, { text_Node({ " * ", " * @return " }), inode, text_Node({ "", "" }) })
		param_nodes.ret = inode
		insert = insert + 1
	end

	if vim.tbl_count(args[3]) ~= 1 then
		local exc = string.gsub(args[3][2], " throws ", "")
		local ins
		if old_state and old_state.ex then
			ins = insert_Node(insert, old_state.ex:get_text())
		else
			ins = insert_Node(insert)
		end
		vim.list_extend(nodes, { text_Node({ " * ", " * @throws " .. exc .. " " }), ins, text_Node({ "", "" }) })
		param_nodes.ex = ins
		insert = insert + 1
	end

	vim.list_extend(nodes, { text_Node({ " */" }) })

	local snip = snippet_Node(nil, nodes)
	-- Error on attempting overwrite.
	snip.old_state = param_nodes
	return snip
end

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

-- Returns a snippet_node wrapped around an insertNode whose initial
-- text value is set to the current date in the desired format.
local date_input = function(args, snip, old_state, fmt)
	local fmt = fmt or "%Y-%m-%d"
	return snippet_Node(nil, insert_Node(1, os.date(fmt)))
end

-- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
-- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
-- for snippets that should expand directly after the trigger is typed).
--
-- opts can also specify a key. By passing an unique key to each add_snippets, it's possible to reload snippets by
-- re-`:luafile`ing the file in which they are defined (eg. this one).
lua_Snip.add_snippets("all", {
	-- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
	snippet("fn", {
		-- Simple static text.
		text_Node("//Parameters: "),
		-- function, first parameter is the function, second the Placeholders
		-- whose text it gets as input.
		function_Node(copy, 2),
		text_Node({ "", "function " }),
		-- Placeholder/Insert.
		insert_Node(1),
		text_Node("("),
		-- Placeholder with initial text.
		insert_Node(2, "int foo"),
		-- Linebreak
		text_Node({ ") {", "\t" }),
		-- Last Placeholder, exit Point of the snippet.
		insert_Node(0),
		text_Node({ "", "}" }),
	}),
	snippet("class", {
		-- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
		choice_Node(1, {
			text_Node("public "),
			text_Node("private "),
		}),
		text_Node("class "),
		insert_Node(2),
		text_Node(" "),
		choice_Node(3, {
			text_Node("{"),
			-- sn: Nested Snippet. Instead of a trigger, it has a position, just like insertNodes. !!! These don't expect a 0-node!!!!
			-- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
			snippet_Node(nil, {
				text_Node("extends "),
				-- restoreNode: stores and restores nodes.
				-- pass position, store-key and nodes.
				restore_Node(1, "other_class", insert_Node(1)),
				text_Node(" {"),
			}),
			snippet_Node(nil, {
				text_Node("implements "),
				-- no need to define the nodes for a given key a second time.
				restore_Node(1, "other_class"),
				text_Node(" {"),
			}),
		}),
		text_Node({ "", "\t" }),
		insert_Node(0),
		text_Node({ "", "}" }),
	}),
	-- Alternative printf-like notation for defining snippets. It uses format
	-- string with placeholders similar to the ones used with Python's .format().
	snippet(
		"fmt1",
		fmt("To {title} {} {}.", {
			insert_Node(2, "Name"),
			insert_Node(3, "Surname"),
			title = choice_Node(1, { text_Node("Mr."), text_Node("Ms.") }),
		})
	),
	-- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
	-- Multi-line format strings by default have empty first/last line removed.
	-- Indent common to all lines is also removed. Use the third `opts` argument
	-- to control this behaviour.
	snippet(
		"fmt2",
		fmt(
			[[
		foo({1}, {3}) {{
			return {2} * {4}
		}}
		]],
			{
				insert_Node(1, "x"),
				rep(1),
				insert_Node(2, "y"),
				rep(2),
			}
		)
	),
	-- Empty placeholders are numbered automatically starting from 1 or the last
	-- value of a numbered placeholder. Named placeholders do not affect numbering.
	snippet(
		"fmt3",
		fmt("{} {a} {} {1} {}", {
			text_Node("1"),
			text_Node("2"),
			a = text_Node("A"),
		})
	),
	-- The delimiters can be changed from the default `{}` to something else.
	snippet("fmt4", fmt("foo() { return []; }", insert_Node(1, "x"), { delimiters = "[]" })),
	-- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
	snippet("fmt5", fmta("foo() { return <>; }", insert_Node(1, "x"))),
	-- By default all args must be used. Use strict=false to disable the check
	snippet("fmt6", fmt("use {} only", { text_Node("this"), text_Node("not this") }, { strict = false })),
	-- Use a dynamicNode to interpolate the output of a
	-- function (see date_input above) into the initial
	-- value of an insertNode.
	snippet("novel", {
		text_Node("It was a dark and stormy night on "),
		dynamic_Node(1, date_input, {}, { user_args = { "%A, %B %d of %Y" } }),
		text_Node(" and the clocks were striking thirteen."),
	}),
	-- Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
	-- Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty string.
	-- This means they are not SELECTed like in other editors/Snippet engines.
	lua_Snip.parser.parse_snippet("lspsyn", "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"),

	-- When wordTrig is set to false, snippets may also expand inside other words.
	lua_Snip.parser.parse_snippet({ trig = "te", wordTrig = false }, "${1:cond} ? ${2:true} : ${3:false}"),

	-- When regTrig is set, trig is treated like a pattern, this snippet will expand after any number.
	lua_Snip.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
	-- Using the condition, it's possible to allow expansion only in specific cases.
	snippet("cond", {
		text_Node("will only expand in c-style comments"),
	}, {
		condition = function(line_to_cursor, matched_trigger, captures)
			-- optional whitespace followed by //
			return line_to_cursor:match("%s*//")
		end,
	}),
	-- there's some built-in conditions in "luasnip.extras.conditions.expand" and "luasnip.extras.conditions.show".
	snippet("cond2", {
		text_Node("will only expand at the beginning of the line"),
	}, {
		condition = conds_expand.line_begin,
	}),
	snippet("cond3", {
		text_Node("will only expand at the end of the line"),
	}, {
		condition = conds_expand.line_end,
	}),
	-- on conditions some logic operators are defined
	snippet("cond4", {
		text_Node("will only expand at the end and the start of the line"),
	}, {
		-- last function is just an example how to make own function objects and apply operators on them
		condition = conds_expand.line_end + conds_expand.line_begin * conds.make_condition(function()
			return true
		end),
	}),
	-- The last entry of args passed to the user-function is the surrounding snippet.
	snippet(
		{ trig = "a%d", regTrig = true },
		function_Node(function(_, snip)
			return "Triggered with " .. snip.trigger .. "."
		end, {})
	),
	-- It's possible to use capture-groups inside regex-triggers.
	snippet(
		{ trig = "b(%d)", regTrig = true },
		function_Node(function(_, snip)
			return "Captured Text: " .. snip.captures[1] .. "."
		end, {})
	),
	snippet({ trig = "c(%d+)", regTrig = true }, {
		text_Node("will only expand for even numbers"),
	}, {
		condition = function(line_to_cursor, matched_trigger, captures)
			return tonumber(captures[1]) % 2 == 0
		end,
	}),
	-- Use a function to execute any shell command and print its text.
	snippet("bash", function_Node(bash, {}, { user_args = { "ls" } })),
	-- Short version for applying String transformations using function nodes.
	snippet("transform", {
		insert_Node(1, "initial text"),
		text_Node({ "", "" }),
		-- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
		-- This list will be applied in order to the first node given in the second argument.
		lambda(lambda._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
	}),

	snippet("transform2", {
		insert_Node(1, "initial text"),
		text_Node("::"),
		insert_Node(2, "replacement for e"),
		text_Node({ "", "" }),
		-- Lambdas can also apply transforms USING the text of other nodes:
		lambda(lambda._1:gsub("e", lambda._2), { 1, 2 }),
	}),
	snippet({ trig = "trafo(%d+)", regTrig = true }, {
		-- env-variables and captures can also be used:
		lambda(lambda.CAPTURE1:gsub("1", lambda.TM_FILENAME), {}),
	}),
	-- Set store_selection_keys = "<Tab>" (for example) in your
	-- luasnip.config.setup() call to populate
	-- TM_SELECTED_TEXT/SELECT_RAW/SELECT_DEDENT.
	-- In this case: select a URL, hit Tab, then expand this snippet.
	snippet("link_url", {
		text_Node('<a href="'),
		function_Node(function(_, snip)
			-- TM_SELECTED_TEXT is a table to account for multiline-selections.
			-- In this case only the first line is inserted.
			return snip.env.TM_SELECTED_TEXT[1] or {}
		end, {}),
		text_Node('">'),
		insert_Node(1),
		text_Node("</a>"),
		insert_Node(0),
	}),
	-- Shorthand for repeating the text in a given node.
	snippet("repeat", { insert_Node(1, "text"), text_Node({ "", "" }), rep(1) }),
	-- Directly insert the ouput from a function evaluated at runtime.
	snippet("part", partial(os.date, "%Y")),
	-- use matchNodes (`m(argnode, condition, then, else)`) to insert text
	-- based on a pattern/function/lambda-evaluation.
	-- It's basically a shortcut for simple functionNodes:
	snippet("mat", {
		insert_Node(1, { "sample_text" }),
		text_Node(": "),
		match(1, "%d", "contains a number", "no number :("),
	}),
	-- The `then`-text defaults to the first capture group/the entire
	-- match if there are none.
	snippet("mat2", {
		insert_Node(1, { "sample_text" }),
		text_Node(": "),
		match(1, "[abc][abc][abc]"),
	}),
	-- It is even possible to apply gsubs' or other transformations
	-- before matching.
	snippet("mat3", {
		insert_Node(1, { "sample_text" }),
		text_Node(": "),
		match(1, lambda._1:gsub("[123]", ""):match("%d"), "contains a number that isn't 1, 2 or 3!"),
	}),
	-- `match` also accepts a function in place of the condition, which in
	-- turn accepts the usual functionNode-args.
	-- The condition is considered true if the function returns any
	-- non-nil/false-value.
	-- If that value is a string, it is used as the `if`-text if no if is explicitly given.
	snippet("mat4", {
		insert_Node(1, { "sample_text" }),
		text_Node(": "),
		match(1, function(args)
			-- args is a table of multiline-strings (as usual).
			return (#args[1][1] % 2 == 0 and args[1]) or nil
		end),
	}),
	-- The nonempty-node inserts text depending on whether the arg-node is
	-- empty.
	snippet("nempty", {
		insert_Node(1, "sample_text"),
		non_Empty(1, "i(1) is not empty!"),
	}),
	-- dynamic lambdas work exactly like regular lambdas, except that they
	-- don't return a textNode, but a dynamicNode containing one insertNode.
	-- This makes it easier to dynamically set preset-text for insertNodes.
	snippet("dl1", {
		insert_Node(1, "sample_text"),
		text_Node({ ":", "" }),
		dynamic_Lambda(2, lambda._1, 1),
	}),
	-- Obviously, it's also possible to apply transformations, just like lambdas.
	snippet("dl2", {
		insert_Node(1, "sample_text"),
		insert_Node(2, "sample_text_2"),
		text_Node({ "", "" }),
		dynamic_Lambda(3, lambda._1:gsub("\n", " linebreak ") .. lambda._2, { 1, 2 }),
	}),
}, {
	key = "all",
})

lua_Snip.add_snippets("java", {
	-- Very long example for a java class.
	snippet("fn", {
		dynamic_Node(6, jdocsnip, { 2, 4, 5 }),
		text_Node({ "", "" }),
		choice_Node(1, {
			text_Node("public "),
			text_Node("private "),
		}),
		choice_Node(2, {
			text_Node("void"),
			text_Node("String"),
			text_Node("char"),
			text_Node("int"),
			text_Node("double"),
			text_Node("boolean"),
			insert_Node(nil, ""),
		}),
		text_Node(" "),
		insert_Node(3, "myFunc"),
		text_Node("("),
		insert_Node(4),
		text_Node(")"),
		choice_Node(5, {
			text_Node(""),
			snippet_Node(nil, {
				text_Node({ "", " throws " }),
				insert_Node(1),
			}),
		}),
		text_Node({ " {", "\t" }),
		insert_Node(0),
		text_Node({ "", "}" }),
	}),
}, {
	key = "java",
})

lua_Snip.add_snippets("tex", {
	-- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
	-- \item as necessary by utilizing a choiceNode.
	snippet("ls", {
		text_Node({ "\\begin{itemize}", "\t\\item " }),
		insert_Node(1),
		dynamic_Node(2, rec_ls, {}),
		text_Node({ "", "\\end{itemize}" }),
	}),
}, {
	key = "tex",
})

-- set type to "autosnippets" for adding autotriggered snippets.
lua_Snip.add_snippets("all", {
	snippet("autotrigger", {
		text_Node("autosnippet"),
	}),
}, {
	type = "autosnippets",
	key = "all_auto",
})

-- in a lua file: search lua-, then c-, then all-snippets.
lua_Snip.filetype_extend("lua", { "c" })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
lua_Snip.filetype_set("cpp", { "c" })

-- Beside defining your own snippets you can also load snippets from "vscode-like" packages
-- that expose snippets in json files, for example <https://github.com/rafamadriz/friendly-snippets>.

require("luasnip.loaders.from_vscode").load({ include = { "python" } }) -- Load only python snippets

-- The directories will have to be structured like eg. <https://github.com/rafamadriz/friendly-snippets> (include
-- a similar `package.json`)
require("luasnip.loaders.from_vscode").load({ paths = { "./my-snippets" } }) -- Load snippets from my-snippets folder

-- You can also use lazy loading so snippets are loaded on-demand, not all at once (may interfere with lazy-loading luasnip itself).
require("luasnip.loaders.from_vscode").lazy_load() -- You can pass { paths = "./my-snippets/"} as well

-- You can also use snippets in snipmate format, for example <https://github.com/honza/vim-snippets>.
-- The usage is similar to vscode.

-- One peculiarity of honza/vim-snippets is that the file containing global
-- snippets is _.snippets, so we need to tell luasnip that the filetype "_"
-- contains global snippets:
lua_Snip.filetype_extend("all", { "_" })

require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only snippets for c.

-- Load snippets from my-snippets folder
-- The "." refers to the directory where of your `$MYVIMRC` (you can print it
-- out with `:lua print(vim.env.MYVIMRC)`.
-- NOTE: It's not always set! It isn't set for example if you call neovim with
-- the `-u` argument like this: `nvim -u yeet.txt`.
require("luasnip.loaders.from_snipmate").load({ path = { "./my-snippets" } })
-- If path is not specified, luasnip will look for the `snippets` directory in rtp (for custom-snippet probably
-- `~/.config/nvim/snippets`).

require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading

-- see DOC.md/LUA SNIPPETS LOADER for some details.
require("luasnip.loaders.from_lua").load({ include = { "c" } })
require("luasnip.loaders.from_lua").lazy_load({ include = { "all", "cpp" } })

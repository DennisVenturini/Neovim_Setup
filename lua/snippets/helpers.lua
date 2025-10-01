local lua_Snip = require("luasnip")
-- some shorthands...
local snippet_Node = lua_Snip.snippet_node
local text_Node = lua_Snip.text_node
local insert_Node = lua_Snip.insert_node
local choice_Node = lua_Snip.choice_node
local dynamic_Node = lua_Snip.dynamic_node

local helper = {}

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
function helper.copy(args)
	return args[1]
end

helper.recursive_insert_with_comma = function()
	return snippet_Node(nil, {
		choice_Node(1, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				text_Node(", "),
				insert_Node(1, "name"),
				dynamic_Node(2, helper.recursive_insert_with_comma, {}),
			}),
		}),
	})
end

helper.if_conditionals = function()
	return snippet_Node(nil, {
		choice_Node(nil, {
			insert_Node(1, ""),
			text_Node("!"),
		}),

		choice_Node(nil, {
			snippet_Node(nil, {
				insert_Node(1, "single boolean"),
			}),

			snippet_Node(nil, {
				insert_Node(1, "conditional"),

				choice_Node(2, {
					text_Node(" == "),
					text_Node(" !="),
					text_Node(" > "),
					text_Node(" >= "),
					text_Node(" <  "),
					text_Node(" <= "),
				}),

				choice_Node(3, {
					text_Node(""),
					text_Node("!"),
				}),
				insert_Node(4, "conditional"),
			}),
		}),
	})
end

helper.recursive_if_conditionals = function()
	return snippet_Node(nil, {
		choice_Node(1, {
			snippet_Node(nil, {
				insert_Node(1, ""),
			}),

			snippet_Node(nil, {
				insert_Node(1, ""),
				choice_Node(2, {
					text_Node(" && "),
					text_Node(" || "),
				}),

				choice_Node(3, {
					insert_Node(1, ""),
					text_Node("!"),
				}),

				choice_Node(4, {
					snippet_Node(nil, {
						insert_Node(1, "single boolean"),
					}),

					snippet_Node(nil, {
						insert_Node(1, "conditional"),

						choice_Node(2, {
							text_Node(" == "),
							text_Node(" !="),
							text_Node(" > "),
							text_Node(" >= "),
							text_Node(" <  "),
							text_Node(" <= "),
						}),

						choice_Node(3, {
							text_Node(""),
							text_Node("!"),
						}),
						insert_Node(4, "conditional"),
					}),
				}),

				dynamic_Node(5, helper.recursive_if_conditionals, {}),
			}),
		}),
	})
end

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
helper.rec_ls = function()
	return snippet_Node(
		nil,
		choice_Node(2, {
			snippet_Node(nil, {}), -- empty choice: stop recursion safely
			snippet_Node(nil, {
				text_Node({ "", "\t\\item " }),
				insert_Node(1),
				dynamic_Node(2, helper.rec_ls, {}),
			}),
		})
	)
end

-- complicated function for dynamicNode.
function helper.jdocsnip(args, _, old_state)
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
function helper.bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

-- Returns a snippet_node wrapped around an insertNode whose initial
-- text value is set to the current date in the desired format.
helper.date_input = function(args, snip, old_state, fmt)
	local fmt = fmt or "%Y-%m-%d"
	return snippet_Node(nil, insert_Node(1, os.date(fmt)))
end

return helper

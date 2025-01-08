-- Example popup menu using vim.fn.complete()
local items = {
	{ word = "apple", menu = "[Fruit]", info = "A tasty fruit" },
	{ word = "banana", menu = "[Fruit]", info = "Yellow and healthy" },
	{ word = "carrot", menu = "[Vegetable]", info = "Good for vision" },
}

-- Trigger the popup menu with the above items

vim.keymap.set("i", "<leader>;", function()
	vim.fn.complete(vim.fn.col("."), items)
end, { noremap = true })

vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end)

-- Load LuaSnip
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

-- Example 1: Basic Function Snippet
ls.add_snippets("javascript", {
	s("func", { -- Trigger word: "func"
		t("function "),
		i(1, "myFunction"),
		t("("),
		i(2, "args"),
		t(") {"),
		t({ "", "\t" }),
		i(3, "body"),
		t({ "", "}" }),
	}),
})

-- Example 2: Choice Node Snippet (Dropdown menu)
ls.add_snippets("javascript", {
	s("clgc", { -- Trigger word: "clgc"
		t("console.log("),
		c(1, { t("message"), t("object"), t("variable") }), -- Choices: message, object, variable
		t(");"),
	}),
})
-- ls.add_snippets("javascript", {
-- 	s("clgc", {
-- 		t("console.log("),
-- 		i(1, "2"), -- Placeholder for the first number or left side of the expression
-- 		t(" + "),
-- 		i(2, "3"), -- Placeholder for the second number or right side of the expression
-- 		t(")"),
-- 	}),
-- })

-- vim.keymap.set({ "i", "s" }, "<C-l>", function()
--   if ls.choice_active() then
--     ls.change_choice(1)
--   end
-- end)
-- vim.keymap.set({ "i", "s" }, "<C-h>", function()
--   if ls.choice_active() then
--  ls.change_choice(-1)
--  end
-- end)
-- Example 3: Multiple Placeholders
ls.add_snippets("javascript", {
	s("fn", { -- Trigger word: "fn"
		t("function "),
		i(1, "name"),
		t("("),
		i(2, "args"),
		t(") {"),
		t({ "", "\t" }),
		i(3, "body"),
		t({ "", "}" }),
	}),
})

-- Example 4: Dynamic Date (with Lua)
ls.add_snippets("javascript", {
	s("date", {
		t("// "),
		f(function()
			return os.date("%Y-%m-%d") -- Inserts the current date
		end, {}),
	}),
})

-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Automatically enter insert mode when opening a terminal
vim.api.nvim_create_augroup("TerminalInsertMode", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
	group = "TerminalInsertMode",
	pattern = "*",
	command = "startinsert", -- Enter insert mode automatically
})

-- [[ Basic Keymaps ]]

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Open terminal in a new tab and switch to that tab
vim.keymap.set(
	"n",
	"<leader>t",
	":tabnew<CR>:terminal<CR>a",
	{ desc = "Open terminal in new tab and switch to that tab" }
)

-- Open lazy in a new tab and switch to that tab
vim.keymap.set("n", "<leader>lg", function()
	vim.cmd("tabnew | terminal lazygit")
	vim.cmd("startinsert")
	-- vim.cmd("stopinsert")
end, { desc = "Open LazyGit in a new tab" })

-- Go to previous and next tabs with <leader>{h,l}
vim.keymap.set("n", "<leader>h", function()
	vim.cmd("tabprevious")
end, { desc = "Go to the previous tab" })

vim.keymap.set("n", "<leader>l", function()
	vim.cmd("tabnext")
end, { desc = "Go to the next tab" })

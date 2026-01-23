-- Set leader early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local mappings = {
	-- Saving and Exiting
	{ modes = { "n" }, keys = "<leader>w", cmd = ":w<CR>", desc = "Save" },
	{ modes = { "n" }, keys = "<leader>Q", cmd = ":q!<CR>", desc = "Quit without saving" },
	{ modes = { "n" }, keys = "<leader>q", cmd = ":q<CR>", desc = "Quit" },
	{ modes = { "n" }, keys = "<leader><leader>", cmd = ":b#<CR>", desc = "Switch to alternate buffer" },

	-- Tabs
	{
		modes = { "n", "t" },
		keys = "<leader>l",
		cmd = function()
			vim.cmd("tabnext")
		end,
		desc = "Go to next tab",
	},
	{
		modes = { "n", "t" },
		keys = "<leader>h",
		cmd = function()
			vim.cmd("tabnext")
		end,
		desc = "Go to previous tab",
	},

	-- Terminal
	{
		modes = { "n" },
		keys = "<leader>t",
		cmd = ":tabnew<CR>:terminal<CR>",
		desc = "Open terminal in new tab and switch to that tab",
	},

	-- Quickfix list
	{
		modes = { "n" },
		keys = "<leader>qn",
		cmd = function()
			vim.cmd("cnext")
		end,
		desc = "Go to next quickfix item",
	},
	{
		modes = { "n" },
		keys = "<leader>qp",
		cmd = function()
			vim.cmd("cprev")
		end,
		desc = "Go to previous quickfix item",
	},

	-- Location list
	{
		modes = { "n" },
		keys = "<leader>ln",
		cmd = function()
			vim.cmd("cnext")
		end,
		desc = "Go to next locationlist item",
	},
	{
		modes = { "n" },
		keys = "<leader>lp",
		cmd = function()
			vim.cmd("cprev")
		end,
		desc = "Go to previous locationlist item",
	},

	-- Search
	{
		modes = { "n" },
		keys = "<Esc>",
		cmd = "<cmd>nohlsearch<CR>",
		desc = "Clear highlights on search when pressing <Esc> in normal mode",
	},

	-- Diagnostics
	{
		modes = { "n" },
		keys = "<leader>d",
		cmd = function()
			vim.diagnostic.setloclist()
		end,
		desc = "Open diagnostic [Q]uickfix list",
	},

	-- All diagnostics
	{
		modes = { "n" },
		keys = "]d",
		cmd = function()
			vim.diagnostic.jump({ count = 1, float = false })
		end,
		desc = "Next diagnostic",
	},
	{
		modes = { "n" },
		keys = "]d",
		cmd = function()
			vim.diagnostic.jump({ count = -1, float = false })
		end,
		desc = "Previous diagnostic",
	},

	-- Errors only
	{
		modes = { "n" },
		keys = "]e",
		cmd = function()
			vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = false })
		end,
		desc = "Next error",
	},
	{
		modes = { "n" },
		keys = "[e",
		cmd = function()
			vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = false })
		end,
		desc = "Previous error",
	},

	-- Warnings only
	{
		modes = { "n" },
		keys = "]w",
		cmd = function()
			vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN, float = false })
		end,
		desc = "Next warning",
	},
	{
		modes = { "n" },
		keys = "[w",
		cmd = function()
			vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN, float = false })
		end,
		desc = "Previous warning",
	},
}

for _, map in ipairs(mappings) do
	keymap(map.modes, map.keys, map.cmd, { desc = map.desc, noremap = true })
end

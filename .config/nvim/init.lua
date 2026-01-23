-- Set leader early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require("autocommands")
require("options")
require("keymaps/keymaps")
require("diagnostics")

-- Lazy plugin manager bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins with lazy
require("lazy").setup({
	require("plugins.aerial"),
	require("plugins.auto-pairs"),
	require("plugins.breadcrumbs"),
	require("plugins.code-companion"),
	require("plugins.colorscheme"),
	require("plugins.comments"),
	require("plugins.completions"),
	require("plugins.debugging"),
	require("plugins.formatting"),
	require("plugins.git"),
	require("plugins.indent-line"),
	require("plugins.linters"),
	require("plugins.lsp"),
	require("plugins.markdown"),
	require("plugins.mason"),
	require("plugins.neo-tree"),
	require("plugins.noice"),
	require("plugins.oil"),
	require("plugins.telescope"),
	require("plugins.tmux-navigator"),
	require("plugins.treesitter-objects"),
	require("plugins.treesitter"),
})

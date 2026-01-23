local opt = vim.opt

opt.termguicolors = true
-- opt.swapfile = false
-- opt.backup = false

-- [[ Setting options ]]

-- Enable line numbers and relative line numbers
opt.number = true
opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = "yes:2"

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display tabs, trailing spaces, EOL, and non-breaking spaces in the editor.
opt.list = true
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", eol = "↴" }
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", eol = "↴" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor
opt.scrolloff = 20

-- Use 4 spaces for indentation and tabs, and expand tabs to spaces
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Highlight column 81 as a visual guide (keep lines ≤ 80 chars)
opt.colorcolumn = "81"

-- Automatically insert a line break when typing past 80 characters
opt.textwidth = 80
-- Make long lines wrap visually
opt.wrap = true

-- Wrap at word boundaries, not in the middle of a word
opt.linebreak = true

-- Prefix visually wrapped lines with this symbol (doesn't affect file content)
opt.showbreak = "↪ "

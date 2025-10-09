-- [[ Configure and install plugins ]]
require("lazy").setup({
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	-- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

	require("config/autocomplete"),
	require("config/autopairs"),
	require("config/code-companion"),
	require("config/comments"),
	require("config/debug"),
	require("config/format"),
	require("config/git"),
	require("config/indent_line"),
	require("config/lint"),
	require("config/lsp"),
	require("config/lspkind"),
	require("config/mini"),
	require("config/nvim-tree"),
	require("config/oil"),
	-- require("config/snippets"),
	require("config/telescope"),
	require("config/theme"),
	require("config/tmux-navigator"),
	require("config/treesitter"),
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- [[ Configure and install plugins ]]
require("lazy").setup({
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	-- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

	require("kickstart/plugins/git"),

	require("kickstart/plugins/telescope"),

	require("kickstart/plugins/lsp"),

	require("kickstart/plugins/format"),

	require("kickstart/plugins/autocomplete"),

	require("kickstart/plugins/theme"),

	require("kickstart/plugins/comments"),

	require("kickstart/plugins/mini"),

	require("kickstart/plugins/treesitter"),

	require("kickstart/plugins/nvim-tree"),

	require("kickstart/plugins/tmux-navigator"),

	require("kickstart/plugins/llm"),

	require("kickstart/plugins/oil"),

	require("kickstart/plugins/debug"),
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

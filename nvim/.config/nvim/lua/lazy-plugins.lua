-- [[ Configure and install plugins ]]
require("lazy").setup({
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	-- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

	require("kickstart/plugins/gitsigns"),

	require("kickstart/plugins/telescope"),

	require("kickstart/plugins/lspconfig"),

	require("kickstart/plugins/conform"),

	require("kickstart/plugins/cmp"),

	require("kickstart/plugins/gruvbox"),

	require("kickstart/plugins/todo-comments"),

	require("kickstart/plugins/mini"),

	require("kickstart/plugins/treesitter"),

	require("kickstart/plugins/nvim-tree"),

	require("kickstart/plugins/tmux-navigator"),
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
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

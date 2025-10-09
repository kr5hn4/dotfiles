return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
			opts = {},
		},
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "gemini",
				},
				inline = {
					adapter = "gemini",
				},
				agent = {
					adapter = "gemini",
				},
			},
			gemini = function()
				return require("codecompanion.adapters").extend("gemini", {
					schema = {
						model = {
							default = "gemini-2.5-flash-preview-05-20",
						},
					},
					env = {
						api_key = "GEMINI_API_KEY",
					},
				})
			end,
			display = {
				diff = {
					provider = "mini_diff",
				},
			},
		})
		vim.api.nvim_set_keymap("n", "<leader>c", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { noremap = true, silent = true })
	end,
}

return {
	{
		"echasnovski/mini.comment",
		version = false,
		config = function()
			require("mini.comment").setup()
		end,
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- Customize keywords or colors if you want
			keywords = {
				TODO = { icon = "󰄬", color = "info" },
				HACK = { icon = "", color = "warning" },
				FIXME = { icon = "󰃤", color = "error" },
			},
		},
	},
}

return {
	"olimorris/codecompanion.nvim",

	dependencies = {
		"nvim-mini/mini.diff",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"stevearc/dressing.nvim",
			opts = {},
		},
	},

	keys = {
		{ "<leader>c", "<cmd>CodeCompanion<CR>", desc = "CodeCompanion" },
		{ "<leader>cc", "<cmd>CodeCompanionChat<CR>", desc = "CodeCompanion Chat" },
	},

	opts = {
		interactions = {
			chat = {

				adapter = {
					name = "cline_cli",
					model = os.getenv("GEMINI_MODEL"),
				},
			},

			inline = {
				adapter = {
					name = "cline_cli",
					model = os.getenv("GEMINI_MODEL"),
				},
			},
		},

		adapters = {
			acp = {
				extend = {
					cline_cli = {
						env = {
							CLINE_PROVIDER = "gemini",
							CLINE_API_KEY = os.getenv("GEMINI_API_KEY"),
						},
					},
				},
			},
		},

		display = {
			diff = {
				provider = "mini_diff",
			},
		},

		-- Temporary: enable detailed request/error logging.
		opts = {
			log_level = "DEBUG",
		},
	},
}

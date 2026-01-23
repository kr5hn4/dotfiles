return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({

				views = {
					cmdline_popup = {
						position = {
							row = -20,
							-- col = 2,
						},
						border = { style = "rounded" },
						-- win_options = {
						-- 	winhighlight = {
						-- 		Normal = "NormalFloat", -- popup background
						-- 		FloatBorder = "MyBorder", -- bright/glowing border
						-- 	},
						-- },
					},
				},
				routes = {
					routes = {
						{
							view = "notify",
							filter = { event = "msg_show", kind = "error" }, -- errors
							opts = { position = { row = -1, col = "80%" } }, -- top-right
						},
						{
							view = "notify",
							filter = { event = "msg_show", kind = "warn" }, -- warnings
							opts = { position = { row = -1, col = "50%" } }, -- bottom-middle
						},
					},
				},
			})
		end,
	},
}

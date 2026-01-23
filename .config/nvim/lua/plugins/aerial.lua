return {
	"stevearc/aerial.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("aerial").setup({
			backends = { "treesitter" },
			filter_kind = {
				"Function",
				"Method",
				"Constructor",
				"Class",
				"Interface",
				"Struct",
				"Enum",
				"TypeAlias",
			},
			icons = {
				File = "",
				Module = "",
				Namespace = "",
				Package = "",
				Class = "𝑐",
				Method = "𝑓",
				Function = "𝑓",
				Constructor = "𝑓",
				Interface = "𝑖",
				Struct = "𝑡",
				Enum = "𝑒",
				EnumMember = "𝑒",
				TypeAlias = "𝑡",
				Variable = "𝑣",
			},
			layout = {
				default_direction = "right",
				placement = "edge",
				min_width = 30,
				max_width = 40,
			},
			highlight_on_hover = true,
		})

		-- Keep original text color, just highlight current line
		vim.cmd([[
          highlight! link AerialLine CursorLine
          highlight! link AerialLineNC Normal
        ]])
		-- 2️⃣ Auto-open/auto-close logic (outside setup)
		local function any_real_file_open()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local ft = vim.bo[buf].filetype
				local bt = vim.bo[buf].buftype
				if bt == "" and ft ~= "neo-tree" and ft ~= "aerial" then
					return true
				end
			end
			return false
		end

		-- Auto-open on first file load
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function()
				if any_real_file_open() then
					require("aerial").open({ focus = false })
				end
			end,
		})

		-- Auto-close when no real files remain
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWinLeave", "WinClosed" }, {
			callback = function()
				if not any_real_file_open() then
					pcall(require("aerial").close)
				end
			end,
		})
	end,
}

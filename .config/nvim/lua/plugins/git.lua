return {
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "✚" },
				change = { text = "✎" },
				delete = { text = "✖" },
				topdelete = { text = "↥" },
				changedelete = { text = "✎" },
			},
			sign_priority = 20,

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				vim.keymap.set("n", "<leader>gc", function()
					local msg = vim.fn.input("Commit message: ")
					local output = vim.fn.system('git commit -am "' .. msg .. '"')
					print(output) -- optional: only prints result in command line
				end, { desc = "git log (floating terminal, modern)" })

				local float_term = nil

				local function toggle_float(cmd)
					-- if window exists, close it
					if float_term and vim.api.nvim_win_is_valid(float_term) then
						vim.api.nvim_win_close(float_term, true)
						float_term = nil
						return
					end

					-- create a fresh buffer for each new terminal
					local buf = vim.api.nvim_create_buf(false, true)

					local width = math.floor(vim.o.columns * 0.6)
					local height = math.floor(vim.o.lines * 0.6)
					local row = math.floor((vim.o.lines - height) / 2)
					local col = math.floor((vim.o.columns - width) / 2)

					float_term = vim.api.nvim_open_win(buf, true, {
						relative = "editor",
						width = width,
						height = height,
						row = row,
						col = col,
						style = "minimal",
						border = "rounded",
					})

					-- open terminal with the command
					vim.cmd("terminal " .. cmd)

					-- press q to close this float
					vim.keymap.set("n", "q", function()
						if vim.api.nvim_win_is_valid(float_term) then
							vim.api.nvim_win_close(float_term, true)
							float_term = nil
						end
					end, { buffer = buf })
				end

				-- example keymaps
				vim.keymap.set("n", "<leader>gs", function()
					toggle_float("git status")
				end)
				vim.keymap.set("n", "<leader>gl", function()
					toggle_float("git log")
				end)

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Jump to next git [c]hange" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Jump to previous git [c]hange" })

				-- Actions
				-- visual mode
				map("v", "<leader>sh", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "stage git hunk" })
				map("v", "<leader>rh", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "reset git hunk" })
				-- normal mode
				map("n", "<leader>sh", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
				map("n", "<leader>rh", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
				map("n", "<leader>sb", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
				map("n", "<leader>rb", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
				map("n", "<leader>bh", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
				map("n", "<leader>bl", gitsigns.toggle_current_line_blame, { desc = "git [b]lame line" })
				map("n", "<leader>di", gitsigns.diffthis, { desc = "git [d]iff against index" })
				map("n", "<leader>dc", function()
					gitsigns.diffthis("@")
				end, { desc = "git [D]iff against last commit" })
				-- Toggles
			end,
		},
	},
}

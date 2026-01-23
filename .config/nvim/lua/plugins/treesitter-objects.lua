return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	lazy = true,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true, -- jump forward to textobject like targets.vim
				include_surrounding_whitespace = false,
			},
			move = {
				set_jumps = true, -- add jumps to jumplist
			},
		})

		-- ======== Keymaps ========
		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")
		local swap = require("nvim-treesitter-textobjects.swap")
		local repeatable = require("nvim-treesitter-textobjects.repeatable_move")

		-- Helpers
		local map = vim.keymap.set
		local xo = { "x", "o" }
		local nxo = { "n", "x", "o" }

		-- === Select textobjects ===
		local select_maps = {
			["af"] = { "@function.outer", "textobjects" },
			["if"] = { "@function.inner", "textobjects" },
			["ac"] = { "@comment.outer", "textobjects" },
			["ic"] = { "@comment.inner", "textobjects" },
			["as"] = { "@local.scope", "locals" },
			["al"] = { "@loop.outer", "textobjects" },
			["il"] = { "@loop.inner", "textobjects" },
			["ai"] = { "@conditional.outer", "textobjects" },
			["ii"] = { "@conditional.inner", "textobjects" },
			["ab"] = { "@block.outer", "textobjects" },
			["ib"] = { "@block.inner", "textobjects" },
		}

		for keys, args in pairs(select_maps) do
			map(xo, keys, function()
				select.select_textobject(args[1], args[2])
			end)
		end

		-- === Swap textobjects ===
		map("n", "<leader>a", function()
			swap.swap_next("@parameter.inner")
		end)
		map("n", "<leader>A", function()
			swap.swap_previous("@parameter.outer")
		end)

		-- === Movement ===
		local move_maps = {
			["]m"] = { "goto_next_start", "@function.outer", "textobjects" },
			["]t"] = { "goto_next_start", "@parameter.inner", "textobjects" },
			["]]"] = { "goto_next_start", "@class.outer", "textobjects" },
			["]s"] = { "goto_next_start", "@local.scope", "locals" },
			["]z"] = { "goto_next_start", "@fold", "folds" },

			["]M"] = { "goto_next_end", "@function.outer", "textobjects" },
			["]["] = { "goto_next_end", "@class.outer", "textobjects" },

			["[m"] = { "goto_previous_start", "@function.outer", "textobjects" },
			["[["] = { "goto_previous_start", "@class.outer", "textobjects" },

			["[M"] = { "goto_previous_end", "@function.outer", "textobjects" },
			["[]"] = { "goto_previous_end", "@class.outer", "textobjects" },

			["]d"] = { "goto_next", "@conditional.outer", "textobjects" },
			["[d"] = { "goto_previous", "@conditional.outer", "textobjects" },
		}

		for keys, m in pairs(move_maps) do
			local fn, target, group = unpack(m)
			map(nxo, keys, function()
				move[fn](target, group)
			end)
		end

		-- === Repeat movements ===
		map(nxo, ";", repeatable.repeat_last_move_next)
		map(nxo, ",", repeatable.repeat_last_move_previous)

		-- Builtin motions (expr)
		map(nxo, "f", repeatable.builtin_f_expr, { expr = true })
		map(nxo, "F", repeatable.builtin_F_expr, { expr = true })
		map(nxo, "t", repeatable.builtin_t_expr, { expr = true })
		map(nxo, "T", repeatable.builtin_T_expr, { expr = true })

		-- === Custom repeat movements ===
		map(nxo, "<Home>", function()
			repeatable.repeat_last_move({ forward = false, start = true })
			repeatable.repeat_last_move({ forward = false, start = true })
		end)

		map(nxo, "<End>", function()
			repeatable.repeat_last_move({ forward = true, start = false })
		end)
	end,
}

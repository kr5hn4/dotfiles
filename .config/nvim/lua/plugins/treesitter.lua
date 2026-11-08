return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter", -- Sets main module to use for opts
		config = function()
			local ts = require("nvim-treesitter")

			-- 1. Run the base plugin setup (optional if using defaults, but good to have)
			ts.setup({})

			-- 2. Pass your list of languages directly into the install function
			ts.install({
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"typescript",
				"javascript",
				"svelte",
				"json",
				"yaml",
				"go",
				"rust",
				"zig",
			})
			-- =================================================================
			-- REPLACEMENT FOR MIGRATED LOGIC (Old `opts` blocks)
			-- =================================================================

			-- A. REPLACEMENT FOR: highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } }
			-- Enable native treesitter highlighting globally except for ruby, which falls back to standard regex
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if lang and lang ~= "ruby" then
						pcall(vim.treesitter.start, args.buf, lang)
					else
						-- Keeps traditional vim regex highlighting on for Ruby
						vim.bo[args.buf].syntax = "ON"
					end
				end,
			})

			-- B. REPLACEMENT FOR: indent = { enable = true, disable = { "ruby" } }
			-- Enable native Neovim treesitter indentation for all buffers except ruby
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					if vim.bo[args.buf].filetype ~= "ruby" then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- C. REPLACEMENT FOR: auto_install = true
			-- Automatically downloads missing treesitter parsers when entering a file
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if lang then
						local has_parser = pcall(vim.treesitter.language.add, lang)
						if not has_parser then
							-- Triggers the install command silently if missing
							vim.cmd("TSInstall " .. lang)
						end
					end
				end,
			})

			-- D. REPLACEMENT FOR: incremental_selection
			-- Initialize & expand selection with <C-space> in Visual mode
			vim.keymap.set("x", "<C-space>", function()
				require("vim.treesitter._select").select_parent()
			end, { desc = "Increment Treesitter Selection" })

			-- Decrement selection with <bs> (Backspace) in Visual mode
			vim.keymap.set("x", "<bs>", function()
				pcall(require("vim.treesitter._select").select_child)
			end, { desc = "Decrement Treesitter Selection" })
		end,
	},
}

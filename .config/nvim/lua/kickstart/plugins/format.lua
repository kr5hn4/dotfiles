return {
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			-- Set to true to ignore errors
			ignore_errors = false,
			-- Map of treesitter language to file extension
			-- A temporary file name with this extension will be generated during formatting
			-- because some formatters care about the filename.
			lang_to_ext = {
				bash = "sh",
				c_sharp = "cs",
				elixir = "exs",
				javascript = "js",
				julia = "jl",
				latex = "tex",
				markdown = "md",
				python = "py",
				ruby = "rb",
				rust = "rs",
				teal = "tl",
				typescript = "ts",
			},
			-- Map of treesitter language to formatters to use
			-- (defaults to the value from formatters_by_ft)
			lang_to_formatters = {},

			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				javascript = { "prettier", stop_after_first = true },
				json = { "prettier" },
				svelte = { "prettier" },
				typescript = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				xml = { "prettier" },
				html = { "prettier" },
			},
		},
	},
}

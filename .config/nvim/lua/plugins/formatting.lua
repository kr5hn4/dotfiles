return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",

		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format buffer",
			},
		},

		opts = {
			ignore_errors = false,
			notify_on_error = true,

			-- File extensions for temp files
			lang_to_ext = {
				c_sharp = "cs",
				elixir = "exs",
				javascript = "js",
				json = "json",
				julia = "jl",
				latex = "tex",
				lua = "lua",
				markdown = "md",
				nix = "nix",
				python = "py",
				ruby = "rb",
				rust = "rs",
				teal = "tl",
				typescript = "ts",
				zig = "zig",
			},

			-- Disable LSP fallback for filetypes without standard formatting
			format_on_save = function(buf)
				local no_fallback = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_format = no_fallback[vim.bo[buf].filetype] and "never" or "fallback",
				}
			end,

			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "alejandra" },
				rust = { "rustfmt" },
				zig = { "zig" },

				javascript = { "prettier", stop_after_first = true },
				typescript = { "prettier" },
				svelte = { "prettier" },
				json = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				html = { "prettier" },

				sh = { "shfmt" },
				bash = { "shfmt" },
			},

			formatters = {
				zig = {
					command = "zig",
					args = { "fmt", "--stdin" },
					stdin = true,
				},
			},
		},
	},
}

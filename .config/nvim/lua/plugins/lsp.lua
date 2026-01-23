return {
	-- Lazydev for Neovim Lua configuration
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},

	-- Main LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			require("plugins.mason"), -- Mason setup
			{ "j-hui/fidget.nvim", opts = {} }, -- LSP status updates
			"hrsh7th/cmp-nvim-lsp", -- LSP completion capabilities
		},
		config = function()
			-- LSP keymaps and buffer-local settings
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Navigation
					map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("gr", require("telescope.builtin").lsp_references, "References")
					map("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
					map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

					-- Code actions & refactoring
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("K", vim.lsp.buf.hover, "Hover")

					-- Refresh codelens automatically
					vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
						buffer = event.buf,
						callback = function()
							pcall(vim.lsp.codelens.refresh)
						end,
					})

					-- CodeLens
					map("<leader>cl", vim.lsp.codelens.run, "Run CodeLens")

					-- Inlay hints (if supported by client)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle Inlay Hints")
					end

					-- Highlight references under cursor
					if client and client:supports_method("textDocument/documentHighlight") then
						local hl_group = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = hl_group,
							buffer = event.buf,
							callback = function()
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = hl_group, buffer = event.buf })
							end,
						})
					end
				end,
			})

			-- Highlight settings for LspInlayHint and LspCodeLens
			vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#555047", bg = "NONE" })
			vim.api.nvim_set_hl(
				0,
				"LspCodeLens",
				{ fg = "#555047", bg = "NONE", italic = true, underdotted = true, blend = 80 }
			)
		end,
	},
}

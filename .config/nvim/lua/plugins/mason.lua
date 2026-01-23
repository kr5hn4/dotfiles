return {
	-- Core Mason package manager
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason + LSP configuration
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- LSP servers and settings
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							codeLens = { enable = true },
							hint = {
								enable = true,
								paramName = "All",
								paramType = true,
								paramTypeHint = "All",
								arrayIndex = "Enable",
							},
							completion = { callSnippet = "Replace" },
						},
					},
				},
				gopls = {
					settings = {
						gopls = {
							codelenses = {
								generate = true,
								gc_details = true,
								test = true,
								tidy = true,
								vendor = true,
								regenerate_cgo = true,
								upgrade_dependency = true,
							},
						},
					},
				},
				-- Add other servers as needed
				tsserver = {},
				rust_analyzer = {},
				zls = {},
				bashls = {},
			}

			-- Setup LSP servers through mason-lspconfig
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}

						-- Special tsserver settings
						if server_name == "tsserver" or server_name == "ts_ls" then
							server.init_options = vim.tbl_deep_extend("force", server.init_options or {}, {
								preferences = {
									completeJSDocs = true,
									includeCompletionsWithInsertText = true,
									includeCompletionsWithSnippetText = true,
									completeFunctionCalls = true,
									includeCompletionsForModuleExports = true,
								},
							})
						end

						-- Merge capabilities
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

						-- Minimal on_attach for hover
						server.on_attach = function()
							vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
						end

						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-- Mason: automatically install tools (LSPs, formatters, debuggers)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- LSPs
					"gopls",
					"lua-language-server",
					"typescript-language-server",
					"rust-analyzer",
					"zls",
					"bashls",
					-- Tools
					"stylua",
					"delve",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}

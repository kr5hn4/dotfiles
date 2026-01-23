return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-mini/mini.diff",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
			opts = {},
		},
	},

	keys = {
		{ "<leader>c", "<cmd>CodeCompanion<CR>", desc = "CodeCompanion" },
		{ "<leader>cc", "<cmd>CodeCompanionChat<CR>", desc = "CodeCompanion Chat" },
	},

	opts = {
		adapters = {
			http = {
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						-- schema = {
						-- 	model = {
						-- 		default = "gemini-2.5-flash-preview-05-20",
						-- 	},
						-- },
						env = {
							api_key = "GEMINI_API_KEY",
						},
					})
				end,
			},
			acp = {
				gemini_cli = function()
					return require("codecompanion.adapters").extend("gemini_cli", {
						defaults = {
							auth_method = "gemini-api-key",
							-- mcpServers = {},
							timeout = 10000, -- 10 seconds
						},
						env = {
							GEMINI_API_KEY = "GEMINI_API_KEY",
						},
					})
				end,
			},
		},
		strategies = {
			chat = {
				adapter = "gemini",
			},
			inline = {
				adapter = "gemini",
			},
			agent = {
				adapter = "gemini",
			},
		},
		display = {
			diff = {
				provider = "mini_diff",
			},
		},
	},
	-- extensions = {
	-- 	mcphub = {
	-- 		callback = "mcphub.extensions.codecompanion",
	-- 		opts = {
	-- 			-- MCP Tools
	-- 			make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
	-- 			show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
	-- 			add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
	-- 			show_result_in_chat = true, -- Show tool results directly in chat buffer
	-- 			format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
	-- 			-- MCP Resources
	-- 			make_vars = true, -- Convert MCP resources to #variables for prompts
	-- 			-- MCP Prompts
	-- 			make_slash_commands = true, -- Add MCP prompts as /slash commands
	-- 		},
	-- 	},
	-- },
}

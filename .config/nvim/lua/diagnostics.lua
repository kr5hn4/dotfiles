vim.diagnostic.config({
	virtual_text = true, -- show inline messages
	underline = true, -- underline problematic code
	update_in_insert = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

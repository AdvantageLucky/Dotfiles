-- @Langs: @Diagnostics
local severity = vim.diagnostic.severity

vim.diagnostic.config({
	signs = {
		text = {
			[severity.ERROR] = "󰅚",
			[severity.WARN] = "󰀪",
			[severity.INFO] = "󰋼",
			[severity.HINT] = "󰌶",
		},
		numhl = {
			[severity.ERROR] = "DiagnosticSignError",
			[severity.WARN] = "DiagnosticSignWarn",
			[severity.INFO] = "DiagnosticSignInfo",
			[severity.HINT] = "DiagnosticSignHint",
		},
	},

	float = {
		source = true,
		border = "rounded",
	},

	underline = true,
	virtual_text = true,
	severity_sort = true,
	update_in_insert = true,
})

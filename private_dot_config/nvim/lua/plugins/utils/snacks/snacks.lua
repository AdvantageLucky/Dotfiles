require("snacks").setup({

	indent = {
		enabled = true,
		filter = function(buf, _)
			return vim.g.snacks_indent ~= false
				and vim.b[buf].snacks_indent ~= false
				and vim.bo[buf].buftype == ""
				and vim.bo[buf].filetype ~= "text"
		end,
	},

	bigfile = { enabled = true },
	quickfile = { enabled = true },
})

require("tiny-code-action").setup({
	backend = "delta",
	picker = "telescope",
	backend_opts = {
		delta = {
			header_lines_to_remove = 4,
			args = {
				"--line-numbers",
			},
		},
	},
})

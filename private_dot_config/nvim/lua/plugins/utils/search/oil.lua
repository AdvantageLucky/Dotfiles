require("oil").setup({
	default_file_explorer = false, -- fallback to :Explore
	use_default_keymaps = true,
	delete_to_trash = true, -- trash-cli
	watch_for_changes = true,
	constrain_cursor = "name",

	columns = {
		"icon",
		"size",
	},

	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = "unmodified",
	},

	win_options = {
		number = false,
		relativenumber = false,
	},

	preview_win = {
		win_options = {
			number = false,
			relativenumber = false,
		},
	},

	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			-- .class or .pyc
			return name:match("%.class$") or name:match("%.pyc$")
		end,
	},

	float = {
		padding = 2,
		max_width = 80,
		max_height = 30,
		border = "rounded",
		preview_split = "right",

		override = function(conf)
			local screen_w = vim.o.columns
			local screen_h = vim.o.lines - vim.o.cmdheight
			local window_w = conf.width
			local window_h = conf.height

			conf.col = math.floor((screen_w - window_w) / 2)
			conf.row = math.floor((screen_h - window_h) / 2)

			return conf
		end,
	},

	keymaps = {
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["<C-h>"] = { "actions.select", opts = { horizontal = true } },
		["<C-t>"] = { "actions.select", opts = { tab = true } },
		["<C-p>"] = "actions.preview",
		["<C-c>"] = { "actions.close", mode = "n" },
		["<C-l>"] = "actions.refresh",
		["<C-d>"] = { "actions.cd", mode = "n" },
		["g."] = { "actions.toggle_hidden", mode = "n" },
	},
})

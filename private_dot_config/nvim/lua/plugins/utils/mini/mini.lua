-- Mini autopairs
require("mini.pairs").setup()

-- Mini f keymap for jumping in find
require("mini.jump").setup()

-- Mini colorizer
require("mini.hipatterns").setup()

-- Mini clue
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` / `z`
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },

		-- Marks, registers, windows
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "n", keys = "<C-w>" },
	},

	clues = {
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},

	window = {
		delay = 500,
	},
})

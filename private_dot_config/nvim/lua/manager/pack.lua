-- manager.commands registers the PackChanged build-hook autocmd; must run
-- before vim.pack.add() so the "install" event isn't missed.
require("manager.commands")

vim.pack.add({
	-- @UI
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/shaunsingh/nord.nvim" },
	{ src = "https://github.com/savq/melange-nvim" },

	-- @LSP
	-- completions LuaSnip
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },

	-- mason
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- conform formatter
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- code actions previews
	{ src = "https://github.com/rachartier/tiny-code-action.nvim" },

	-- snippets
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = "v2.5.0" },

	-- @UTILS
	-- etc
	{ src = "https://github.com/vyfor/cord.nvim" },

	-- Snacks
	{ src = "https://github.com/folke/snacks.nvim" },

	-- Mini
	{ src = "https://github.com/nvim-mini/mini.nvim" },

	-- Parser
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },

	-- Search
	-- Oil
	{ src = "https://github.com/stevearc/oil.nvim" },

	-- Telescope
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-frecency.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },

	-- Hlslens
	{ src = "https://github.com/kevinhwang91/nvim-hlslens" },

	-- Notes
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/f3fora/cmp-spell" },
	{ src = "https://github.com/3rd/image.nvim" },
})

-- @REQUIRES
-- @UI
require("plugins.ui.gitsigns")
require("plugins.ui.lualine")
require("plugins.ui.icons")
require("plugins.ui.melange")

-- @LSP
require("plugins.lsp.engine.mason")
require("plugins.lsp.engine.conform")
require("plugins.lsp.completions.nvim_cmp")
require("plugins.lsp.actions.code_actions_preview")

-- @UTILS
-- etc
require("plugins.utils.etc.discord")

-- Parser
require("plugins.utils.parser.treesitter")

-- Search
require("plugins.utils.search.oil")
require("plugins.utils.search.telescope")
require("plugins.utils.search.hlsearch")

-- Notes
require("plugins.utils.notes.render_markdown")
require("plugins.utils.notes.image")

-- Snacks
require("plugins.utils.snacks.snacks")

-- Mini
require("plugins.utils.mini.mini")

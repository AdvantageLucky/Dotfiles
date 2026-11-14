---@return string|osdate
local function get_datetime()
	return os.date("%I:%M%p")
end

vim.api.nvim_del_mark("M")
---@return string
local function markM()
	local ok, markObj = pcall(vim.api.nvim_get_mark, "M", {})
	if not ok then
		return ""
	end

	local markLn = markObj[1]
	local markBufname = vim.fs.basename(markObj[4])
	if markBufname == "" then
		return ""
	end

	return " mark at " .. markBufname:gsub("%.%w+$", "") .. ":" .. markLn
end

local theme = require("plugins.ui.theme")

---@param key string|fun():string
local function pill(key)
	return function()
		local p = theme.palette()
		if not p then
			return { gui = "bold" }
		end
		return { fg = p.base00, bg = p[type(key) == "function" and key() or key], gui = "bold" }
	end
end

--- the text next to a pill: the color is only on the letters
---@param key string|fun():string
local function label(key)
	return function()
		local p = theme.palette()
		if not p then
			return { gui = "bold" }
		end
		return { fg = p[type(key) == "function" and key() or key], bg = p.base01, gui = "bold" }
	end
end

--- a small colored square with an icon
---@param icon string|fun():string
---@param key string|fun():string
local function square(icon, key)
	return {
		function()
			return type(icon) == "function" and icon() or icon
		end,
		color = pill(key),
		padding = { left = 1, right = 1 },
		separator = "",
	}
end

local mode_keys =
	{ n = "base09", i = "base0B", v = "base0E", V = "base0E", ["\22"] = "base0E", R = "base08", c = "base0A" }
local function mode_key()
	return mode_keys[vim.fn.mode()] or "base09"
end

--- the gap between two pills
local function gap()
	return {
		function()
			return " "
		end,
		color = function()
			local p = theme.palette()
			return p and { bg = p.base01 } or {}
		end,
		padding = 0,
		separator = "",
	}
end

require("lualine").setup({
	options = {
		-- built from the desktop palette; loading the module also applies the colorscheme first
		theme = require("plugins.ui.theme").lualine_theme(),
		section_separators = "",
		component_separators = { left = "", right = "::" },
		disabled_filetypes = { "alpha", "Outline" },
	},

	sections = {
		-- vim mode
		lualine_a = {
			{
				"mode",
				fmt = function(mode)
					return mode:sub(1, 1)
				end,
			},
			gap(),
		},

		-- filename
		lualine_b = {
			{
				"filetype",
				icon_only = true,
				colored = false,
				color = pill("base08"),
				padding = { left = 1, right = 0 },
				separator = "",
			},
			{
				"filename",
				color = label("base08"),
				padding = { left = 1, right = 1 },
				separator = "",
			},
		},

		-- changes
		lualine_c = {
			gap(),
			{
				"diff",
			},
		},

		-- diagnostics, git and marks
		lualine_x = {
			{
				markM,
				color = { gui = "bold" },
			},
			{
				"diagnostics",
				symbols = { error = " ", warn = " ", info = " ", hint = " " },
				update_in_insert = true,
			},
			{
				"branch",
				icon = "",
				color = { gui = "bold" },
			},
		},

		lualine_y = {
			square("≡", "base09"),
			{
				"location",
				fmt = vim.trim,
				color = label("base09"),
				padding = { left = 1, right = 0 },
				separator = "",
			},
			{
				"progress",
				color = label("base09"),
				padding = { left = 1, right = 1 },
				separator = "",
			},
			gap(),
		},

		-- the filetype (yellow pill) and the position (orange pill)
		lualine_z = {
			square(function()
				return vim.fn.nr2char(0xF0954)
			end, "base0A"),
			{
				get_datetime,
				color = label("base0A"),
				padding = { left = 1, right = 1 },
				separator = "",
			},
		},
	},
	extensions = { "mason", "oil", "quickfix", "man" },
})

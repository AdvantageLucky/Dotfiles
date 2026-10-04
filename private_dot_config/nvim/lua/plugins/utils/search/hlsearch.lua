local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
end

local function with_lens(cmd)
	return function()
		local ok, err = pcall(vim.cmd, "normal! " .. vim.v.count1 .. cmd)
		if not ok then
			vim.notify(err, vim.log.levels.WARN)
			return
		end
		require("hlslens").start()
	end
end

require("hlslens").setup({
	calm_down = true,
	nearest_only = false,
})

map("n", with_lens("n"), "next match with lens")
map("N", with_lens("N"), "previous match with lens")
map("*", function()
	vim.cmd("normal! *")
	require("hlslens").start()
end, "search word forward")
map("#", function()
	vim.cmd("normal! #")
	require("hlslens").start()
end, "search word backward")
map("g*", function()
	vim.cmd("normal! g*")
	require("hlslens").start()
end, "search partial forward")
map("g#", function()
	vim.cmd("normal! g#")
	require("hlslens").start()
end, "search partial backward")

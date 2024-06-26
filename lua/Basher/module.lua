---@class CustomModule

local popup = require("plenary.popup")

local M = {}

--[[
--
-- this is an example of what the config file will look like

[config]
autochmod=true

[/home/vince]
1_alias=/home/vince/projects/Basher/anotherDir/build.sh -additionalargs
2=/home/vince/Desktop/build.sh

[/home/vince/projects/Basher]
1=/home/vince/projects/Basher/build.sh
2_superCoolName=/home/vince/projects/Basher/build.sh -anAddtionalArgument

-- The user will be able to give the scripts an alias and be able
-- to add additional arguments as well as reorder them and I think
-- this is the easiest way to store their settings
--
--]]

local defaultDataFile = [[
[config]
autochmod=true

]]

-- write the default values inside this function for now
local function createNewDataFile()
	io.output(vim.fn.stdpath("data") .. "/basher.data")
	io.write(defaultDataFile)
	io.write("[" .. vim.fn.getcwd() .. "]\n")
	io.close()
end

local function define_popup_mappings(buf)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		":lua require('Basher').handleEnterKey()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<Esc>",
		":lua require('Basher').closeMainWin()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<S-d>",
		":lua require('Basher').moveDown()<CR>",
		{ noremap = true, silent = true, desc = "[M]ove [D]own" }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<S-u>",
		":lua require('Basher').moveUp()<CR>",
		{ noremap = true, silent = true, desc = "[M]ove [U]p" }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"1",
		":lua require('Basher').runScript(1)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"2",
		":lua require('Basher').runScript(2)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"3",
		":lua require('Basher').runScript(3)<CR>",
		{ noremap = true, silent = true }
	)
end

M.scriptList = {}

M.handle_enter_key = function()
	M.run_script(vim.fn.line("."))
end

M.close_main_win = function()
	vim.api.nvim_win_close(0, true)
end

M.move_down = function()
	print("Down pressed")
end

M.move_up = function()
	print("Up pressed")
end

M.run_script = function(which)
	print("Called run on script : " .. which)
	M.close_main_win()
end

M.show_main_win = function()
	M.populateScriptList()

	local buf = vim.api.nvim_create_buf(false, true)
	local popupOpts = {
		title = "Basher",
		line = math.floor(((vim.o.lines - 5) / 2) - 1),
		col = math.floor((vim.o.columns - 60) / 2),
		minwidth = 60,
		minheight = 5,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	}
	local _, pu = popup.create(buf, popupOpts)
	vim.api.nvim_win_set_var(pu.border.win_id, "winhl", "Basher")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Option 1", "Option 2", "Option 3" })
	vim.opt_local.number = true
	vim.opt_local.cursorline = true
	vim.opt_local.cursorlineopt = "both"
	define_popup_mappings(buf)
end

M.populateScriptList = function()
	for i, _ in ipairs(M.scriptList) do
		M.scriptList[i] = nil
	end

	local dataFile = (vim.fn.stdpath("data") .. "/basher.data")
	local file = io.open(dataFile)

	if not file then
		createNewDataFile()
	else
		print("Exists!")
	end
end

return M

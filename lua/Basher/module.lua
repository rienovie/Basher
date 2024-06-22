---@class CustomModule

local popup = require("plenary.popup")

local M = {}

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
	define_popup_mappings(buf)
end

return M

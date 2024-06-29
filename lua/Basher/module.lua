---@class CustomModule

local popup = require("plenary.popup")

local M = {}

--[[
--
-- this is an example of what the config file will look like

[config]
autochmod=true
templateDefault="basic.sh"

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

local function getSomeFun()
	local targetSingular = {
		"Basher",
		"NeoVim",
		"Linux",
		"Bash",
		"The World",
		"The Matrix",
		"AI",
		"Emacs",
		"The Algorithm",
		"The Cloud",
		"The Internet",
		"Scrum",
		"Clean Code",
	}
	local targetPlural = {
		"You",
		"Penguins",
		"Cats",
		"Dogs",
		"Developers",
		"Hackers",
		"The AI Overlords",
		"Wizards",
		"Dragons",
		"Goblins",
		"Elves",
		"Time Travelers",
	}
	local actionsSingular = {
		"loves",
		"challenges",
		"runs",
		"protects",
		"admires",
		"confides in",
		"secretly likes",
		"is scared of",
		"is jealous of",
		"mocks",
		"respects",
		"teaches",
		"depends on",
		"dreams about",
		"questions",
		"saves time using",
		"trusts",
		"understands",
		"forgives",
		"avoids",
		"blames everything on",
		"is still using",
		"envies",
		"fights against",
		"whispers about",
	}
	local actionsPlural = {
		"love",
		"challenge",
		"run",
		"protect",
		"admire",
		"confide in",
		"secretly like",
		"are scared of",
		"are jealous of",
		"mock",
		"respect",
		"teach",
		"depend on",
		"dream about",
		"question",
		"save time using",
		"trust",
		"understand",
		"forgive",
		"avoid",
		"blame everything on",
		"are still using",
		"envy",
		"fight against",
		"whisper about",
	}
	local punc = {
		".",
		"!",
		"?",
		"!?",
		"...",
		"???",
		"!!!",
	}

	math.randomseed(os.clock())
	local r = math.random(2)
	local subject = ""
	local action = ""
	if r == 1 then
		subject = targetSingular[math.random(#targetSingular)]
		action = actionsSingular[math.random(#actionsSingular)]
	else
		subject = targetPlural[math.random(#targetPlural)]
		action = actionsPlural[math.random(#actionsPlural)]
	end
	local object = ""
	r = math.random(2)
	if r == 1 then
		object = targetSingular[math.random(#targetSingular)]
	else
		object = targetPlural[math.random(#targetPlural)]
	end
	r = math.random(#punc)

	return subject .. " " .. action .. " " .. object .. punc[r]
end

local defaultDataFile = [[
[config]
autochmod=true
templateDefault="basic.sh"

]]

local basicBashTemplate = [[#!usr/bin/bash

]]

-- write the default values inside this function for now
local function createNewDataFileAndDir()
	--create basher directory
	vim.fn.mkdir(vim.fn.stdpath("data") .. "/Basher")

	--create dataFile
	io.output(vim.fn.stdpath("data") .. "/Basher/basher.data")
	io.write(defaultDataFile)
	io.write("[" .. vim.fn.getcwd() .. "]\n")
	io.close()

	--create basic bash template
	local templateDir = vim.fn.stdpath("data") .. "/Basher/Templates"
	vim.fn.mkdir(templateDir)
	io.output(templateDir .. "/basic.sh")
	io.write(basicBashTemplate)
	io.close()
end

local function doesDataFileExist()
	return not (
		vim.fs.find("Basher", { upward = false, type = "directory", path = tostring(vim.fn.stdpath("data")) })[1]
			== nil
		or vim.fs.find("basher.data", { upward = false, type = "file", path = tostring(vim.fn.stdpath("data")) })[1]
			== nil
	)
end

local function getSectionFromDataFile(sectionName)
	if not doesDataFileExist() then
		createNewDataFileAndDir()
		return nil
	end
	local filePath = vim.fn.stdpath("data") .. "/Basher/basher.data"
	local file = io.open(filePath)
	if not file then
		createNewDataFileAndDir()
		return nil
	else
		local buildString = "[" .. sectionName .. "]"
		local insideSection = false
		local output = {}
		for line in io.lines(filePath) do
			if insideSection then
				if string.sub(line, 1, 1) == "[" then
					insideSection = false
					goto continue
				elseif string.len(line) == 0 then
					goto continue
				else
					table.insert(output, line)
				end
			elseif line == buildString then
				insideSection = true
			end
			::continue:: -- lua doesn't have built-in continue :(
		end
		return output
	end
end

local function define_popup_mappings(buf)
	local function preventInsertMode()
		vim.cmd("stopinsert")
		print("boop")
	end

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
	vim.api.nvim_create_autocmd("InsertEnter", { buffer = buf, callback = preventInsertMode })
	vim.api.nvim_create_autocmd("BufLeave", { buffer = buf, callback = M.close_main_win })
end

M.scriptList = {}

M.handle_enter_key = function()
	M.run_script(vim.fn.line("."))
end

M.close_main_win = function()
	vim.cmd("set modifiable")
	MainWinOpen = false
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

M.print_some_fun = function()
	print(getSomeFun())
end

MainWinOpen = false

M.show_main_win = function()
	if MainWinOpen then
		return
	end

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
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.scriptList)
	vim.opt_local.number = true
	vim.opt_local.cursorline = true
	vim.opt_local.cursorlineopt = "both"
	vim.cmd("set nomodifiable")
	define_popup_mappings(buf)
	MainWinOpen = true
end

M.populateScriptList = function()
	for i, _ in ipairs(M.scriptList) do
		M.scriptList[i] = nil
	end

	if not doesDataFileExist() then
		createNewDataFileAndDir()
	end

	local filePath = (vim.fn.stdpath("data") .. "/Basher/basher.data")
	local file = io.open(filePath)
	local sectionData = getSectionFromDataFile(vim.fn.getcwd())
	if sectionData ~= nil then
		for _, v in pairs(sectionData) do
			table.insert(M.scriptList, v)
		end
	end
	io.close(file)
end

return M

---@class CustomModule

local popup = require("plenary.popup")

local M = {}

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

--TODO: look into zsh and if I should include a basic template for it

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
		":lua require('Basher').runSelected()<CR>",
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
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"e",
		":lua require('Basher').editSelected()<CR>",
		{ noremap = true, silent = true})
	vim.api.nvim_create_autocmd("InsertEnter", { buffer = buf, callback = preventInsertMode })
	vim.api.nvim_create_autocmd("BufLeave", { buffer = buf, callback = M.close_main_win })
end

M.scriptList = {}
--[[
--"FL" = full line text
--"Num" = order
--"Alias" = name to represent
--"File" = full path to file
--"Args" = additional arguments
--]]

local function pushToSL(fullLine)
	local output = {}
	output["FL"] = fullLine
	local sBuild = ""
	local bIndexDetermined = false
	local bAliasDetermined = false
	local bFileDetermined = false
	local bEscSpace = false -- used to check if space doesn't end filepath
	local c = ""
	for i = 1, #fullLine do
		c = string.sub(fullLine, i, i)
		if not bIndexDetermined then
			sBuild = sBuild .. c
			if string.sub(fullLine,i+1,i+1) == "_" then
				output["Num"] = tonumber(sBuild)
				sBuild = ""
				bIndexDetermined = true
				goto continue
			else
				goto continue
			end
		end

		if not bAliasDetermined then
			if c == "_" then goto continue end
			if c == "=" then
				bAliasDetermined = true
				if string.len(sBuild) == 0 then
					output["Alias"] = nil
					goto continue
				else
					output["Alias"] = sBuild
					sBuild = ""
					goto continue
				end
			end
			sBuild = sBuild .. c
			goto continue
		end

		if c == "\\" then
			bEscSpace = true
			sBuild = sBuild .. c
			goto continue
		end
		if not bFileDetermined then
			if c == " " and not bEscSpace then
				output["File"] = sBuild
				sBuild = ""
				bFileDetermined = true
				goto continue
			elseif i == #fullLine then
				sBuild = sBuild .. c
				output["File"] = sBuild
				sBuild = ""
				goto continue
			end
		end

		sBuild = sBuild .. c
		bEscSpace = false
		::continue::
	end

	if string.len(sBuild) >= 1 then
		output["Args"] = sBuild
	end

	table.insert(M.scriptList, output)
end

local function getMainLines()
	local output = {}
	for _, value in pairs(M.scriptList) do
		if value["Alias"] == nil then
			local fp = value["File"]
			local slashCount = 2 -- TODO: create user config option
			local curSlashCount = 0
			local bAdded = false
			for i = #fp, 1, -1 do
				if string.sub(fp,i,i) == "/" then
					curSlashCount = curSlashCount + 1
					if curSlashCount >= slashCount then
						table.insert(output,"..." .. string.sub(fp,i))
						bAdded = true
						break
					end
				end
			end
			if not bAdded then
				table.insert(output, fp)
			end
		else
			table.insert(output, value["Alias"])
		end
	end

	return output
end

local function sortSL()
	table.sort(M.scriptList, function(a,b) return a.Num < b.Num end)
end

local function rebuildSLFullLines()
	local sBuild = ""
	for _, v in ipairs(M.scriptList) do
		sBuild = tostring(v["Num"]) .. "_"
		if v["Alias"] ~= nil then
			sBuild = sBuild .. v["Alias"]
		end
		sBuild = sBuild .. "=" .. v["File"]
		if v["Args"] ~= nil then
			sBuild = sBuild .. " " .. v["Args"]
		end
		v["FL"] = sBuild
	end
end

-- Assumes file exists, TODO: maybe handle if not?
local function writeScriptListToFile()
	local sectionHeader = "[" .. vim.fn.getcwd() .. "]"
	local bInsideSection = false
	local finalFile = ""
	local dFilePath = vim.fn.stdpath("data") .. "/Basher/basher.data"
	for line in io.lines(dFilePath) do
		if bInsideSection then
			if string.sub(line,1,1) == "[" then
				bInsideSection = false
				finalFile = finalFile .. line .. "\n"
			end
		else
			if line == sectionHeader then
				bInsideSection = true
			else
				finalFile = finalFile .. line .. "\n"
			end
		end
	end

	rebuildSLFullLines() -- just in case
	local newSection = "[" .. vim.fn.getcwd() .. "]\n"
	if #M.scriptList ~= 0 then
		for _, value in pairs(M.scriptList) do
			newSection = newSection .. value["FL"] .. "\n"
		end
	end

	finalFile = finalFile .. newSection .. "\n"

	io.output(dFilePath)
	io.write(finalFile)
	io.close()

end

local function populateScriptList()
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
			pushToSL(v)
		end
	end
	io.close(file)

	sortSL()
end

M.run_selected = function()
	M.run_script(vim.fn.line("."))
end

M.close_main_win = function()
	vim.cmd("set modifiable")
	writeScriptListToFile()
	MainWinOpen = false
	vim.api.nvim_win_close(0, true)
end

M.move_down = function()
	local lineNum = vim.fn.line(".")
	if lineNum == vim.api.nvim_buf_line_count(CurrentBuf) then
		return
	else
		M.scriptList[lineNum].Num = lineNum + 1
		M.scriptList[lineNum + 1].Num = lineNum
		sortSL()
		rebuildSLFullLines()
		vim.cmd("set modifiable")
		vim.cmd("m +1")
		vim.cmd("set nomodifiable")
	end
end

M.move_up = function()
	local lineNum = vim.fn.line(".")
	if lineNum == 1 then
		return
	else
		M.scriptList[lineNum].Num = lineNum - 1
		M.scriptList[lineNum - 1].Num = lineNum
		sortSL()
		rebuildSLFullLines()
		vim.cmd("set modifiable")
		vim.cmd("m -2")
		vim.cmd("set nomodifiable")
	end
end

M.run_script = function(scriptIndex)
	if M.scriptList[scriptIndex] == nil then
		M.close_main_win()
		return
	end
	local cmdLine = "!sh " .. M.scriptList[scriptIndex].File
	if M.scriptList[scriptIndex].Args ~= nil then
		cmdLine = cmdLine .. " " .. M.scriptList[scriptIndex].Args
	end
	vim.cmd(cmdLine)
	M.close_main_win()
end

M.edit_selected = function ()
	M.edit_script(vim.fn.line("."))
end

M.edit_script = function (scriptIndex)
	M.close_main_win()
	vim.cmd("e " .. M.scriptList[scriptIndex].File)
end

M.print_some_fun = function()
	print(getSomeFun())
end

MainWinOpen = false

M.show_main_win = function()
	if MainWinOpen then
		return
	end

	populateScriptList()

	CurrentBuf = vim.api.nvim_create_buf(false, true)
	local popupOpts = {
		title = "Basher",
		line = math.floor(((vim.o.lines - 5) / 2) - 1),
		col = math.floor((vim.o.columns - 60) / 2),
		minwidth = 60,
		minheight = 5,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	}
	local _, pu = popup.create(CurrentBuf, popupOpts)
	vim.api.nvim_win_set_var(pu.border.win_id, "winhl", "Basher")
	vim.api.nvim_buf_set_lines(CurrentBuf, 0, -1, false, getMainLines())
	vim.opt_local.number = true
	vim.opt_local.cursorline = true
	vim.opt_local.cursorlineopt = "both"
	vim.cmd("set nomodifiable")
	define_popup_mappings(CurrentBuf)
	MainWinOpen = true

end



return M

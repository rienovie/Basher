---@class CustomModule

local popup = require("plenary.popup")
local plenary = require("plenary.scandir")

local M = {}

M.ModWinOpen = false
M.MainWinOpen = false
M.CreateWinOpen = false
M.BorderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
M.CurrentModifyScript = nil
M.ModBuf = nil
M.MainBuf = nil
M.CreateBuf = nil
M.templateList = {}

--Config Vars
M.PrintFunOnStart = true
M.FunOnScriptCreate = true
M.PathMax = 2
M.AutochmodX = true
M.SilencePrints = false
M.DefaultNewLocation = "bash"

M.scriptList = {}
--[[
--"FL" = full line text
--"Num" = order
--"Alias" = name to represent
--"File" = full path to file
--"Args" = additional arguments
--]]

local function getSomeFun()
	local targetSingular = {
		"Basher",
		"Neovim",
		"Vi",
		"Vim",
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
		"Rust",
		"C++",
		"M*croS*ft",
		"The Fruit Company",
		"C",
		"C#",
		"Lua",
		"JavaScript",
		"HTML",
		"CSS",
		"PHP",
		"Java",
		"Arch (I use it by the way)",
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

local basicBashTemplate = [[#!usr/bin/bash

]]

--TODO: look into zsh and if I should include a basic template for it

local function createNewDataFileAndDir()
	--create basher directory
	vim.fn.mkdir(vim.fn.stdpath("data") .. "/Basher")

	--create dataFile
	io.output(vim.fn.stdpath("data") .. "/Basher/basher.data")
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

local function definePopupMappingsMain()
	vim.api.nvim_create_autocmd("BufLeave", { buffer = M.MainBuf, callback = M.close_main_win })

	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"<CR>",
		":lua require('Basher').runSelected()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"<Esc>",
		":lua require('Basher').closeMainWin()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"<S-d>",
		":lua require('Basher').moveDown()<CR>",
		{ noremap = true, silent = true, desc = "[M]ove [D]own" }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"<S-u>",
		":lua require('Basher').moveUp()<CR>",
		{ noremap = true, silent = true, desc = "[M]ove [U]p" }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"1",
		":lua require('Basher').runScript(1)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"2",
		":lua require('Basher').runScript(2)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"3",
		":lua require('Basher').runScript(3)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"4",
		":lua require('Basher').runScript(4)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"5",
		":lua require('Basher').runScript(5)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"e",
		":lua require('Basher').editSelected()<CR>",
		{ noremap = true, silent = true } )
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"m",
		":lua require('Basher').modifySelected()<CR>",
		{ noremap = true, silent = true } )
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"a",
		":lua require('Basher').addScript()<CR>",
		{ noremap = true, silent = true } )
	vim.api.nvim_buf_set_keymap(
		M.MainBuf,
		"n",
		"c",
		":lua require('Basher').openCreateWin()<CR>",
		{ noremap = true, silent = true } )

end


-- TODO: make sure works with weird directory names and such
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
		if value["File"] == nil then
			table.insert(output, "Error!")
			goto continue
		end
		if value["Alias"] == nil then
			local fp = value["File"]
			local slashCount = M.PathMax
			if slashCount == 0 then
				slashCount = 127
			else
				slashCount = slashCount + 1
			end
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
	    ::continue::
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
		sBuild = sBuild .. "="
		if v["File"] ~= nil then
			sBuild = sBuild .. v["File"]
		end
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

local function definePopupMappingsMod()
	vim.api.nvim_create_autocmd("BufLeave", {buffer = M.ModBuf, callback = M.close_modify_win})
	vim.api.nvim_buf_set_keymap(
		M.ModBuf,
		"n",
		"<Esc>",
		"<cmd>:lua require('Basher').closeModifyWin()<CR>",
		{ noremap = true, silent = true})
	vim.api.nvim_buf_set_keymap(
		M.ModBuf,
		"n",
		"<C-x>",
		"<cmd>:lua require('Basher').removeScript()<CR>",
		{ noremap = true, silent = true })

	-- HACK: function does not allow multiple modes so must do twice
	vim.api.nvim_buf_set_keymap(
		M.ModBuf,
		"n",
		"<C-s>",
		"<cmd>:lua require('Basher').saveScriptOptions()<CR>",
		{ noremap = true, silent = true})
	vim.api.nvim_buf_set_keymap(
		M.ModBuf,
		"i",
		"<C-s>",
		"<cmd>:lua require('Basher').saveScriptOptions()<CR>",
		{ noremap = true, silent = true})

end

M.close_modify_win = function ()
	if not M.ModWinOpen then
		return
	end
	M.ModWinOpen = false
	if vim.api.nvim_get_mode()["mode"] == "i" then
		vim.cmd('stopinsert')
	end
	vim.api.nvim_win_close(0, true)
	M.ModBuf = nil
	M.CurrentModifyScript = nil
	M.open_main_win()
end

local function openModifyWin(scriptIndex)
	if M.ModWinOpen or M.CreateWinOpen then
		return
	end
	M.ModWinOpen = true
	M.close_main_win()

	M.CurrentModifyScript = scriptIndex

	local script = M.scriptList[M.CurrentModifyScript]
	if script == nil then
		return
	end
	local lines = {}
	if script["File"] == nil then
		table.insert(lines, "File=")
	else
		table.insert(lines, 'File=' .. script["File"])
	end
	if script["Args"] == nil then
		table.insert(lines, 'Arguments=')
	else
		table.insert(lines, 'Arguments=' .. script["Args"])
	end
	if script["Alias"] == nil then
		table.insert(lines, 'Alias=')
	else
		table.insert(lines, 'Alias=' .. script["Alias"])
	end

	M.ModBuf = vim.api.nvim_create_buf(false, true)
	local popupOpts = {
		title = " ╔╣Modify╠╗  <Ctrl-S> Save | <Ctrl-X> Remove Script | <Esc> Cancel ",
		line = math.floor(((vim.o.lines - 5) / 2) - 1),
		col = math.floor((vim.o.columns - 75) / 2),
		minwidth = 75,
		minheight = 5,
		borderchars = M.BorderChars,
	}
	local _, pu = popup.create(M.ModBuf, popupOpts)
	vim.api.nvim_win_set_var(pu.border.win_id, "winhl", 'Modify Script Options')
	vim.api.nvim_buf_set_lines(M.ModBuf, 0, -1, false, lines)
	vim.cmd("set modifiable")
	vim.api.nvim_feedkeys("A", "n", true)

	definePopupMappingsMod()
end

local function definePopupMappingsCreate()
	vim.api.nvim_create_autocmd("BufLeave", { buffer = M.CreateBuf, callback = M.close_create_win })

	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"<CR>",
		":lua require('Basher').newFromTemplateCurLine()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"<Esc>",
		":lua require('Basher').closeCreateWin()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"<C-r>",
		":lua require('Basher').refreshTemplateList()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"e",
		":lua require('Basher').editSelectedTemplate()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"1",
		":lua require('Basher').newFromTemplateLine(1)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"2",
		":lua require('Basher').newFromTemplateLine(2)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"3",
		":lua require('Basher').newFromTemplateLine(3)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"4",
		":lua require('Basher').newFromTemplateLine(4)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		M.CreateBuf,
		"n",
		"5",
		":lua require('Basher').newFromTemplateLine(5)<CR>",
		{ noremap = true, silent = true }
	)
end

local function getTemplateList()
	local tList = plenary.scan_dir(vim.fn.stdpath("data") .. "/Basher/Templates")
	local output = {}

	for _,value in pairs(tList) do
		local _,e = string.find(string.reverse(value), "/")
		if e == nil then
			error("Problem in getting template list! For some reason a value of: " .. value .. " was found in TemplateDir!")
			goto continue
		end
		table.insert(output, string.sub(value,string.len(value) - e + 2,string.len(value) - 3))
	    ::continue::
	end

	return output
end

local function doesTemplateExist(nameToCheck)
	for _, value in pairs(M.templateList) do
		if value == nameToCheck then
			return true
		end
	end
	return false
end

M.save_script_options = function ()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local curKey
	local curValue
	local eqIndex
	local countCheck = 0
	local script = M.scriptList[M.CurrentModifyScript]

	for _,ln in pairs(lines) do
		_, eqIndex = string.find(ln, "=")
		if eqIndex == nil then
			goto continue
		end
		curKey = string.sub(ln,0,eqIndex-1)
		curValue = string.sub(ln,eqIndex+1)
		-- TODO: account for more input errors if needed
		if curKey == "File" then
			if curValue == "" then
				error("Could not save! No file given!")
				goto leaveFunc
			end
			script["File"] = curValue
			countCheck = countCheck + 1
		elseif curKey == "Arguments" then
			if curValue ~= "" then
				script["Args"] = curValue
			else
				script["Args"] = nil
			end
			countCheck = countCheck + 1
		elseif curKey == "Alias" then
			if curValue ~= "" then
				script["Alias"] = curValue
			else
				script["Alias"] = nil
			end
			countCheck = countCheck + 1
		end

	    ::continue::
	end
	if countCheck ~= 3 then
		error("Could not save! Incorrect number of options!")
		goto leaveFunc
	end

	rebuildSLFullLines()
	writeScriptListToFile()

	::leaveFunc::
	M.close_modify_win()
end

M.modify_selected = function ()
	M.modify_script(vim.fn.line("."))
end

M.modify_script = function (scriptIndex)
	openModifyWin(scriptIndex)
end

M.run_selected = function()
	M.run_script(vim.fn.line("."))
end

M.close_main_win = function()
	if not M.MainWinOpen then
		return
	end
	vim.cmd("set modifiable")
	writeScriptListToFile()
	M.MainWinOpen = false
	vim.api.nvim_win_close(0, true)
	M.MainBuf = nil
end

M.move_down = function()
	local lineNum = vim.fn.line(".")
	if lineNum == vim.api.nvim_buf_line_count(M.MainBuf) then
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
		return
	end
	local cmdLine = "!sh " .. M.scriptList[scriptIndex].File
	if M.scriptList[scriptIndex].Args ~= nil then
		cmdLine = cmdLine .. " " .. M.scriptList[scriptIndex].Args
	end
	vim.cmd(cmdLine)
	M.close_main_win()
end

M.run_script_from_alias = function(scriptAlias)
	if #M.scriptList == 0 then
		populateScriptList()
	end

	for i,val in ipairs(M.scriptList) do
		if val["Alias"] ~= nil and val["Alias"] == scriptAlias then
			M.run_script(i)
			return
		end
	end

	error("Script with alias: " .. scriptAlias .. " was not found!")
end

local function editScript(scriptIndex)
	M.close_main_win()
	vim.cmd("e " .. M.scriptList[scriptIndex].File)
end
M.edit_selected = function ()
	editScript(vim.fn.line("."))
end


M.print_some_fun = function()
	print(getSomeFun())
end


M.open_main_win = function()
	if M.MainWinOpen then
		return
	end
	M.MainWinOpen = true

	if M.PrintFunOnStart then
		M.print_some_fun()
	end

	populateScriptList()

	M.MainBuf = vim.api.nvim_create_buf(false, true)
	local popupOpts = {
		title = " ╔╣Basher╠╗  [E]dit | [M]odify | [C]reate | [A]dd ",
		line = math.floor(((vim.o.lines - 5) / 2) - 1),
		col = math.floor((vim.o.columns - 60) / 2),
		minwidth = 60,
		minheight = 5,
		borderchars = M.BorderChars,
	}
	local _, pu = popup.create(M.MainBuf, popupOpts)
	vim.api.nvim_win_set_var(pu.border.win_id, "winhl", "Basher")
	vim.api.nvim_buf_set_lines(M.MainBuf, 0, -1, false, getMainLines())
	vim.opt_local.number = true
	vim.opt_local.cursorline = true
	vim.opt_local.cursorlineopt = "both"
	vim.cmd("set nomodifiable")
	definePopupMappingsMain()

end

M.toggle_main_win = function()
	if M.ModWinOpen or M.CreateWinOpen then
		return
	end

	if M.MainWinOpen then
		M.close_main_win()
	else
		M.open_main_win()
	end
end

M.add_script = function()
	if M.ModWinOpen or M.CreateWinOpen then
		return
	end

	if M.MainWinOpen then
		M.close_main_win()
	else
		populateScriptList()
	end

	local newIndex = #M.scriptList + 1
	pushToSL(tostring(newIndex) .. "_=")
	openModifyWin(newIndex)

end

M.add_current_script = function (showModWin)
	if M.ModWinOpen or M.CreateWinOpen then
		return
	end

	if M.MainWinOpen then
		M.close_main_win()
	else
		populateScriptList()
	end

	local curFile = vim.api.nvim_buf_get_name(0)

	if string.sub(curFile, -2) ~= "sh" then
		error(curFile .. "is not a bash script!")
		return
	end

	local newIndex = #M.scriptList + 1
	local newFL = tostring(newIndex) .. "_=" .. curFile
	pushToSL(newFL)
	if showModWin then
		openModifyWin(newIndex)
	else
		if not M.SilencePrints then
			vim.print("Script " .. curFile .. " was added to Basher.")
		end
	end

	writeScriptListToFile()

end

M.add_current_script_as_template = function ()
	if M.MainWinOpen or M.ModWinOpen then
		return
	end

	local fullPath = vim.api.nvim_buf_get_name(0)
	if string.sub(fullPath, -2) ~= "sh" then
		error(fullPath .. " is not a bash script!")
		return
	end

	local fileLines = vim.api.nvim_buf_get_lines(0, 0, -1,false)
	local finalOut = ""
	for _, value in ipairs(fileLines) do
		finalOut = finalOut .. value .. "\n"
	end
	local _, fileNameStartIndex = string.find(fullPath,vim.fn.getcwd(0))
	if fileNameStartIndex == nil then
		error("File name error " .. fullPath)
		return
	end
	fileNameStartIndex = fileNameStartIndex + 2

	local newTemplateName = string.sub(fullPath,fileNameStartIndex, -1)
	local newFilePath = vim.fn.stdpath("data") .. "/Basher/Templates/" .. newTemplateName
	if io.open(newFilePath) ~= nil then
		error("Template: " .. newTemplateName .. " already exists!")
		return
	end

	io.output(newFilePath)
	io.write(finalOut)
	io.close()

end

M.remove_script = function ()
	if not M.ModWinOpen then
		return
	end

	table.remove(M.scriptList, M.CurrentModifyScript)
	writeScriptListToFile()

	M.close_modify_win()
end

M.open_create_win = function ()
	if M.CreateWinOpen or M.ModWinOpen then
		return
	end

	if M.MainWinOpen then
		M.close_main_win()
	end
	M.CreateWinOpen = true

	populateScriptList()

	M.CreateBuf = vim.api.nvim_create_buf(false,true)
	local popupOpts = {
		title = " ╔╣Template╠╗  [E]dit | <Ctrl-R> Refresh | <Esc> Cancel ",
		line = math.floor(((vim.o.lines - 5) / 2) - 1),
		col = math.floor((vim.o.columns - 60) / 2),
		minwidth = 60,
		minheight = 5,
		borderchars = M.BorderChars,
	}
	local _,pu = popup.create(M.CreateBuf, popupOpts)
	vim.api.nvim_win_set_var(pu.border.win_id, "winhl", "Create From Template")
	vim.api.nvim_buf_set_lines(M.CreateBuf,0,-1,false,M.templateList)
	vim.opt_local.number = true
	vim.opt_local.cursorline = true
	vim.opt_local.cursorlineopt = "both"
	vim.cmd("set nomodifiable")
	definePopupMappingsCreate()


end



M.close_create_win = function ()
	if not M.CreateWinOpen then
		return
	end
	vim.cmd("set modifiable")
	M.CreateWinOpen = false
	vim.api.nvim_win_close(0, true)
	M.CreateBuf = nil

	M.open_main_win()
end

M.refresh_template_list = function ()
	M.templateList = getTemplateList()
	if #M.templateList == 0 then
		error("No Basher Templates found in NvimData/Basher/Templates!")
	else
		if not M.SilencePrints then
			vim.print("Basher Templates populated.")
		end
	end
	if M.CreateWinOpen then
		vim.cmd("set modifiable")
		vim.api.nvim_buf_set_lines(M.CreateBuf,0,-1,false,M.templateList)
		vim.cmd("set nomodifiable")
	end
end

local function doesDefaultDirExist()
	for n, t in vim.fs.dir(vim.fn.getcwd()) do
		if t == "directory" and n == M.DefaultNewLocation then
			return true
		end
	end

	return false
end

M.new_from_template = function (templateName)
	if M.templateList[templateName] == nil then
		M.refresh_template_list()
		if not doesTemplateExist(templateName) then
			error("Template " .. templateName .. " was not found! Please check NvimData/Basher/Templates")
			return
		end
	end
	if M.CreateWinOpen then
		M.close_create_win()
	end
	if M.ModWinOpen then
		M.close_modify_win()
	end
	if M.MainWinOpen then
		M.close_main_win()
	end

	local name = vim.fn.input("Please enter name of new script...")
	if #name == 0 then
		return
	end
	-- TODO: check for invalid file name input
	if doesTemplateExist(name) then
		error("\n\nTemplate with name " .. name .. " already exists!\n\nUnable to create template!")
		return
	end

	local filePath = M.DefaultNewLocation .. "/" .. name .. ".sh"

	if not doesDefaultDirExist() then
		vim.fn.mkdir(M.DefaultNewLocation, "p")
	end

	--Will discard any changes on current buffer  TODO: maybe give warning?
	vim.cmd(":edit! " .. filePath)

	--Shouldn't fail but  TODO: make sure it doesn't
	local templateFullPath = vim.fn.stdpath("data") .. "/Basher/Templates/" .. templateName .. ".sh"
	local finalLines = {}
	for value in io.lines(templateFullPath) do
		table.insert(finalLines, value)
	end
	if type(finalLines) ~= "table" then
		error("Type error when reading Template file: " .. templateFullPath .. " returned type " .. tostring(type(finalLines)))
		return
	end
	table.insert(finalLines, "# Made with Basher")
	if M.FunOnScriptCreate then
		table.insert(finalLines, "# " .. getSomeFun())
	end
	-- HACK: cannot use \n in strings, so bleh
	table.insert(finalLines, "")
	table.insert(finalLines, "")

	vim.api.nvim_buf_set_lines(0, 0, -1, false, finalLines)
	vim.cmd(":w")
	vim.api.nvim_feedkeys("GA", "n", false)

	M.add_current_script(false)
end

M.new_from_template_cur_line = function()
	M.new_from_template(vim.fn.getline(vim.fn.line(".")))
end

M.new_from_template_line = function (lineNumber)
	if not M.CreateWinOpen then
		return
	end

	local line = vim.api.nvim_buf_get_lines(0, lineNumber - 1, lineNumber, false)[1]

	if line == nil then
		return
	end

	M.new_from_template(line)
end

M.init = function(opts)
	M.PrintFunOnStart = opts.funOnStart
	M.PathMax = opts.pathMaxDirs
	M.AutochmodX = opts.autoMakeExec
	M.FunOnScriptCreate = opts.funOnCreate
	M.SilencePrints = opts.silencePrints
	M.DefaultNewLocation = opts.defaultNewLocation

	populateScriptList()
	M.refresh_template_list()
end

M.edit_selected_template = function()
	if not M.CreateWinOpen then
		return
	end

	local curLine = vim.fn.getline(vim.fn.line("."))
	M.close_create_win()
	M.close_main_win()

	local fullPath = vim.fn.stdpath("data") .. "/Basher/Templates/" .. curLine .. ".sh"
	vim.cmd(":edit! " .. fullPath)

end

return M

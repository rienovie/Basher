-- main module file
local module = require("Basher.module")

---@class Config
local config = {
	-- Prints fun message whenever main window opens
	funOnStart = true,

	-- When creating new bash script, automatically mark the file as executable
	autochmod = true,

	-- Max amount of prior directories shown when file has no alias
	pathMaxDirs = 2,
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
	M.PrintFunOnStart = M.config.funOnStart
	M.PathMax = M.config.pathMaxDirs
end

M.showMainWin = function()
	return module.show_main_win()
end

M.runSelected = function()
	return module.run_selected()
end

M.closeMainWin = function()
	return module.close_main_win()
end

M.moveDown = function()
	return module.move_down()
end

M.moveUp = function()
	return module.move_up()
end

M.runScript = function(scriptIndex)
	return module.run_script(scriptIndex)
end

M.editScript = function(scriptIndex)
	return module.edit_script(scriptIndex)
end

M.editSelected = function()
	return module.edit_selected()
end

M.printSomeFun = function()
	return module.print_some_fun()
end

M.modifySelected = function()
	return module.modify_selected()
end

M.closeModifyWin = function()
	return module.close_modify_win()
end

M.saveScriptOptions = function()
	return module.save_script_options()
end

M.addScript = function()
	return module.add_script()
end

M.removeScript = function()
	return module.remove_script()
end

return M

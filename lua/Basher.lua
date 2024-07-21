-- main module file
local module = require("Basher.module")

---@class Config
local config = {
	-- Prints fun message whenever main window opens
	funOnStart = true,

	-- When creating new bash script, automatically mark the file as executable
	autoMakeExec = true,

	-- Max amount of prior directories shown when file has no alias
	pathMaxDirs = 2,

	-- When creating new bash script, adds a fun comment
	funOnCreate = true,

	-- Silence general prints giving updates
	-- i.e. script added / templates populated
	silencePrints = false,
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
	M.AutochmodX = M.config.autoMakeExec
	M.FunOnScriptCreate = M.config.funOnCreate
	M.SilencePrints = M.config.silencePrints

	module.init()
end

M.openMainWin = function()
	return module.open_main_win()
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

M.addCurrentScript = function(bShowModWin)
	return module.add_current_script(bShowModWin)
end

M.addCurrentScriptAsTemplate = function()
	return module.add_current_script_as_template()
end

M.openCreateWin = function()
	return module.open_create_win()
end

M.closeCreateWin = function()
	return module.close_create_win()
end

M.refreshTemplateList = function()
	return module.refresh_template_list()
end

M.newFromTemplate = function(templateName)
	return module.new_from_template(templateName)
end

M.newFromTemplateCurLine = function()
	return module.new_from_template_cur_line()
end

M.editSelectedTemplate = function()
	return module.edit_selected_template()
end

M.newFromTemplateLine = function(lineNumber)
	return module.new_from_template_line(lineNumber)
end

M.runScriptFromAlias = function(scriptAlias)
	return module.run_script_from_alias(scriptAlias)
end

M.toggleMainWin = function()
	return module.toggle_main_win()
end

return M

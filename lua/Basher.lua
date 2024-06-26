-- main module file
local module = require("Basher.module")

---@class Config
---@field opt string Your config option
local config = {
	opt = "Hello!",
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

	--module.populateScriptList()
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

return M

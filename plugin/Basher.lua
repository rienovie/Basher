--#region Useful Functions
--These are the functions you should know about

--This is probably the function you'll use the most
vim.api.nvim_create_user_command("RunScriptFromAlias", function(opts)
	require("Basher").runScriptFromAlias(opts.args)
end, { nargs = 1 })

--This is probably the function you'll use the second most
--The input is the name of the template i.e newFromTemplate("basic")
vim.api.nvim_create_user_command("NewFromTemplate", function(opts)
	require("Basher").newFromTemplate(opts.args)
end, { nargs = 1 })

--This will bring up a modify window that'll allow you to explictly add a script to Basher
vim.api.nvim_create_user_command("AddScript", require("Basher").addScript, {})

--This will add the current open file to Basher if it's a bash script
--Bool input determines if you want to bring up the modify window after adding
vim.api.nvim_create_user_command("AddCurrentScript", function(opts)
	require("Basher").addCurrentScript(opts.args)
end, { nargs = 1 })

--This will copy the current open file and save it as a template to "NvimData/Basher/Templates"
--This DOES NOT change the current open buffer to the new file
--Any changes made to the current open buffer after adding WILL NOT save to the Template
--If you want to edit the template after adding it, you can open the Create window and edit it from there
vim.api.nvim_create_user_command("AddCurrentScriptAsTemplate", require("Basher").addCurrentScriptAsTemplate, {})

--#endregion

--#region MainWin
--These functions will mostly only work inside the Main Win

vim.api.nvim_create_user_command("ToggleMainWin", require("Basher").toggleMainWin, {})
vim.api.nvim_create_user_command("OpenMainWin", require("Basher").openMainWin, {})
vim.api.nvim_create_user_command("CloseMainWin", require("Basher").closeMainWin, {})
vim.api.nvim_create_user_command("RunSelected", require("Basher").runSelected, {})
vim.api.nvim_create_user_command("EditSelected", require("Basher").editSelected, {})

-- Will open the Modify Win
vim.api.nvim_create_user_command("ModifySelected", require("Basher").modifySelected, {})

--This takes an input which is the line number the script is on
--i.e. if you want to run the script on line 3 in the main win you could hit "3"
--The scripts stay in the same order so you could shortcut with this
vim.api.nvim_create_user_command("RunScript", function(opts)
	require("Basher").runScript(opts.args)
end, { nargs = 1 })

-- These will change the order of the scripts
-- Use <Shift-U> and <Shift-D>
-- Only works for the Main Win
vim.api.nvim_create_user_command("MoveUp", require("Basher").moveUp, {})
vim.api.nvim_create_user_command("MoveDown", require("Basher").moveDown, {})

--#endregion

--#region Modify window
--These functions will only work inside the Modify Win

--This WILL NOT delete the script on disk, just remove from Basher
vim.api.nvim_create_user_command("RemoveScript", require("Basher").removeScript, {})

--Saves the current info to disk
vim.api.nvim_create_user_command("SaveScriptOptions", require("Basher").saveScriptOptions, {})

vim.api.nvim_create_user_command("CloseModifyWin", require("Basher").closeModifyWin, {})

--#endregion

--#region Create Window
--You can open the Create Window without going thru the Main Window
vim.api.nvim_create_user_command("OpenCreateWin", require("Basher").openCreateWin, {})
vim.api.nvim_create_user_command("CloseCreateWin", require("Basher").closeCreateWin, {})

--Will create and open a new bash script from the selected Template
vim.api.nvim_create_user_command("NewFromTemplateCurLine", require("Basher").newFromTemplateCurLine, {})

--Will open and edit the selected template file in the current buffer
--This is how you can update and modify templates after they have been added
vim.api.nvim_create_user_command("EditSelectedTemplate", require("Basher").editSelectedTemplate, {})

--You can use the number keys to create a new script based on the template on that line number
vim.api.nvim_create_user_command("NewFromTemplateLine", function(opts)
	require("Basher").newFromTemplateLine(opts.args)
end, { nargs = 1 })
--#endregion

--#region Misc
--If you want to manually refresh the Template list
vim.api.nvim_create_user_command("RefreshTemplateList", require("Basher").refreshTemplateList, {})

--Have some fun :)
vim.api.nvim_create_user_command("PrintSomeFun", require("Basher").printSomeFun, {})
--#endregion

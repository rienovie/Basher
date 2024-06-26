vim.api.nvim_create_user_command("ShowMainWin", require("Basher").showMainWin, {})
vim.api.nvim_create_user_command("RunSelected", require("Basher").runSelected, {})
vim.api.nvim_create_user_command("EditSelected", require("Basher").editSelected, {})
vim.api.nvim_create_user_command("CloseMainWin", require("Basher").closeMainWin, {})
vim.api.nvim_create_user_command("MoveDown", require("Basher").moveDown, {})
vim.api.nvim_create_user_command("MoveUp", require("Basher").moveUp, {})
vim.api.nvim_create_user_command("RunScript", function(opts)
	require("Basher").runScript(opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command("EditScript", function(opts)
	require("Basher").editScript(opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command("PrintSomeFun", require("Basher").printSomeFun, {})

local ok, laravel = pcall(require, "laravel")
if not ok then
	return
end

local artisan = require("laravel.artisan")
local notify = require("notify")

laravel.setup()

vim.keymap.set("n", "<leader>ac", function()
	artisan.clean_cmd_list_cache()
	notify.notify("Artisan cmd list cache clean", "info", { title = "Laravel.nvim" })
end, { noremap = true })

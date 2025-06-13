local M = {}

M.open_popup = function()
  require("jsonifyenv.ui").open_popup()
end

M.setup = function(opts)
  -- Optionally accept user config here
  vim.api.nvim_create_user_command("JsonifyEnv", require("jsonifyenv.runner"), { nargs = "?" })

  vim.keymap.set("n", "j{", M.open_popup, { desc = "Open JsonifyEnv UI" })
end

return M

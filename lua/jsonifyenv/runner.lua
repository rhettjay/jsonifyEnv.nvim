local state = require("jsonifyenv.state")

return function(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local env_table = {}

  for _, line in ipairs(lines) do
    local key, val = string.match(line, "^%s*([%w_]+)%s*=%s*(.-)%s*$")
    if key and val then
      val = val:gsub('^["\']', ''):gsub('["\']$', '')
      env_table[key] = val
    end
  end

  local ok, json = pcall(vim.fn.json_encode, env_table)
  if not ok then
    print("JSON encode error:", json)
    return
  end

  local args = opts.args or ""
  local function has_flag(f) return args:find(f) end
  local file = args:match("write=([%w%._/-]+)")

  if has_flag("pretty") and vim.fn.executable("jq") == 1 then
    local handle = io.popen("echo '" .. json .. "' | jq .")
    if handle then json = handle:read("*a"); handle:close() end
  end

  if file then
    local f = io.open(file, "w")
    if f then f:write(json); f:close(); print("Written to: " .. file) end
  end

  if has_flag("clip") then
    vim.fn.setreg("+", json)
    print("Copied to clipboard.")
  end

  if has_flag("replace") or args == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(json, "\n"))
  end
end

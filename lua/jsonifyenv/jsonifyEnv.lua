local M = {}

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

-- Shared state
local jsonify_flags = {
  pretty = false,
  clip = false,
  replace = true,
  write = nil,
}

-- Run :JsonifyEnv with current flags
local function run_jsonify_env()
  local args = {}
  for k, v in pairs(jsonify_flags) do
    if k == "write" and v then
      table.insert(args, "write=" .. v)
    elseif v == true then
      table.insert(args, k)
    end
  end
  vim.cmd("JsonifyEnv " .. table.concat(args, " "))
end

-- Open animated popup
function M.open_popup()
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = { top = " JsonifyEnv " },
    },
    position = "50%",
    size = {
      width = 50,
      height = 10,
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  local function refresh()
    local lines = {
      "Select Flags:",
      "",
      "[p] Pretty     : " .. tostring(jsonify_flags.pretty),
      "[c] Clipboard  : " .. tostring(jsonify_flags.clip),
      "[r] Replace    : " .. tostring(jsonify_flags.replace),
      "[w] Write File : " .. (jsonify_flags.write or "nil"),
      "",
      "[j] ▶ Run with current flags",
      "[q] ✖ Close",
    }
    popup:buf_set_lines(0, 0, -1, false, lines)
  end

  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  popup:map("n", "p", function()
    jsonify_flags.pretty = not jsonify_flags.pretty
    refresh()
  end)
  popup:map("n", "c", function()
    jsonify_flags.clip = not jsonify_flags.clip
    refresh()
  end)
  popup:map("n", "r", function()
    jsonify_flags.replace = not jsonify_flags.replace
    refresh()
  end)
  popup:map("n", "w", function()
    vim.ui.input({ prompt = "Filename to write to:" }, function(input)
      jsonify_flags.write = input ~= "" and input or nil
      refresh()
    end)
  end)
  popup:map("n", "j", function()
    popup:unmount()
    run_jsonify_env()
  end)
  popup:map("n", "q", function()
    popup:unmount()
  end)

  popup:mount()
  refresh()

  -- Animate open (scale-up)
  local anim_timer = vim.loop.new_timer()
  local step, total = 1, 5
  anim_timer:start(0, 20, vim.schedule_wrap(function()
    local scale = step / total
    popup:update_layout({
      size = {
        width = math.floor(50 * scale),
        height = math.floor(10 * scale),
      },
    })
    if step >= total then
      anim_timer:stop()
      anim_timer:close()
    else
      step = step + 1
    end
  end))
end

return M

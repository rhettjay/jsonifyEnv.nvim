local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local state = require("jsonifyenv.state")
local run = require("jsonifyenv.runner")

local M = {}

function M.open_popup()
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = { top = " JsonifyEnv " },
    },
    position = "50%",
    size = { width = 50, height = 10 },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  local function refresh()
    local lines = {
      "Select Flags:",
      "",
      "[p] Pretty     : " .. tostring(state.pretty),
      "[c] Clipboard  : " .. tostring(state.clip),
      "[r] Replace    : " .. tostring(state.replace),
      "[w] Write File : " .. (state.write or "nil"),
      "",
      "[j] ▶ Run with current flags",
      "[q] ✖ Close",
    }
    popup:buf_set_lines(0, 0, -1, false, lines)
  end

  popup:map("n", "p", function()
    state.pretty = not state.pretty
    refresh()
  end)
  popup:map("n", "c", function()
    state.clip = not state.clip
    refresh()
  end)
  popup:map("n", "r", function()
    state.replace = not state.replace
    refresh()
  end)
  popup:map("n", "w", function()
    vim.ui.input({ prompt = "Filename to write to:" }, function(input)
      state.write = input ~= "" and input or nil
      refresh()
    end)
  end)
  popup:map("n", "j", function()
    popup:unmount()
    run({ args = table.concat({
      state.pretty and "pretty" or "",
      state.clip and "clip" or "",
      state.replace and "replace" or "",
      state.write and ("write=" .. state.write) or "",
    }, " ") })
  end)
  popup:map("n", "q", function()
    popup:unmount()
  end)

  popup:mount()
  refresh()

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

# jsonifyenv.nvim

Convert environment variable lines to JSON with a beautiful animated popup. Uses `nui.nvim` to toggle flags like:

- `pretty`: pretty-print with `jq`
- `clip`: copy to clipboard
- `write=filename`: output to file
- `replace`: update buffer

### 🔧 Usage

```lua
require("jsonifyenv").setup()
```

## 📦 Installation

Install the plugin with your package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "rhettjay/jsonifyEnv.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim"
  }
}
```

Setup:
```lua
require("jsonifenv").setup()
```

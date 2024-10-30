# 🔖 WezTerm Marks Plugin (Experimental)

A minimal WezTerm plugin that allows you to mark and instantly return to specific panes across workspaces. Think of it as a quick bookmark for your terminal positions.

## ⭐ Features

- 📍 Save current pane position to memory
- ↩️ Quick return to marked position
- 🔄 Works across different workspaces
- 🪟 Preserves workspace context

## 🚀 Installation

```lua
local wez = require('wezterm')
local marks = wez.plugin.require("https://github.com/PaysanCorrezien/marks.wezterm")
```

## 💡 Usage

Add to your WezTerm configuration:

```lua
local config = {
  keys = {
    -- Save current position
    {
      key = "m",
      mods = "LEADER",
      action = wezterm.action_callback(function(window)
        marks.WriteMarkToMemory(window)
      end),
    },
    -- Return to marked position
    {
      key = "M",
      mods = "LEADER",
      action = wezterm.action_callback(function(window)
        marks.AccessMarkFromMemory(window)
      end),
    },
  }
}
```

### Default Keybindings

- `LEADER+m`: Save current position
- `LEADER+M`: Jump to saved position

## 🤝 Contributing

Contributions are welcome! Please note:

- This project is maintained as time permits
- Focus on meaningful improvements that don't add unnecessary complexity

## 📄 License

This project follows the MIT License conventions. Feel free to use, modify, and distribute as per MIT License terms.

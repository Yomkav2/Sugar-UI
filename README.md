# Sugar UI (Yomka modified)

A lightweight Roblox UI library.  
Provides windowing, tabs, sections, controls, notifications and simple config management.

## Features
- Window creation with tabs and sections.
- Common UI elements: Toggle, Button, Slider, Keybind, Dropdown, Textbox.
- Notifications.
- Config save/load in JSON files.
- Icon support (lucide, craft, geist) with fallback.

## Quick start
```lua
local SugarLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Yomkav2/Sugar-UI/refs/heads/main/main'))();
local Notification = SugarLibrary.Notification();

Notification.new({
    Title = "Notification",
    Description = "test xD",
    Duration = 5,
    Icon = "bell-ring"
})

local Windows = SugarLibrary.new({
    Title = "SUGAR",
    Description = "Sugar UI Library",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=75225673325066',
    ConfigFolder = "ExampleConfigs"
})

local TabFrame = Windows:NewTab({Title = "Example", Description = "example tab", Icon = "house"})
local Section = TabFrame:NewSection({Title = "Section", Icon = "list", Position = "Left"})

Section:NewToggle({
    Title = "Toggle",
    Name = "Toggle1",
    Default = false,
    Callback = function(tr) print(tr) end,
})
```

## Config API
- `Windows.ListConfigs()` -> returns list of saved config names.
- `Windows.SaveConfig(name)` -> saves current UI state as `name.json` in the `ConfigFolder`.
- `Windows.LoadConfig(name)` -> loads config `name.json`.
- `Windows.DeleteConfig(name)` -> deletes config file.

## Notifications
Use `SugarLibrary.Notification().new({ Title, Description, Duration, Icon })`.

## Notes
- Icons may use pack names like `"lucide:house"` or short names like `"house"`. The library falls back to plain images when icons are unavailable.
- Requires exploit functions such as `isfolder`, `makefolder`, `writefile`, `readfile`, and HTTP get to load remote modules.

## License
MIT

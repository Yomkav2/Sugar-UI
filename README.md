# SUGAR UI
### Nothing UI Library, but BETTER
#### (yeah open source yay)
## **Features**
* **Smooth**
* **Not Laggy**
* **Better then Nothing Library**
* **Collapsible Sections**: Foldable sections for better organization.
* **Images**: Display images in sections with adaptive sizing.
* **Labels/Titles**: Add text headers or info labels.
* **Config System**: Save/load/delete/refresh configs; UI toggle keybind.

## **Components**
  * **Toggles:**
  * **Buttons:**
  * **Sliders:**
  * **Keybinds:**
  * **Dropdown:**
  * **Images:** Add visual elements; adaptive size, set image ID.
  * **Labels/Titles:** Static text for info; update via Set().
  * **Collapsible Sections:** Toggle open/close; DefaultOpen option.

## **Config**
* **"Create Config"**: Saves current UI state to file.
* **"Load Config"**: Loads saved state from file.
* **"Delete Config"**: Removes config file.
* **"Refresh Configs"**: Updates dropdown with current configs.
* **UI Toggle Keybind**: Changes hotkey to show/hide UI.

# Require Library
```lua
local SugarLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Yomkav2/Sugar-UI/refs/heads/main/Source'))();
local Windows = SugarLibrary.new({
    Title = "My UI",
    Description = "Custom UI Description",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'rbxassetid://1234567890',
    ConfigFolder = "MyConfigs" -- Custom folder name
});
```

# Notification
```lua
local Notification = SugarLibrary.Notification();
Notification.new({
    Title = "Notification Title",
    Description = "This is a description",
    Duration = 5,
    Icon = "bell-ring"
});
```

# Tab
```lua
local TabFrame = Windows:NewTab({
Title = "Example",
Description = "example tab",
Icon = "house"
})
```

# Section
```lua
local Section = TabFrame:NewSection({
Title = "Section",
Icon = "list",
Position = "Left"
})
```

# Collapsible Section
```lua
local CollapsibleSection = TabFrame:NewCollapsibleSection({
Title = "Collapsible",
Icon = "folder",
Position = "Left",
DefaultOpen = true
})
```

# Toggle
```lua
Section:NewToggle({
Title = "Toggle",
Name = "Toggle1",
Default = false,
Callback = function(tr)
print(tr)
end,
})
```

# Button
```lua
Section:NewButton({
Title = "Kill All",
Callback = function()
Notification.new({
Title = "Killed",
Description = "10",
Duration = 5,
Icon = "sword"
})
print('killed')
end,
})
```

# Slider
```lua
Section:NewSlider({
Title = "Slider",
Name = "Slider1",
Min = 10,
Max = 50,
Default = 25,
Callback = function(a)
print(a)
end,
})
```

# KeyBind
```lua
Section:NewKeybind({
Title = "Keybind",
Name = "Keybind1",
Default = Enum.KeyCode.RightAlt,
Callback = function(a)
print(a)
end,
})
```

# Dropdown
```lua
Section:NewDropdown({
Title = "Method",
Name = "Method",
Data = {'Teleport','Locker','Auto'},
Default = 'Auto',
Callback = function(a)
print(a)
end,
})
```

# Label/Title
```lua
InfoSection:NewTitle('UI by CATSUS') -- Or NewLabel for info text; update with .Set("New Text")
```

# Image
```lua
InfoSection:NewImage({
ImageId = "rbxassetid://1234567890" -- update with .SetImage("newId") for normal size, set image so to 4392x1600
})
```

# End (aka Title)
```lua
InfoSection:NewTitle('UI by CATSUS')
InfoSection:NewTitle('Modified by Yomka')
InfoSection:NewButton({
Title = "Discord",
Callback = function()
print('https://discord.gg/PKdh229jqg')
end,
})
```

# Credits
* **Original UI by CATSUS**
* **Modified by Yomka (me)**

# Example Script
```lua
local SugarLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Yomkav2/Sugar-UI/refs/heads/main/Source'))();
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
Windows.SetKeybind(Enum.KeyCode.RightControl)
local TabFrame = Windows:NewTab({
Title = "Example",
Description = "example tab",
Icon = "house"
})
local ConfigTab = Windows:NewTab({
Title = "Configs",
Description = "Config Management",
Icon = "save"
})
local Section = TabFrame:NewSection({
Title = "Section",
Icon = "list",
Position = "Left"
})
local InfoSection = TabFrame:NewSection({
Title = "Information",
Icon = "info",
Position = "Right"
})
local CollapsibleSection = TabFrame:NewCollapsibleSection({
Title = "Collapsible",
Icon = "folder",
Position = "Left",
DefaultOpen = true
})
local ConfigSection = ConfigTab:NewSection({
Title = "Config Tools",
Icon = "file-cog",
Position = "Left"
})
Section:NewToggle({
Title = "Toggle",
Name = "Toggle1",
Default = false,
Callback = function(tr)
print(tr)
end,
})
Section:NewToggle({
Title = "Auto Farm",
Name = "AutoFarm",
Default = false,
Callback = function(tr)
print(tr)
end,
})
Section:NewButton({
Title = "Kill All",
Callback = function()
Notification.new({
Title = "Killed",
Description = "10",
Duration = 5,
Icon = "sword"
})
print('killed')
end,
})
Section:NewButton({
Title = "Teleport",
Callback = function()
print('tp')
end,
})
Section:NewSlider({
Title = "Slider",
Name = "Slider1",
Min = 10,
Max = 50,
Default = 25,
Callback = function(a)
print(a)
end,
})
Section:NewSlider({
Title = "WalkSpeed",
Name = "WalkSpeed",
Min = 15,
Max = 50,
Default = 16,
Callback = function(a)
print(a)
end,
})
Section:NewKeybind({
Title = "Keybind",
Name = "Keybind1",
Default = Enum.KeyCode.RightAlt,
Callback = function(a)
print(a)
end,
})
Section:NewKeybind({
Title = "Auto Combo",
Name = "AutoCombo",
Default = Enum.KeyCode.T,
Callback = function(a)
print(a)
end,
})
local configNames = Windows.ListConfigs()
local configDropdown = ConfigSection:NewDropdown({
Title = "Configs",
Data = configNames,
Default = configNames[1] or "None",
Callback = function(a)
print("Selected config: " .. a)
end,
})
local configNameTextbox = ConfigSection:NewTextbox({
Title = "Config Name",
Default = "",
FileType = "",
Callback = function(name)
print("Entered name: " .. name)
end,
})
ConfigSection:NewButton({
Title = "Create Config",
Callback = function()
local newName = configNameTextbox.Get()
if newName and newName ~= "" then
Windows.SaveConfig(newName)
configNames = Windows.ListConfigs()
configDropdown.Refresh(configNames)
print("Created config: " .. newName)
end
end,
})
ConfigSection:NewButton({
Title = "Load Config",
Callback = function()
local selected = configDropdown.Get()
if selected then
Windows.LoadConfig(selected)
print("Loaded config: " .. selected)
end
end,
})
ConfigSection:NewButton({
Title = "Delete Config",
Callback = function()
local selected = configDropdown.Get()
if selected then
delfile(Windows.ConfigFolder .. "/" .. selected .. ".json")
configNames = Windows.ListConfigs()
configDropdown.Refresh(configNames)
print("Deleted config: " .. selected)
end
end,
})
ConfigSection:NewButton({
Title = "Refresh Configs",
Callback = function()
configNames = Windows.ListConfigs()
configDropdown.Refresh(configNames)
print("Configs refreshed")
end,
})
ConfigSection:NewKeybind({
Title = "UI Toggle Key",
Name = "UIToggleKey",
Default = Enum.KeyCode.RightControl,
Callback = function(key)
Windows.SetKeybind(key)
print("UI toggle key set to: " .. key.Name)
end,
})
Section:NewDropdown({
Title = "Method",
Name = "Method",
Data = {"Teleport","Locker","Auto"},
Default = "Auto",
Callback = function(a)
print(a)
end,
})
InfoSection:NewTitle("UI by CATSUS")
InfoSection:NewTitle("Modified by Yomka")
InfoSection:NewButton({
Title = "Discord",
Callback = function()
print("https://discord.gg/PKdh229jqg")
end,
})
local statusLabel = InfoSection:NewLabel("Status: Offline")
InfoSection:NewImage({
ImageId = "rbxassetid://102333378976363"
})
CollapsibleSection:NewToggle({
Title = "Toggle in Collapsible",
Name = "ToggleCollapsible",
Default = true,
Callback = function(tr)
print(tr)
end,
})
CollapsibleSection:NewButton({
Title = "Button in Collapsible",
Callback = function()
print("clicked in collapsible")
end,
})
CollapsibleSection:NewImage({
ImageId = "rbxassetid://102333378976363"
})
statusLabel.Set("Status: YOMKA SASAT")
wait(4)
statusLabel.Set("Status: YOMKA ON TOP")
```

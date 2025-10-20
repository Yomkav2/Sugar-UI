## Nothing UI Library, but BETTER (yeah open source yay)

### **Features**

Smooth
Not Laggy
Better then Nothing Library

#### **Example Tab**

  * **Toggles:**
  * **Buttons:**
  * **Sliders:**
  * **Keybinds:**
  * **Dropdown:**

#### **Configs Tab**

  * **Dropdown:** Lists all existing saved configurations.
  * **Textbox:** Used to input the name for a new configuration.
  * **Buttons:**
      * **"Create Config"**: Saves the current settings.
      * **"Load Config"**: Applies the settings from the selected configuration.
      * **"Delete Config"**: Removes the selected configuration file.
      * **"Refresh Configs"**: Updates the list of available configurations.

###Here the Example Script

```lua
-- Loads the Sugar UI library
local SugarLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Yomkav2/Sugar-UI/refs/heads/main/main'))();

-- Initialize the main window, set the title, keybind (LeftControl), and config folder
local Windows = SugarLibrary.new({
    Title = "SUGAR",
    Description = "Sugar UI Library",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=75225673325066',
    ConfigFolder = "ExampleConfigs"
})

-- Create tabs (Example, Configs)
local TabFrame = Windows:NewTab({...})
local ConfigTab = Windows:NewTab({...})

-- Create sections within the tabs (e.g., Left/Right position)
local Section = TabFrame:NewSection({...})

-- Add UI elements to sections (Toggle, Button, Slider, etc.)
Section:NewToggle({...})
Section:NewButton({...})
-- ... and so on
```

-----

Let me know if you'd like any specific sections or details added to the `README.md`\!

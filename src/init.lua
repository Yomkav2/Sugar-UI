-- init.lua (Sugar UI - Minimalist redesign, full)
local SugarUI = {}
SugarUI.__index = SugarUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

-- ======================
-- Preset Themes (фиксированные)
-- ======================
SugarUI.Presets = {
    Pinky = {
        Background = Color3.fromRGB(24, 12, 18),
        Panel = Color3.fromRGB(34, 16, 28),
        Accent = Color3.fromRGB(255, 100, 180),
        AccentSoft = Color3.fromRGB(230, 130, 200),
        AccentDark = Color3.fromRGB(170, 55, 95),
        Text = Color3.fromRGB(245, 240, 246),
        Muted = Color3.fromRGB(170, 150, 160),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(60, 40, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(28, 12, 22),
        ToggleBox = Color3.fromRGB(230,230,230),
        Button = Color3.fromRGB(28,12,22),
        ButtonHover = Color3.fromRGB(40,18,30),
    },
    Amethyst = {
        Background = Color3.fromRGB(16, 12, 26),
        Panel = Color3.fromRGB(26, 18, 40),
        Accent = Color3.fromRGB(148, 102, 199),
        AccentSoft = Color3.fromRGB(165, 135, 210),
        AccentDark = Color3.fromRGB(85, 50, 120),
        Text = Color3.fromRGB(245, 244, 250),
        Muted = Color3.fromRGB(160, 150, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(50, 40, 60),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(22,16,34),
        ToggleBox = Color3.fromRGB(210,210,210),
        Button = Color3.fromRGB(24,18,36),
        ButtonHover = Color3.fromRGB(44,36,62),
    },
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Panel = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(70, 140, 255),
        AccentSoft = Color3.fromRGB(90, 160, 255),
        AccentDark = Color3.fromRGB(15, 90, 190),
        Text = Color3.fromRGB(240, 240, 240),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(50, 50, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(30, 30, 30),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(32, 34, 36),
        ButtonHover = Color3.fromRGB(45, 48, 50),
    },
    White = {
        Background = Color3.fromRGB(245, 245, 245),
        Panel = Color3.fromRGB(236, 236, 236),
        Accent = Color3.fromRGB(25, 110, 210),
        AccentSoft = Color3.fromRGB(70, 130, 230),
        AccentDark = Color3.fromRGB(10, 70, 140),
        Text = Color3.fromRGB(18, 18, 18),
        Muted = Color3.fromRGB(110, 110, 110),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(200, 200, 200),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(245,245,245),
        ToggleBox = Color3.fromRGB(30,30,30),
        Button = Color3.fromRGB(245,245,245),
        ButtonHover = Color3.fromRGB(232,232,232),
    }
}

-- default theme (Dark)
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.Dark) do SugarUI.Theme[k] = v end

-- Apply preset helper
function SugarUI.ApplyPreset(name)
    local preset = SugarUI.Presets[name]
    if not preset then return false end
    for k,v in pairs(preset) do SugarUI.Theme[k] = v end
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    SugarUI.CurrentConfig["Theme"] = name
    if SugarUI.CurrentWindow and SugarUI.CurrentWindow.UpdateTheme then
        pcall(function() SugarUI.CurrentWindow:UpdateTheme() end)
    end
    return true
end

-- ======================
-- Utilities
-- ======================
function SugarUI.RoundCorner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration or 0.18, style, dir)
    local t = TweenService:Create(instance, ti, props)
    t:Play()
    return t
end

function SugarUI.AddSoftShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 8, 1, size or 8)
    shadow.Position = UDim2.new(0, -(size or 8)/2, 0, -(size or 8)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame
    return shadow
end

-- Minimal spacing helper
local function pad(n) return UDim.new(0, n) end

-- ======================
-- Components (Minimalist style)
-- ======================

-- Button (clean)
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent
function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -16, 0, 36)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1

    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12)
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.12)
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
        -- minimalist ripple: subtle scale
        SugarUI.Tween(Btn, {Size = UDim2.new(1, -14, 0, 38)}, 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(0.06, function() SugarUI.Tween(Btn, {Size = UDim2.new(1, -16, 0, 36)}, 0.08) end)
    end)

    self.Instance = Btn
    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
    end
    return self
end

-- Toggle (flat, neat)
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent
function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default and true or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.BackgroundTransparency = 0
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.95
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.75, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 42, 0, 24)
    Switch.Position = UDim2.new(1, -54, 0.5, -12)
    Switch.BackgroundColor3 = SugarUI.Theme.Toggle
    Switch.Parent = Frame
    SugarUI.RoundCorner(12).Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(self.State and 1 or 0, (self.State and -28 or 6), 0.5, -9)
    Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    Knob.Parent = Switch
    SugarUI.RoundCorner(9).Parent = Knob

    local function refreshVisual()
        local targetX = self.State and UDim2.new(1, -28, 0, 3) or UDim2.new(0, 6, 0, 3)
        SugarUI.Tween(Knob, {Position = targetX}, 0.14)
        SugarUI.Tween(Knob, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.14)
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            refreshVisual()
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        refreshVisual()
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        Switch.BackgroundColor3 = SugarUI.Theme.Toggle
    end

    return self
end

-- Slider (kept simple)
local SliderComponent = {}
SliderComponent.__index = SliderComponent
function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or (min or 0)
    min = min or 0
    max = max or 100

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 44)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.BackgroundTransparency = 0
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.95
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -12, 0, 18)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 8)
    Track.Position = UDim2.new(0, 10, 0, 26)
    Track.BackgroundColor3 = Color3.fromRGB(72,72,72)
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    SugarUI.RoundCorner(6).Parent = Track

    local Fill = Instance.new("Frame")
    local initialFill = 0
    if max - min ~= 0 then initialFill = (value - min) / (max - min) end
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    SugarUI.RoundCorner(6).Parent = Fill

    local dragging = false
    local function set_value(newValue, fire)
        newValue = tonumber(newValue) or newValue
        if type(newValue) ~= "number" then return end
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = 0
        if max - min ~= 0 then fillSize = (value - min) / (max - min) end
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.12)
        if fire and callback then pcall(callback, value) end
        if configKey then SugarUI.CurrentConfig[configKey] = value end
    end

    local function update_from_mouse(input)
        local positionX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
        local newValue = min + (positionX / Track.AbsoluteSize.X) * (max - min)
        set_value(newValue, true)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update_from_mouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update_from_mouse(input) end
    end)

    self.Instance = Frame
    self.SetValue = set_value
    self.GetValue = function() return value end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        Track.BackgroundColor3 = Color3.fromRGB(72,72,72)
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
    end

    return self
end

-- Dropdown (compact)
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent
function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    local isOpen = false
    options = options or {}
    multiSelect = multiSelect or false
    local selected
    if multiSelect then selected = default or {} else selected = default or options[1] or "None" end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.95
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -12, 1, 0)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 36)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 6
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.ScrollBarImageTransparency = 0.7

    local optionsList = Instance.new("UIListLayout", OptionsFrame)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Padding = UDim.new(0, 6)

    local optionsPadding = Instance.new("UIPadding", OptionsFrame)
    optionsPadding.PaddingTop = UDim.new(0, 6)
    optionsPadding.PaddingBottom = UDim.new(0, 6)
    optionsPadding.PaddingLeft = UDim.new(0, 6)
    optionsPadding.PaddingRight = UDim.new(0, 6)

    local function update_value_display()
        if multiSelect then
            local count = #selected
            if count == 0 then ValueLabel.Text = "None"
            elseif count <= 2 then ValueLabel.Text = table.concat(selected, ", ")
            else ValueLabel.Text = selected[1] .. ", " .. selected[2] .. " + " .. (count - 2) end
        else
            ValueLabel.Text = tostring(selected)
        end
    end

    local function apply_config_store()
        if configKey then SugarUI.CurrentConfig[configKey] = multiSelect and selected or selected end
    end

    local optionObjects = {}

    local function create_option(optionText, index)
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Size = UDim2.new(1, 0, 0, 30)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.LayoutOrder = index
        OptionFrame.Parent = OptionsFrame

        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.BackgroundColor3 = SugarUI.Theme.Panel
        OptionButton.BackgroundTransparency = 0
        OptionButton.Text = tostring(optionText)
        OptionButton.TextColor3 = SugarUI.Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 13
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionFrame
        SugarUI.RoundCorner(8).Parent = OptionButton

        local pad = Instance.new("UIPadding", OptionButton)
        pad.PaddingLeft = UDim.new(0, 8)

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.95
        optionStroke.Thickness = 1

        local Check = nil
        if multiSelect then
            Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 16, 0, 16)
            Check.Position = UDim2.new(1, -24, 0.5, -8)
            Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            Check.Parent = OptionButton
            SugarUI.RoundCorner(4).Parent = Check

            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(1, 0, 1, 0)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = SugarUI.Theme.Highlight
            CheckIcon.Visible = table.find(selected, optionText) ~= nil
            CheckIcon.Parent = Check

            OptionButton.MouseButton1Click:Connect(function()
                local idx = table.find(selected, optionText)
                if idx then table.remove(selected, idx) else table.insert(selected, optionText) end
                update_value_display()
                apply_config_store()
                Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                CheckIcon.Visible = table.find(selected, optionText) ~= nil
            end)
        else
            OptionButton.BackgroundColor3 = (selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel
            OptionButton.MouseButton1Click:Connect(function()
                selected = optionText
                update_value_display()
                apply_config_store()
                for _, obj in ipairs(optionObjects) do
                    local isSel = (obj.btn.Text == selected)
                    SugarUI.Tween(obj.btn, {BackgroundColor3 = isSel and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
                end
                -- close after select
                if isOpen then
                    isOpen = false
                    SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.16)
                    SugarUI.Tween(Frame, {Size = UDim2.new(1, -16, 0, 36)}, 0.16)
                end
            end)
        end

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.08)
        end)
        OptionButton.MouseLeave:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundColor3 = (selected == optionText and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel)}, 0.08)
        end)

        optionObjects[#optionObjects + 1] = {frame = OptionFrame, btn = OptionButton, check = Check, optionStroke = optionStroke}
    end

    local function rebuild_options()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        optionObjects = {}
        local order = 1
        for i, option in ipairs(options) do
            create_option(option, order)
            order = order + 1
        end
    end

    function self:Toggle()
        isOpen = not isOpen
        if isOpen then
            local height = math.min((#options * 30 + 8), 200)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -16, 0, 36 + height)}, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            OptionsFrame.ZIndex = 1000
        else
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -16, 0, 36)}, 0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.delay(0.16, function() OptionsFrame.ZIndex = 60 end)
        end
    end

    local function update_from_options(newOptions)
        options = newOptions or {}
        rebuild_options()
        if not multiSelect then
            if not table.find(options, selected) then selected = options[1] or "None" end
        else
            local filtered = {}
            for _, s in ipairs(selected) do if table.find(options, s) then table.insert(filtered, s) end end
            selected = filtered
        end
        update_value_display()
        apply_config_store()
    end

    rebuild_options()
    update_value_display()

    HeaderBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    self.Instance = Frame
    self.IsOpen = function() return isOpen end
    self.UpdateOptions = update_from_options
    self.SetValue = function(value)
        if multiSelect then selected = value or {} else selected = value or options[1] or "None" end
        update_value_display()
        apply_config_store()
    end
    self.GetValue = function() return selected end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        for _, obj in ipairs(optionObjects) do
            obj.btn.BackgroundColor3 = SugarUI.Theme.Panel
            obj.btn.TextColor3 = SugarUI.Theme.Text
            if obj.check then obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel end
            if obj.optionStroke then obj.optionStroke.Color = SugarUI.Theme.Border end
        end
    end

    return self
end

-- ======================
-- Section (clean header)
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent
function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 34)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1)
    line.Position = UDim2.new(0, 20, 1, -8)
    line.BackgroundColor3 = SugarUI.Theme.Border
    line.BorderSizePixel = 0
    line.Parent = wrapper

    self._wrapper = wrapper
    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Muted
        line.BackgroundColor3 = SugarUI.Theme.Border
    end
    return self
end

-- ======================
-- Notifications (minimal)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 300, 0, 300)
    self.Container.Position = UDim2.new(1, -320, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 900

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 8)

    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 4
    notifType = notifType or "Info"

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = SugarUI.Theme.Panel
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    SugarUI.RoundCorner(10).Parent = notification
    notification.ZIndex = 901

    SugarUI.AddSoftShadow(notification, 0.28, 8)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 6, 1, 0)
    accent.BackgroundColor3 = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType] or SugarUI.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    accent.ZIndex = 902

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 16, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    titleLabel.ZIndex = 902

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -60, 0, 0)
    messageLabel.Position = UDim2.new(0, 16, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    messageLabel.ZIndex = 902

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -36, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Muted
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 16
    closeButton.Parent = notification
    closeButton.ZIndex = 902

    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(220, 1000))
        textHeight = size.Y
    end

    local totalHeight = math.clamp(54 + textHeight, 60, 140)
    messageLabel.Size = UDim2.new(1, -60, 0, textHeight)

    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.18)

    closeButton.MouseButton1Click:Connect(function() self:Remove(notification) end)
    if duration > 0 then
        task.delay(duration, function() if notification.Parent then self:Remove(notification) end end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.14)
    task.delay(0.15, function() if notification.Parent then notification:Destroy() end end)
    for i, notif in ipairs(self.Notifications) do if notif == notification then table.remove(self.Notifications, i); break end end
end

-- ======================
-- Window & Tabs (minimalist layout)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0
    local tabComponents = {}

    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 48)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -24, 1, 0)
    tabBtn.Position = UDim2.new(0, 12, 0, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -14)
    indicator.Position = UDim2.new(0, -6, 0, 7)
    indicator.BackgroundColor3 = SugarUI.Theme.Accent
    indicator.Visible = false
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn
    SugarUI.RoundCorner(2).Parent = indicator

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = selfObj.PagesHolder

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -28, 1, -28)
    scrollingFrame.Position = UDim2.new(0, 14, 0, 14)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    scrollingFrame.ScrollBarImageTransparency = 0.6
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            SugarUI.Tween(t.button, {TextColor3 = (t.name == name) and SugarUI.Theme.Text or SugarUI.Theme.Muted}, 0.12)
        end
        selfObj.ActiveTab = name
    end)

    local tabObj = {
        name = name,
        button = tabBtn,
        wrapper = btnWrap,
        indicator = indicator,
        page = page,
        pageInner = scrollingFrame,
        layoutOrderCounter = layoutOrderCounter,
        components = tabComponents,
        AddSection = function(_, ttl)
            layoutOrderCounter = layoutOrderCounter + 1
            local sec = SectionComponent.new(scrollingFrame, ttl)
            sec._wrapper.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "section", obj = sec})
            table.insert(selfObj.Components, {type = "section", obj = sec})
            return sec
        end,
        AddButton = function(_, txt, cb)
            layoutOrderCounter = layoutOrderCounter + 1
            local btn = ButtonComponent.new(scrollingFrame, txt, cb)
            btn.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "button", obj = btn})
            table.insert(selfObj.Components, {type = "button", obj = btn})
            return btn
        end,
        AddToggle = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local tog = ToggleComponent.new(scrollingFrame, txt, def, cb, configKey)
            tog.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "toggle", key = configKey, obj = tog})
                table.insert(selfObj.Components, {type = "toggle", key = configKey, obj = tog})
            else
                table.insert(tabComponents, {type = "toggle", obj = tog})
            end
            return tog
        end,
        AddSlider = function(_, txt, min, max, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local slider = SliderComponent.new(scrollingFrame, txt, min, max, def, cb, configKey)
            slider.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "slider", key = configKey, obj = slider})
                table.insert(selfObj.Components, {type = "slider", key = configKey, obj = slider})
            else
                table.insert(tabComponents, {type = "slider", obj = slider})
            end
            return slider
        end,
        AddDropdown = function(_, txt, options, def, cb, multi, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local drop = DropdownComponent.new(scrollingFrame, txt, options, def, cb, multi, configKey)
            drop.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "dropdown", key = configKey, obj = drop})
                table.insert(selfObj.Components, {type = "dropdown", key = configKey, obj = drop})
            else
                table.insert(tabComponents, {type = "dropdown", obj = drop})
            end
            return drop
        end,
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = SugarUI.Theme.Text
        indicator.Visible = true
        page.Visible = true
        selfObj.ActiveTab = name
    end

    return tabObj
end

function Window.new(title)
    local selfObj = {}
    selfObj.Tabs = {}
    selfObj.Pages = {}
    selfObj.ActiveTab = nil
    selfObj.Visible = true
    selfObj.Components = {}
    selfObj.ToggleKey = Enum.KeyCode.V

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.DisplayOrder = 1000 end)
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok or not ScreenGui.Parent then
        local player = Players.LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            ScreenGui.Parent = player.PlayerGui
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end

    local OuterFrame = Instance.new("Frame")
    OuterFrame.Size = UDim2.new(0, 520, 0, 420)
    OuterFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(12).Parent = Frame

    SugarUI.AddSoftShadow(Frame, 0.25, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0
    TopBar.Parent = Frame
    SugarUI.RoundCorner(12).Parent = TopBar

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.95
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0.7, -16, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamSemibold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local SubLbl = Instance.new("TextLabel")
    SubLbl.Size = UDim2.new(0.3, -16, 1, 0)
    SubLbl.Position = UDim2.new(0.7, 16, 0, 0)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Text = "Minimal"
    SubLbl.TextColor3 = SugarUI.Theme.Muted
    SubLbl.Font = Enum.Font.Gotham
    SubLbl.TextSize = 12
    SubLbl.TextXAlignment = Enum.TextXAlignment.Right
    SubLbl.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -56, 0.5, -18)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Panel
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamSemibold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = SugarUI.Theme.Muted
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function() SugarUI.Tween(CloseBtn, {TextColor3 = SugarUI.Theme.Text}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() SugarUI.Tween(CloseBtn, {TextColor3 = SugarUI.Theme.Muted}, 0.12) end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -56)
    Sidebar.Position = UDim2.new(0, 0, 0, 56)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(0).Parent = Sidebar

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.95

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 18)
    tabsPadding.PaddingLeft = UDim.new(0, 12)
    tabsPadding.PaddingRight = UDim.new(0, 12)
    tabsPadding.PaddingBottom = UDim.new(0, 16)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -180, 1, -56)
    PagesHolder.Position = UDim2.new(0, 180, 0, 56)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Responsive
    local function getViewport()
        Camera = Camera or Workspace.CurrentCamera
        if Camera and Camera.ViewportSize then return Camera.ViewportSize end
        return Vector2.new(1280, 720)
    end

    local function updateOuterSize()
        local vp = getViewport()
        local w = math.clamp(math.floor(vp.X * 0.52), 360, 1280)
        local h = math.clamp(math.floor(vp.Y * 0.56), 240, 900)
        if not selfObj._userResized then
            OuterFrame.Size = UDim2.new(0, w, 0, h)
        end
        OuterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    end

    if Camera then
        pcall(function() Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateOuterSize) end)
    else
        Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            Camera = Workspace.CurrentCamera
            if Camera then pcall(function() Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateOuterSize) end) end
        end)
    end

    updateOuterSize()

    -- Smooth dragging (minimal)
    local dragging = false
    local dragInput, mousePos, framePos
    local activeTween = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = OuterFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            if activeTween then pcall(function() activeTween:Cancel() end) end
            activeTween = TweenService:Create(OuterFrame, TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos})
            activeTween:Play()
        end
    end)

    -- Resize handle (subtle)
    local resizeBtn = Instance.new("Frame")
    resizeBtn.Size = UDim2.new(0, 20, 0, 20)
    resizeBtn.Position = UDim2.new(1, 0, 1, 0)
    resizeBtn.AnchorPoint = Vector2.new(1, 1)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Parent = Frame

    local resizing = false
    local resizeMousePos, resizeFrameSize

    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMousePos = input.Position
            resizeFrameSize = OuterFrame.Size
            selfObj._userResized = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeMousePos
            local newWidth = math.max(360, resizeFrameSize.X.Offset + delta.X)
            local newHeight = math.max(240, resizeFrameSize.Y.Offset + delta.Y)
            OuterFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    local toggleConnection
    local function setupToggleKey(key)
        if toggleConnection then toggleConnection:Disconnect() end
        toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == key then
                if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
            end
        end)
    end
    setupToggleKey(Enum.KeyCode.V)

    -- Mobile toggle button (draggable)
    local mobileButtons = {}
    local function createMobileButton(name, sizeX, sizeY, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, sizeX, 0, sizeY)
        btn.Position = pos or UDim2.new(1, -180, 1, -120)
        btn.AnchorPoint = Vector2.new(0, 0)
        btn.BackgroundColor3 = SugarUI.Theme.Panel
        btn.Text = name
        btn.TextColor3 = SugarUI.Theme.Text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.ZIndex = 1001
        btn.Parent = ScreenGui
        SugarUI.RoundCorner(10).Parent = btn
        return btn
    end

    if UserInputService.TouchEnabled then
        local toggleBtn = createMobileButton("GUI", 96, 44, UDim2.new(1, -180, 1, -120))
        mobileButtons.toggle = toggleBtn

        local function makeDraggable(btn, onTap)
            local touchInput = nil
            local startPos, startBtnPos
            local moved = false
            local threshold = 10

            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchInput = input
                    startPos = input.Position
                    startBtnPos = btn.Position
                    moved = false
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            if not moved and onTap then pcall(onTap) end
                            touchInput = nil
                        end
                    end)
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    startPos = input.Position
                    startBtnPos = btn.Position
                    moved = false
                    local connMove
                    connMove = UserInputService.InputChanged:Connect(function(mouse)
                        if mouse.UserInputType == Enum.UserInputType.MouseMovement then
                            local delta = mouse.Position - startPos
                            if math.abs(delta.X) > threshold or math.abs(delta.Y) > threshold then
                                moved = true
                                local newX = startBtnPos.X.Offset + delta.X
                                local newY = startBtnPos.Y.Offset + delta.Y
                                local vp = getViewport()
                                newX = math.clamp(newX, 8, vp.X - btn.AbsoluteSize.X - 8)
                                newY = math.clamp(newY, 8, vp.Y - btn.AbsoluteSize.Y - 8)
                                btn.Position = UDim2.new(0, newX, 0, newY)
                            end
                        end
                    end)
                    local upConn
                    upConn = UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            if not moved and onTap then pcall(onTap) end
                            connMove:Disconnect()
                            upConn:Disconnect()
                        end
                    end)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if touchInput and input == touchInput then
                    local delta = input.Position - startPos
                    if math.abs(delta.X) > threshold or math.abs(delta.Y) > threshold then
                        moved = true
                        local newX = startBtnPos.X.Offset + delta.X
                        local newY = startBtnPos.Y.Offset + delta.Y
                        local vp = getViewport()
                        newX = math.clamp(newX, 8, vp.X - btn.AbsoluteSize.X - 8)
                        newY = math.clamp(newY, 8, vp.Y - btn.AbsoluteSize.Y - 8)
                        btn.Position = UDim2.new(0, newX, 0, newY)
                    end
                end
            end)
        end

        makeDraggable(mobileButtons.toggle, function()
            if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
        end)
    end

    -- Show / Hide (synchronized animations)
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        if activeTween then pcall(function() activeTween:Cancel() end) end
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        SugarUI.Tween(Frame, {BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        task.delay(0.02, function() pcall(function() selfObj:UpdateTheme() end) end)
    end

    function selfObj:Hide()
        selfObj.Visible = false
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5, 0, 1.4, 0)}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        for _, child in ipairs(Notifications.Container:GetChildren()) do
            if child:IsA("Frame") then pcall(function() SugarUI.Tween(child, {Size = UDim2.new(1,0,0,0)}, 0.22) end)
            end
        end
        task.delay(0.26, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
            Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 3, "Info")
        end)
    end

    task.defer(function() wait(0.04); selfObj:Show() end)

    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Close UI", "Do you want to close the UI?", function() ScreenGui:Destroy() end, function() end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.46
        overlay.Parent = ScreenGui
        overlay.ZIndex = 999

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 360, 0, 160)
        panel.Position = UDim2.new(0.5, -180, 0.5, -80)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        SugarUI.RoundCorner(10).Parent = panel
        panel.Parent = overlay
        panel.ZIndex = 1000

        SugarUI.AddSoftShadow(panel, 0.36, 10)
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.9

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,-20,0,34)
        titleLbl.Position = UDim2.new(0,10,0,10)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamSemibold
        titleLbl.TextSize = 15
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = panel

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -20, 0, 60)
        msgLbl.Position = UDim2.new(0,10,0,44)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 13
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        msgLbl.Parent = panel

        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.42, 0, 0, 34)
        yesBtn.Instance.Position = UDim2.new(0.06, 0, 1, -48)

        local noBtn = ButtonComponent.new(panel, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.42, 0, 0, 34)
        noBtn.Instance.Position = UDim2.new(0.52, 0, 1, -48)
    end

    -- Expose to user
    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications
    selfObj.GlobalContainer = PagesHolder

    function selfObj:AddTab(name) return createTab(selfObj, name) end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end

    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs) do if t.name == selfObj.ActiveTab then return t end end
        return nil
    end

    function selfObj:SetToggleKey(key)
        setupToggleKey(key)
        selfObj.ToggleKey = key
        SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
        SugarUI.CurrentConfig["ToggleKey"] = key.Name
    end

    function selfObj:Notify(title, message, duration, kind)
        return Notifications:Notify(title, message, duration, kind)
    end

    function selfObj:ApplyConfig(config)
        if not config or type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local val = comp.key and config[comp.key] or nil
            if val ~= nil then
                if comp.type == "toggle" then
                    if type(comp.obj.Set) == "function" then comp.obj.Set(val, false) end
                elseif comp.type == "slider" then
                    if type(comp.obj.SetValue) == "function" then
                        local num = tonumber(val) or val
                        comp.obj.SetValue(num, false)
                    end
                elseif comp.type == "dropdown" then
                    if type(comp.obj.SetValue) == "function" then comp.obj.SetValue(val) end
                end
            end
        end
        if config["ToggleKey"] then
            local key = Enum.KeyCode[config["ToggleKey"]]
            if key then selfObj:SetToggleKey(key) end
        end
        if config["Theme"] then
            pcall(function() SugarUI.ApplyPreset(config["Theme"]) end)
        end
        task.defer(function() pcall(function() selfObj:Notify("Info", "Configuration applied.", 2, "Info") end) end)
    end

    function selfObj:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Background
        TopBar.BackgroundColor3 = SugarUI.Theme.Panel
        topStroke.Color = SugarUI.Theme.Border
        TitleLbl.TextColor3 = SugarUI.Theme.Text
        SubLbl.TextColor3 = SugarUI.Theme.Muted
        Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
        sideStroke.Color = SugarUI.Theme.Border
        for _, tab in ipairs(selfObj.Tabs) do
            tab.button.TextColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Text or SugarUI.Theme.Muted
            tab.indicator.BackgroundColor3 = SugarUI.Theme.Accent
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Border
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then
                    comp.obj:UpdateTheme()
                end
            end
        end
        -- shadows
        for _, shadow in ipairs(ScreenGui:GetDescendants()) do
            if shadow.Name == "Shadow" and shadow:IsA("ImageLabel") then
                shadow.ImageColor3 = SugarUI.Theme.Shadow
            end
        end
    end

    SugarUI.CurrentWindow = selfObj
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}

    return selfObj
end

-- Public API
function SugarUI:CreateWindow(title)
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    local window = Window.new(title)
    if SugarUI.CurrentConfig["Theme"] then
        pcall(function() SugarUI.ApplyPreset(SugarUI.CurrentConfig["Theme"]) end)
    end
    return window
end

SugarUI.ApplyTheme = SugarUI.ApplyPreset
SugarUI.GetAvailableThemes = function()
    local keys = {}
    for k,_ in pairs(SugarUI.Presets) do table.insert(keys,k) end
    return keys
end

return SugarUI

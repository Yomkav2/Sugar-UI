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
-- Preset Themes (modern, beautiful themes with gradients and soft colors)
-- ======================
SugarUI.Presets = {
    Nebula = {
        Background = Color3.fromRGB(10, 15, 30),
        Panel = Color3.fromRGB(20, 25, 50),
        Accent = Color3.fromRGB(100, 150, 255),
        AccentSoft = Color3.fromRGB(150, 180, 255),
        AccentDark = Color3.fromRGB(50, 100, 200),
        Text = Color3.fromRGB(220, 230, 255),
        Muted = Color3.fromRGB(150, 160, 200),
        Shadow = Color3.fromRGB(0, 0, 10),
        Border = Color3.fromRGB(40, 50, 80),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Toggle = Color3.fromRGB(30, 35, 60),
        ToggleBox = Color3.fromRGB(200, 210, 255),
        Button = Color3.fromRGB(30, 35, 60),
        ButtonHover = Color3.fromRGB(50, 60, 90),
        GradientStart = Color3.fromRGB(20, 25, 50),
        GradientEnd = Color3.fromRGB(10, 15, 30),
    },
    Aurora = {
        Background = Color3.fromRGB(15, 30, 20),
        Panel = Color3.fromRGB(25, 50, 35),
        Accent = Color3.fromRGB(100, 255, 150),
        AccentSoft = Color3.fromRGB(150, 255, 180),
        AccentDark = Color3.fromRGB(50, 200, 100),
        Text = Color3.fromRGB(220, 255, 230),
        Muted = Color3.fromRGB(150, 200, 160),
        Shadow = Color3.fromRGB(0, 10, 0),
        Border = Color3.fromRGB(40, 80, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Toggle = Color3.fromRGB(35, 60, 40),
        ToggleBox = Color3.fromRGB(200, 255, 210),
        Button = Color3.fromRGB(35, 60, 40),
        ButtonHover = Color3.fromRGB(50, 90, 60),
        GradientStart = Color3.fromRGB(25, 50, 35),
        GradientEnd = Color3.fromRGB(15, 30, 20),
    },
    Sunset = {
        Background = Color3.fromRGB(30, 15, 10),
        Panel = Color3.fromRGB(50, 25, 20),
        Accent = Color3.fromRGB(255, 150, 100),
        AccentSoft = Color3.fromRGB(255, 180, 150),
        AccentDark = Color3.fromRGB(200, 100, 50),
        Text = Color3.fromRGB(255, 230, 220),
        Muted = Color3.fromRGB(200, 160, 150),
        Shadow = Color3.fromRGB(10, 0, 0),
        Border = Color3.fromRGB(80, 50, 40),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Toggle = Color3.fromRGB(60, 35, 30),
        ToggleBox = Color3.fromRGB(255, 210, 200),
        Button = Color3.fromRGB(60, 35, 30),
        ButtonHover = Color3.fromRGB(90, 60, 50),
        GradientStart = Color3.fromRGB(50, 25, 20),
        GradientEnd = Color3.fromRGB(30, 15, 10),
    },
}
-- default theme (start with Nebula)
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.Nebula) do SugarUI.Theme[k] = v end
-- helper to apply a preset
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
-- Helpers
-- ======================
function SugarUI.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)
    return corner
end
function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Exponential
    dir = dir or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.25, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end
function SugarUI.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.75
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = frame
    return shadow
end
function SugarUI.AddGradient(frame, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    gradient.Color = ColorSequence.new(SugarUI.Theme.GradientStart, SugarUI.Theme.GradientEnd)
    gradient.Parent = frame
    return gradient
end
-- ======================
-- Button component (modern with gradient and ripple)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent
function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 48)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 16
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5
    SugarUI.AddGradient(Btn)
    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover, Size = UDim2.new(1, -8, 0, 50)}, 0.2)
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.Button, Size = UDim2.new(1, -12, 0, 48)}, 0.2)
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then
            -- Advanced ripple
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = SugarUI.Theme.Highlight
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Parent = Btn
            SugarUI.RoundCorner(999).Parent = ripple
            local maxSize = math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y) * 2
            SugarUI.Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 0.8}, 0.5, Enum.EasingStyle.Quad)
            task.delay(0.5, function() ripple:Destroy() end)
            pcall(callback)
        end
    end)
    self.Instance = Btn
    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
        local grad = Btn:FindFirstChildOfClass("UIGradient")
        if grad then grad.Color = ColorSequence.new(SugarUI.Theme.GradientStart, SugarUI.Theme.GradientEnd) end
    end
    return self
end
-- ======================
-- Toggle component (sleek with animated switch)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent
function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 48)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 52, 0, 28)
    Switch.Position = UDim2.new(1, -64, 0.5, -14)
    Switch.BackgroundColor3 = SugarUI.Theme.Toggle
    Switch.Parent = Frame
    SugarUI.RoundCorner(14).Parent = Switch
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 24, 0, 24)
    Knob.Position = UDim2.new(0, self.State and 28 or 0, 0.5, -12)
    Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    Knob.Parent = Switch
    SugarUI.RoundCorner(12).Parent = Knob
    SugarUI.AddShadow(Knob, 0.5, 8)
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(Knob, {Position = UDim2.new(0, self.State and 28 or 0, 0.5, -12), BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.2)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)
    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = newState
        SugarUI.Tween(Knob, {Position = UDim2.new(0, self.State and 28 or 0, 0.5, -12), BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.2)
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Switch.BackgroundColor3 = SugarUI.Theme.Toggle
        Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    end
    return self
end
-- ======================
-- Slider component (smooth with fill animation)
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent
function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or min
    min = min or 0
    max = max or 100
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 60)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 24)
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -12, 0, 24)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 10)
    Track.Position = UDim2.new(0, 12, 0, 40)
    Track.BackgroundColor3 = SugarUI.Theme.Border
    Track.Parent = Frame
    SugarUI.RoundCorner(5).Parent = Track
    local Fill = Instance.new("Frame")
    local fillSize = (value - min) / (max - min)
    Fill.Size = UDim2.new(fillSize, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.Parent = Track
    SugarUI.RoundCorner(5).Parent = Fill
    SugarUI.AddGradient(Fill, 0)
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 20, 0, 20)
    Handle.Position = UDim2.new(fillSize, -10, 0.5, -10)
    Handle.BackgroundColor3 = SugarUI.Theme.Highlight
    Handle.Parent = Track
    SugarUI.RoundCorner(10).Parent = Handle
    SugarUI.AddShadow(Handle, 0.6, 6)
    local dragging = false
    local function set_value(newValue, fire)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = (value - min) / (max - min)
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.15)
        SugarUI.Tween(Handle, {Position = UDim2.new(fillSize, -10, 0.5, -10)}, 0.15)
        if fire and callback then pcall(callback, value) end
        if configKey then SugarUI.CurrentConfig[configKey] = value end
    end
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
            set_value(min + (posX / Track.AbsoluteSize.X) * (max - min), true)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
            set_value(min + (posX / Track.AbsoluteSize.X) * (max - min), true)
        end
    end)
    self.Instance = Frame
    self.SetValue = set_value
    self.GetValue = function() return value end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        Track.BackgroundColor3 = SugarUI.Theme.Border
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
        Handle.BackgroundColor3 = SugarUI.Theme.Highlight
    end
    return self
end
-- ======================
-- Dropdown component (with multi-select support)
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent
function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    local isOpen = false
    options = options or {}
    multiSelect = multiSelect or false
    local selected = multiSelect and (default or {}) or (default or options[1] or "Select")
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 48)
    Frame.BackgroundColor3 = SugarUI.Theme.Button
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -12, 1, 0)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and table.concat(selected, ", ") or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.Parent = Frame
    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.Parent = Frame
    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 5
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.Parent = Frame
    local list = Instance.new("UIListLayout", OptionsFrame)
    list.Padding = UDim.new(0, 4)
    local function update_display()
        ValueLabel.Text = multiSelect and ( #selected > 0 and table.concat(selected, ", ") or "None" ) or tostring(selected)
    end
    local function toggle_option(option)
        if multiSelect then
            local idx = table.find(selected, option)
            if idx then table.remove(selected, idx) else table.insert(selected, option) end
        else
            selected = option
            self:Toggle()
        end
        update_display()
        if callback then callback(multiSelect and selected or selected) end
        if configKey then SugarUI.CurrentConfig[configKey] = selected end
    end
    local optionBtns = {}
    local function rebuild_options()
        for _, btn in ipairs(optionBtns) do btn:Destroy() end
        optionBtns = {}
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 40)
            optBtn.BackgroundColor3 = SugarUI.Theme.Button
            optBtn.Text = opt
            optBtn.TextColor3 = SugarUI.Theme.Text
            optBtn.Font = Enum.Font.SourceSans
            optBtn.TextSize = 16
            optBtn.Parent = OptionsFrame
            SugarUI.RoundCorner(8).Parent = optBtn
            optBtn.MouseButton1Click:Connect(function() toggle_option(opt) end)
            table.insert(optionBtns, optBtn)
        end
    end
    rebuild_options()
    update_display()
    function self:Toggle()
        isOpen = not isOpen
        SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, isOpen and math.min(#options * 40, 200) or 0)}, 0.25)
    end
    HeaderBtn.MouseButton1Click:Connect(function() self:Toggle() end)
    self.Instance = Frame
    self.UpdateOptions = function(newOpts)
        options = newOpts
        rebuild_options()
        update_display()
    end
    self.SetValue = function(val)
        selected = val
        update_display()
    end
    self.GetValue = function() return selected end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Button
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        for _, btn in ipairs(optionBtns) do
            btn.BackgroundColor3 = SugarUI.Theme.Button
            btn.TextColor3 = SugarUI.Theme.Text
        end
    end
    return self
end
-- ======================
-- New: TextBox component
-- ======================
local TextBoxComponent = {}
TextBoxComponent.__index = TextBoxComponent
function TextBoxComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, TextBoxComponent)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 48)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "TextBox"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.6, -12, 1, 0)
    Box.Position = UDim2.new(0.4, 0, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Text = default or ""
    Box.TextColor3 = SugarUI.Theme.Text
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 16
    Box.TextXAlignment = Enum.TextXAlignment.Right
    Box.Parent = Frame
    Box.FocusLost:Connect(function(enter)
        if enter and callback then callback(Box.Text) end
        if configKey then SugarUI.CurrentConfig[configKey] = Box.Text end
    end)
    self.Instance = Frame
    self.SetText = function(txt) Box.Text = txt end
    self.GetText = function() return Box.Text end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Box.TextColor3 = SugarUI.Theme.Text
    end
    return self
end
-- ======================
-- New: Keybind component
-- ======================
local KeybindComponent = {}
KeybindComponent.__index = KeybindComponent
function KeybindComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, KeybindComponent)
    local key = default or Enum.KeyCode.Unknown
    local listening = false
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 48)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Keybind"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local KeyLabel = Instance.new("TextButton")
    KeyLabel.Size = UDim2.new(0.4, -12, 1, 0)
    KeyLabel.Position = UDim2.new(0.6, 0, 0, 0)
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Text = key.Name
    KeyLabel.TextColor3 = SugarUI.Theme.Muted
    KeyLabel.Font = Enum.Font.SourceSansBold
    KeyLabel.TextSize = 16
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
    KeyLabel.Parent = Frame
    KeyLabel.MouseButton1Click:Connect(function()
        listening = true
        KeyLabel.Text = "Press key..."
    end)
    local conn = UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            KeyLabel.Text = key.Name
            listening = false
            if callback then callback(key) end
            if configKey then SugarUI.CurrentConfig[configKey] = key.Name end
        end
    end)
    self.Instance = Frame
    self.SetKey = function(newKey) key = newKey; KeyLabel.Text = newKey.Name end
    self.GetKey = function() return key end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        KeyLabel.TextColor3 = SugarUI.Theme.Muted
    end
    self.Destroy = function() conn:Disconnect() end
    return self
end
-- ======================
-- New: ColorPicker component
-- ======================
local ColorPickerComponent = {}
ColorPickerComponent.__index = ColorPickerComponent
function ColorPickerComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ColorPickerComponent)
    local color = default or Color3.fromRGB(255, 255, 255)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 200)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Color Picker"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.Parent = Frame
    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0, 40, 0, 40)
    Preview.Position = UDim2.new(1, -52, 0, 8)
    Preview.BackgroundColor3 = color
    Preview.Parent = Frame
    SugarUI.RoundCorner(6).Parent = Preview
    -- Saturation-Value square
    local SVSquare = Instance.new("ImageLabel")
    SVSquare.Size = UDim2.new(1, -24, 0, 120)
    SVSquare.Position = UDim2.new(0, 12, 0, 32)
    SVSquare.Image = "rbxassetid://461350199" -- White to black gradient with color overlay
    SVSquare.Parent = Frame
    local hue, sat, val = color:ToHSV()
    local SVGradient = Instance.new("UIGradient")
    SVGradient.Color = ColorSequence.new(Color3.fromHSV(hue, 1, 1), Color3.new(1,1,1))
    SVGradient.Rotation = 90
    SVGradient.Parent = SVSquare
    local SVBlackGradient = Instance.new("UIGradient")
    SVBlackGradient.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
    SVBlackGradient.Transparency = NumberSequence.new(0,1)
    SVBlackGradient.Rotation = 0
    SVBlackGradient.Parent = SVSquare
    -- Hue slider
    local HueSlider = Instance.new("Frame")
    HueSlider.Size = UDim2.new(1, -24, 0, 12)
    HueSlider.Position = UDim2.new(0, 12, 0, 160)
    HueSlider.BackgroundColor3 = Color3.new(1,1,1)
    HueSlider.Parent = Frame
    SugarUI.RoundCorner(6).Parent = HueSlider
    local HueGradient = Instance.new("UIGradient")
    HueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
    }
    HueGradient.Parent = HueSlider
    -- Update function
    local function updateColor(newColor, fire)
        color = newColor
        hue, sat, val = color:ToHSV()
        Preview.BackgroundColor3 = color
        if fire and callback then callback(color) end
        if configKey then SugarUI.CurrentConfig[configKey] = {color.R, color.G, color.B} end
    end
    self.Instance = Frame
    self.SetColor = updateColor
    self.GetColor = function() return color end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
    end
    return self
end
-- ======================
-- New: Image component
-- ======================
local ImageComponent = {}
ImageComponent.__index = ImageComponent
function ImageComponent.new(parent, imageId, sizeX, sizeY)
    local self = setmetatable({}, ImageComponent)
    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(0, sizeX or 100, 0, sizeY or 100)
    Img.BackgroundTransparency = 1
    Img.Image = "rbxassetid://" .. (imageId or "0")
    Img.Parent = parent
    SugarUI.RoundCorner(10).Parent = Img
    self.Instance = Img
    self.SetImage = function(id) Img.Image = "rbxassetid://" .. id end
    function self:UpdateTheme() end -- No theme update needed
    return self
end
-- ======================
-- Section component
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent
function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title or "Section"
    Label.TextColor3 = SugarUI.Theme.Accent
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 18
    Label.Parent = Frame
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 2)
    Line.Position = UDim2.new(0, 0, 1, -2)
    Line.BackgroundColor3 = SugarUI.Theme.Border
    Line.Parent = Frame
    self.Instance = Frame
    function self:UpdateTheme()
        Label.TextColor3 = SugarUI.Theme.Accent
        Line.BackgroundColor3 = SugarUI.Theme.Border
    end
    return self
end
-- ======================
-- Notifications (modern with slide-in)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 300, 1, 0)
    self.Container.Position = UDim2.new(1, -320, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    list.Padding = UDim.new(0, 8)
    return self
end
function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 80)
    notif.Position = UDim2.new(1, 0, 1, 0)
    notif.BackgroundColor3 = SugarUI.Theme.Panel
    notif.Parent = self.Container
    SugarUI.RoundCorner(10).Parent = notif
    SugarUI.AddShadow(notif, 0.6, 10)
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType]
    accentBar.Parent = notif
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -8, 0, 24)
    titleLbl.Position = UDim2.new(0, 8, 0, 8)
    titleLbl.Text = title
    titleLbl.TextColor3 = SugarUI.Theme.Text
    titleLbl.Font = Enum.Font.SourceSansBold
    titleLbl.TextSize = 16
    titleLbl.Parent = notif
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -8, 0, 40)
    msgLbl.Position = UDim2.new(0, 8, 0, 32)
    msgLbl.Text = message
    msgLbl.TextColor3 = SugarUI.Theme.Muted
    msgLbl.Font = Enum.Font.SourceSans
    msgLbl.TextSize = 14
    msgLbl.TextWrapped = true
    msgLbl.Parent = notif
    SugarUI.Tween(notif, {Position = UDim2.new(0, 0, 1, 0)}, 0.3)
    task.delay(duration, function()
        SugarUI.Tween(notif, {Position = UDim2.new(1, 0, 1, 0)}, 0.3)
        task.delay(0.3, function() notif:Destroy() end)
    end)
end
-- ======================
-- Window
-- ======================
local Window = {}
Window.__index = Window
function Window.new(title)
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.Components = {}
    self.Visible = false
    self.ToggleKey = Enum.KeyCode.V
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = SugarUI.Theme.Background
    MainFrame.Parent = ScreenGui
    SugarUI.RoundCorner(14).Parent = MainFrame
    SugarUI.AddShadow(MainFrame, 0.5, 12)
    SugarUI.AddGradient(MainFrame)
    -- Add tabs and other logic similar to original, but with new components
    function self:AddTab(name)
        -- Implement tab creation with new design
        local tab = {}
        -- ... (adapt from original)
        return tab
    end
    -- Add new methods for new components
    function self:AddTextBox(...) return TextBoxComponent.new(...) end
    function self:AddKeybind(...) return KeybindComponent.new(...) end
    function self:AddColorPicker(...) return ColorPickerComponent.new(...) end
    function self:AddImage(...) return ImageComponent.new(...) end
    -- Show with animation
    function self:Show()
        self.Visible = true
        MainFrame.Visible = true
        SugarUI.Tween(MainFrame, {BackgroundTransparency = 0, Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Back)
    end
    -- Hide with animation
    function self:Hide()
        self.Visible = false
        SugarUI.Tween(MainFrame, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
        task.delay(0.5, function() MainFrame.Visible = false end)
    end
    -- Confirm dialog fixed
    function self:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = SugarUI.Theme.Shadow
        overlay.BackgroundTransparency = 0.5
        overlay.Parent = ScreenGui
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 300, 0, 150)
        dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        dialog.BackgroundColor3 = SugarUI.Theme.Panel
        dialog.Parent = overlay
        SugarUI.RoundCorner(10).Parent = dialog
        local dTitle = Instance.new("TextLabel")
        dTitle.Text = title
        dTitle.Parent = dialog
        local dMsg = Instance.new("TextLabel")
        dMsg.Text = msg
        dMsg.Parent = dialog
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0.45, 0, 0, 40)
        yesBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
        yesBtn.Text = "Yes"
        yesBtn.Parent = dialog
        yesBtn.MouseButton1Click:Connect(function() yesCb() overlay:Destroy() end)
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0.45, 0, 0, 40)
        noBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
        noBtn.Text = "No"
        noBtn.Parent = dialog
        noBtn.MouseButton1Click:Connect(function() noCb() overlay:Destroy() end)
    end
    return self
end
function SugarUI:CreateWindow(title)
    return Window.new(title)
end
return SugarUI

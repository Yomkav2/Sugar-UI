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
-- Preset Themes (updated for modern, beautiful design - inspired by neumorphism and glassmorphism)
-- ======================
SugarUI.Presets = {
    Nebula = {
        Background = Color3.fromRGB(15, 20, 35),  -- Deep space blue
        Panel = Color3.fromRGB(25, 30, 55),      -- Slightly lighter
        Accent = Color3.fromRGB(120, 200, 255),  -- Soft cyan
        AccentSoft = Color3.fromRGB(150, 220, 255),
        AccentDark = Color3.fromRGB(80, 150, 200),
        Text = Color3.fromRGB(240, 245, 255),
        Muted = Color3.fromRGB(180, 190, 210),
        Shadow = Color3.fromRGB(0, 10, 30),      -- Subtle dark shadow
        Border = Color3.fromRGB(40, 50, 80),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 220, 120),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Toggle = Color3.fromRGB(20, 25, 45),
        ToggleBox = Color3.fromRGB(200, 220, 255),
        Button = Color3.fromRGB(20, 25, 45),
        ButtonHover = Color3.fromRGB(35, 40, 65),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassTint = 0.3,
    },
    Aurora = {
        Background = Color3.fromRGB(10, 15, 25),
        Panel = Color3.fromRGB(20, 25, 45),
        Accent = Color3.fromRGB(100, 255, 200),
        AccentSoft = Color3.fromRGB(120, 255, 220),
        AccentDark = Color3.fromRGB(60, 200, 150),
        Text = Color3.fromRGB(245, 250, 255),
        Muted = Color3.fromRGB(170, 200, 230),
        Shadow = Color3.fromRGB(0, 5, 20),
        Border = Color3.fromRGB(30, 40, 70),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 220, 120),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Toggle = Color3.fromRGB(15, 20, 40),
        ToggleBox = Color3.fromRGB(180, 255, 220),
        Button = Color3.fromRGB(15, 20, 40),
        ButtonHover = Color3.fromRGB(30, 35, 60),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassTint = 0.2,
    },
    Eclipse = {
        Background = Color3.fromRGB(5, 5, 15),
        Panel = Color3.fromRGB(15, 15, 30),
        Accent = Color3.fromRGB(200, 100, 255),
        AccentSoft = Color3.fromRGB(220, 120, 255),
        AccentDark = Color3.fromRGB(150, 60, 200),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(150, 150, 200),
        Shadow = Color3.fromRGB(0, 0, 10),
        Border = Color3.fromRGB(25, 25, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(100, 220, 120),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Toggle = Color3.fromRGB(10, 10, 25),
        ToggleBox = Color3.fromRGB(220, 180, 255),
        Button = Color3.fromRGB(10, 10, 25),
        ButtonHover = Color3.fromRGB(25, 25, 45),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassTint = 0.4,
    },
    Solar = {
        Background = Color3.fromRGB(255, 240, 200),
        Panel = Color3.fromRGB(255, 245, 220),
        Accent = Color3.fromRGB(255, 150, 50),
        AccentSoft = Color3.fromRGB(255, 170, 70),
        AccentDark = Color3.fromRGB(200, 100, 30),
        Text = Color3.fromRGB(50, 40, 20),
        Muted = Color3.fromRGB(150, 130, 100),
        Shadow = Color3.fromRGB(100, 80, 40),
        Border = Color3.fromRGB(220, 200, 160),
        Highlight = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(100, 220, 120),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Toggle = Color3.fromRGB(255, 250, 230),
        ToggleBox = Color3.fromRGB(50, 150, 255),
        Button = Color3.fromRGB(255, 250, 230),
        ButtonHover = Color3.fromRGB(240, 230, 200),
        Glass = Color3.fromRGB(0, 0, 0),
        GlassTint = 0.1,
    }
}

-- Default theme (start with Nebula)
SugarUI.Theme = {}
for k, v in pairs(SugarUI.Presets.Nebula) do SugarUI.Theme[k] = v end

-- Helper to apply a preset
function SugarUI.ApplyPreset(name)
    local preset = SugarUI.Presets[name]
    if not preset then return false end
    for k, v in pairs(preset) do SugarUI.Theme[k] = v end
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
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, dir)
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
    shadow.Image = "rbxassetid://1316045217"  -- Updated shadow asset for softer look
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(36, 36, 284, 284)
    shadow.Parent = frame
    return shadow
end

function SugarUI.AddGlassEffect(frame, tint)
    local glass = Instance.new("Frame")
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.BackgroundColor3 = SugarUI.Theme.Glass
    glass.BackgroundTransparency = tint or SugarUI.Theme.GlassTint
    glass.ZIndex = frame.ZIndex - 1
    glass.Parent = frame
    SugarUI.RoundCorner(12).Parent = glass
    return glass
end

-- ======================
-- Button component (updated - no size change on hover to prevent stretching)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 42)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(12).Parent = Btn
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    local gradient = Instance.new("UIGradient", Btn)
    gradient.Rotation = 45  -- Diagonal for modern look
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Button),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.2)
    })

    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.2)
        stroke.Transparency = 0.4
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.2)
        stroke.Transparency = 0.7
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            -- Enhanced ripple effect
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.BackgroundColor3 = SugarUI.Theme.Highlight
            ripple.BackgroundTransparency = 0.5
            ripple.ZIndex = Btn.ZIndex + 1
            ripple.Parent = Btn
            SugarUI.RoundCorner(50).Parent = ripple  -- Circular ripple
            SugarUI.Tween(ripple, {
                Size = UDim2.new(2, 0, 2, 0),
                BackgroundTransparency = 1
            }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.delay(0.4, function() if ripple then ripple:Destroy() end end)
            pcall(callback)
        end
    end)

    self.Instance = Btn
    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
        if Btn:FindFirstChild("UIGradient") then
            Btn.UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, SugarUI.Theme.Button),
                ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)
            })
        end
    end
    return self
end

-- ======================
-- Toggle component (updated with smooth animations)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 42)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.75, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 28, 0, 28)
    Box.Position = UDim2.new(1, -42, 0.5, -14)
    Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.Toggle
    Box.Parent = Frame
    SugarUI.RoundCorner(14).Parent = Box

    local check = Instance.new("ImageLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://6031094667"  -- Check icon
    check.ImageColor3 = SugarUI.Theme.Highlight
    check.ImageTransparency = self.State and 0 or 1
    check.Parent = Box

    -- Add inner glow for accent
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Parent = Box
    innerStroke.Color = SugarUI.Theme.Accent
    innerStroke.Transparency = 0.5
    innerStroke.Thickness = 2

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.Toggle}, 0.2)
            SugarUI.Tween(check, {ImageTransparency = self.State and 0 or 1}, 0.2)
            innerStroke.Transparency = self.State and 0.3 or 1
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    function self:Set(newState, fire)
        self.State = not not newState
        SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.Toggle}, 0.2)
        SugarUI.Tween(check, {ImageTransparency = self.State and 0 or 1}, 0.2)
        innerStroke.Transparency = self.State and 0.3 or 1
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    function self:Get() return self.State end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.Toggle
        check.ImageColor3 = SugarUI.Theme.Highlight
        innerStroke.Color = SugarUI.Theme.Accent
    end
    return self
end

-- ======================
-- Slider component (updated with better handle and fill)
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or (min or 0)
    min = min or 0
    max = max or 100
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 56)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -12, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 6)
    Track.Position = UDim2.new(0, 12, 0, 36)
    Track.BackgroundColor3 = SugarUI.Theme.Border
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    SugarUI.RoundCorner(3).Parent = Track

    local Fill = Instance.new("Frame")
    local initialFill = (max - min ~= 0) and (value - min) / (max - min) or 0
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    SugarUI.RoundCorner(3).Parent = Fill
    local fillGradient = Instance.new("UIGradient", Fill)
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.AccentDark),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.Accent)
    })

    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 20, 0, 20)
    Handle.Position = UDim2.new(initialFill, -10, 0.5, -10)
    Handle.BackgroundColor3 = SugarUI.Theme.Highlight
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    SugarUI.RoundCorner(10).Parent = Handle
    local handleStroke = Instance.new("UIStroke", Handle)
    handleStroke.Color = SugarUI.Theme.Accent
    handleStroke.Thickness = 2

    local dragging = false
    local function set_value(newValue, fire)
        newValue = math.clamp(tonumber(newValue) or newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = (max - min ~= 0) and (value - min) / (max - min) or 0
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.15)
        SugarUI.Tween(Handle, {Position = UDim2.new(fillSize, -10, 0.5, -10)}, 0.15)
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
            SugarUI.Tween(Handle, {Size = UDim2.new(0, 24, 0, 24)}, 0.1)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            SugarUI.Tween(Handle, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update_from_mouse(input)
        end
    end)

    self.Instance = Frame
    self.SetValue = set_value
    function self:GetValue() return value end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        Track.BackgroundColor3 = SugarUI.Theme.Border
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
        Handle.BackgroundColor3 = SugarUI.Theme.Highlight
        handleStroke.Color = SugarUI.Theme.Accent
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SugarUI.Theme.AccentDark),
            ColorSequenceKeypoint.new(1, SugarUI.Theme.Accent)
        })
    end
    return self
end

-- ======================
-- Dropdown component (updated with better multi-select as MultiList)
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent

function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    local isOpen = false
    options = options or {}
    multiSelect = multiSelect or false
    local selected = multiSelect and (default or {}) or (default or options[1] or "None")
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 42)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -12, 1, 0)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and (#selected > 0 and table.concat(selected, ", ") or "None") or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame
    HeaderBtn.ZIndex = 50

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Accent
    OptionsFrame.ScrollBarImageTransparency = 0.5
    OptionsFrame.ZIndex = 60
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local optionsList = Instance.new("UIListLayout", OptionsFrame)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Padding = UDim.new(0, 4)

    local optionsPadding = Instance.new("UIPadding", OptionsFrame)
    optionsPadding.PaddingTop = UDim.new(0, 4)
    optionsPadding.PaddingBottom = UDim.new(0, 4)
    optionsPadding.PaddingLeft = UDim.new(0, 8)
    optionsPadding.PaddingRight = UDim.new(0, 8)

    local function update_value_display()
        if multiSelect then
            local count = #selected
            if count == 0 then
                ValueLabel.Text = "None"
            elseif count <= 2 then
                ValueLabel.Text = table.concat(selected, ", ")
            else
                ValueLabel.Text = selected[1] .. " + " .. (count - 1)
            end
        else
            ValueLabel.Text = tostring(selected)
        end
    end

    local function apply_config_store()
        if configKey then SugarUI.CurrentConfig[configKey] = multiSelect and selected or selected end
    end

    local function toggle_option(option)
        if multiSelect then
            local index = table.find(selected, option)
            if index then
                table.remove(selected, index)
            else
                table.insert(selected, option)
            end
            callback(selected)
        else
            selected = option
            self:Toggle()
            callback(option)
        end
        update_value_display()
        apply_config_store()
    end

    local optionObjects = {}
    local function create_option(optionText, index)
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Size = UDim2.new(1, 0, 0, 36)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.LayoutOrder = index
        OptionFrame.Parent = OptionsFrame

        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.BackgroundColor3 = SugarUI.Theme.Button
        OptionButton.Text = optionText
        OptionButton.TextColor3 = SugarUI.Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionFrame
        SugarUI.RoundCorner(8).Parent = OptionButton

        local pad = Instance.new("UIPadding", OptionButton)
        pad.PaddingLeft = UDim.new(0, 12)

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.8
        optionStroke.Thickness = 1

        local isSelected = multiSelect and table.find(selected, optionText) or (selected == optionText)
        OptionButton.BackgroundColor3 = isSelected and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button

        if multiSelect then
            local Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 24, 0, 24)
            Check.Position = UDim2.new(1, -30, 0.5, -12)
            Check.BackgroundColor3 = isSelected and SugarUI.Theme.Accent or SugarUI.Theme.Toggle
            Check.Parent = OptionButton
            SugarUI.RoundCorner(12).Parent = Check

            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(1, 0, 1, 0)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = SugarUI.Theme.Highlight
            CheckIcon.Visible = isSelected
            CheckIcon.Parent = Check
        end

        OptionButton.MouseButton1Click:Connect(function()
            local wasSelected = isSelected
            toggle_option(optionText)
            isSelected = multiSelect and table.find(selected, optionText) or (selected == optionText)
            SugarUI.Tween(OptionButton, {BackgroundColor3 = isSelected and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button}, 0.15)
            if multiSelect and OptionButton:FindFirstChild("Frame") then
                local Check = OptionButton.Frame
                SugarUI.Tween(Check, {BackgroundColor3 = isSelected and SugarUI.Theme.Accent or SugarUI.Theme.Toggle}, 0.15)
                Check.CheckIcon.Visible = isSelected
            end
        end)

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.1)
        end)
        OptionButton.MouseLeave:Connect(function()
            local targetColor = isSelected and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button
            SugarUI.Tween(OptionButton, {BackgroundColor3 = targetColor}, 0.1)
        end)

        optionObjects[#optionObjects + 1] = {btn = OptionButton}
    end

    local function rebuild_options()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= optionsList and child ~= optionsPadding then
                child:Destroy()
            end
        end
        optionObjects = {}
        for i, option in ipairs(options) do
            create_option(option, i)
        end
        update_value_display()
    end

    function self:Toggle()
        isOpen = not isOpen
        local height = math.min(#options * 36 + 8, 200)
        if isOpen then
            Label.Visible = false
            ValueLabel.Visible = false
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.25, Enum.EasingStyle.Back)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -12, 0, 42 + height)}, 0.25, Enum.EasingStyle.Back)
        else
            Label.Visible = true
            ValueLabel.Visible = true
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25, Enum.EasingStyle.Sine)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -12, 0, 42)}, 0.25, Enum.EasingStyle.Sine)
        end
    end

    function self:UpdateOptions(newOptions)
        options = newOptions or {}
        rebuild_options()
        if not multiSelect then
            if not table.find(options, selected) then selected = options[1] or "None" end
        else
            local filtered = {}
            for _, s in ipairs(selected) do
                if table.find(options, s) then table.insert(filtered, s) end
            end
            selected = filtered
        end
        update_value_display()
        apply_config_store()
    end

    rebuild_options()
    HeaderBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    self.Instance = Frame
    function self:IsOpen() return isOpen end
    function self:SetValue(value)
        selected = multiSelect and (value or {}) or (value or options[1] or "None")
        update_value_display()
        apply_config_store()
    end
    function self:GetValue() return selected end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Accent
        for _, obj in ipairs(optionObjects) do
            obj.btn.BackgroundColor3 = SugarUI.Theme.Button
            obj.btn.TextColor3 = SugarUI.Theme.Text
            obj.btn.UIStroke.Color = SugarUI.Theme.Border
        end
    end
    return self
end

-- ======================
-- TextBox component (new)
-- ======================
local TextBoxComponent = {}
TextBoxComponent.__index = TextBoxComponent

function TextBoxComponent.new(parent, placeholder, default, callback, configKey)
    local self = setmetatable({}, TextBoxComponent)
    self.Value = default or ""
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 42)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = placeholder or "Enter text..."
    Label.TextColor3 = SugarUI.Theme.Muted
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -24, 0, 24)
    TextBox.Position = UDim2.new(0, 12, 0, 28)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = self.Value
    TextBox.PlaceholderText = placeholder or "Enter text..."
    TextBox.TextColor3 = SugarUI.Theme.Text
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Frame

    TextBox.Focused:Connect(function()
        SugarUI.Tween(stroke, {Transparency = 0.4, Color = SugarUI.Theme.Accent}, 0.2)
        Label.Visible = false
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        self.Value = TextBox.Text
        SugarUI.Tween(stroke, {Transparency = 0.8, Color = SugarUI.Theme.Border}, 0.2)
        Label.Visible = self.Value == ""
        if enterPressed and callback then pcall(callback, self.Value) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.Value end
    end)

    self.Instance = Frame
    function self:GetValue() return self.Value end
    function self:SetValue(newValue)
        self.Value = tostring(newValue or "")
        TextBox.Text = self.Value
        Label.Visible = self.Value == ""
        if configKey then SugarUI.CurrentConfig[configKey] = self.Value end
    end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        TextBox.TextColor3 = SugarUI.Theme.Text
        Label.TextColor3 = SugarUI.Theme.Muted
    end
    return self
end

-- ======================
-- Keybind component (new - proper keybind)
-- ======================
local KeybindComponent = {}
KeybindComponent.__index = KeybindComponent

function KeybindComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, KeybindComponent)
    self.Key = default or Enum.KeyCode.V
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 42)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Keybind"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(0.3, -12, 1, 0)
    KeyLabel.Position = UDim2.new(0.7, 0, 0, 0)
    KeyLabel.BackgroundColor3 = SugarUI.Theme.Button
    KeyLabel.Text = self.Key.Name
    KeyLabel.TextColor3 = SugarUI.Theme.Text
    KeyLabel.Font = Enum.Font.GothamBold
    KeyLabel.TextSize = 14
    KeyLabel.Parent = Frame
    SugarUI.RoundCorner(8).Parent = KeyLabel

    local listening = false
    local conn
    local function startListening()
        if listening then return end
        listening = true
        KeyLabel.Text = "..."
        KeyLabel.BackgroundColor3 = SugarUI.Theme.Accent
        if conn then conn:Disconnect() end
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            self.Key = input.KeyCode
            KeyLabel.Text = self.Key.Name
            KeyLabel.BackgroundColor3 = SugarUI.Theme.Button
            listening = false
            if callback then pcall(callback, self.Key) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.Key.Name end
            conn:Disconnect()
        end)
    end

    KeyLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startListening()
        end
    end)

    self.Instance = Frame
    function self:GetKey() return self.Key end
    function self:SetKey(newKey)
        self.Key = newKey
        KeyLabel.Text = newKey.Name
        if configKey then SugarUI.CurrentConfig[configKey] = newKey.Name end
    end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        KeyLabel.BackgroundColor3 = SugarUI.Theme.Button
        KeyLabel.TextColor3 = SugarUI.Theme.Text
    end
    return self
end

-- ======================
-- ColorPicker component (new - simple RGB sliders)
-- ======================
local ColorPickerComponent = {}
ColorPickerComponent.__index = ColorPickerComponent

function ColorPickerComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ColorPickerComponent)
    self.Color = default or Color3.fromRGB(255, 255, 255)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 120)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.Parent = parent
    SugarUI.RoundCorner(12).Parent = Frame
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Color Picker"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Parent = Frame

    local ColorPreview = Instance.new("Frame")
    ColorPreview.Size = UDim2.new(0, 30, 0, 30)
    ColorPreview.Position = UDim2.new(1, -42, 0, 10)
    ColorPreview.BackgroundColor3 = self.Color
    ColorPreview.BorderSizePixel = 0
    ColorPreview.Parent = Frame
    SugarUI.RoundCorner(6).Parent = ColorPreview

    local rSlider = SliderComponent.new(Frame, "R", 0, 255, self.Color.R * 255, function(val) self:UpdateColor(val / 255, self.Color.G, self.Color.B) end)
    rSlider.Instance.Position = UDim2.new(0, 0, 0, 40)
    rSlider.Instance.Size = UDim2.new(1, 0, 0, 20)

    local gSlider = SliderComponent.new(Frame, "G", 0, 255, self.Color.G * 255, function(val) self:UpdateColor(self.Color.R, val / 255, self.Color.B) end)
    gSlider.Instance.Position = UDim2.new(0, 0, 0, 60)
    gSlider.Instance.Size = UDim2.new(1, 0, 0, 20)

    local bSlider = SliderComponent.new(Frame, "B", 0, 255, self.Color.B * 255, function(val) self:UpdateColor(self.Color.R, self.Color.G, val / 255) end)
    bSlider.Instance.Position = UDim2.new(0, 0, 0, 80)
    bSlider.Instance.Size = UDim2.new(1, 0, 0, 20)

    function self:UpdateColor(r, g, b)
        self.Color = Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
        ColorPreview.BackgroundColor3 = self.Color
        if callback then pcall(callback, self.Color) end
        if configKey then SugarUI.CurrentConfig[configKey] = {R = self.Color.R, G = self.Color.G, B = self.Color.B} end
    end

    self.Instance = Frame
    function self:GetColor() return self.Color end
    function self:SetColor(newColor)
        self.Color = newColor or Color3.fromRGB(255, 255, 255)
        rSlider:SetValue(self.Color.R * 255)
        gSlider:SetValue(self.Color.G * 255)
        bSlider:SetValue(self.Color.B * 255)
        ColorPreview.BackgroundColor3 = self.Color
        if configKey then SugarUI.CurrentConfig[configKey] = {R = self.Color.R, G = self.Color.G, B = self.Color.B} end
    end
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        rSlider:UpdateTheme()
        gSlider:UpdateTheme()
        bSlider:UpdateTheme()
    end
    return self
end

-- ======================
-- Image component (new)
-- ======================
local ImageComponent = {}
ImageComponent.__index = ImageComponent

function ImageComponent.new(parent, imageId, size)
    local self = setmetatable({}, ImageComponent)
    local Frame = Instance.new("Frame")
    Frame.Size = size or UDim2.new(1, 0, 0, 100)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    local Image = Instance.new("ImageLabel")
    Image.Size = UDim2.new(1, 0, 1, 0)
    Image.BackgroundTransparency = 1
    Image.Image = "rbxassetid://" .. tostring(imageId or 0)
    Image.ScaleType = Enum.ScaleType.Fit
    Image.Parent = Frame
    SugarUI.RoundCorner(8).Parent = Image
    self.Instance = Frame
    function self:SetImage(newId)
        Image.Image = "rbxassetid://" .. tostring(newId or 0)
    end
    return self
end

-- ======================
-- Section component (updated)
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 40)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -24, 0, 2)
    line.Position = UDim2.new(0, 12, 1, -10)
    line.BackgroundColor3 = SugarUI.Theme.Accent
    line.BorderSizePixel = 0
    line.Parent = wrapper
    SugarUI.RoundCorner(1).Parent = line
    self._wrapper = wrapper
    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Accent
        line.BackgroundColor3 = SugarUI.Theme.Accent
    end
    return self
end

-- ======================
-- Notifications (updated with better animations)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 360, 1, 0)
    self.Container.Position = UDim2.new(1, -380, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 900
    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 12)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 0, 0, 80)
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = SugarUI.Theme.Panel
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = #self.Notifications + 1
    notification.Parent = self.Container
    SugarUI.RoundCorner(12).Parent = notification
    SugarUI.AddShadow(notification, 0.3, 10)
    notification.ZIndex = 901

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = (function()
        if notifType == "Success" then return SugarUI.Theme.Success
        elseif notifType == "Warning" then return SugarUI.Theme.Warning
        elseif notifType == "Error" then return SugarUI.Theme.Error
        else return SugarUI.Theme.Accent end
    end)()
    accent.BorderSizePixel = 0
    accent.Parent = notification

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 16, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = (function()
        if notifType == "Success" then return "rbxassetid://6031094667"
        elseif notifType == "Warning" then return "rbxassetid://6031094687"
        elseif notifType == "Error" then return "rbxassetid://6031094688"
        else return "rbxassetid://6031280882" end
    end)()
    icon.ImageColor3 = SugarUI.Theme.Text
    icon.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 44, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -60, 0, 40)
    messageLabel.Position = UDim2.new(0, 44, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -26, 0.5, -10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Muted
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = notification

    -- Slide in animation
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, 80), Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)

    closeButton.MouseButton1Click:Connect(function()
        self:Remove(notification)
    end)

    closeButton.MouseEnter:Connect(function()
        SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Text}, 0.1)
    end)
    closeButton.MouseLeave:Connect(function()
        SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Muted}, 0.1)
    end)

    if duration > 0 then
        task.delay(duration, function() self:Remove(notification) end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Sine)
    task.delay(0.2, function() if notification then notification:Destroy() end end)
    for i, v in ipairs(self.Notifications) do
        if v == notification then table.remove(self.Notifications, i) break end
    end
end

-- ======================
-- Window (updated design - new layout, glass effects, better animations)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0
    local tabComponents = {}
    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 50)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -20, 1, 0)
    tabBtn.Position = UDim2.new(0, 10, 0, 0)
    tabBtn.BackgroundColor3 = SugarUI.Theme.Button
    tabBtn.Text = name
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap
    SugarUI.RoundCorner(10).Parent = tabBtn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0.6, 0)
    indicator.Position = UDim2.new(0, 2, 0.2, 0)
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
    scrollingFrame.Size = UDim2.new(1, -20, 1, -20)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 10)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = SugarUI.Theme.Accent
    scrollingFrame.ScrollBarImageTransparency = 0.4
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.PagesHolder:GetChildren()) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            SugarUI.Tween(t.button, {
                BackgroundColor3 = (t.name == name) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button,
                TextColor3 = (t.name == name) and SugarUI.Theme.Highlight or SugarUI.Theme.Muted
            }, 0.2)
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
            table.insert(tabComponents, {type = "toggle", key = configKey, obj = tog})
            table.insert(selfObj.Components, {type = "toggle", key = configKey, obj = tog})
            return tog
        end,
        AddSlider = function(_, txt, min, max, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local slider = SliderComponent.new(scrollingFrame, txt, min, max, def, cb, configKey)
            slider.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "slider", key = configKey, obj = slider})
            table.insert(selfObj.Components, {type = "slider", key = configKey, obj = slider})
            return slider
        end,
        AddDropdown = function(_, txt, options, def, cb, multi, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local drop = DropdownComponent.new(scrollingFrame, txt, options, def, cb, multi, configKey)
            drop.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "dropdown", key = configKey, obj = drop})
            table.insert(selfObj.Components, {type = "dropdown", key = configKey, obj = drop})
            return drop
        end,
        AddTextBox = function(_, placeholder, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local tb = TextBoxComponent.new(scrollingFrame, placeholder, def, cb, configKey)
            tb.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "textbox", key = configKey, obj = tb})
            table.insert(selfObj.Components, {type = "textbox", key = configKey, obj = tb})
            return tb
        end,
        AddKeybind = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local kb = KeybindComponent.new(scrollingFrame, txt, def, cb, configKey)
            kb.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "keybind", key = configKey, obj = kb})
            table.insert(selfObj.Components, {type = "keybind", key = configKey, obj = kb})
            return kb
        end,
        AddColorPicker = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local cp = ColorPickerComponent.new(scrollingFrame, txt, def, cb, configKey)
            cp.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "colorpicker", key = configKey, obj = cp})
            table.insert(selfObj.Components, {type = "colorpicker", key = configKey, obj = cp})
            return cp
        end,
        AddImage = function(_, imageId, size)
            layoutOrderCounter = layoutOrderCounter + 1
            local img = ImageComponent.new(scrollingFrame, imageId, size)
            img.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type = "image", obj = img})
            table.insert(selfObj.Components, {type = "image", obj = img})
            return img
        end,
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page
    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = SugarUI.Theme.Highlight
        tabBtn.BackgroundColor3 = SugarUI.Theme.AccentSoft
        indicator.Visible = true
        page.Visible = true
        selfObj.ActiveTab = name
    end
    return tabObj
end

function Window.new(title)
    local selfObj = setmetatable({}, Window)
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
    pcall(function() ScreenGui.DisplayOrder = 100 end)

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
    OuterFrame.Size = UDim2.new(0, 600, 0, 500)
    OuterFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 24, 1, 24)
    ShadowFrame.Position = UDim2.new(0, -12, 0, -12)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://1316045217"
    ShadowFrame.ImageColor3 = SugarUI.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.5
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(36, 36, 284, 284)
    ShadowFrame.Parent = OuterFrame

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(16).Parent = Frame
    SugarUI.AddGlassEffect(Frame, 0.1)  -- Glass effect

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 64)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.Parent = Frame
    SugarUI.RoundCorner(16, 0, 16, 16).CornerRadius = UDim.new(0, 16)  -- Only top corners
    TopBar.Corner = SugarUI.RoundCorner(16)

    local topGradient = Instance.new("UIGradient", TopBar)
    topGradient.Rotation = 90
    topGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Panel),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentDark)
    })
    topGradient.Transparency = NumberSequence.new(0.05, 0.2)

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.6
    topStroke.Thickness = 1

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLbl.Position = UDim2.new(0, 20, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    MinimizeBtn.Position = UDim2.new(1, -90, 0.5, -20)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Muted
    MinimizeBtn.Text = "−"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.TextColor3 = SugarUI.Theme.Text
    MinimizeBtn.Parent = TopBar
    SugarUI.RoundCorner(20).Parent = MinimizeBtn

    MinimizeBtn.MouseEnter:Connect(function()
        SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.Warning}, 0.15)
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.Muted}, 0.15)
    end)
    MinimizeBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -20)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Muted
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.TextColor3 = SugarUI.Theme.Text
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(20).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Error}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Muted}, 0.15)
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, -64)
    Sidebar.Position = UDim2.new(0, 0, 0, 64)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(0, 16, 0, 0).CornerRadius = UDim.new(0, 0)  -- Left side only

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.7
    sideStroke.Thickness = 1

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 16)
    tabsPadding.PaddingLeft = UDim.new(0, 16)
    tabsPadding.PaddingRight = UDim.new(0, 16)
    tabsPadding.PaddingBottom = UDim.new(0, 16)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -200, 1, -64)
    PagesHolder.Position = UDim2.new(0, 200, 0, 64)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Responsiveness
    local function getViewport()
        Camera = Workspace.CurrentCamera
        return Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    end

    local function updateSize()
        local vp = getViewport()
        local w = math.clamp(vp.X * 0.6, 500, 1200)
        local h = math.clamp(vp.Y * 0.7, 400, 800)
        OuterFrame.Size = UDim2.new(0, w, 0, h)
        OuterFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end

    updateSize()
    if Camera then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)
    end

    -- Dragging
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = OuterFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            OuterFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle key
    local toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == selfObj.ToggleKey then
            if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
        end
    end)

    -- Mobile support (simplified)
    if UserInputService.TouchEnabled then
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 80, 0, 40)
        toggleBtn.Position = UDim2.new(1, -90, 1, -50)
        toggleBtn.Text = "UI"
        toggleBtn.BackgroundColor3 = SugarUI.Theme.Panel
        toggleBtn.TextColor3 = SugarUI.Theme.Text
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 14
        toggleBtn.Parent = ScreenGui
        SugarUI.RoundCorner(8).Parent = toggleBtn
        toggleBtn.MouseButton1Click:Connect(function() 
            if selfObj.Visible then selfObj:Hide() else selfObj:Show() end 
        end)
    end

    -- Enhanced animations
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        OuterFrame.Size = UDim2.new(0, 0, 0, 0)
        OuterFrame.Position = UDim2.new(0.5, 0, 0.5, 100)  -- Start from top
        ShadowFrame.ImageTransparency = 1
        Frame.BackgroundTransparency = 1
        SugarUI.Tween(OuterFrame, {
            Size = UDim2.new(0, 600, 0, 500),
            Position = UDim2.new(0.5, -300, 0.5, -250)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 0.5}, 0.4)
        SugarUI.Tween(Frame, {BackgroundTransparency = 0}, 0.4)
    end

    function selfObj:Hide()
        selfObj.Visible = false
        SugarUI.Tween(OuterFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 100)
        }, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 1}, 0.3)
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
        end)
    end

    -- Initial show with delay
    task.wait(0.1)
    selfObj:Show()

    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Close UI?", "Are you sure you want to close Sugar UI?", function()
            SugarUI.Tween(OuterFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            task.delay(0.3, function() ScreenGui:Destroy() end)
        end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.6
        overlay.Parent = ScreenGui
        overlay.ZIndex = 2000

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 400, 0, 200)
        panel.Position = UDim2.new(0.5, -200, 0.5, -100)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        panel.Parent = overlay
        SugarUI.RoundCorner(12).Parent = panel
        SugarUI.AddShadow(panel, 0.4, 12)

        local pStroke = Instance.new("UIStroke", panel)
        pStroke.Color = SugarUI.Theme.Border
        pStroke.Transparency = 0.5
        pStroke.Thickness = 1.5

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -20, 0, 40)
        titleLbl.Position = UDim2.new(0, 10, 0, 10)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16
        titleLbl.TextXAlignment = Enum.TextXAlignment.Center
        titleLbl.Parent = panel

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -20, 0, 80)
        msgLbl.Position = UDim2.new(0, 10, 0, 50)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.TextWrapped = true
        msgLbl.TextXAlignment = Enum.TextXAlignment.Center
        msgLbl.Parent = panel

        -- Fixed buttons - no size change, positioned absolutely
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0.4, -10, 0, 40)
        yesBtn.Position = UDim2.new(0.1, 0, 1, -50)
        yesBtn.BackgroundColor3 = SugarUI.Theme.Success
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = SugarUI.Theme.Highlight
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 14
        yesBtn.Parent = panel
        SugarUI.RoundCorner(8).Parent = yesBtn
        yesBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)

        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0.4, -10, 0, 40)
        noBtn.Position = UDim2.new(0.55, 0, 1, -50)
        noBtn.BackgroundColor3 = SugarUI.Theme.Error
        noBtn.Text = "No"
        noBtn.TextColor3 = SugarUI.Theme.Highlight
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 14
        noBtn.Parent = panel
        SugarUI.RoundCorner(8).Parent = noBtn
        noBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
            if noCb then noCb() end
        end)

        -- Hover for buttons without size change
        for _, btn in pairs({yesBtn, noBtn}) do
            btn.AutoButtonColor = false
            btn.MouseEnter:Connect(function()
                SugarUI.Tween(btn, {Size = UDim2.new(0.4, -8, 0, 40)}, 0.1)  -- Slight padding increase only
            end)
            btn.MouseLeave:Connect(function()
                SugarUI.Tween(btn, {Size = UDim2.new(0.4, -10, 0, 40)}, 0.1)
            end)
        end
    end

    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications

    function selfObj:AddTab(name) return createTab(selfObj, name) end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end

    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs) do
            if t.name == selfObj.ActiveTab then return t end
        end
        return nil
    end

    function selfObj:SetToggleKey(key)
        selfObj.ToggleKey = key
        if toggleConnection then toggleConnection:Disconnect() end
        toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == key then
                if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
            end
        end)
        SugarUI.CurrentConfig["ToggleKey"] = key.Name
    end

    function selfObj:Notify(title, message, duration, type_) return selfObj.Notifications:Notify(title, message, duration, type_) end

    function selfObj:ApplyConfig(config)
        if type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local val = comp.key and config[comp.key]
            if val ~= nil then
                if comp.type == "toggle" and comp.obj.Set then comp.obj:Set(val, false)
                elseif comp.type == "slider" and comp.obj.SetValue then comp.obj:SetValue(tonumber(val) or val)
                elseif comp.type == "dropdown" and comp.obj.SetValue then comp.obj:SetValue(val)
                elseif comp.type == "textbox" and comp.obj.SetValue then comp.obj:SetValue(val)
                elseif comp.type == "keybind" and comp.obj.SetKey then
                    local k = Enum.KeyCode[val]
                    if k then comp.obj:SetKey(k) end
                elseif comp.type == "colorpicker" and comp.obj.SetColor then
                    if type(val) == "table" then comp.obj:SetColor(Color3.fromRGB(val.R * 255, val.G * 255, val.B * 255)) end
                end
            end
        end
        if config["ToggleKey"] then
            local key = Enum.KeyCode[config["ToggleKey"]]
            if key then selfObj:SetToggleKey(key) end
        end
        if config["Theme"] then SugarUI.ApplyPreset(config["Theme"]) end
        selfObj:Notify("Config", "Configuration applied successfully!", 2, "Success")
    end

    function selfObj:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Background
        TopBar.BackgroundColor3 = SugarUI.Theme.Panel
        topGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SugarUI.Theme.Panel),
            ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentDark)
        })
        topStroke.Color = SugarUI.Theme.Border
        TitleLbl.TextColor3 = SugarUI.Theme.Text
        MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Muted
        MinimizeBtn.TextColor3 = SugarUI.Theme.Text
        CloseBtn.BackgroundColor3 = SugarUI.Theme.Muted
        CloseBtn.TextColor3 = SugarUI.Theme.Text
        Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
        sideStroke.Color = SugarUI.Theme.Border
        for _, tab in ipairs(selfObj.Tabs) do
            tab.button.BackgroundColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button
            tab.button.TextColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Highlight or SugarUI.Theme.Muted
            tab.indicator.BackgroundColor3 = SugarUI.Theme.Accent
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Accent
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then comp.obj:UpdateTheme() end
            end
        end
        -- Update all shadows
        for _, desc in ipairs(ScreenGui:GetDescendants()) do
            if desc.Name == "Shadow" and desc:IsA("ImageLabel") then
                desc.ImageColor3 = SugarUI.Theme.Shadow
            end
        end
        if selfObj.Frame:FindFirstChild("Frame") and selfObj.Frame.Frame:IsA("Frame") then  -- Glass
            selfObj.Frame.Frame.BackgroundTransparency = SugarUI.Theme.GlassTint
        end
    end

    SugarUI.CurrentWindow = selfObj
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    return selfObj
end

function SugarUI:CreateWindow(title)
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    local window = Window.new(title)
    if SugarUI.CurrentConfig["Theme"] then
        SugarUI.ApplyPreset(SugarUI.CurrentConfig["Theme"])
    end
    return window
end

SugarUI.ApplyTheme = SugarUI.ApplyPreset
function SugarUI.GetAvailableThemes()
    local keys = {}
    for k in pairs(SugarUI.Presets) do table.insert(keys, k) end
    return keys
end

return SugarUI

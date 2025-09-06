-- init.lua (Sugar UI - Обновлённый дизайн и анимация появления)
local SugarUI = {}
SugarUI.__index = SugarUI

-- Сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Camera = Workspace.CurrentCamera

-- ======================
-- Preset Themes (фиксированные)
-- ======================
SugarUI.Presets = {
    Pinky = {
        Background = Color3.fromRGB(18, 10, 18),
        Panel = Color3.fromRGB(30, 12, 28),
        Accent = Color3.fromRGB(255, 105, 180),
        AccentSoft = Color3.fromRGB(230, 95, 150),
        AccentDark = Color3.fromRGB(170, 30, 90),
        Text = Color3.fromRGB(245, 240, 250),
        Muted = Color3.fromRGB(170, 150, 160),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(50, 30, 40),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(28, 12, 22),
        ToggleBox = Color3.fromRGB(230,230,230),
        Button = Color3.fromRGB(28,12,22),
        ButtonHover = Color3.fromRGB(45,20,35),
    },
    Amethyst = {
        Background = Color3.fromRGB(12, 8, 26),
        Panel = Color3.fromRGB(26, 16, 40),
        Accent = Color3.fromRGB(153, 102, 204),
        AccentSoft = Color3.fromRGB(150, 110, 210),
        AccentDark = Color3.fromRGB(90, 60, 120),
        Text = Color3.fromRGB(240, 240, 250),
        Muted = Color3.fromRGB(160, 150, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(48, 40, 60),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(24,18,36),
        ToggleBox = Color3.fromRGB(200,200,200),
        Button = Color3.fromRGB(24,18,36),
        ButtonHover = Color3.fromRGB(42,35,60),
    },
    Dark = {
        Background = Color3.fromRGB(14, 14, 16),
        Panel = Color3.fromRGB(26, 26, 30),
        Accent = Color3.fromRGB(95, 176, 238),
        AccentSoft = Color3.fromRGB(70, 140, 210),
        AccentDark = Color3.fromRGB(2, 119, 189),
        Text = Color3.fromRGB(240, 240, 240),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(45, 45, 48),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(30, 30, 30),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(30, 30, 30),
        ButtonHover = Color3.fromRGB(52, 52, 56),
    },
    White = {
        Background = Color3.fromRGB(245, 245, 248),
        Panel = Color3.fromRGB(238, 238, 240),
        Accent = Color3.fromRGB(40, 120, 200),
        AccentSoft = Color3.fromRGB(85, 140, 220),
        AccentDark = Color3.fromRGB(10, 70, 140),
        Text = Color3.fromRGB(18, 18, 18),
        Muted = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(210, 210, 210),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(245,245,245),
        ToggleBox = Color3.fromRGB(40,40,40),
        Button = Color3.fromRGB(245,245,245),
        ButtonHover = Color3.fromRGB(230,230,230),
    }
}

-- default theme (start with Dark)
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.Dark) do SugarUI.Theme[k] = v end

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
-- Вспомогательные
-- ======================
function SugarUI.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    return corner
end

function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Sine
    dir = dir or Enum.EasingDirection.InOut
    local tweenInfo = TweenInfo.new(duration or 0.22, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function SugarUI.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 18, 1, size or 18)
    shadow.Position = UDim2.new(0, -(size or 18)/2, 0, -(size or 18)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.78
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 1
    shadow.Parent = frame
    return shadow
end

-- small helper for subtle overlay (glass effect)
function SugarUI.AddGlassOverlay(parent)
    local overlay = Instance.new("Frame")
    overlay.Name = "GlassOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 0
    overlay.BackgroundColor3 = parent.BackgroundColor3
    overlay.BorderSizePixel = 0
    overlay.Parent = parent

    local grad = Instance.new("UIGradient", overlay)
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255):Lerp(Color3.new(1,1,1), 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255):Lerp(Color3.new(1,1,1), 0))
    })
    grad.Transparency = NumberSequence.new(0.93, 0.96) -- very subtle

    overlay.ZIndex = parent.ZIndex + 1
    return overlay
end

-- ======================
-- Button component (улучшенный внешний вид)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 36)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.88
    stroke.Thickness = 1

    local gradient = Instance.new("UIGradient", Btn)
    gradient.Name = "BtnGrad"
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new(0.12,0)
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, SugarUI.Theme.Button), ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)})

    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12)
        SugarUI.Tween(stroke, {Transparency = 0.7}, 0.12)
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.12)
        SugarUI.Tween(stroke, {Transparency = 0.88}, 0.12)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            -- Ripple
            local ripple = Instance.new("ImageLabel")
            ripple.Size = UDim2.new(0, 12, 0, 12)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundTransparency = 1
            ripple.Image = "rbxassetid://7663593618"
            ripple.ImageColor3 = SugarUI.Theme.Highlight
            ripple.AnchorPoint = Vector2.new(0.5,0.5)
            ripple.Rotation = 0
            ripple.ZIndex = Btn.ZIndex + 5
            ripple.Parent = Btn
            SugarUI.Tween(ripple, {Size = UDim2.new(2.6, 0, 2.6, 0), ImageTransparency = 1}, 0.36, Enum.EasingStyle.Quad)
            task.delay(0.36, function() if ripple and ripple.Parent then ripple:Destroy() end end)
            pcall(callback)
        end
    end)

    self.Instance = Btn

    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
        local grad = Btn:FindFirstChild("BtnGrad")
        if grad and grad:IsA("UIGradient") then
            grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, SugarUI.Theme.Button), ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)})
        end
    end

    return self
end

-- ======================
-- Toggle component
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.BackgroundTransparency = 0
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
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

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 26, 0, 26)
    Box.Position = UDim2.new(1, -40, 0.5, -13)
    Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    Box.Parent = Frame
    SugarUI.RoundCorner(8).Parent = Box

    local check = Instance.new("ImageLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://6031094667"
    check.ImageColor3 = SugarUI.Theme.Highlight
    check.Visible = self.State
    check.Parent = Box

    SugarUI.AddShadow(Box, 0.6, 6)

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.12, Enum.EasingStyle.Sine)
            SugarUI.Tween(check, {ImageTransparency = self.State and 0 or 1}, 0.12)
            check.Visible = true
            task.delay(0.12, function() if not self.State then check.Visible = false end end)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.12)
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        check.ImageColor3 = SugarUI.Theme.Highlight
    end

    return self
end

-- ======================
-- Slider component (унитарный)
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or (min or 0)
    min = min or 0
    max = max or 100

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 52)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.BackgroundTransparency = 0
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -16, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 10)
    Track.Position = UDim2.new(0, 12, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    SugarUI.RoundCorner(8).Parent = Track

    local Fill = Instance.new("Frame")
    local initialFill = 0
    if max - min ~= 0 then initialFill = (value - min) / (max - min) end
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    SugarUI.RoundCorner(8).Parent = Fill

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
        Track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
    end

    return self
end

-- ======================
-- Dropdown component
-- ======================
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
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Button
    Frame.BackgroundTransparency = 0
    Frame.ClipsDescendants = false
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1

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
    ValueLabel.Position = UDim2.new(0.7, -6, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame
    HeaderBtn.ZIndex = 50

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 36)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.ScrollBarImageTransparency = 0.5
    OptionsFrame.ZIndex = 60

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

    local function toggle_option(option)
        if multiSelect then
            local index = table.find(selected, option)
            if index then table.remove(selected, index) else table.insert(selected, option) end
        else
            selected = option
            self.Toggle(self)
        end
        update_value_display()
        if callback then pcall(callback, multiSelect and selected or option) end
        apply_config_store()
    end

    local optionObjects = {}

    local function create_option(optionText, index)
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Size = UDim2.new(1, 0, 0, 34)
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
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionFrame
        SugarUI.RoundCorner(8).Parent = OptionButton

        local pad = Instance.new("UIPadding", OptionButton)
        pad.PaddingLeft = UDim.new(0, 10)

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.9
        optionStroke.Thickness = 1

        local Check
        local CheckIcon
        if multiSelect then
            Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 18, 0, 18)
            Check.Position = UDim2.new(1, -26, 0.5, -9)
            Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            Check.Parent = OptionButton
            SugarUI.RoundCorner(6).Parent = Check

            CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(1, 0, 1, 0)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = SugarUI.Theme.Highlight
            CheckIcon.Visible = table.find(selected, optionText) ~= nil
            CheckIcon.Parent = Check

            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                CheckIcon.Visible = table.find(selected, optionText) ~= nil
            end)
        else
            OptionButton.BackgroundColor3 = (selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel
            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                for _, obj in ipairs(optionObjects) do
                    SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
                end
            end)
        end

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.09)
        end)
        OptionButton.MouseLeave:Connect(function()
            local targetColor = multiSelect and SugarUI.Theme.Panel or ((selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel)
            SugarUI.Tween(OptionButton, {BackgroundColor3 = targetColor}, 0.09)
        end)

        optionObjects[#optionObjects + 1] = {frame = OptionFrame, btn = OptionButton, check = Check, checkIcon = CheckIcon, optionStroke = optionStroke}
    end

    local function rebuild_options()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageLabel") then
                child:Destroy()
            end
        end
        optionObjects = {}
        local order = 1
        if multiSelect then
            local controlFrame = Instance.new("Frame")
            controlFrame.Size = UDim2.new(1, 0, 0, 34)
            controlFrame.BackgroundTransparency = 1
            controlFrame.LayoutOrder = order
            controlFrame.Parent = OptionsFrame
            order = order + 1

            local selAllBtn = Instance.new("TextButton")
            selAllBtn.Size = UDim2.new(0.48, -6, 1, 0)
            selAllBtn.BackgroundColor3 = SugarUI.Theme.Button
            selAllBtn.Text = "Select All"
            selAllBtn.TextColor3 = SugarUI.Theme.Text
            selAllBtn.Font = Enum.Font.Gotham
            selAllBtn.TextSize = 14
            selAllBtn.AutoButtonColor = false
            selAllBtn.Parent = controlFrame
            SugarUI.RoundCorner(8).Parent = selAllBtn
            local pad1 = Instance.new("UIPadding", selAllBtn)
            pad1.PaddingLeft = UDim.new(0, 8)

            local clearBtn = Instance.new("TextButton")
            clearBtn.Size = UDim2.new(0.48, -6, 1, 0)
            clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
            clearBtn.BackgroundColor3 = SugarUI.Theme.Button
            clearBtn.Text = "Clear"
            clearBtn.TextColor3 = SugarUI.Theme.Text
            clearBtn.Font = Enum.Font.Gotham
            clearBtn.TextSize = 14
            clearBtn.AutoButtonColor = false
            clearBtn.Parent = controlFrame
            SugarUI.RoundCorner(8).Parent = clearBtn
            local pad2 = Instance.new("UIPadding", clearBtn)
            pad2.PaddingLeft = UDim.new(0, 8)

            selAllBtn.MouseButton1Click:Connect(function()
                selected = table.clone(options)
                update_value_display()
                apply_config_store()
                for _, obj in ipairs(optionObjects) do
                    if obj.check then
                        obj.check.BackgroundColor3 = SugarUI.Theme.Accent
                        local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                        if img then img.Visible = true end
                    end
                end
            end)
            clearBtn.MouseButton1Click:Connect(function()
                selected = {}
                update_value_display()
                apply_config_store()
                for _, obj in ipairs(optionObjects) do
                    if obj.check then
                        obj.check.BackgroundColor3 = SugarUI.Theme.Panel
                        local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                        if img then img.Visible = false end
                    end
                end
            end)
        end

        for i, option in ipairs(options) do
            create_option(option, order)
            order = order + 1
        end
    end

    function self:Toggle()
        isOpen = not isOpen
        if isOpen then
            Label.Visible = false
            ValueLabel.Visible = false
            local height = math.min((#options * 34 + (multiSelect and 34 or 0) + 10), 260)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 36 + height)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            OptionsFrame.ZIndex = 1000
        else
            Label.Visible = true
            ValueLabel.Visible = true
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 36)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.delay(0.22, function() OptionsFrame.ZIndex = 60 end)
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
        for _, obj in ipairs(optionObjects) do
            if obj.check then
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                if img then img.Visible = table.find(selected, obj.btn.Text) ~= nil end
            else
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
            end
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
        for _, obj in ipairs(optionObjects) do
            if obj.check then
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                if img then img.Visible = table.find(selected, obj.btn.Text) ~= nil end
            else
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
            end
        end
        apply_config_store()
    end
    self.GetValue = function() return selected end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Button
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        for _, obj in ipairs(optionObjects) do
            obj.btn.BackgroundColor3 = SugarUI.Theme.Panel
            obj.btn.TextColor3 = SugarUI.Theme.Text
            if obj.optionStroke then obj.optionStroke.Color = SugarUI.Theme.Border end
            if obj.check then
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                if obj.checkIcon then obj.checkIcon.ImageColor3 = SugarUI.Theme.Highlight end
            end
        end
    end

    return self
end

-- ======================
-- Section component
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 38)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 1, -8)
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
-- Notifications
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 340, 0, 360)
    self.Container.Position = UDim2.new(1, -360, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 1200

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 10)

    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = SugarUI.Theme.Panel
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    notification.ZIndex = 1201
    SugarUI.RoundCorner(10).Parent = notification

    SugarUI.AddShadow(notification, 0.28, 10)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 6, 1, 0)
    accent.BackgroundColor3 = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType] or SugarUI.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    accent.ZIndex = 1202

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0, 18, 0, 14)
    icon.BackgroundTransparency = 1
    icon.Image = ({ Info = "rbxassetid://6031280882", Success = "rbxassetid://6031094667", Warning = "rbxassetid://6031094687", Error = "rbxassetid://6031094688" })[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = SugarUI.Theme.Text
    icon.Parent = notification
    icon.ZIndex = 1202

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 20)
    titleLabel.Position = UDim2.new(0, 48, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    titleLabel.ZIndex = 1202

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -80, 0, 0)
    messageLabel.Position = UDim2.new(0, 48, 0, 34)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    messageLabel.ZIndex = 1202

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 22, 0, 22)
    closeButton.Position = UDim2.new(1, -36, 0, 8)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Muted
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = notification
    closeButton.ZIndex = 1202

    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(260, 1000))
        textHeight = size.Y
    end

    local totalHeight = math.clamp(56 + textHeight, 64, 150)
    messageLabel.Size = UDim2.new(1, -80, 0, textHeight)

    -- animate in: slide + fade
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.Position = UDim2.new(0, 0, 0, 0)
    notification.BackgroundTransparency = 1
    SugarUI.Tween(notification, {BackgroundTransparency = 0}, 0.18)
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    closeButton.MouseButton1Click:Connect(function() self:Remove(notification) end)
    closeButton.MouseEnter:Connect(function() SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Text}, 0.09) end)
    closeButton.MouseLeave:Connect(function() SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Muted}, 0.09) end)

    if duration > 0 then
        task.delay(duration, function() if notification.Parent then self:Remove(notification) end end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    task.delay(0.18, function() if notification.Parent then notification:Destroy() end end)
    for i, notif in ipairs(self.Notifications) do if notif == notification then table.remove(self.Notifications, i); break end end
end

-- ======================
-- Window & Tabs
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0
    local tabComponents = {}

    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 46)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -36, 1, 0)
    tabBtn.Position = UDim2.new(0, 18, 0, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 6, 1, -12)
    indicator.Position = UDim2.new(0, -10, 0, 6)
    indicator.BackgroundColor3 = SugarUI.Theme.Accent
    indicator.Visible = false
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn
    SugarUI.RoundCorner(4).Parent = indicator
    local indStroke = Instance.new("UIStroke", indicator)
    indStroke.Color = SugarUI.Theme.Accent
    indStroke.Transparency = 0.7
    indStroke.Thickness = 1

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
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 12)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

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
    pcall(function() ScreenGui.DisplayOrder = 2000 end)
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
    OuterFrame.Size = UDim2.new(0, 620, 0, 460)
    OuterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui
    OuterFrame.ZIndex = 1000

    -- UIScale (for pop-in animation)
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0.6
    uiScale.Parent = OuterFrame

    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 34, 1, 34)
    ShadowFrame.Position = UDim2.new(0, -17, 0, -17)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = SugarUI.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.78
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10, 10, 118, 118)
    ShadowFrame.Parent = OuterFrame
    ShadowFrame.ZIndex = 999

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 1  -- start hidden
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(14).Parent = Frame
    Frame.ZIndex = 1000

    SugarUI.AddShadow(Frame, 0.28, 12)

    -- top blur shimmer (decorative)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 64)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0
    TopBar.Parent = Frame
    SugarUI.RoundCorner(14).Parent = TopBar
    TopBar.ZIndex = 1001

    local topGradient = Instance.new("UIGradient", TopBar)
    topGradient.Rotation = 0
    topGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, SugarUI.Theme.Panel), ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)})
    topGradient.Transparency = NumberSequence.new(0.03, 0)

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.9
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- small left logo
    local LogoWrap = Instance.new("Frame")
    LogoWrap.Size = UDim2.new(0, 40, 0, 40)
    LogoWrap.Position = UDim2.new(0, 12, 0.5, -20)
    LogoWrap.BackgroundTransparency = 0
    LogoWrap.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = LogoWrap
    LogoWrap.BackgroundColor3 = SugarUI.Theme.Panel
    LogoWrap.ZIndex = 1002
    local logoGrad = Instance.new("UIGradient", LogoWrap)
    logoGrad.Rotation = 45
    logoGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, SugarUI.Theme.Accent), ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentSoft)})

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0.8, -24, 1, 0)
    TitleLbl.Position = UDim2.new(0, 64, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar
    TitleLbl.ZIndex = 1002

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.2, -24, 1, 0)
    Subtitle.Position = UDim2.new(0.8, 12, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "v1.1"
    Subtitle.TextColor3 = SugarUI.Theme.Muted
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Right
    Subtitle.Parent = TopBar
    Subtitle.ZIndex = 1002

    -- small shimmer bar on top
    local shimmer = Instance.new("ImageLabel")
    shimmer.Size = UDim2.new(0, 120, 0, 20)
    shimmer.Position = UDim2.new(1, -160, 0, 12)
    shimmer.BackgroundTransparency = 1
    shimmer.Image = "rbxassetid://3570695787" -- white texture
    shimmer.ImageColor3 = Color3.fromRGB(255,255,255)
    shimmer.ImageTransparency = 0.95
    shimmer.Parent = TopBar
    shimmer.ZIndex = 1003
    shimmer.Rotation = 12

    -- animate shimmer on Show
    local function playShimmer()
        shimmer.ImageTransparency = 0.95
        SugarUI.Tween(shimmer, {ImageTransparency = 0.85, Position = UDim2.new(1, -80, 0, 12)}, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        task.delay(0.5, function()
            SugarUI.Tween(shimmer, {ImageTransparency = 0.95, Position = UDim2.new(1, -160, 0, 12)}, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        end)
    end

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    MinimizeBtn.Position = UDim2.new(1, -116, 0.5, -18)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
    MinimizeBtn.Text = "—"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = MinimizeBtn
    MinimizeBtn.ZIndex = 1002

    MinimizeBtn.MouseEnter:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    MinimizeBtn.MouseLeave:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.Warning}, 0.12) end)
    MinimizeBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -56, 0.5, -18)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = SugarUI.Theme.Highlight
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = CloseBtn
    CloseBtn.ZIndex = 1002

    CloseBtn.MouseEnter:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Error}, 0.12) end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, -64)
    Sidebar.Position = UDim2.new(0, 0, 0, 64)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(0).Parent = Sidebar
    Sidebar.ZIndex = 1001

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.9

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 10)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 18)
    tabsPadding.PaddingLeft = UDim.new(0, 16)
    tabsPadding.PaddingRight = UDim.new(0, 12)
    tabsPadding.PaddingBottom = UDim.new(0, 16)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -200, 1, -64)
    PagesHolder.Position = UDim2.new(0, 200, 0, 64)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame
    PagesHolder.ZIndex = 1001

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Адаптивность
    local function getViewport()
        Camera = Camera or Workspace.CurrentCamera
        if Camera and Camera.ViewportSize then return Camera.ViewportSize end
        return Vector2.new(1280, 720)
    end

    local function updateOuterSize()
        local vp = getViewport()
        local w = math.clamp(math.floor(vp.X * 0.62), 420, 1400)
        local h = math.clamp(math.floor(vp.Y * 0.62), 300, 1000)
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

    -- Плавное перетаскивание (твин + масштаб)
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
            if activeTween then
                pcall(function() activeTween:Cancel() end)
            end
            activeTween = TweenService:Create(OuterFrame, TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos})
            activeTween:Play()
        end
    end)

    local resizeBtn = Instance.new("Frame")
    resizeBtn.Size = UDim2.new(0, 20, 0, 20)
    resizeBtn.Position = UDim2.new(1, 0, 1, 0)
    resizeBtn.AnchorPoint = Vector2.new(1, 1)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Parent = Frame
    resizeBtn.ZIndex = 1003

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
            local newWidth = math.max(420, resizeFrameSize.X.Offset + delta.X)
            local newHeight = math.max(300, resizeFrameSize.Y.Offset + delta.Y)
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

    -- Mobile toggle button
    local mobileButtons = {}

    local function createMobileButton(name, sizeX, sizeY, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, sizeX, 0, sizeY)
        btn.Position = pos or UDim2.new(1, -220, 1, -140)
        btn.AnchorPoint = Vector2.new(0, 0)
        btn.BackgroundColor3 = SugarUI.Theme.Panel
        btn.Text = name
        btn.TextColor3 = SugarUI.Theme.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.ZIndex = 1500
        btn.Parent = ScreenGui
        SugarUI.RoundCorner(12).Parent = btn
        return btn
    end

    if UserInputService.TouchEnabled then
        local toggleBtn = createMobileButton("GUI", 110, 56, UDim2.new(1, -220, 1, -140))
        mobileButtons.toggle = toggleBtn

        local function makeDraggable(btn, onTap)
            local touchInput = nil
            local startPos = nil
            local startBtnPos = nil
            local moved = false
            local threshold = 10

            local function onInputChanged(input)
                if not touchInput or input ~= touchInput then return end
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

            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchInput = input
                    startPos = input.Position
                    startBtnPos = btn.Position
                    moved = false
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            if not moved then
                                if onTap then pcall(onTap) end
                            end
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
                    onInputChanged(input)
                end
            end)
        end

        makeDraggable(mobileButtons.toggle, function()
            if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
        end)
    end

    -- Show / Hide with nicer animation
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        -- Cancel any active tween
        if activeTween then pcall(function() activeTween:Cancel() end) end
        -- Pop-in with elastic easing and subtle fade-in
        uiScale.Scale = 0.6
        Frame.BackgroundTransparency = 1
        ShadowFrame.ImageTransparency = 0.78
        OuterFrame.Position = UDim2.new(0.5, 0, 0.46, 0) -- slight rise before pop
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.44, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        SugarUI.Tween(uiScale, {Scale = 1}, 0.42, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        SugarUI.Tween(Frame, {BackgroundTransparency = 0.02}, 0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 0.6}, 0.32)
        -- small shimmer and theme update
        task.delay(0.06, function() pcall(function() selfObj:UpdateTheme() end) end)
        task.delay(0.1, function() pcall(playShimmer) end)
    end

    function selfObj:Hide()
        selfObj.Visible = false
        -- Scale down and slide out
        if activeTween then pcall(function() activeTween:Cancel() end) end
        SugarUI.Tween(uiScale, {Scale = 0.75}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5, 0, 1.6, 0)}, 0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 0.9}, 0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        for _, child in ipairs(Notifications.Container:GetChildren()) do
            if child:IsA("Frame") then
                pcall(function() SugarUI.Tween(child, {Size = UDim2.new(1,0,0,0)}, 0.18) end)
            end
        end
        task.delay(0.34, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
            Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 3, "Info")
        end)
    end

    task.defer(function() wait(0.06); selfObj:Show() end)

    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function() ScreenGui:Destroy() end, function() end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.5
        overlay.Parent = ScreenGui
        overlay.ZIndex = 2000

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 420, 0, 190)
        panel.Position = UDim2.new(0.5, -210, 0.5, -95)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        SugarUI.RoundCorner(12).Parent = panel
        panel.Parent = overlay
        panel.ZIndex = 2001

        SugarUI.AddShadow(panel, 0.42, 14)
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.8

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,-24,0,36)
        titleLbl.Position = UDim2.new(0,12,0,10)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = panel
        titleLbl.ZIndex = 2002

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -24, 0, 80)
        msgLbl.Position = UDim2.new(0,12,0,46)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        msgLbl.Parent = panel
        msgLbl.ZIndex = 2002

        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.38, 0, 0, 36)
        yesBtn.Instance.Position = UDim2.new(0.12, 0, 1, -56)
        yesBtn.Instance.ZIndex = 2002

        local noBtn = ButtonComponent.new(panel, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.38, 0, 0, 36)
        noBtn.Instance.Position = UDim2.new(0.5, 0, 1, -56)
        noBtn.Instance.ZIndex = 2002
    end

    -- Expose on object
    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications
    selfObj.GlobalContainer = PagesHolder
    selfObj._uiScale = uiScale

    function selfObj:AddTab(name) local tab = createTab(selfObj, name); return tab end
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

    function selfObj:Notify(title, message, duration, type)
        return Notifications:Notify(title, message, duration, type)
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
        task.defer(function()
            pcall(function() selfObj:Notify("Info", "Configuration applied.", 3, "Info") end)
        end)
    end

    function selfObj:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Background
        TopBar.BackgroundColor3 = SugarUI.Theme.Panel
        topStroke.Color = SugarUI.Theme.Border
        TitleLbl.TextColor3 = SugarUI.Theme.Text
        Subtitle.TextColor3 = SugarUI.Theme.Muted
        MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
        MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
        CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
        CloseBtn.TextColor3 = SugarUI.Theme.Highlight
        Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
        sideStroke.Color = SugarUI.Theme.Border
        for _, tab in ipairs(selfObj.Tabs) do
            tab.button.TextColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Text or SugarUI.Theme.Muted
            tab.indicator.BackgroundColor3 = SugarUI.Theme.Accent
            local uiStroke = tab.indicator:FindFirstChildOfClass("UIStroke")
if uiStroke then uiStroke.Color = SugarUI.Theme.Accent end

            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Border
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then
                    comp.obj:UpdateTheme()
                end
            end
        end
        -- Update shadows and gradients
        for _, shadow in ipairs(ScreenGui:GetDescendants()) do
            if shadow.Name == "Shadow" and shadow:IsA("ImageLabel") then
                shadow.ImageColor3 = SugarUI.Theme.Shadow
            end
            if shadow:IsA("Frame") and shadow.Name == "GlassOverlay" then
                shadow.BackgroundColor3 = SugarUI.Theme.Background
            end
        end
    end

    -- keep global reference
    SugarUI.CurrentWindow = selfObj
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}

    return selfObj
end

function SugarUI:CreateWindow(title)
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    local window = Window.new(title)
    if SugarUI.CurrentConfig["Theme"] then
        pcall(function() SugarUI.ApplyPreset(SugarUI.CurrentConfig["Theme"]) end)
    end
    return window
end

-- expose ApplyPreset and Presets for external use
SugarUI.ApplyTheme = SugarUI.ApplyPreset
SugarUI.GetAvailableThemes = function()
    local keys = {}
    for k,_ in pairs(SugarUI.Presets) do table.insert(keys,k) end
    return keys
end

return SugarUI

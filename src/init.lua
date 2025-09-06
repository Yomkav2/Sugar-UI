-- init.lua (Sugar UI - Полностью переработанный с расширенными функциями)
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

local Camera = Workspace.CurrentCamera

-- ======================
-- Preset Themes (обновленные для минимализма: flat, clean, subtle gradients)
-- ======================
SugarUI.Presets = {
    Pinky = {
        Background = Color3.fromRGB(255, 255, 255),
        Panel = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(255, 105, 180),
        AccentSoft = Color3.fromRGB(255, 182, 193),
        AccentDark = Color3.fromRGB(219, 112, 147),
        Text = Color3.fromRGB(50, 50, 50),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(220, 220, 220),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 83),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 82, 82),
        Toggle = Color3.fromRGB(245, 245, 245),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(240, 240, 240),
    },
    Amethyst = {
        Background = Color3.fromRGB(255, 255, 255),
        Panel = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(156, 39, 176),
        AccentSoft = Color3.fromRGB(186, 104, 200),
        AccentDark = Color3.fromRGB(142, 36, 170),
        Text = Color3.fromRGB(50, 50, 50),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(220, 220, 220),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 83),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 82, 82),
        Toggle = Color3.fromRGB(245, 245, 245),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(240, 240, 240),
    },
    Dark = {
        Background = Color3.fromRGB(18, 18, 18),
        Panel = Color3.fromRGB(28, 28, 28),
        Accent = Color3.fromRGB(3, 155, 229),
        AccentSoft = Color3.fromRGB(2, 119, 189),
        AccentDark = Color3.fromRGB(1, 87, 155),
        Text = Color3.fromRGB(240, 240, 240),
        Muted = Color3.fromRGB(170, 170, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(40, 40, 40),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 83),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 82, 82),
        Toggle = Color3.fromRGB(28, 28, 28),
        ToggleBox = Color3.fromRGB(60, 60, 60),
        Button = Color3.fromRGB(28, 28, 28),
        ButtonHover = Color3.fromRGB(38, 38, 38),
    },
    White = {
        Background = Color3.fromRGB(255, 255, 255),
        Panel = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(33, 150, 243),
        AccentSoft = Color3.fromRGB(66, 165, 245),
        AccentDark = Color3.fromRGB(25, 118, 210),
        Text = Color3.fromRGB(50, 50, 50),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(220, 220, 220),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 83),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 82, 82),
        Toggle = Color3.fromRGB(245, 245, 245),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(240, 240, 240),
    }
}

-- default theme (start with White for minimalism)
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.White) do SugarUI.Theme[k] = v end

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
-- Вспомогательные (улучшены для минимализма: меньше углов, тонкие линии)
-- ======================
function SugarUI.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 4)  -- Уменьшены углы для минимализма
    return corner
end

function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quint  -- Более плавный easing для красоты
    dir = dir or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, dir)  -- Увеличена длительность для smooth
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function SugarUI.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)  -- Большие, но мягкие тени
    shadow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.9  -- Мягче тени
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Button component (минималистичный: flat, без градиентов, subtle hover)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)  -- Выше для минимализма
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.SourceSans  -- Минималистичный шрифт
    Btn.TextSize = 16
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(4).Parent = Btn  -- Меньше скругления

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.95  -- Тонкая граница
    stroke.Thickness = 1

    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.2)
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.2)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            -- Subtle ripple
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = SugarUI.Theme.Highlight
            ripple.AnchorPoint = Vector2.new(0.5,0.5)
            ripple.ZIndex = 10
            SugarUI.RoundCorner(999).Parent = ripple  -- Круглый ripple
            ripple.Parent = Btn
            SugarUI.Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)
            task.delay(0.5, function() ripple:Destroy() end)
            pcall(callback)
        end
    end)

    self.Instance = Btn

    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
    end

    return self
end

-- ======================
-- Toggle component (минималистичный: pill shape, smooth transition)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1  -- Без фона для минимализма
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 40, 0, 20)
    Box.Position = UDim2.new(1, -40, 0.5, -10)
    Box.BackgroundColor3 = SugarUI.Theme.Toggle
    Box.Parent = Frame
    SugarUI.RoundCorner(10).Parent = Box  -- Pill shape

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 1, 0)
    Knob.Position = UDim2.new(self.State and 0.5 or 0, 0, 0, 0)
    Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    Knob.Parent = Box
    SugarUI.RoundCorner(10).Parent = Knob

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(Knob, {Position = UDim2.new(self.State and 0.5 or 0, 0, 0, 0), BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.3, Enum.EasingStyle.Quint)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        SugarUI.Tween(Knob, {Position = UDim2.new(self.State and 0.5 or 0, 0, 0, 0), BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.3)
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    function self:UpdateTheme()
        Label.TextColor3 = SugarUI.Theme.Text
        Box.BackgroundColor3 = SugarUI.Theme.Toggle
        Knob.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    end

    return self
end

-- ======================
-- Slider component (минималистичный: thin track, circle knob)
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or (min or 0)
    min = min or 0
    max = max or 100

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 4)
    Track.Position = UDim2.new(0, 0, 1, -12)
    Track.BackgroundColor3 = SugarUI.Theme.Border
    Track.Parent = Frame
    SugarUI.RoundCorner(2).Parent = Track

    local Fill = Instance.new("Frame")
    local initialFill = (value - min) / (max - min)
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.Parent = Track
    SugarUI.RoundCorner(2).Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(initialFill, -8, 0.5, -8)
    Knob.BackgroundColor3 = SugarUI.Theme.Accent
    Knob.Parent = Frame
    SugarUI.RoundCorner(8).Parent = Knob  -- Круглый knob

    local dragging = false
    local function set_value(newValue, fire)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = (value - min) / (max - min)
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.2)
        SugarUI.Tween(Knob, {Position = UDim2.new(fillSize, -8, 0.5, -8)}, 0.2)
        if fire and callback then pcall(callback, value) end
        if configKey then SugarUI.CurrentConfig[configKey] = value end
    end

    local function update_from_mouse(input)
        local positionX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
        local newValue = min + (positionX / Track.AbsoluteSize.X) * (max - min)
        set_value(newValue, true)
    end

    Frame.InputBegan:Connect(function(input)
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
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        Track.BackgroundColor3 = SugarUI.Theme.Border
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
        Knob.BackgroundColor3 = SugarUI.Theme.Accent
    end

    return self
end

-- ======================
-- Dropdown component (минималистичный: clean list, no borders)
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
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = false
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundTransparency = 0
    OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 2  -- Тонкий скролл
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.ScrollBarImageTransparency = 0.8

    local optionsList = Instance.new("UIListLayout", OptionsFrame)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Padding = UDim.new(0, 2)

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
            self:Toggle()
        end
        update_value_display()
        if callback then pcall(callback, multiSelect and selected or option) end
        apply_config_store()
    end

    local optionObjects = {}

    local function create_option(optionText)
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 36)
        OptionButton.BackgroundTransparency = 1
        OptionButton.Text = tostring(optionText)
        OptionButton.TextColor3 = SugarUI.Theme.Text
        OptionButton.Font = Enum.Font.SourceSans
        OptionButton.TextSize = 16
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionsFrame

        OptionButton.MouseButton1Click:Connect(function()
            toggle_option(optionText)
        end)

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundTransparency = 0.95}, 0.2)
        end)
        OptionButton.MouseLeave:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundTransparency = 1}, 0.2)
        end)

        table.insert(optionObjects, OptionButton)
    end

    local function rebuild_options()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        optionObjects = {}
        for _, option in ipairs(options) do
            create_option(option)
        end
    end

    function self:Toggle()
        isOpen = not isOpen
        local height = math.min(#options * 36, 180)
        SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, isOpen and height or 0)}, 0.3, Enum.EasingStyle.Quint)
        Frame.Size = UDim2.new(1, 0, 0, isOpen and 40 + height or 40)
    end

    rebuild_options()
    update_value_display()

    HeaderBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    self.Instance = Frame
    self.UpdateOptions = function(newOptions)
        options = newOptions or {}
        rebuild_options()
        update_value_display()
    end
    self.SetValue = function(value)
        selected = value
        update_value_display()
    end
    self.GetValue = function() return selected end

    function self:UpdateTheme()
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Muted
        OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        for _, obj in ipairs(optionObjects) do
            obj.TextColor3 = SugarUI.Theme.Text
        end
    end

    return self
end

-- ======================
-- Section component (минималистичный: только текст, no line)
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Muted
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    self.Instance = label

    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Muted
    end

    return self
end

-- ======================
-- Notifications (минималистичные: card style, fade in right)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 300, 1, 0)
    self.Container.Position = UDim2.new(1, 20, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom  -- Снизу вверх для стека
    list.Padding = UDim.new(0, 8)

    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 80)
    notification.Position = UDim2.new(1, 0, 1, 0)  -- Start offscreen right
    notification.BackgroundColor3 = SugarUI.Theme.Panel
    notification.BorderSizePixel = 0
    notification.Parent = self.Container
    SugarUI.RoundCorner(8).Parent = notification

    SugarUI.AddShadow(notification, 0.95, 10)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification

    SugarUI.Tween(notification, {Position = UDim2.new(1, -320, 1, 0)}, 0.4, Enum.EasingStyle.Quint)  -- Slide in from right

    task.delay(duration, function() self:Remove(notification) end)

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {Position = UDim2.new(1, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quint)
    task.delay(0.4, function() notification:Destroy() end)
end

-- ======================
-- Window & Tabs (минималистичный: no sidebar, tabs at bottom or top, clean)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local tab = {
        name = name,
        page = Instance.new("Frame")
    }
    tab.page.Size = UDim2.new(1, 0, 1, -40)
    tab.page.Position = UDim2.new(0, 0, 0, 40)
    tab.page.BackgroundTransparency = 1
    tab.page.Parent = selfObj.Frame
    tab.page.Visible = false

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 2
    scrollingFrame.Parent = tab.page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 8)

    tab.AddSection = function(_, ttl)
        return SectionComponent.new(scrollingFrame, ttl)
    end
    tab.AddButton = function(_, txt, cb)
        return ButtonComponent.new(scrollingFrame, txt, cb)
    end
    tab.AddToggle = function(_, txt, def, cb, key)
        return ToggleComponent.new(scrollingFrame, txt, def, cb, key)
    end
    tab.AddSlider = function(_, txt, min, max, def, cb, key)
        return SliderComponent.new(scrollingFrame, txt, min, max, def, cb, key)
    end
    tab.AddDropdown = function(_, txt, opts, def, cb, multi, key)
        return DropdownComponent.new(scrollingFrame, txt, opts, def, cb, multi, key)
    end

    table.insert(selfObj.Tabs, tab)
    if #selfObj.Tabs == 1 then tab.page.Visible = true end

    return tab
end

function Window.new(title)
    local selfObj = setmetatable({}, Window)
    selfObj.Tabs = {}
    selfObj.Visible = true

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.Parent = ScreenGui
    SugarUI.RoundCorner(8).Parent = Frame

    SugarUI.AddShadow(Frame, 0.9, 20)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, 0, 0, 40)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.SourceSansBold
    TitleLbl.TextSize = 18
    TitleLbl.Parent = Frame

    selfObj.Frame = Frame

    function selfObj:AddTab(name)
        return createTab(selfObj, name)
    end

    function selfObj:Show()
        Frame.Visible = true
        SugarUI.Tween(Frame, {Size = UDim2.new(0, 400, 0, 300)}, 0.5, Enum.EasingStyle.Quint)  -- Scale up from center
        SugarUI.Tween(Frame, {BackgroundTransparency = 0}, 0.5)
    end

    selfObj:Show()

    return selfObj
end

function SugarUI:CreateWindow(title)
    return Window.new(title)
end

return SugarUI

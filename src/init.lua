-- init.lua (Sugar UI - Полностью переработанный с расширенными функциями и современным дизайном)
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
-- Preset Themes (обновленные с современными цветами)
-- ======================
SugarUI.Presets = {
    Pinky = {
        Background = Color3.fromRGB(15, 8, 25),
        Panel = Color3.fromRGB(25, 15, 35),
        Accent = Color3.fromRGB(255, 105, 180),
        AccentSoft = Color3.fromRGB(255, 140, 200),
        AccentDark = Color3.fromRGB(180, 50, 100),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(180, 160, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(60, 40, 55),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(35, 20, 40),
        ToggleBox = Color3.fromRGB(240,240,240),
        Button = Color3.fromRGB(35, 20, 40),
        ButtonHover = Color3.fromRGB(55, 30, 50),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Amethyst = {
        Background = Color3.fromRGB(12, 8, 25),
        Panel = Color3.fromRGB(20, 15, 35),
        Accent = Color3.fromRGB(153, 102, 255),
        AccentSoft = Color3.fromRGB(180, 140, 255),
        AccentDark = Color3.fromRGB(100, 60, 180),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(160, 150, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(60, 50, 80),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(30, 25, 45),
        ToggleBox = Color3.fromRGB(220,220,220),
        Button = Color3.fromRGB(30, 25, 45),
        ButtonHover = Color3.fromRGB(50, 40, 70),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Dark = {
        Background = Color3.fromRGB(8, 10, 15),
        Panel = Color3.fromRGB(18, 20, 25),
        Accent = Color3.fromRGB(100, 181, 246),
        AccentSoft = Color3.fromRGB(66, 153, 233),
        AccentDark = Color3.fromRGB(2, 119, 189),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(40, 45, 55),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(25, 28, 35),
        ToggleBox = Color3.fromRGB(220, 220, 220),
        Button = Color3.fromRGB(25, 28, 35),
        ButtonHover = Color3.fromRGB(40, 45, 55),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    White = {
        Background = Color3.fromRGB(250, 252, 255),
        Panel = Color3.fromRGB(240, 245, 250),
        Accent = Color3.fromRGB(40, 120, 200),
        AccentSoft = Color3.fromRGB(80, 140, 220),
        AccentDark = Color3.fromRGB(10, 70, 140),
        Text = Color3.fromRGB(20, 25, 35),
        Muted = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(200, 210, 220),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(250, 252, 255),
        ToggleBox = Color3.fromRGB(60, 70, 80),
        Button = Color3.fromRGB(250, 252, 255),
        ButtonHover = Color3.fromRGB(235, 240, 245),
        Glass = Color3.fromRGB(255, 255, 255),
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
-- Вспомогательные функции (улучшенные)
-- ======================
function SugarUI.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    return corner
end

function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.25, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function SugarUI.AddShadow(frame, transparency, size, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, (size or 12) * 2, 1, (size or 12) * 2)
    shadow.Position = UDim2.new(0, -(size or 12) + (offset or 0), 0, -(size or 12) + (offset or 2))
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.75
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = (frame.ZIndex or 1) - 1
    shadow.Parent = frame
    return shadow
end

function SugarUI.AddGradient(frame, colors, rotation, transparency)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    if colors then
        gradient.Color = colors
    else
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SugarUI.Theme.Panel), 
            ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)
        })
    end
    if transparency then
        gradient.Transparency = transparency
    else
        gradient.Transparency = NumberSequence.new(0.1, 0.05)
    end
    gradient.Parent = frame
    return gradient
end

function SugarUI.AddGlassEffect(frame)
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = SugarUI.Theme.Glass
    blur.BackgroundTransparency = 0.92
    blur.BorderSizePixel = 0
    blur.Parent = frame
    SugarUI.RoundCorner(8).Parent = blur
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = SugarUI.Theme.Glass
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    stroke.Parent = blur
    
    return blur
end

-- ======================
-- Button component (значительно улучшенный)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0.1
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn

    -- Добавляем стеклянный эффект
    SugarUI.AddGlassEffect(Btn)
    
    -- Градиент для кнопки
    SugarUI.AddGradient(Btn, nil, 45, NumberSequence.new(0.2, 0.05))
    
    -- Тень
    SugarUI.AddShadow(Btn, 0.6, 8, 2)

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1.5

    -- Анимированные эффекты при наведении
    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {
            BackgroundColor3 = SugarUI.Theme.ButtonHover,
            BackgroundTransparency = 0.05
        }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        SugarUI.Tween(stroke, {Transparency = 0.6}, 0.15)
    end)
    
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {
            BackgroundColor3 = SugarUI.Theme.Button,
            BackgroundTransparency = 0.1
        }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        SugarUI.Tween(stroke, {Transparency = 0.8}, 0.15)
    end)

    Btn.MouseButton1Click:Connect(function()
        -- Улучшенный эффект нажатия
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 4, 0, 4)
        ripple.Position = UDim2.new(0.5, -2, 0.5, -2)
        ripple.BackgroundColor3 = SugarUI.Theme.Highlight
        ripple.BackgroundTransparency = 0.3
        ripple.BorderSizePixel = 0
        ripple.ZIndex = Btn.ZIndex + 10
        ripple.Parent = Btn
        SugarUI.RoundCorner(50).Parent = ripple
        
        -- Анимация волны
        SugarUI.Tween(ripple, {
            Size = UDim2.new(3, 0, 3, 0),
            Position = UDim2.new(-1, 0, -1, 0),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Эффект "нажатия"
        SugarUI.Tween(Btn, {Size = UDim2.new(1, -12, 0, 36)}, 0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        task.wait(0.08)
        SugarUI.Tween(Btn, {Size = UDim2.new(1, -10, 0, 38)}, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        task.delay(0.4, function() if ripple and ripple.Parent then ripple:Destroy() end end)
        if callback then pcall(callback) end
    end)

    self.Instance = Btn

    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
        
        -- Обновляем градиенты
        for _, child in ipairs(Btn:GetChildren()) do
            if child:IsA("UIGradient") then
                child.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, SugarUI.Theme.Button), 
                    ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)
                })
            elseif child.Name == "Shadow" then
                child.ImageColor3 = SugarUI.Theme.Shadow
            end
        end
    end

    return self
end

-- ======================
-- Toggle component (улучшенный дизайн)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = SugarUI.Theme.Panel
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    -- Стеклянный эффект
    SugarUI.AddGlassEffect(Frame)
    SugarUI.AddGradient(Frame)
    SugarUI.AddShadow(Frame, 0.7, 6, 1)

    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = Frame.ZIndex + 2
    Label.Parent = Frame

    -- Современный toggle switch
    local ToggleTrack = Instance.new("Frame")
    ToggleTrack.Size = UDim2.new(0, 50, 0, 24)
    ToggleTrack.Position = UDim2.new(1, -65, 0.5, -12)
    ToggleTrack.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    ToggleTrack.Parent = Frame
    SugarUI.RoundCorner(12).Parent = ToggleTrack

    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
    ToggleKnob.Position = self.State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    ToggleKnob.BackgroundColor3 = SugarUI.Theme.Highlight
    ToggleKnob.Parent = ToggleTrack
    SugarUI.RoundCorner(10).Parent = ToggleKnob
    
    SugarUI.AddShadow(ToggleKnob, 0.5, 4, 1)

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            
            -- Анимированный переход
            SugarUI.Tween(ToggleTrack, {
                BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
            }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            SugarUI.Tween(ToggleKnob, {
                Position = self.State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        SugarUI.Tween(ToggleTrack, {
            BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        }, 0.2)
        SugarUI.Tween(ToggleKnob, {
            Position = self.State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ToggleTrack.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        ToggleKnob.BackgroundColor3 = SugarUI.Theme.Highlight
    end

    return self
end

-- ======================
-- Slider component (современный дизайн)
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
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    SugarUI.AddGlassEffect(Frame)
    SugarUI.AddGradient(Frame)
    SugarUI.AddShadow(Frame, 0.7, 6, 1)

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 0, 22)
    Label.Position = UDim2.new(0, 15, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = Frame.ZIndex + 2
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.35, -15, 0, 22)
    ValueLabel.Position = UDim2.new(0.65, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Accent
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = Frame.ZIndex + 2
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -30, 0, 6)
    Track.Position = UDim2.new(0, 15, 0, 34)
    Track.BackgroundColor3 = SugarUI.Theme.ToggleBox
    Track.BackgroundTransparency = 0.3
    Track.BorderSizePixel = 0
    Track.ZIndex = Frame.ZIndex + 1
    Track.Parent = Frame
    SugarUI.RoundCorner(3).Parent = Track

    local Fill = Instance.new("Frame")
    local initialFill = 0
    if max - min ~= 0 then initialFill = (value - min) / (max - min) end
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.ZIndex = Track.ZIndex + 1
    Fill.Parent = Track
    SugarUI.RoundCorner(3).Parent = Fill
    
    -- Добавляем градиент к заполнению
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Accent),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentSoft)
    })
    fillGradient.Parent = Fill

    -- Ползунок
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(initialFill, -8, 0.5, -8)
    Knob.BackgroundColor3 = SugarUI.Theme.Highlight
    Knob.ZIndex = Fill.ZIndex + 1
    Knob.Parent = Track
    SugarUI.RoundCorner(8).Parent = Knob
    SugarUI.AddShadow(Knob, 0.4, 4, 1)

    local dragging = false
    local function set_value(newValue, fire)
        newValue = tonumber(newValue) or newValue
        if type(newValue) ~= "number" then return end
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = 0
        if max - min ~= 0 then fillSize = (value - min) / (max - min) end
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.15, Enum.EasingStyle.Quart)
        SugarUI.Tween(Knob, {Position = UDim2.new(fillSize, -8, 0.5, -8)}, 0.15, Enum.EasingStyle.Quart)
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
            SugarUI.Tween(Knob, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)}, 0.1, Enum.EasingStyle.Back)
            update_from_mouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then 
            dragging = false
            SugarUI.Tween(Knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)}, 0.15, Enum.EasingStyle.Back)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
            update_from_mouse(input) 
        end
    end)

    self.Instance = Frame
    self.SetValue = set_value
    self.GetValue = function() return value end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        ValueLabel.TextColor3 = SugarUI.Theme.Accent
        Track.BackgroundColor3 = SugarUI.Theme.ToggleBox
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
        Knob.BackgroundColor3 = SugarUI.Theme.Highlight
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SugarUI.Theme.Accent),
            ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentSoft)
        })
    end

    return self
end

-- ======================
-- Dropdown component (обновленный)
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
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = SugarUI.Theme.Button
    Frame.BackgroundTransparency = 0.1
    Frame.ClipsDescendants = false
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame

    SugarUI.AddGlassEffect(Frame)
    SugarUI.AddGradient(Frame)
    SugarUI.AddShadow(Frame, 0.7, 6, 1)

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = Frame.ZIndex + 2
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.35, -25, 1, 0)
    ValueLabel.Position = UDim2.new(0.65, -5, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.ZIndex = Frame.ZIndex + 2
    ValueLabel.Parent = Frame

    -- Стрелка
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 12, 0, 12)
    Arrow.Position = UDim2.new(1, -25, 0.5, -6)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6031094678"
    Arrow.ImageColor3 = SugarUI.Theme.Muted
    Arrow.ZIndex = Frame.ZIndex + 2
    Arrow.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 0, 38)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.ZIndex = Frame.ZIndex + 3
    HeaderBtn.Parent = Frame

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 38)
    OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
    OptionsFrame.BackgroundTransparency = 0.05
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.ScrollBarImageTransparency = 0.5
    OptionsFrame.ZIndex = Frame.ZIndex + 10
    SugarUI.RoundCorner(10).Parent = OptionsFrame
    SugarUI.AddShadow(OptionsFrame, 0.6, 8, 2)

    local optionsStroke = Instance.new("UIStroke", OptionsFrame)
    optionsStroke.Color = SugarUI.Theme.Border
    optionsStroke.Transparency = 0.7
    optionsStroke.Thickness = 1

    local optionsList = Instance.new("UIListLayout", OptionsFrame)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Padding = UDim.new(0, 2)

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
        OptionFrame.Size = UDim2.new(1, 0, 0, 32)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.LayoutOrder = index
        OptionFrame.Parent = OptionsFrame

        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.BackgroundColor3 = SugarUI.Theme.Panel
        OptionButton.BackgroundTransparency = 0.1
        OptionButton.Text = tostring(optionText)
        OptionButton.TextColor3 = SugarUI.Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 13
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = OptionsFrame.ZIndex + 1
        OptionButton.Parent = OptionFrame
        SugarUI.RoundCorner(6).Parent = OptionButton

        local pad = Instance.new("UIPadding", OptionButton)
        pad.PaddingLeft = UDim.new(0, 10)

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.9
        optionStroke.Thickness = 1

        local Check, CheckIcon
        if multiSelect then
            Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 18, 0, 18)
            Check.Position = UDim2.new(1, -26, 0.5, -9)
            Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            Check.ZIndex = OptionButton.ZIndex + 1
            Check.Parent = OptionButton
            SugarUI.RoundCorner(4).Parent = Check

            CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(1, 0, 1, 0)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = SugarUI.Theme.Highlight
            CheckIcon.Visible = table.find(selected, optionText) ~= nil
            CheckIcon.ZIndex = Check.ZIndex + 1
            CheckIcon.Parent = Check

            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                SugarUI.Tween(Check, {BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Panel}, 0.15)
                CheckIcon.Visible = table.find(selected, optionText) ~= nil
            end)
        else
            OptionButton.BackgroundColor3 = (selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel
            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                for _, obj in ipairs(optionObjects) do
                    SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.15)
                end
            end)
        end

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundColor3 = SugarUI.Theme.ButtonHover, BackgroundTransparency = 0.05}, 0.1)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            local targetColor = multiSelect and SugarUI.Theme.Panel or ((selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel)
            SugarUI.Tween(OptionButton, {BackgroundColor3 = targetColor, BackgroundTransparency = 0.1}, 0.1)
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
            controlFrame.Size = UDim2.new(1, 0, 0, 36)
            controlFrame.BackgroundTransparency = 1
            controlFrame.LayoutOrder = order
            controlFrame.Parent = OptionsFrame
            order = order + 1

            local selAllBtn = Instance.new("TextButton")
            selAllBtn.Size = UDim2.new(0.48, -2, 1, 0)
            selAllBtn.BackgroundColor3 = SugarUI.Theme.Button
            selAllBtn.BackgroundTransparency = 0.1
            selAllBtn.Text = "Select All"
            selAllBtn.TextColor3 = SugarUI.Theme.Text
            selAllBtn.Font = Enum.Font.Gotham
            selAllBtn.TextSize = 13
            selAllBtn.AutoButtonColor = false
            selAllBtn.ZIndex = OptionsFrame.ZIndex + 1
            selAllBtn.Parent = controlFrame
            SugarUI.RoundCorner(6).Parent = selAllBtn

            local clearBtn = Instance.new("TextButton")
            clearBtn.Size = UDim2.new(0.48, -2, 1, 0)
            clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
            clearBtn.BackgroundColor3 = SugarUI.Theme.Button
            clearBtn.BackgroundTransparency = 0.1
            clearBtn.Text = "Clear"
            clearBtn.TextColor3 = SugarUI.Theme.Text
            clearBtn.Font = Enum.Font.Gotham
            clearBtn.TextSize = 13
            clearBtn.AutoButtonColor = false
            clearBtn.ZIndex = OptionsFrame.ZIndex + 1
            clearBtn.Parent = controlFrame
            SugarUI.RoundCorner(6).Parent = clearBtn

            selAllBtn.MouseButton1Click:Connect(function()
                selected = table.clone(options)
                update_value_display()
                apply_config_store()
                for _, obj in ipairs(optionObjects) do
                    if obj.check then
                        SugarUI.Tween(obj.check, {BackgroundColor3 = SugarUI.Theme.Accent}, 0.15)
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
                        SugarUI.Tween(obj.check, {BackgroundColor3 = SugarUI.Theme.Panel}, 0.15)
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
            local height = math.min((#options * 32 + (multiSelect and 36 or 0) + 12), 240)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 38 + height)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            SugarUI.Tween(Arrow, {Rotation = 180}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            OptionsFrame.ZIndex = 1000
        else
            Label.Visible = true
            ValueLabel.Visible = true
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 38)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            SugarUI.Tween(Arrow, {Rotation = 0}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            task.delay(0.22, function() OptionsFrame.ZIndex = Frame.ZIndex + 10 end)
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
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.15)
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
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.15)
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
        Arrow.ImageColor3 = SugarUI.Theme.Muted
        OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        optionsStroke.Color = SugarUI.Theme.Border
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
-- Section component (улучшенный)
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
    label.Size = UDim2.new(1, -20, 0, 24)
    label.Position = UDim2.new(0, 15, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -30, 0, 2)
    line.Position = UDim2.new(0, 15, 1, -8)
    line.BackgroundColor3 = SugarUI.Theme.Accent
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = wrapper
    SugarUI.RoundCorner(1).Parent = line

    -- Добавляем градиент к линии
    local lineGradient = Instance.new("UIGradient")
    lineGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Accent),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentSoft)
    })
    lineGradient.Parent = line

    self._wrapper = wrapper

    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Accent
        line.BackgroundColor3 = SugarUI.Theme.Accent
        lineGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SugarUI.Theme.Accent),
            ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentSoft)
        })
    end

    return self
end

-- ======================
-- Notifications (улучшенные)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 340, 0, 400)
    self.Container.Position = UDim2.new(1, -360, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 900

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 12)

    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = SugarUI.Theme.Panel
    notification.BackgroundTransparency = 0.05
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    SugarUI.RoundCorner(12).Parent = notification
    notification.ZIndex = 901

    -- Стеклянный эффект для уведомления
    SugarUI.AddGlassEffect(notification)
    SugarUI.AddShadow(notification, 0.4, 12, 3)

    local stroke = Instance.new("UIStroke")
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = notification

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 6, 1, 0)
    accent.BackgroundColor3 = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType] or SugarUI.Theme.Accent
    accent.BorderSizePixel = 0
    accent.ZIndex = 902
    accent.Parent = notification
    SugarUI.RoundCorner(3).Parent = accent

    -- Градиент для акцента
    local accentGradient = Instance.new("UIGradient")
    local accentColor = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType] or SugarUI.Theme.Accent
    accentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(255, accentColor.R * 255 + 30),
            math.min(255, accentColor.G * 255 + 30),
            math.min(255, accentColor.B * 255 + 30)
        ))
    })
    accentGradient.Rotation = 90
    accentGradient.Parent = accent

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 18, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Image = ({ Info = "rbxassetid://6031280882", Success = "rbxassetid://6031094667", Warning = "rbxassetid://6031094687", Error = "rbxassetid://6031094688" })[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = SugarUI.Theme.Text
    icon.ZIndex = 902
    icon.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 22)
    titleLabel.Position = UDim2.new(0, 50, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 902
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -70, 0, 0)
    messageLabel.Position = UDim2.new(0, 50, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 902
    messageLabel.Parent = notification

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -38, 0, 10)
    closeButton.BackgroundColor3 = SugarUI.Theme.Error
    closeButton.BackgroundTransparency = 0.8
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Text
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.ZIndex = 902
    closeButton.Parent = notification
    SugarUI.RoundCorner(14).Parent = closeButton

    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(260, 1000))
        textHeight = size.Y
    end

    local totalHeight = math.clamp(60 + textHeight, 70, 160)
    messageLabel.Size = UDim2.new(1, -70, 0, textHeight)

    -- Анимация появления с улучшенным эффектом
    notification.Position = UDim2.new(1, 50, 0, 0)
    notification.Size = UDim2.new(1, 0, 0, totalHeight)
    notification.BackgroundTransparency = 1
    
    SugarUI.Tween(notification, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.05
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    closeButton.MouseButton1Click:Connect(function() self:Remove(notification) end)
    closeButton.MouseEnter:Connect(function() 
        SugarUI.Tween(closeButton, {BackgroundTransparency = 0.6, Size = UDim2.new(0, 30, 0, 30)}, 0.1, Enum.EasingStyle.Back) 
    end)
    closeButton.MouseLeave:Connect(function() 
        SugarUI.Tween(closeButton, {BackgroundTransparency = 0.8, Size = UDim2.new(0, 28, 0, 28)}, 0.1, Enum.EasingStyle.Back) 
    end)

    if duration > 0 then
        task.delay(duration, function() if notification.Parent then self:Remove(notification) end end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {
        Position = UDim2.new(1, 50, 0, 0),
        BackgroundTransparency = 1
    }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.25, function() if notification.Parent then notification:Destroy() end end)
    for i, notif in ipairs(self.Notifications) do if notif == notification then table.remove(self.Notifications, i); break end end
end

-- ======================
-- Window & Tabs (значительно улучшенные)
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
    tabBtn.Size = UDim2.new(1, -20, 1, -8)
    tabBtn.Position = UDim2.new(0, 10, 0, 4)
    tabBtn.BackgroundColor3 = SugarUI.Theme.Panel
    tabBtn.BackgroundTransparency = 0.9
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Center
    tabBtn.Parent = btnWrap
    SugarUI.RoundCorner(8).Parent = tabBtn

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = SugarUI.Theme.Border
    tabStroke.Transparency = 0.9
    tabStroke.Thickness = 1
    tabStroke.Parent = tabBtn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = selfObj.PagesHolder

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -30, 1, -30)
    scrollingFrame.Position = UDim2.new(0, 15, 0, 15)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = SugarUI.Theme.Accent
    scrollingFrame.ScrollBarImageTransparency = 0.3
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 12)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            local isActive = (t.name == name)
            SugarUI.Tween(t.button, {
                TextColor3 = isActive and SugarUI.Theme.Text or SugarUI.Theme.Muted,
                BackgroundTransparency = isActive and 0.1 or 0.9,
                BackgroundColor3 = isActive and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            SugarUI.Tween(t.stroke, {Transparency = isActive and 0.6 or 0.9}, 0.2)
        end
        selfObj.ActiveTab = name
    end)

    tabBtn.MouseEnter:Connect(function()
        if selfObj.ActiveTab ~= name then
            SugarUI.Tween(tabBtn, {BackgroundTransparency = 0.7}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if selfObj.ActiveTab ~= name then
            SugarUI.Tween(tabBtn, {BackgroundTransparency = 0.9}, 0.15)
        end
    end)

    local tabObj = {
        name = name,
        button = tabBtn,
        wrapper = btnWrap,
        stroke = tabStroke,
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
        tabBtn.BackgroundTransparency = 0.1
        tabBtn.BackgroundColor3 = SugarUI.Theme.Accent
        tabStroke.Transparency = 0.6
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
    OuterFrame.Size = UDim2.new(0, 560, 0, 450)
    OuterFrame.Position = UDim2.new(0.5, -280, 0.5, -225)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 1  -- start hidden
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(16).Parent = Frame

    -- Добавляем стеклянный эффект к основному окну
    SugarUI.AddGlassEffect(Frame)
    SugarUI.AddShadow(Frame, 0.3, 20, 5)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = SugarUI.Theme.Border
    mainStroke.Transparency = 0.6
    mainStroke.Thickness = 2
    mainStroke.Parent = Frame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0.1
    TopBar.Parent = Frame
    SugarUI.RoundCorner(16).Parent = TopBar

    -- Градиент для топбара
    SugarUI.AddGradient(TopBar, ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Panel),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.Background)
    }), 180, NumberSequence.new(0.05, 0.15))

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.8
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0.7, -24, 1, 0)
    TitleLbl.Position = UDim2.new(0, 20, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI Enhanced"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.3, -24, 1, 0)
    Subtitle.Position = UDim2.new(0.7, 12, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "v2.0 Premium"
    Subtitle.TextColor3 = SugarUI.Theme.Accent
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = 13
    Subtitle.TextXAlignment = Enum.TextXAlignment.Right
    Subtitle.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    MinimizeBtn.Position = UDim2.new(1, -114, 0.5, -20)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
    MinimizeBtn.BackgroundTransparency = 0.2
    MinimizeBtn.Text = "—"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = TopBar
    SugarUI.RoundCorner(12).Parent = MinimizeBtn
    SugarUI.AddShadow(MinimizeBtn, 0.5, 6, 1)

    MinimizeBtn.MouseEnter:Connect(function() 
        SugarUI.Tween(MinimizeBtn, {BackgroundTransparency = 0.1, Size = UDim2.new(0, 42, 0, 42)}, 0.15, Enum.EasingStyle.Back) 
    end)
    MinimizeBtn.MouseLeave:Connect(function() 
        SugarUI.Tween(MinimizeBtn, {BackgroundTransparency = 0.2, Size = UDim2.new(0, 40, 0, 40)}, 0.15, Enum.EasingStyle.Back) 
    end)
    MinimizeBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -60, 0.5, -20)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
    CloseBtn.BackgroundTransparency = 0.2
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 22
    CloseBtn.TextColor3 = SugarUI.Theme.Highlight
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(12).Parent = CloseBtn
    SugarUI.AddShadow(CloseBtn, 0.5, 6, 1)

    CloseBtn.MouseEnter:Connect(function() 
        SugarUI.Tween(CloseBtn, {BackgroundTransparency = 0.1, Size = UDim2.new(0, 42, 0, 42)}, 0.15, Enum.EasingStyle.Back) 
    end)
    CloseBtn.MouseLeave:Connect(function() 
        SugarUI.Tween(CloseBtn, {BackgroundTransparency = 0.2, Size = UDim2.new(0, 40, 0, 40)}, 0.15, Enum.EasingStyle.Back) 
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 190, 1, -60)
    Sidebar.Position = UDim2.new(0, 0, 0, 60)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(0).Parent = Sidebar

    -- Стеклянный эффект для сайдбара
    SugarUI.AddGlassEffect(Sidebar)
    SugarUI.AddGradient(Sidebar, nil, 45, NumberSequence.new(0.1, 0.05))

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.8

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 20)
    tabsPadding.PaddingLeft = UDim.new(0, 15)
    tabsPadding.PaddingRight = UDim.new(0, 15)
    tabsPadding.PaddingBottom = UDim.new(0, 20)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -190, 1, -60)
    PagesHolder.Position = UDim2.new(0, 190, 0, 60)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Адаптивность (улучшенная)
    local function getViewport()
        Camera = Camera or Workspace.CurrentCamera
        if Camera and Camera.ViewportSize then return Camera.ViewportSize end
        return Vector2.new(1280, 720)
    end

    local function updateOuterSize()
        local vp = getViewport()
        local w = math.clamp(math.floor(vp.X * 0.55), 400, 1400)
        local h = math.clamp(math.floor(vp.Y * 0.6), 300, 1000)
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

    -- Улучшенное перетаскивание
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
            activeTween = TweenService:Create(OuterFrame, TweenInfo.new(0.04, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = newPos})
            activeTween:Play()
        end
    end)

    -- Изменение размера (улучшенное)
    local resizeBtn = Instance.new("Frame")
    resizeBtn.Size = UDim2.new(0, 24, 0, 24)
    resizeBtn.Position = UDim2.new(1, 0, 1, 0)
    resizeBtn.AnchorPoint = Vector2.new(1, 1)
    resizeBtn.BackgroundColor3 = SugarUI.Theme.Accent
    resizeBtn.BackgroundTransparency = 0.7
    resizeBtn.Parent = Frame
    SugarUI.RoundCorner(12).Parent = resizeBtn

    local resizeIcon = Instance.new("ImageLabel")
    resizeIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    resizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    resizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Image = "rbxassetid://6031094678"
    resizeIcon.ImageColor3 = SugarUI.Theme.Text
    resizeIcon.Rotation = -45
    resizeIcon.Parent = resizeBtn

    local resizing = false
    local resizeMousePos, resizeFrameSize

    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMousePos = input.Position
            resizeFrameSize = OuterFrame.Size
            selfObj._userResized = true
            SugarUI.Tween(resizeBtn, {BackgroundTransparency = 0.4}, 0.1)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    resizing = false
                    SugarUI.Tween(resizeBtn, {BackgroundTransparency = 0.7}, 0.1)
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeMousePos
            local newWidth = math.max(400, resizeFrameSize.X.Offset + delta.X)
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

    -- Мобильные кнопки (улучшенные)
    local mobileButtons = {}

    local function createMobileButton(name, sizeX, sizeY, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, sizeX, 0, sizeY)
        btn.Position = pos or UDim2.new(1, -200, 1, -140)
        btn.AnchorPoint = Vector2.new(0, 0)
        btn.BackgroundColor3 = SugarUI.Theme.Panel
        btn.BackgroundTransparency = 0.1
        btn.Text = name
        btn.TextColor3 = SugarUI.Theme.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.ZIndex = 1001
        btn.Parent = ScreenGui
        SugarUI.RoundCorner(12).Parent = btn
        SugarUI.AddGlassEffect(btn)
        SugarUI.AddShadow(btn, 0.4, 8, 2)
        return btn
    end

    if UserInputService.TouchEnabled then
        local toggleBtn = createMobileButton("GUI", 100, 52, UDim2.new(1, -200, 1, -140))
        mobileButtons.toggle = toggleBtn

        local function makeDraggable(btn, onTap)
            local draggingTouch = false
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
                    draggingTouch = true
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
                            draggingTouch = false
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

    -- Улучшенные Show / Hide с эффектной анимацией
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        
        -- Начальное состояние - невидимое и уменьшенное
        Frame.BackgroundTransparency = 1
        OuterFrame.Size = UDim2.new(0, 50, 0, 50)
        OuterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        -- Анимация появления с эффектным масштабированием
        local targetSize = UDim2.new(0, selfObj._userResized and OuterFrame.Size.X.Offset or 560, 0, selfObj._userResized and OuterFrame.Size.Y.Offset or 450)
        
        SugarUI.Tween(OuterFrame, {
            Size = targetSize
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        SugarUI.Tween(Frame, {
            BackgroundTransparency = 0.05
        }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Добавляем волновой эффект
        task.wait(0.1)
        for i, tab in ipairs(selfObj.Tabs) do
            task.wait(0.05)
            tab.button.Size = UDim2.new(1, -20, 1, -8)
            SugarUI.Tween(tab.button, {
                Size = UDim2.new(1, -18, 1, -6)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(0.1)
            SugarUI.Tween(tab.button, {
                Size = UDim2.new(1, -20, 1, -8)
            }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
        
        task.delay(0.3, function()
            pcall(function() selfObj:UpdateTheme() end)
        end)
    end
    function selfObj:Hide()
        selfObj.Visible = false
        
        -- Эффектная анимация скрытия
        SugarUI.Tween(OuterFrame, {
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(0.5, 0, 1.2, 0)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        SugarUI.Tween(Frame, {
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        
        -- Скрываем уведомления с эффектом
        for _, child in ipairs(Notifications.Container:GetChildren()) do
            if child:IsA("Frame") then
                pcall(function() 
                    SugarUI.Tween(child, {
                        Position = UDim2.new(1, 50, 0, 0),
                        BackgroundTransparency = 1
                    }, 0.3) 
                end)
            end
        end
        
        task.delay(0.45, function()
            if not selfObj.Visible then 
                OuterFrame.Visible = false 
                OuterFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Сбрасываем позицию
            end
            Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 3, "Info")
        end)
    end

    -- Запускаем с эффектной анимацией появления
    task.defer(function() 
        wait(0.1) 
        selfObj:Show() 
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function() 
            -- Анимация закрытия перед уничтожением
            SugarUI.Tween(OuterFrame, {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.35)
            ScreenGui:Destroy() 
        end, function() end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 1
        overlay.Parent = ScreenGui
        overlay.ZIndex = 999

        -- Анимация появления оверлея
        SugarUI.Tween(overlay, {BackgroundTransparency = 0.6}, 0.3)

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 380, 0, 200)
        panel.Position = UDim2.new(0.5, -190, 0.5, -100)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        panel.BackgroundTransparency = 0.05
        panel.ZIndex = 1000
        panel.Parent = overlay
        SugarUI.RoundCorner(14).Parent = panel

        -- Стеклянный эффект для диалога
        SugarUI.AddGlassEffect(panel)
        SugarUI.AddShadow(panel, 0.3, 16, 4)
        
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.7
        stroke.Thickness = 1.5

        -- Анимация появления панели
        panel.Size = UDim2.new(0, 50, 0, 50)
        SugarUI.Tween(panel, {Size = UDim2.new(0, 380, 0, 200)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,-30,0,40)
        titleLbl.Position = UDim2.new(0,15,0,15)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 18
        titleLbl.BackgroundTransparency = 1
        titleLbl.ZIndex = 1001
        titleLbl.Parent = panel

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -30, 0, 90)
        msgLbl.Position = UDim2.new(0,15,0,55)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        msgLbl.ZIndex = 1001
        msgLbl.Parent = panel

        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            SugarUI.Tween(overlay, {BackgroundTransparency = 1}, 0.2)
            SugarUI.Tween(panel, {Size = UDim2.new(0, 20, 0, 20)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.25, function() overlay:Destroy() end)
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.4, 0, 0, 38)
        yesBtn.Instance.Position = UDim2.new(0.08, 0, 1, -52)
        yesBtn.Instance.ZIndex = 1001

        local noBtn = ButtonComponent.new(panel, "No", function()
            SugarUI.Tween(overlay, {BackgroundTransparency = 1}, 0.2)
            SugarUI.Tween(panel, {Size = UDim2.new(0, 20, 0, 20)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.25, function() overlay:Destroy() end)
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.4, 0, 0, 38)
        noBtn.Instance.Position = UDim2.new(0.52, 0, 1, -52)
        noBtn.Instance.ZIndex = 1001
    end

    -- Expose on object
    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications
    selfObj.GlobalContainer = PagesHolder

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
            pcall(function() selfObj:Notify("Success", "Configuration applied successfully!", 3, "Success") end)
        end)
    end

    function selfObj:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Background
        TopBar.BackgroundColor3 = SugarUI.Theme.Panel
        topStroke.Color = SugarUI.Theme.Border
        TitleLbl.TextColor3 = SugarUI.Theme.Text
        Subtitle.TextColor3 = SugarUI.Theme.Accent
        MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
        MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
        CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
        CloseBtn.TextColor3 = SugarUI.Theme.Highlight
        Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
        sideStroke.Color = SugarUI.Theme.Border
        mainStroke.Color = SugarUI.Theme.Border
        resizeBtn.BackgroundColor3 = SugarUI.Theme.Accent
        resizeIcon.ImageColor3 = SugarUI.Theme.Text
        
        for _, tab in ipairs(selfObj.Tabs) do
            local isActive = (tab.name == selfObj.ActiveTab)
            tab.button.TextColor3 = isActive and SugarUI.Theme.Text or SugarUI.Theme.Muted
            tab.button.BackgroundColor3 = isActive and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            tab.stroke.Color = SugarUI.Theme.Border
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Accent
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then
                    comp.obj:UpdateTheme()
                end
            end
        end
        
        -- Обновляем все градиенты и эффекты
        for _, descendant in ipairs(ScreenGui:GetDescendants()) do
            if descendant.Name == "Shadow" and descendant:IsA("ImageLabel") then
                descendant.ImageColor3 = SugarUI.Theme.Shadow
            elseif descendant:IsA("UIGradient") then
                -- Обновляем градиенты в зависимости от родителя
                local parent = descendant.Parent
                if parent and parent.Name == "BtnGrad" then
                    descendant.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, SugarUI.Theme.Button), 
                        ColorSequenceKeypoint.new(1, SugarUI.Theme.ButtonHover)
                    })
                end
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
    -- apply theme name stored in config if exists
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

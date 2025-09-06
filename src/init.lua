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
-- Preset Themes (полностью обновленные)
-- ======================
SugarUI.Presets = {
    Aurora = {
        Background = Color3.fromRGB(15, 15, 25),
        Panel = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(0, 180, 255),
        AccentSoft = Color3.fromRGB(0, 140, 220),
        AccentDark = Color3.fromRGB(0, 100, 180),
        Text = Color3.fromRGB(240, 240, 245),
        Muted = Color3.fromRGB(170, 170, 180),
        Shadow = Color3.fromRGB(5, 5, 10),
        Border = Color3.fromRGB(50, 50, 60),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 217, 100),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 80, 80),
        Toggle = Color3.fromRGB(35, 35, 45),
        ToggleBox = Color3.fromRGB(200, 200, 210),
        Button = Color3.fromRGB(40, 40, 50),
        ButtonHover = Color3.fromRGB(60, 60, 70),
        Input = Color3.fromRGB(30, 30, 40),
        InputBorder = Color3.fromRGB(70, 70, 80),
        Gradient1 = Color3.fromRGB(106, 90, 205),
        Gradient2 = Color3.fromRGB(65, 105, 225),
    },
    Cyber = {
        Background = Color3.fromRGB(10, 12, 18),
        Panel = Color3.fromRGB(20, 22, 28),
        Accent = Color3.fromRGB(0, 255, 170),
        AccentSoft = Color3.fromRGB(0, 220, 150),
        AccentDark = Color3.fromRGB(0, 180, 120),
        Text = Color3.fromRGB(230, 230, 235),
        Muted = Color3.fromRGB(150, 150, 160),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(40, 45, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 230, 120),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 60, 60),
        Toggle = Color3.fromRGB(25, 27, 33),
        ToggleBox = Color3.fromRGB(180, 180, 190),
        Button = Color3.fromRGB(30, 32, 38),
        ButtonHover = Color3.fromRGB(40, 45, 55),
        Input = Color3.fromRGB(25, 27, 33),
        InputBorder = Color3.fromRGB(50, 55, 60),
        Gradient1 = Color3.fromRGB(0, 255, 170),
        Gradient2 = Color3.fromRGB(0, 200, 220),
    },
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Panel = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(100, 181, 246),
        AccentSoft = Color3.fromRGB(66, 153, 233),
        AccentDark = Color3.fromRGB(2, 119, 189),
        Text = Color3.fromRGB(240, 240, 240),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(50, 50, 50),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(35, 35, 35),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(40, 40, 40),
        ButtonHover = Color3.fromRGB(60, 60, 60),
        Input = Color3.fromRGB(30, 30, 30),
        InputBorder = Color3.fromRGB(70, 70, 70),
        Gradient1 = Color3.fromRGB(66, 133, 244),
        Gradient2 = Color3.fromRGB(52, 119, 235),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Panel = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(66, 133, 244),
        AccentSoft = Color3.fromRGB(82, 149, 255),
        AccentDark = Color3.fromRGB(52, 119, 235),
        Text = Color3.fromRGB(30, 30, 30),
        Muted = Color3.fromRGB(120, 120, 120),
        Shadow = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(220, 220, 220),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(225, 225, 225),
        ToggleBox = Color3.fromRGB(80, 80, 80),
        Button = Color3.fromRGB(230, 230, 230),
        ButtonHover = Color3.fromRGB(220, 220, 220),
        Input = Color3.fromRGB(250, 250, 250),
        InputBorder = Color3.fromRGB(200, 200, 200),
        Gradient1 = Color3.fromRGB(66, 133, 244),
        Gradient2 = Color3.fromRGB(26, 115, 232),
    }
}

-- default theme (start with Aurora)
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.Aurora) do SugarUI.Theme[k] = v end

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
    shadow.Size = UDim2.new(1, size or 14, 1, size or 14)
    shadow.Position = UDim2.new(0, -(size or 14)/2, 0, -(size or 14)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Button component (полностью обновленный)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback, configKey, imageId)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 42)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient", Btn)
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new(0.05, 0.15)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Gradient1),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.Gradient2)
    })
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Btn
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    
    -- Add image if provided
    if imageId then
        local image = Instance.new("ImageLabel")
        image.Size = UDim2.new(0, 20, 0, 20)
        image.Position = UDim2.new(0, 12, 0.5, -10)
        image.BackgroundTransparency = 1
        image.Image = imageId
        image.ImageColor3 = SugarUI.Theme.Text
        image.Parent = Btn
        
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        local padding = Instance.new("UIPadding", Btn)
        padding.PaddingLeft = UDim.new(0, 40)
    end
    
    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundTransparency = 0.05, Size = UDim2.new(1, -6, 0, 42)}, 0.15)
        SugarUI.Tween(stroke, {Color = SugarUI.Theme.Accent}, 0.15)
    end)
    
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundTransparency = 0, Size = UDim2.new(1, -10, 0, 42)}, 0.15)
        SugarUI.Tween(stroke, {Color = SugarUI.Theme.Border}, 0.15)
    end)
    
    Btn.MouseButton1Click:Connect(function()
        if callback then
            -- Ripple effect
            local ripple = Instance.new("ImageLabel")
            ripple.Size = UDim2.new(0, 8, 0, 8)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundTransparency = 1
            ripple.Image = "rbxassetid://7663593618"
            ripple.ImageColor3 = SugarUI.Theme.Highlight
            ripple.AnchorPoint = Vector2.new(0.5,0.5)
            ripple.Rotation = 0
            ripple.Parent = Btn
            SugarUI.Tween(ripple, {Size = UDim2.new(2.5, 0, 2.5, 0), ImageTransparency = 1}, 0.36, Enum.EasingStyle.Quad)
            task.delay(0.36, function() if ripple and ripple.Parent then ripple:Destroy() end end)
            pcall(callback)
        end
    end)
    
    self.Instance = Btn
    
    function self:UpdateTheme()
        Btn.BackgroundColor3 = SugarUI.Theme.Button
        Btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
        
        if gradient and gradient:IsA("UIGradient") then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, SugarUI.Theme.Gradient1),
                ColorSequenceKeypoint.new(1, SugarUI.Theme.Gradient2)
            })
        end
    end
    
    return self
end

-- ======================
-- Toggle component (обновленный)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
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
    Box.Position = UDim2.new(1, -38, 0.5, -13)
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
            SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.15)
            SugarUI.Tween(check, {ImageTransparency = self.State and 0 or 1}, 0.15)
            check.Visible = true
            task.delay(0.15, function() if not self.State then check.Visible = false end end)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)
    
    self.Instance = Frame
    
    self.Set = function(newState, fire)
        self.State = not not newState
        SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.15)
        check.Visible = self.State
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
-- Slider component (обновленный)
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or (min or 0)
    min = min or 0
    max = max or 100
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 54)
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
    Track.Size = UDim2.new(1, -24, 0, 8)
    Track.Position = UDim2.new(0, 12, 0, 34)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    SugarUI.RoundCorner(4).Parent = Track
    
    local Fill = Instance.new("Frame")
    local initialFill = 0
    if max - min ~= 0 then initialFill = (value - min) / (max - min) end
    Fill.Size = UDim2.new(initialFill, 0, 1, 0)
    Fill.BackgroundColor3 = SugarUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    SugarUI.RoundCorner(4).Parent = Fill
    
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 16, 0, 16)
    Handle.Position = UDim2.new(initialFill, -8, 0.5, -8)
    Handle.BackgroundColor3 = SugarUI.Theme.Highlight
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    SugarUI.RoundCorner(8).Parent = Handle
    
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
        SugarUI.Tween(Handle, {Position = UDim2.new(fillSize, -8, 0.5, -8)}, 0.12)
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
        Handle.BackgroundColor3 = SugarUI.Theme.Highlight
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
    Frame.Size = UDim2.new(1, -10, 0, 42)
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
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -26, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6031090990"
    arrow.ImageColor3 = SugarUI.Theme.Muted
    arrow.Rotation = 0
    arrow.Parent = Frame
    
    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame
    HeaderBtn.ZIndex = 50
    
    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 42)
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
    optionsList.Padding = UDim.new(0, 4)
    
    local optionsPadding = Instance.new("UIPadding", OptionsFrame)
    optionsPadding.PaddingTop = UDim.new(0, 4)
    optionsPadding.PaddingBottom = UDim.new(0, 4)
    optionsPadding.PaddingLeft = UDim.new(0, 4)
    optionsPadding.PaddingRight = UDim.new(0, 4)
    
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
        pad.PaddingLeft = UDim.new(0, 8)
        
        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.9
        optionStroke.Thickness = 1
        
        local Check
        local CheckIcon
        
        if multiSelect then
            Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 20, 0, 20)
            Check.Position = UDim2.new(1, -26, 0.5, -10)
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
            controlFrame.Size = UDim2.new(1, 0, 0, 38)
            controlFrame.BackgroundTransparency = 1
            controlFrame.LayoutOrder = order
            controlFrame.Parent = OptionsFrame
            order = order + 1
            
            local selAllBtn = Instance.new("TextButton")
            selAllBtn.Size = UDim2.new(0.48, -4, 1, 0)
            selAllBtn.BackgroundColor3 = SugarUI.Theme.Button
            selAllBtn.Text = "Select All"
            selAllBtn.TextColor3 = SugarUI.Theme.Text
            selAllBtn.Font = Enum.Font.Gotham
            selAllBtn.TextSize = 14
            selAllBtn.AutoButtonColor = false
            selAllBtn.Parent = controlFrame
            SugarUI.RoundCorner(6).Parent = selAllBtn
            
            local pad1 = Instance.new("UIPadding", selAllBtn)
            pad1.PaddingLeft = UDim.new(0, 8)
            
            local clearBtn = Instance.new("TextButton")
            clearBtn.Size = UDim2.new(0.48, -4, 1, 0)
            clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
            clearBtn.BackgroundColor3 = SugarUI.Theme.Button
            clearBtn.Text = "Clear"
            clearBtn.TextColor3 = SugarUI.Theme.Text
            clearBtn.Font = Enum.Font.Gotham
            clearBtn.TextSize = 14
            clearBtn.AutoButtonColor = false
            clearBtn.Parent = controlFrame
            SugarUI.RoundCorner(6).Parent = clearBtn
            
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
            SugarUI.Tween(arrow, {Rotation = 180}, 0.18)
            local height = math.min((#options * 34 + (multiSelect and 38 or 0) + 8), 220)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 42 + height)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            OptionsFrame.ZIndex = 1000
        else
            Label.Visible = true
            ValueLabel.Visible = true
            SugarUI.Tween(arrow, {Rotation = 0}, 0.18)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -10, 0, 42)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.delay(0.2, function() OptionsFrame.ZIndex = 60 end)
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
        arrow.ImageColor3 = SugarUI.Theme.Muted
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
-- TextBox component (новый)
-- ======================
local TextBoxComponent = {}
TextBoxComponent.__index = TextBoxComponent

function TextBoxComponent.new(parent, placeholder, default, callback, configKey)
    local self = setmetatable({}, TextBoxComponent)
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = SugarUI.Theme.Input
    Frame.BackgroundTransparency = 0
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = Frame
    stroke.Color = SugarUI.Theme.InputBorder
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 1, 0)
    TextBox.Position = UDim2.new(0, 10, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = default or ""
    TextBox.PlaceholderText = placeholder or "Type here..."
    TextBox.TextColor3 = SugarUI.Theme.Text
    TextBox.PlaceholderColor3 = SugarUI.Theme.Muted
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Frame
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if callback and enterPressed then
            pcall(callback, TextBox.Text)
        end
        if configKey then SugarUI.CurrentConfig[configKey] = TextBox.Text end
    end)
    
    self.Instance = Frame
    self.TextBox = TextBox
    
    self.SetText = function(text, fire)
        TextBox.Text = text or ""
        if fire and callback then pcall(callback, text) end
        if configKey then SugarUI.CurrentConfig[configKey] = text end
    end
    
    self.GetText = function() return TextBox.Text end
    
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Input
        stroke.Color = SugarUI.Theme.InputBorder
        TextBox.TextColor3 = SugarUI.Theme.Text
        TextBox.PlaceholderColor3 = SugarUI.Theme.Muted
    end
    
    return self
end

-- ======================
-- Keybind component (новый)
-- ======================
local KeybindComponent = {}
KeybindComponent.__index = KeybindComponent

function KeybindComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, KeybindComponent)
    self.Key = default or Enum.KeyCode.Unknown
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
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
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Keybind"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0.25, 0, 0, 30)
    KeyButton.Position = UDim2.new(0.75, -10, 0.5, -15)
    KeyButton.BackgroundColor3 = SugarUI.Theme.Button
    KeyButton.Text = tostring(self.Key.Name):gsub("Enum.KeyCode.", "")
    KeyButton.TextColor3 = SugarUI.Theme.Text
    KeyButton.Font = Enum.Font.GothamMedium
    KeyButton.TextSize = 12
    KeyButton.AutoButtonColor = false
    KeyButton.Parent = Frame
    SugarUI.RoundCorner(6).Parent = KeyButton
    
    local listening = false
    
    KeyButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        KeyButton.Text = "..."
        KeyButton.BackgroundColor3 = SugarUI.Theme.Accent
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Key = input.KeyCode
                KeyButton.Text = tostring(input.KeyCode.Name):gsub("Enum.KeyCode.", "")
                KeyButton.BackgroundColor3 = SugarUI.Theme.Button
                
                if callback then pcall(callback, input.KeyCode) end
                if configKey then SugarUI.CurrentConfig[configKey] = input.KeyCode.Name end
                
                listening = false
                if conn then conn:Disconnect() end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Key = Enum.KeyCode.Unknown
                KeyButton.Text = "None"
                KeyButton.BackgroundColor3 = SugarUI.Theme.Button
                
                if callback then pcall(callback, Enum.KeyCode.Unknown) end
                if configKey then SugarUI.CurrentConfig[configKey] = "Unknown" end
                
                listening = false
                if conn then conn:Disconnect() end
            end
        end)
    end)
    
    self.Instance = Frame
    self.KeyButton = KeyButton
    
    self.SetKey = function(key, fire)
        self.Key = key or Enum.KeyCode.Unknown
        KeyButton.Text = tostring(key.Name):gsub("Enum.KeyCode.", "")
        if fire and callback then pcall(callback, key) end
        if configKey then SugarUI.CurrentConfig[configKey] = key.Name end
    end
    
    self.GetKey = function() return self.Key end
    
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        KeyButton.BackgroundColor3 = SugarUI.Theme.Button
        KeyButton.TextColor3 = SugarUI.Theme.Text
    end
    
    return self
end

-- ======================
-- ColorPicker component (новый)
-- ======================
local ColorPickerComponent = {}
ColorPickerComponent.__index = ColorPickerComponent

function ColorPickerComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ColorPickerComponent)
    self.Color = default or Color3.fromRGB(255, 255, 255)
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
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
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Color Picker"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ColorBox = Instance.new("Frame")
    ColorBox.Size = UDim2.new(0, 30, 0, 30)
    ColorBox.Position = UDim2.new(0.75, -10, 0.5, -15)
    ColorBox.BackgroundColor3 = self.Color
    ColorBox.Parent = Frame
    SugarUI.RoundCorner(6).Parent = ColorBox
    
    local ColorPickerBtn = Instance.new("TextButton")
    ColorPickerBtn.Size = UDim2.new(1, 0, 1, 0)
    ColorPickerBtn.BackgroundTransparency = 1
    ColorPickerBtn.Text = ""
    ColorPickerBtn.AutoButtonColor = false
    ColorPickerBtn.Parent = Frame
    
    local PickerFrame
    local isPickerOpen = false
    
    local function closePicker()
        if PickerFrame and PickerFrame.Parent then
            PickerFrame:Destroy()
            isPickerOpen = false
        end
    end
    
    local function openPicker()
        if isPickerOpen then return end
        isPickerOpen = true
        
        PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(0, 200, 0, 220)
        PickerFrame.Position = UDim2.new(1, 10, 0, 0)
        PickerFrame.BackgroundColor3 = SugarUI.Theme.Panel
        PickerFrame.BorderSizePixel = 0
        PickerFrame.Parent = Frame
        SugarUI.RoundCorner(10).Parent = PickerFrame
        SugarUI.AddShadow(PickerFrame, 0.3, 10)
        PickerFrame.ZIndex = 100
        
        local HueSlider = Instance.new("Frame")
        HueSlider.Size = UDim2.new(0, 20, 0, 180)
        HueSlider.Position = UDim2.new(0, 10, 0, 10)
        HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueSlider.Parent = PickerFrame
        SugarUI.RoundCorner(4).Parent = HueSlider
        
        local SVPicker = Instance.new("ImageButton")
        SVPicker.Size = UDim2.new(0, 150, 0, 150)
        SVPicker.Position = UDim2.new(0, 40, 0, 10)
        SVPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        SVPicker.Image = "rbxassetid://4155801252"
        SVPicker.Parent = PickerFrame
        SugarUI.RoundCorner(4).Parent = SVPicker
        
        local HueSelector = Instance.new("Frame")
        HueSelector.Size = UDim2.new(1, 0, 0, 2)
        HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueSelector.BorderSizePixel = 0
        HueSelector.Parent = HueSlider
        
        local SVSelector = Instance.new("Frame")
        SVSelector.Size = UDim2.new(0, 8, 0, 8)
        SVSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SVSelector.BorderSizePixel = 0
        SVSelector.Parent = SVPicker
        SugarUI.RoundCorner(4).Parent = SVSelector
        
        local ConfirmBtn = Instance.new("TextButton")
        ConfirmBtn.Size = UDim2.new(0, 80, 0, 30)
        ConfirmBtn.Position = UDim2.new(0.5, -40, 1, -40)
        ConfirmBtn.BackgroundColor3 = SugarUI.Theme.Accent
        ConfirmBtn.Text = "Confirm"
        ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ConfirmBtn.Font = Enum.Font.Gotham
        ConfirmBtn.TextSize = 12
        ConfirmBtn.AutoButtonColor = false
        ConfirmBtn.Parent = PickerFrame
        SugarUI.RoundCorner(6).Parent = ConfirmBtn
        
        local h, s, v = self.Color:ToHSV()
        HueSelector.Position = UDim2.new(0, 0, h, -1)
        SVSelector.Position = UDim2.new(s, -4, 1 - v, -4)
        
        local function updateColorFromHue(hue)
            SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        end
        
        local function updateColorFromSV(x, y)
            s = math.clamp(x / SVPicker.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp(y / SVPicker.AbsoluteSize.Y, 0, 1)
            self.Color = Color3.fromHSV(h, s, v)
            ColorBox.BackgroundColor3 = self.Color
        end
        
        HueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local y = math.clamp(input.Position.Y - HueSlider.AbsolutePosition.Y, 0, HueSlider.AbsoluteSize.Y)
                h = y / HueSlider.AbsoluteSize.Y
                updateColorFromHue(h)
                HueSelector.Position = UDim2.new(0, 0, h, -1)
                updateColorFromSV(SVSelector.Position.X.Offset + 4, SVSelector.Position.Y.Offset + 4)
            end
        end)
        
        SVPicker.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x = math.clamp(input.Position.X - SVPicker.AbsolutePosition.X, 0, SVPicker.AbsoluteSize.X)
                local y = math.clamp(input.Position.Y - SVPicker.AbsolutePosition.Y, 0, SVPicker.AbsoluteSize.Y)
                updateColorFromSV(x, y)
                SVSelector.Position = UDim2.new(x/SVPicker.AbsoluteSize.X, -4, y/SVPicker.AbsoluteSize.Y, -4)
            end
        end)
        
        ConfirmBtn.MouseButton1Click:Connect(function()
            if callback then pcall(callback, self.Color) end
            if configKey then SugarUI.CurrentConfig[configKey] = {self.Color.R, self.Color.G, self.Color.B} end
            closePicker()
        end)
        
        -- Close picker when clicking outside
        local inputConn
        inputConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if PickerFrame and not (input.Position.X >= PickerFrame.AbsolutePosition.X and 
                    input.Position.X <= PickerFrame.AbsolutePosition.X + PickerFrame.AbsoluteSize.X and
                    input.Position.Y >= PickerFrame.AbsolutePosition.Y and
                    input.Position.Y <= PickerFrame.AbsolutePosition.Y + PickerFrame.AbsoluteSize.Y) then
                    closePicker()
                    if inputConn then inputConn:Disconnect() end
                end
            end
        end)
    end
    
    ColorPickerBtn.MouseButton1Click:Connect(function()
        if isPickerOpen then
            closePicker()
        else
            openPicker()
        end
    end)
    
    self.Instance = Frame
    self.ColorBox = ColorBox
    
    self.SetColor = function(color, fire)
        if typeof(color) == "Color3" then
            self.Color = color
            ColorBox.BackgroundColor3 = color
            if fire and callback then pcall(callback, color) end
            if configKey then SugarUI.CurrentConfig[configKey] = {color.R, color.G, color.B} end
        end
    end
    
    self.GetColor = function() return self.Color end
    
    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
    end
    
    return self
end

-- ======================
-- Section component (обновленный)
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
    line.Position = UDim2.new(0, 10, 1, -6)
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
-- Notifications (обновленные)
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 340, 0, 380)
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
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    SugarUI.RoundCorner(12).Parent = notification
    notification.ZIndex = 901
    
    SugarUI.AddShadow(notification, 0.28, 8)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 6, 1, 0)
    accent.BackgroundColor3 = ({ 
        Info = SugarUI.Theme.Accent, 
        Success = SugarUI.Theme.Success, 
        Warning = SugarUI.Theme.Warning, 
        Error = SugarUI.Theme.Error 
    })[notifType] or SugarUI.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    accent.ZIndex = 902
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Image = ({ 
        Info = "rbxassetid://6031280882", 
        Success = "rbxassetid://6031094667", 
        Warning = "rbxassetid://6031094687", 
        Error = "rbxassetid://6031094688" 
    })[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = SugarUI.Theme.Text
    icon.Parent = notification
    icon.ZIndex = 902
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 24)
    titleLabel.Position = UDim2.new(0, 50, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    titleLabel.ZIndex = 902
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -70, 0, 0)
    messageLabel.Position = UDim2.new(0, 50, 0, 38)
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
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -34, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Muted
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = notification
    closeButton.ZIndex = 902
    
    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(260, 1000))
        textHeight = size.Y
    end
    
    local totalHeight = math.clamp(60 + textHeight, 64, 150)
    messageLabel.Size = UDim2.new(1, -70, 0, textHeight)
    
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
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    task.delay(0.18, function() if notification.Parent then notification:Destroy() end end)
    for i, notif in ipairs(self.Notifications) do if notif == notification then table.remove(self.Notifications, i); break end end
end

-- ======================
-- Window & Tabs (полностью обновленные)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name, iconId)
    local layoutOrderCounter = 0
    local tabComponents = {}
    
    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 48)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -28, 1, 0)
    tabBtn.Position = UDim2.new(0, 14, 0, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap
    
    -- Add icon if provided
    if iconId then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 12, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = SugarUI.Theme.Muted
        icon.Parent = tabBtn
        
        local padding = Instance.new("UIPadding", tabBtn)
        padding.PaddingLeft = UDim.new(0, 40)
    end
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -8)
    indicator.Position = UDim2.new(0, -6, 0, 4)
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
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.Parent = page
    
    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 12)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            SugarUI.Tween(t.button, {TextColor3 = (t.name == name) and SugarUI.Theme.Text or SugarUI.Theme.Muted}, 0.12)
            
            if t.button:FindFirstChildWhichIsA("ImageLabel") then
                SugarUI.Tween(t.button:FindFirstChildWhichIsA("ImageLabel"), 
                    {ImageColor3 = (t.name == name) and SugarUI.Theme.Text or SugarUI.Theme.Muted}, 0.12)
            end
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
        
        AddButton = function(_, txt, cb, cfgKey, imgId)
            layoutOrderCounter = layoutOrderCounter + 1
            local btn = ButtonComponent.new(scrollingFrame, txt, cb, cfgKey, imgId)
            btn.Instance.LayoutOrder = layoutOrderCounter
            if cfgKey then
                table.insert(tabComponents, {type = "button", key = cfgKey, obj = btn})
                table.insert(selfObj.Components, {type = "button", key = cfgKey, obj = btn})
            else
                table.insert(tabComponents, {type = "button", obj = btn})
            end
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
        
        AddTextBox = function(_, placeholder, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local textbox = TextBoxComponent.new(scrollingFrame, placeholder, def, cb, configKey)
            textbox.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "textbox", key = configKey, obj = textbox})
                table.insert(selfObj.Components, {type = "textbox", key = configKey, obj = textbox})
            else
                table.insert(tabComponents, {type = "textbox", obj = textbox})
            end
            return textbox
        end,
        
        AddKeybind = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local keybind = KeybindComponent.new(scrollingFrame, txt, def, cb, configKey)
            keybind.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "keybind", key = configKey, obj = keybind})
                table.insert(selfObj.Components, {type = "keybind", key = configKey, obj = keybind})
            else
                table.insert(tabComponents, {type = "keybind", obj = keybind})
            end
            return keybind
        end,
        
        AddColorPicker = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local colorpicker = ColorPickerComponent.new(scrollingFrame, txt, def, cb, configKey)
            colorpicker.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type = "colorpicker", key = configKey, obj = colorpicker})
                table.insert(selfObj.Components, {type = "colorpicker", key = configKey, obj = colorpicker})
            else
                table.insert(tabComponents, {type = "colorpicker", obj = colorpicker})
            end
            return colorpicker
        end
    }
    
    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page
    
    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = SugarUI.Theme.Text
        if tabBtn:FindFirstChildWhichIsA("ImageLabel") then
            tabBtn:FindFirstChildWhichIsA("ImageLabel").ImageColor3 = SugarUI.Theme.Text
        end
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
    OuterFrame.Size = UDim2.new(0, 560, 0, 460)
    OuterFrame.Position = UDim2.new(0.5, -280, 0.5, -230)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui
    
    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 30, 1, 30)
    ShadowFrame.Position = UDim2.new(0, -15, 0, -15)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = SugarUI.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.72
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10, 10, 118, 118)
    ShadowFrame.Parent = OuterFrame
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(14).Parent = Frame
    SugarUI.AddShadow(Frame, 0.28, 12)
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0
    TopBar.Parent = Frame
    SugarUI.RoundCorner(14).Parent = TopBar
    
    local topGradient = Instance.new("UIGradient", TopBar)
    topGradient.Rotation = 0
    topGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Gradient1),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.Gradient2)
    })
    topGradient.Transparency = NumberSequence.new(0.02, 0)
    
    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.9
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0.8, -24, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.2, -24, 1, 0)
    Subtitle.Position = UDim2.new(0.8, 12, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "v2.0"
    Subtitle.TextColor3 = SugarUI.Theme.Muted
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Right
    Subtitle.Parent = TopBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    MinimizeBtn.Position = UDim2.new(1, -104, 0.5, -18)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
    MinimizeBtn.Text = "—"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = MinimizeBtn
    
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
    
    CloseBtn.MouseEnter:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Error}, 0.12) end)
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -60)
    Sidebar.Position = UDim2.new(0, 0, 0, 60)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(0).Parent = Sidebar
    
    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.9
    
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
    PagesHolder.Size = UDim2.new(1, -180, 1, -60)
    PagesHolder.Position = UDim2.new(0, 180, 0, 60)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame
    
    local Notifications = NotificationSystem.new(ScreenGui)
    
    -- Адаптивность
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
    
    -- Плавное перетаскивание
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
    
    -- Мобильные кнопки
    local mobileButtons = {}
    
    local function createMobileButton(name, sizeX, sizeY, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, sizeX, 0, sizeY)
        btn.Position = pos or UDim2.new(1, -180, 1, -120)
        btn.AnchorPoint = Vector2.new(0, 0)
        btn.BackgroundColor3 = SugarUI.Theme.Panel
        btn.Text = name
        btn.TextColor3 = SugarUI.Theme.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.ZIndex = 1001
        btn.Parent = ScreenGui
        SugarUI.RoundCorner(8).Parent = btn
        return btn
    end
    
    if UserInputService.TouchEnabled then
        local toggleBtn = createMobileButton("GUI", 96, 48, UDim2.new(1, -180, 1, -120))
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
    
    -- Новая анимация появления
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        
        -- Начальное состояние для анимации
        OuterFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
        OuterFrame.Size = UDim2.new(0, 0, 0, 0)
        Frame.BackgroundTransparency = 1
        ShadowFrame.ImageTransparency = 1
        
        -- Анимация появления
        SugarUI.Tween(OuterFrame, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 560, 0, 460)
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        SugarUI.Tween(Frame, {BackgroundTransparency = 0}, 0.5)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 0.72}, 0.5)
    end
    
    function selfObj:Hide()
        selfObj.Visible = false
        
        -- Анимация исчезновения
        SugarUI.Tween(OuterFrame, {
            Position = UDim2.new(0.5, 0, 0.6, 0),
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.4)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 1}, 0.4)
        
        task.delay(0.4, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
            Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 3, "Info")
        end)
    end
    
    task.defer(function() wait(0.05); selfObj:Show() end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function() 
            ScreenGui:Destroy() 
            SugarUI.CurrentWindow = nil
        end, function() end)
    end)
    
    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.52
        overlay.Parent = ScreenGui
        overlay.ZIndex = 999
        
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 360, 0, 180)
        panel.Position = UDim2.new(0.5, -180, 0.5, -90)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        SugarUI.RoundCorner(10).Parent = panel
        panel.Parent = overlay
        panel.ZIndex = 1000
        
        SugarUI.AddShadow(panel, 0.42, 12)
        
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.8
        
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,-20,0,36)
        titleLbl.Position = UDim2.new(0,10,0,10)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = panel
        titleLbl.ZIndex = 1001
        
        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -20, 0, 80)
        msgLbl.Position = UDim2.new(0,10,0,46)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        msgLbl.Parent = panel
        msgLbl.ZIndex = 1001
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -20, 0, 34)
        buttonContainer.Position = UDim2.new(0, 10, 1, -48)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = panel
        buttonContainer.ZIndex = 1001
        
        local uiList = Instance.new("UIListLayout", buttonContainer)
        uiList.FillDirection = Enum.FillDirection.Horizontal
        uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uiList.VerticalAlignment = Enum.VerticalAlignment.Center
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Padding = UDim.new(0, 10)
        
        local yesBtn = ButtonComponent.new(buttonContainer, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.4, 0, 1, 0)
        yesBtn.Instance.ZIndex = 1001
        
        local noBtn = ButtonComponent.new(buttonContainer, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.4, 0, 1, 0)
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
    
    function selfObj:AddTab(name, iconId) 
        local tab = createTab(selfObj, name, iconId); 
        return tab 
    end
    
    function selfObj:AddPage(name, iconId) 
        return selfObj:AddTab(name, iconId) 
    end
    
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
                elseif comp.type == "textbox" then
                    if type(comp.obj.SetText) == "function" then comp.obj.SetText(val, false) end
                elseif comp.type == "keybind" then
                    if type(comp.obj.SetKey) == "function" then
                        local key = Enum.KeyCode[val] or Enum.KeyCode.Unknown
                        comp.obj.SetKey(key, false)
                    end
                elseif comp.type == "colorpicker" then
                    if type(comp.obj.SetColor) == "function" then
                        if type(val) == "table" and #val == 3 then
                            local color = Color3.new(val[1], val[2], val[3])
                            comp.obj.SetColor(color, false)
                        end
                    end
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
        
        if topGradient and topGradient:IsA("UIGradient") then
            topGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, SugarUI.Theme.Gradient1),
                ColorSequenceKeypoint.new(1, SugarUI.Theme.Gradient2)
            })
        end
        
        for _, tab in ipairs(selfObj.Tabs) do
            tab.button.TextColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Text or SugarUI.Theme.Muted
            tab.indicator.BackgroundColor3 = SugarUI.Theme.Accent
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Border
            
            if tab.button:FindFirstChildWhichIsA("ImageLabel") then
                tab.button:FindFirstChildWhichIsA("ImageLabel").ImageColor3 = 
                    (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Text or SugarUI.Theme.Muted
            end
            
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then
                    comp.obj:UpdateTheme()
                end
            end
        end
        
        -- Update shadows
        for _, shadow in ipairs(ScreenGui:GetDescendants()) do
            if shadow.Name == "Shadow" and shadow:IsA("ImageLabel") then
                shadow.ImageColor3 = SugarUI.Theme.Shadow
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

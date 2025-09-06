-- init.lua (Sugar UI - Enhanced with Themes and Improved Design)
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

-- Predefined Themes
SugarUI.Themes = {
    Pinky = {
        Background = Color3.fromRGB(240, 182, 214),
        Panel = Color3.fromRGB(255, 204, 229),
        Accent = Color3.fromRGB(255, 105, 180),
        AccentSoft = Color3.fromRGB(255, 182, 193),
        AccentDark = Color3.fromRGB(219, 112, 147),
        Text = Color3.fromRGB(50, 50, 50),
        Muted = Color3.fromRGB(120, 120, 120),
        Shadow = Color3.fromRGB(50, 50, 50),
        Border = Color3.fromRGB(150, 150, 150),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(255, 204, 229),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(255, 182, 193),
        ButtonHover = Color3.fromRGB(255, 160, 180),
    },
    Amethyst = {
        Background = Color3.fromRGB(153, 102, 204),
        Panel = Color3.fromRGB(186, 147, 216),
        Accent = Color3.fromRGB(138, 43, 226),
        AccentSoft = Color3.fromRGB(171, 103, 255),
        AccentDark = Color3.fromRGB(106, 13, 173),
        Text = Color3.fromRGB(230, 230, 230),
        Muted = Color3.fromRGB(160, 160, 160),
        Shadow = Color3.fromRGB(40, 40, 40),
        Border = Color3.fromRGB(120, 120, 120),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(186, 147, 216),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(171, 103, 255),
        ButtonHover = Color3.fromRGB(150, 80, 220),
    },
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Panel = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(100, 181, 246),
        AccentSoft = Color3.fromRGB(66, 153, 233),
        AccentDark = Color3.fromRGB(2, 119, 189),
        Text = Color3.fromRGB(240, 240, 240),
        Muted = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(20, 20, 20),
        Border = Color3.fromRGB(60, 60, 60),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(40, 40, 40),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(50, 50, 50),
        ButtonHover = Color3.fromRGB(70, 70, 70),
    },
    White = {
        Background = Color3.fromRGB(240, 240, 240),
        Panel = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(30, 144, 255),
        AccentSoft = Color3.fromRGB(135, 206, 250),
        AccentDark = Color3.fromRGB(0, 105, 255),
        Text = Color3.fromRGB(40, 40, 40),
        Muted = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(50, 50, 50),
        Border = Color3.fromRGB(150, 150, 150),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Toggle = Color3.fromRGB(255, 255, 255),
        ToggleBox = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(230, 230, 230),
        ButtonHover = Color3.fromRGB(210, 210, 210),
    },
}

SugarUI.CurrentTheme = "Dark"
SugarUI.Theme = SugarUI.Themes[SugarUI.CurrentTheme]

-- Helper Functions
function SugarUI.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    return corner
end

function SugarUI.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.InOut
    local tweenInfo = TweenInfo.new(duration or 0.3, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function SugarUI.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 12, 1, size or 12)
    shadow.Position = UDim2.new(0, -(size or 12)/2, 0, -(size or 12)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = SugarUI.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame
    return shadow
end

function SugarUI.AddGradient(frame)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SugarUI.Theme.Background),
        ColorSequenceKeypoint.new(1, SugarUI.Theme.AccentDark)
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    return gradient
end

-- Button Component
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 36)
    Btn.BackgroundColor3 = SugarUI.Theme.Button
    Btn.BackgroundTransparency = 0.1
    Btn.Text = text or "Button"
    Btn.TextColor3 = SugarUI.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = Btn
    SugarUI.AddShadow(Btn, 0.5, 8)

    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5

    Btn.MouseEnter:Connect(function()
        SugarUI.Tween(Btn, {BackgroundTransparency = 0, Size = UDim2.new(1, -10, 0, 38)}, 0.2)
    end)
    Btn.MouseLeave:Connect(function()
        SugarUI.Tween(Btn, {BackgroundTransparency = 0.1, Size = UDim2.new(1, -12, 0, 36)}, 0.2)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = SugarUI.Theme.Highlight
            ripple.BackgroundTransparency = 0.6
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Parent = Btn
            SugarUI.RoundCorner(100).Parent = ripple
            SugarUI.Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4)
            task.delay(0.4, function() if ripple.Parent then ripple:Destroy() end end)
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

-- Toggle Component
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Toggle
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    SugarUI.AddShadow(Frame, 0.5, 8)

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 40, 0, 20)
    Box.Position = UDim2.new(0.95, -44, 0.5, -10)
    Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    Box.Parent = Frame
    SugarUI.RoundCorner(10).Parent = Box

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(self.State and 0.6 or 0.1, 0, 0.5, -8)
    Knob.BackgroundColor3 = SugarUI.Theme.Highlight
    Knob.Parent = Box
    SugarUI.RoundCorner(8).Parent = Knob

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.2)
            SugarUI.Tween(Knob, {Position = UDim2.new(self.State and 0.6 or 0.1, 0, 0.5, -8)}, 0.2)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        SugarUI.Tween(Box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.2)
        SugarUI.Tween(Knob, {Position = UDim2.new(self.State and 0.6 or 0.1, 0, 0.5, -8)}, 0.2)
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    function self:UpdateTheme()
        Frame.BackgroundColor3 = SugarUI.Theme.Toggle
        stroke.Color = SugarUI.Theme.Border
        Label.TextColor3 = SugarUI.Theme.Text
        Box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        Knob.BackgroundColor3 = SugarUI.Theme.Highlight
    end

    return self
end

-- Slider Component
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
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    SugarUI.AddShadow(Frame, 0.5, 8)

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 24)
    Label.Position = UDim2.new(0, 8, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 24)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 15
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -16, 0, 8)
    Track.Position = UDim2.new(0, 8, 0, 40)
    Track.BackgroundColor3 = SugarUI.Theme.Border
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

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(initialFill, -8, 0, -4)
    Knob.BackgroundColor3 = SugarUI.Theme.Highlight
    Knob.Parent = Track
    SugarUI.RoundCorner(8).Parent = Knob
    SugarUI.AddShadow(Knob, 0.4, 6)

    local dragging = false
    local function set_value(newValue, fire)
        newValue = tonumber(newValue) or newValue
        if type(newValue) ~= "number" then return end
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = 0
        if max - min ~= 0 then fillSize = (value - min) / (max - min) end
        SugarUI.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.15)
        SugarUI.Tween(Knob, {Position = UDim2.new(fillSize, -8, 0, -4)}, 0.15)
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
        Track.BackgroundColor3 = SugarUI.Theme.Border
        Fill.BackgroundColor3 = SugarUI.Theme.Accent
        Knob.BackgroundColor3 = SugarUI.Theme.Highlight
    end

    return self
end

-- Dropdown Component
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
    Frame.Size = UDim2.new(1, -12, 0, 36)
    Frame.BackgroundColor3 = SugarUI.Theme.Button
    Frame.BackgroundTransparency = 0.1
    Frame.ClipsDescendants = false
    Frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = Frame
    SugarUI.AddShadow(Frame, 0.5, 8)

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = SugarUI.Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    ValueLabel.Position = UDim2.new(0.7, -14, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = SugarUI.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 15
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
    OptionsFrame.BackgroundTransparency = 0.1
    OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    OptionsFrame.ScrollBarImageTransparency = 0.5
    OptionsFrame.ZIndex = 60
    SugarUI.AddShadow(OptionsFrame, 0.5, 8)

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
            self:Toggle()
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
        OptionButton.BackgroundColor3 = SugarUI.Theme.Button
        OptionButton.BackgroundTransparency = 0.1
        OptionButton.Text = tostring(optionText)
        OptionButton.TextColor3 = SugarUI.Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionFrame
        SugarUI.RoundCorner(6).Parent = OptionButton

        local pad = Instance.new("UIPadding", OptionButton)
        pad.PaddingLeft = UDim.new(0, 10)

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = SugarUI.Theme.Border
        optionStroke.Transparency = 0.7
        optionStroke.Thickness = 1.5

        local Check
        if multiSelect then
            Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 20, 0, 20)
            Check.Position = UDim2.new(1, -30, 0.5, -10)
            Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Button
            Check.Parent = OptionButton
            SugarUI.RoundCorner(6).Parent = Check

            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(1, 0, 1, 0)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = SugarUI.Theme.Highlight
            CheckIcon.Visible = table.find(selected, optionText) ~= nil
            CheckIcon.Parent = Check

            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                Check.BackgroundColor3 = table.find(selected, optionText) and SugarUI.Theme.Accent or SugarUI.Theme.Button
                CheckIcon.Visible = table.find(selected, optionText) ~= nil
            end)
        else
            OptionButton.BackgroundColor3 = (selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button
            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                for _, obj in ipairs(optionObjects) do
                    SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button}, 0.15)
                end
            end)
        end

        OptionButton.MouseEnter:Connect(function()
            SugarUI.Tween(OptionButton, {BackgroundTransparency = 0}, 0.1)
        end)
        OptionButton.MouseLeave:Connect(function()
            local targetColor = multiSelect and SugarUI.Theme.Button or ((selected == optionText) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button)
            SugarUI.Tween(OptionButton, {BackgroundColor3 = targetColor, BackgroundTransparency = 0.1}, 0.1)
        end)

        optionObjects[#optionObjects + 1] = {frame = OptionFrame, btn = OptionButton, check = Check}
    end

    local function rebuild_options()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        optionObjects = {}
        local order = 1
        if multiSelect then
            local controlFrame = Instance.new("Frame")
            controlFrame.Size = UDim2.new(1, 0, 0, 32)
            controlFrame.BackgroundTransparency = 1
            controlFrame.LayoutOrder = order
            controlFrame.Parent = OptionsFrame
            order = order + 1

            local selAllBtn = Instance.new("TextButton")
            selAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
            selAllBtn.BackgroundColor3 = SugarUI.Theme.Button
            selAllBtn.Text = "Select All"
            selAllBtn.TextColor3 = SugarUI.Theme.Text
            selAllBtn.Font = Enum.Font.Gotham
            selAllBtn.TextSize = 14
            selAllBtn.AutoButtonColor = false
            selAllBtn.Parent = controlFrame
            SugarUI.RoundCorner(6).Parent = selAllBtn
            local pad1 = Instance.new("UIPadding", selAllBtn)
            pad1.PaddingLeft = UDim.new(0, 10)

            local clearBtn = Instance.new("TextButton")
            clearBtn.Size = UDim2.new(0.48, 0, 1, 0)
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
            pad2.PaddingLeft = UDim.new(0, 10)

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
                        obj.check.BackgroundColor3 = SugarUI.Theme.Button
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
            local height = math.min((#options * 32 + (multiSelect and 32 or 0) + 12), 200)
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -12, 0, 36 + height)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            OptionsFrame.ZIndex = 1000
        else
            Label.Visible = true
            ValueLabel.Visible = true
            SugarUI.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            SugarUI.Tween(Frame, {Size = UDim2.new(1, -12, 0, 36)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.25, function() OptionsFrame.ZIndex = 60 end)
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
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Button
                local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                if img then img.Visible = table.find(selected, obj.btn.Text) ~= nil end
            else
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button}, 0.15)
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
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Button
                local img = obj.check:FindFirstChildWhichIsA("ImageLabel")
                if img then img.Visible = table.find(selected, obj.btn.Text) ~= nil end
            else
                SugarUI.Tween(obj.btn, {BackgroundColor3 = (selected == obj.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Button}, 0.15)
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
        OptionsFrame.BackgroundColor3 = SugarUI.Theme.Panel
        OptionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
        for _, obj in ipairs(optionObjects) do
            obj.btn.BackgroundColor3 = SugarUI.Theme.Button
            obj.btn.TextColor3 = SugarUI.Theme.Text
            obj.optionStroke.Color = SugarUI.Theme.Border
            if obj.check then
                obj.check.BackgroundColor3 = table.find(selected, obj.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Button
                obj.check:FindFirstChildWhichIsA("ImageLabel").ImageColor3 = SugarUI.Theme.Highlight
            end
        end
    end

    return self
end

-- Section Component
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 36)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -12, 0, 2)
    line.Position = UDim2.new(0, 6, 1, -2)
    line.BackgroundColor3 = SugarUI.Theme.Accent
    line.BorderSizePixel = 0
    line.Parent = wrapper
    SugarUI.RoundCorner(1).Parent = line

    self._wrapper = wrapper

    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Muted
        line.BackgroundColor3 = SugarUI.Theme.Accent
    end

    return self
end

-- Notification System
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 320, 0, 360)
    self.Container.Position = UDim2.new(1, -340, 0, 20)
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
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    SugarUI.RoundCorner(10).Parent = notification
    SugarUI.AddGradient(notification)
    notification.ZIndex = 901

    SugarUI.AddShadow(notification, 0.4, 10)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 5, 1, 0)
    accent.BackgroundColor3 = ({ Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error })[notifType] or SugarUI.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    accent.ZIndex = 902

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 14, 0, 14)
    icon.BackgroundTransparency = 1
    icon.Image = ({ Info = "rbxassetid://6031280882", Success = "rbxassetid://6031094667", Warning = "rbxassetid://6031094687", Error = "rbxassetid://6031094688" })[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = SugarUI.Theme.Text
    icon.Parent = notification
    icon.ZIndex = 902

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -56, 0, 24)
    titleLabel.Position = UDim2.new(0, 48, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    titleLabel.ZIndex = 902

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -56, 0, 0)
    messageLabel.Position = UDim2.new(0, 48, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = SugarUI.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    messageLabel.ZIndex = 902

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -36, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = SugarUI.Theme.Muted
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.Parent = notification
    closeButton.ZIndex = 902

    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(260, 1000))
        textHeight = size.Y
    end

    local totalHeight = math.clamp(60 + textHeight, 70, 140)
    messageLabel.Size = UDim2.new(1, -56, 0, textHeight)

    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    closeButton.MouseButton1Click:Connect(function() self:Remove(notification) end)
    closeButton.MouseEnter:Connect(function() SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Text}, 0.1) end)
    closeButton.MouseLeave:Connect(function() SugarUI.Tween(closeButton, {TextColor3 = SugarUI.Theme.Muted}, 0.1) end)

    if duration > 0 then
        task.delay(duration, function() if notification.Parent then self:Remove(notification) end end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    SugarUI.Tween(notification, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.3, function() if notification.Parent then notification:Destroy() end end)
    for i, notif in ipairs(self.Notifications) do if notif == notification then table.remove(self.Notifications, i); break end end
end

-- Window & Tabs
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0
    local tabComponents = {}

    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 44)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -28, 1, 0)
    tabBtn.Position = UDim2.new(0, 14, 0, 0)
    tabBtn.BackgroundTransparency = 0.1
    tabBtn.BackgroundColor3 = SugarUI.Theme.Button
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 15
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap
    SugarUI.RoundCorner(8).Parent = tabBtn
    SugarUI.AddShadow(tabBtn, 0.5, 6)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0.8, 0)
    indicator.Position = UDim2.new(0, -8, 0.1, 0)
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
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            SugarUI.Tween(t.button, {TextColor3 = (t.name == name) and SugarUI.Theme.Text or SugarUI.Theme.Muted, BackgroundTransparency = (t.name == name) and 0 or 0.1}, 0.15)
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
            end
            return drop
        end,
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = SugarUI.Theme.Text
        tabBtn.BackgroundTransparency = 0
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
    OuterFrame.Size = UDim2.new(0, 550, 0, 450)
    OuterFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 24, 1, 24)
    ShadowFrame.Position = UDim2.new(0, -12, 0, -12)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = SugarUI.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.5
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10, 10, 118, 118)
    ShadowFrame.Parent = OuterFrame

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    SugarUI.RoundCorner(12).Parent = Frame
    SugarUI.AddGradient(Frame)
    SugarUI.AddShadow(Frame, 0.4, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 54)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0.1
    TopBar.Parent = Frame
    SugarUI.RoundCorner(12).Parent = TopBar

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.8
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -120, 1, 0)
    TitleLbl.Position = UDim2.new(0, 18, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBlack
    TitleLbl.TextSize = 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    MinimizeBtn.Position = UDim2.new(1, -90, 0.5, -18)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
    MinimizeBtn.Text = "-"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = MinimizeBtn

    MinimizeBtn.MouseEnter:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(200, 150, 0)}, 0.15) end)
    MinimizeBtn.MouseLeave:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.Warning}, 0.15) end)
    MinimizeBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -18)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.TextColor3 = SugarUI.Theme.Highlight
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(10).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Error}, 0.15) end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -54)
    Sidebar.Position = UDim2.new(0, 0, 0, 54)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.Parent = Frame
    SugarUI.AddGradient(Sidebar)

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.8

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 10)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 18)
    tabsPadding.PaddingLeft = UDim.new(0, 10)
    tabsPadding.PaddingRight = UDim.new(0, 10)
    tabsPadding.PaddingBottom = UDim.new(0, 18)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -180, 1, -54)
    PagesHolder.Position = UDim2.new(0, 180, 0, 54)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Adaptive Sizing
    local function getViewport()
        Camera = Camera or Workspace.CurrentCamera
        if Camera and Camera.ViewportSize then return Camera.ViewportSize end
        return Vector2.new(1280, 720)
    end

    local function updateOuterSize()
        local vp = getViewport()
        local w = math.clamp(math.floor(vp.X * 0.6), 320, 1200)
        local h = math.clamp(math.floor(vp.Y * 0.6), 240, 900)
        if not selfObj._userResized then
            OuterFrame.Size = UDim2.new(0, w, 0, h)
        end
        OuterFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
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

    -- Smooth Dragging with Tween
    local dragging = false
    local dragInput, mousePos, framePos
    local dragTween

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = OuterFrame.Position
            if dragTween then dragTween:Cancel() end
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
            if dragTween then dragTween:Cancel() end
            dragTween = SugarUI.Tween(OuterFrame, {Position = newPos}, 0.1)
        end
    end)

    local resizeBtn = Instance.new("Frame")
    resizeBtn.Size = UDim2.new(0, 24, 0, 24)
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
            local newWidth = math.max(320, resizeFrameSize.X.Offset + delta.X)
            local newHeight = math.max(240, resizeFrameSize.Y.Offset + delta.Y)
            SugarUI.Tween(OuterFrame, {Size = UDim2.new(0, newWidth, 0, newHeight)}, 0.1)
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

    -- Mobile Buttons
    local mobileButtons = {}

    local function createMobileButton(name, sizeX, sizeY, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, sizeX, 0, sizeY)
        btn.Position = pos or UDim2.new(1, -160, 1, -120)
        btn.AnchorPoint = Vector2.new(0, 0)
        btn.BackgroundColor3 = SugarUI.Theme.Panel
        btn.Text = name
        btn.TextColor3 = SugarUI.Theme.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.ZIndex = 1001
        btn.Parent = ScreenGui
        SugarUI.RoundCorner(8).Parent = btn
        SugarUI.AddShadow(btn, 0.4, 8)
        return btn
    end

    if UserInputService.TouchEnabled then
        local toggleBtn = createMobileButton("GUI", 100, 50, UDim2.new(1, -160, 1, -120))
        mobileButtons.toggle = toggleBtn

        local function makeDraggable(btn, onTap)
            local draggingTouch = false
            local touchInput = nil
            local startPos = nil
            local startBtnPos = nil
            local moved = false
            local threshold = 10
            local btnTween

            local function onInputChanged(input)
                if not touchInput or input ~= touchInput then return end
                local delta = input.Position - startPos
                if math.abs(delta.X) > threshold or math.abs(delta.Y) > threshold then
                    moved = true
                    draggingTouch = true
                    local newX = startBtnPos.X.Offset + delta.X
                    local newY = startBtnPos.Y.Offset + delta.Y
                    local vp = getViewport()
                    newX = math.clamp(newX, 10, vp.X - btn.AbsoluteSize.X - 10)
                    newY = math.clamp(newY, 10, vp.Y - btn.AbsoluteSize.Y - 10)
                    if btnTween then btnTween:Cancel() end
                    btnTween = SugarUI.Tween(btn, {Position = UDim2.new(0, newX, 0, newY)}, 0.1)
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
                                newX = math.clamp(newX, 10, vp.X - btn.AbsoluteSize.X - 10)
                                newY = math.clamp(newY, 10, vp.Y - btn.AbsoluteSize.Y - 10)
                                if btnTween then btnTween:Cancel() end
                                btnTween = SugarUI.Tween(btn, {Position = UDim2.new(0, newX, 0, newY)}, 0.1)
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

    -- Enhanced Show/Hide Animations
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        SugarUI.Tween(Frame, {BackgroundTransparency = 0.05}, 0.3)
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5, -OuterFrame.Size.X.Offset/2, 0.5, -OuterFrame.Size.Y.Offset/2)}, 0.3)
        for _, child in ipairs(Frame:GetDescendants()) do
            if child:IsA("GuiObject") and child ~= Frame then
                SugarUI.Tween(child, {BackgroundTransparency = child.BackgroundTransparency - 0.05, TextTransparency = 0}, 0.3)
            end
        end
    end

    function selfObj:Hide()
        selfObj.Visible = false
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.3)
        for _, child in ipairs(Frame:GetDescendants()) do
            if child:IsA("GuiObject") and child ~= Frame then
                SugarUI.Tween(child, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
            end
        end
        task.delay(0.3, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
            Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 4, "Info")
        end)
    end

    task.defer(function() wait(0.05); selfObj:Show() end)

    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function() ScreenGui:Destroy() end, function() end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.4
        overlay.Parent = ScreenGui
        overlay.ZIndex = 999

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 320, 0, 160)
        panel.Position = UDim2.new(0.5, -160, 0.5, -80)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        panel.BackgroundTransparency = 0.1
        SugarUI.RoundCorner(12).Parent = panel
        SugarUI.AddGradient(panel)
        panel.Parent = overlay
        panel.ZIndex = 1000
        SugarUI.AddShadow(panel, 0.4, 10)

        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.7

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -24, 0, 32)
        titleLbl.Position = UDim2.new(0, 12, 0, 12)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 18
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = panel
        titleLbl.ZIndex = 1001

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -24, 0, 64)
        msgLbl.Position = UDim2.new(0, 12, 0, 48)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        msgLbl.Parent = panel
        msgLbl.ZIndex = 1001

        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.45, 0, 0, 36)
        yesBtn.Instance.Position = UDim2.new(0.05, 0, 1, -48)
        yesBtn.Instance.ZIndex = 1001

        local noBtn = ButtonComponent.new(panel, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.45, 0, 0, 36)
        noBtn.Instance.Position = UDim2.new(0.5, 0, 1, -48)
        noBtn.Instance.ZIndex = 1001
    end

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
        SugarUI.CurrentConfig["ToggleKey"] = key.Name
    end

    function selfObj:Notify(title, message, duration, type)
        return Notifications:Notify(title, message, duration, type)
    end

    function selfObj:ApplyConfig(config)
        if not config or type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local val = config[comp.key]
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
        if config["Theme"] and SugarUI.Themes[config["Theme"]] then
            SugarUI.CurrentTheme = config["Theme"]
            SugarUI.Theme = SugarUI.Themes[SugarUI.CurrentTheme]
            selfObj:UpdateTheme()
        end
        task.defer(function()
            pcall(function() selfObj:Notify("Info", "Configuration applied.", 3, "Info") end)
        end)
    end

    function selfObj:UpdateTheme()
        SugarUI.Theme = SugarUI.Themes[SugarUI.CurrentTheme]
        Frame.BackgroundColor3 = SugarUI.Theme.Background
        TopBar.BackgroundColor3 = SugarUI.Theme.Panel
        topStroke.Color = SugarUI.Theme.Border
        TitleLbl.TextColor3 = SugarUI.Theme.Text
        MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning
        MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
        CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
        CloseBtn.TextColor3 = SugarUI.Theme.Highlight
        Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
        sideStroke.Color = SugarUI.Theme.Border
        for _, tab in ipairs(selfObj.Tabs) do
            tab.button.TextColor3 = (tab.name == selfObj.ActiveTab) and SugarUI.Theme.Text or SugarUI.Theme.Muted
            tab.button.BackgroundColor3 = SugarUI.Theme.Button
            tab.indicator.BackgroundColor3 = SugarUI.Theme.Accent
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Border
            for _, comp in ipairs(tab.components) do
                if comp.obj.UpdateTheme then
                    comp

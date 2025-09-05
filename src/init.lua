-- init.lua (Sugar UI Ultimate: Complete redesign with animations, keybinds, configs, sliders, lists, multi-select, notifications)

local UILib = {}
UILib.__index = UILib

-- ======================
-- Modern Theme (Material-inspired with gradients)
-- ======================
local Theme = {
    Primary = Color3.fromRGB(33, 150, 243),  -- Blue
    PrimaryDark = Color3.fromRGB(25, 118, 210),
    Background = Color3.fromRGB(18, 18, 18),
    Surface = Color3.fromRGB(33, 33, 33),
    SurfaceVariant = Color3.fromRGB(48, 48, 48),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(189, 189, 189),
    Divider = Color3.fromRGB(66, 66, 66),
    Error = Color3.fromRGB(211, 47, 47),
    Success = Color3.fromRGB(76, 175, 80),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- ======================
-- Services
-- ======================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ======================
-- Tween Helper
-- ======================
local function Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Sine
    dir = dir or Enum.EasingDirection.InOut
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.25, style, dir), props)
    tween:Play()
    return tween
end

-- ======================
-- Shadow Helper
-- ======================
local function AddShadow(frame, depth)
    depth = depth or 1
    local shadow = Instance.new("UIStroke")
    shadow.Transparency = 0.6
    shadow.Color = Theme.Shadow
    shadow.Thickness = depth
    shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Parent = shadow
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Gradient Helper
-- ======================
local function AddGradient(frame, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 0
    gradient.Parent = frame
end

-- ======================
-- Ripple Effect Helper
-- ======================
local function CreateRipple(parent)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Theme.Text
    ripple.BackgroundTransparency = 0.7
    ripple.ZIndex = 10
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    ripple.Parent = parent
    return ripple
end

-- ======================
-- Button Component
-- ======================
local Button = {}
Button.__index = Button

function Button.new(parent, text, callback)
    local self = setmetatable({}, Button)
    self.Callback = callback or function() end

    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Surface
    frame.Text = text or "Button"
    frame.Font = Enum.Font.GothamMedium
    frame.TextSize = 14
    frame.TextColor3 = Theme.Text
    frame.AutoButtonColor = false
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local rippleHolder = Instance.new("Frame")
    rippleHolder.Size = UDim2.new(1, 0, 1, 0)
    rippleHolder.BackgroundTransparency = 1
    rippleHolder.ClipsDescendants = true
    rippleHolder.Parent = frame

    frame.MouseEnter:Connect(function()
        Tween(frame, {BackgroundColor3 = Theme.SurfaceVariant})
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, {BackgroundColor3 = Theme.Surface})
    end)
    frame.MouseButton1Down:Connect(function(x, y)
        local ripple = CreateRipple(rippleHolder)
        local absPos = frame.AbsolutePosition
        local absSize = frame.AbsoluteSize
        local mousePos = Vector2.new(x - absPos.X, y - absPos.Y)
        ripple.Position = UDim2.new(mousePos.X / absSize.X, 0, mousePos.Y / absSize.Y, 0)
        local size = math.max(absSize.X, absSize.Y) * 2
        Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
        task.delay(0.5, function() ripple:Destroy() end)
    end)
    frame.MouseButton1Click:Connect(function()
        self.Callback()
    end)

    self.Frame = frame
    return self
end

-- ======================
-- Toggle Component
-- ======================
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, text, default, callback)
    local self = setmetatable({}, Toggle)
    self.State = default or false
    self.Callback = callback or function(state) end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 48, 0, 24)
    toggleBg.Position = UDim2.new(1, -64, 0.5, -12)
    toggleBg.BackgroundColor3 = Theme.SurfaceVariant
    toggleBg.Parent = frame

    local toggleCorner = Instance.new("UICorner", toggleBg)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(self.State and 0.55 or 0.05, 0, 0.5, -10)
    knob.BackgroundColor3 = self.State and Theme.Primary or Theme.TextSecondary
    knob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    AddShadow(knob, 2)

    local function update()
        Tween(knob, {Position = UDim2.new(self.State and 0.55 or 0.05, 0, 0.5, -10)})
        Tween(knob, {BackgroundColor3 = self.State and Theme.Primary or Theme.TextSecondary})
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            update()
            self.Callback(self.State)
        end
    end)

    update()

    self.Frame = frame
    return self
end

function Toggle:Get() return self.State end
function Toggle:Set(state)
    self.State = state
    -- Update visual
end

-- ======================
-- Slider Component
-- ======================
local Slider = {}
Slider.__index = Slider

function Slider.new(parent, text, min, max, default, callback)
    local self = setmetatable({}, Slider)
    self.Min = min or 0
    self.Max = max or 100
    self.Value = default or min
    self.Callback = callback or function(value) end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 24)
    label.Position = UDim2.new(0, 16, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 64, 0, 24)
    valueLabel.Position = UDim2.new(1, -80, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(self.Value)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Theme.Text
    valueLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -32, 0, 8)
    sliderBg.Position = UDim2.new(0, 16, 0, 40)
    sliderBg.BackgroundColor3 = Theme.SurfaceVariant
    sliderBg.Parent = frame

    local sliderCorner = Instance.new("UICorner", sliderBg)
    sliderCorner.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, -8)
    knob.BackgroundColor3 = Theme.Primary
    knob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    AddShadow(knob, 2)

    local dragging = false

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouseX = UserInputService:GetMouseLocation().X
            local bgAbs = sliderBg.AbsolutePosition.X
            local bgSize = sliderBg.AbsoluteSize.X
            local pos = math.clamp((mouseX - bgAbs) / bgSize, 0, 1)
            self.Value = math.round(self.Min + pos * (self.Max - self.Min))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, 0, 0.5, -8)
            valueLabel.Text = tostring(self.Value)
            self.Callback(self.Value)
        end
    end)

    self.Frame = frame
    self.ValueLabel = valueLabel
    return self
end

function Slider:Get() return self.Value end
function Slider:Set(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    local pos = (self.Value - self.Min) / (self.Max - self.Min)
    self.Frame:FindFirstChild("Frame").Size = UDim2.new(pos, 0, 1, 0)  -- fill
    self.Frame:FindFirstChild("Frame"):FindFirstChild("Frame").Position = UDim2.new(pos, 0, 0.5, -8)  -- knob
    self.ValueLabel.Text = tostring(self.Value)
end

-- ======================
-- Dropdown (List) Component
-- ======================
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, text, options, default, callback)
    local self = setmetatable({}, Dropdown)
    self.Options = options or {}
    self.Selected = default or options[1]
    self.Callback = callback or function(selected) end
    self.Expanded = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. self.Selected
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 32, 1, 0)
    arrow.Position = UDim2.new(1, -48, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 14
    arrow.TextColor3 = Theme.Text
    arrow.Parent = frame

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = Theme.Surface
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.Visible = false
    listFrame.Parent = frame

    local listCorner = Instance.new("UICorner", listFrame)
    listCorner.CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    AddShadow(listFrame, 1)

    local function updateList()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #self.Options * 40)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(self.Options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Theme.Surface
            btn.Text = opt
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextColor3 = Theme.Text
            btn.AutoButtonColor = false
            btn.Parent = listFrame

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.SurfaceVariant})
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.Surface})
            end)
            btn.MouseButton1Click:Connect(function()
                self.Selected = opt
                label.Text = text .. ": " .. opt
                self:ToggleExpand()
                self.Callback(opt)
            end)
        end
    end

    function self:ToggleExpand()
        self.Expanded = not self.Expanded
        listFrame.Visible = self.Expanded
        Tween(listFrame, {Size = UDim2.new(1, 0, 0, self.Expanded and math.min(#self.Options * 40, 160) or 0)})
        Tween(arrow, {Rotation = self.Expanded and 180 or 0})
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleExpand()
        end
    end)

    updateList()

    self.Frame = frame
    self.Label = label
    return self
end

function Dropdown:Get() return self.Selected end
function Dropdown:Set(value)
    if table.find(self.Options, value) then
        self.Selected = value
        self.Label.Text = self.Label.Text:match("^(.-):") .. ": " .. value
    end
end

-- ======================
-- MultiSelect Dropdown
-- ======================
local MultiSelect = {}
MultiSelect.__index = MultiSelect

function MultiSelect.new(parent, text, options, defaults, callback)
    local self = setmetatable({}, MultiSelect)
    self.Options = options or {}
    self.Selected = defaults or {}
    self.Callback = callback or function(selected) end
    self.Expanded = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. table.concat(self.Selected, ", ")
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 32, 1, 0)
    arrow.Position = UDim2.new(1, -48, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 14
    arrow.TextColor3 = Theme.Text
    arrow.Parent = frame

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = Theme.Surface
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.Visible = false
    listFrame.Parent = frame

    local listCorner = Instance.new("UICorner", listFrame)
    listCorner.CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    AddShadow(listFrame, 1)

    local function updateList()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #self.Options * 40)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for _, opt in ipairs(self.Options) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, 0, 0, 40)
            item.BackgroundColor3 = Theme.Surface
            item.Parent = listFrame

            local check = Instance.new("TextLabel")
            check.Size = UDim2.new(0, 24, 1, 0)
            check.Position = UDim2.new(0, 8, 0, 0)
            check.BackgroundTransparency = 1
            check.Text = table.find(self.Selected, opt) and "✓" or ""
            check.Font = Enum.Font.GothamBold
            check.TextSize = 14
            check.TextColor3 = Theme.Primary
            check.Parent = item

            local optLabel = Instance.new("TextLabel")
            optLabel.Size = UDim2.new(1, -40, 1, 0)
            optLabel.Position = UDim2.new(0, 40, 0, 0)
            optLabel.BackgroundTransparency = 1
            optLabel.Text = opt
            optLabel.Font = Enum.Font.Gotham
            optLabel.TextSize = 14
            optLabel.TextColor3 = Theme.Text
            optLabel.Parent = item

            item.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if table.find(self.Selected, opt) then
                        table.remove(self.Selected, table.find(self.Selected, opt))
                    else
                        table.insert(self.Selected, opt)
                    end
                    check.Text = table.find(self.Selected, opt) and "✓" or ""
                    label.Text = text .. ": " .. table.concat(self.Selected, ", ")
                    self.Callback(self.Selected)
                end
            end)

            item.MouseEnter:Connect(function()
                Tween(item, {BackgroundColor3 = Theme.SurfaceVariant})
            end)
            item.MouseLeave:Connect(function()
                Tween(item, {BackgroundColor3 = Theme.Surface})
            end)
        end
    end

    function self:ToggleExpand()
        self.Expanded = not self.Expanded
        listFrame.Visible = self.Expanded
        Tween(listFrame, {Size = UDim2.new(1, 0, 0, self.Expanded and math.min(#self.Options * 40, 160) or 0)})
        Tween(arrow, {Rotation = self.Expanded and 180 or 0})
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleExpand()
        end
    end)

    updateList()

    self.Frame = frame
    self.Label = label
    return self
end

function MultiSelect:Get() return self.Selected end
function MultiSelect:Set(values)
    self.Selected = values
    self.Label.Text = self.Label.Text:match("^(.-):") .. ": " .. table.concat(values, ", ")
    -- Update checks
end

-- ======================
-- Section Component
-- ======================
local Section = {}
Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Theme.TextSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = Theme.Divider
    divider.Parent = frame

    self.Frame = frame
    return self
end

-- ======================
-- Notification System
-- ======================
local Notification = {}
Notification.__index = Notification

function Notification.new(screenGui, text, duration, color)
    local self = setmetatable({}, Notification)
    duration = duration or 3
    color = color or Theme.Success

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, 320, 1, -80)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = screenGui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 3)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.Parent = frame

    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Notification"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextWrapped = true
    label.Parent = frame

    -- Animate in
    Tween(frame, {Position = UDim2.new(1, -320, 1, -80)})

    task.delay(duration, function()
        Tween(frame, {Position = UDim2.new(1, 320, 1, -80)}, 0.3, Enum.EasingStyle.Quad)
        task.delay(0.3, function() frame:Destroy() end)
    end)

    return self
end

-- ======================
-- Keybind Component
-- ======================
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(parent, text, default, callback)
    local self = setmetatable({}, Keybind)
    self.Key = default or Enum.KeyCode.Insert
    self.Callback = callback or function(key) end
    self.Binding = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Surface
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    AddShadow(frame, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local keyLabel = Instance.new("TextButton")
    keyLabel.Size = UDim2.new(0, 80, 0, 32)
    keyLabel.Position = UDim2.new(1, -96, 0.5, -16)
    keyLabel.BackgroundColor3 = Theme.SurfaceVariant
    keyLabel.Text = self.Key.Name
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.TextSize = 14
    keyLabel.TextColor3 = Theme.Text
    keyLabel.AutoButtonColor = false
    keyLabel.Parent = frame

    local keyCorner = Instance.new("UICorner", keyLabel)
    keyCorner.CornerRadius = UDim.new(0, 6)

    keyLabel.MouseButton1Click:Connect(function()
        self.Binding = true
        keyLabel.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if self.Binding and input.KeyCode ~= Enum.KeyCode.Unknown then
            self.Key = input.KeyCode
            keyLabel.Text = self.Key.Name
            self.Binding = false
            self.Callback(self.Key)
        end
    end)

    self.Frame = frame
    self.KeyLabel = keyLabel
    return self
end

function Keybind:Get() return self.Key end
function Keybind:Set(key)
    self.Key = key
    self.KeyLabel.Text = key.Name
end

-- ======================
-- Tab Object
-- ======================
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Components = {}
    self.LayoutOrder = 0

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 15
    btn.TextColor3 = Theme.TextSecondary
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Position = UDim2.new(0, 24, 0, 0)
    btn.AutoButtonColor = false
    btn.Parent = window.Sidebar

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = Theme.Primary
    indicator.Visible = false
    indicator.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = window.PagesHolder

    local padding = Instance.new("UIPadding", page)
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        window:SwitchTab(name)
    end)

    function self:AddSection(title)
        self.LayoutOrder = self.LayoutOrder + 1
        local sec = Section.new(page, title)
        sec.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, sec)
        return sec
    end

    function self:AddButton(text, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local btn = Button.new(page, text, cb)
        btn.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, btn)
        return btn
    end

    function self:AddToggle(text, def, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local tog = Toggle.new(page, text, def, cb)
        tog.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, tog)
        return tog
    end

    function self:AddSlider(text, min, max, def, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local sld = Slider.new(page, text, min, max, def, cb)
        sld.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, sld)
        return sld
    end

    function self:AddDropdown(text, opts, def, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local dd = Dropdown.new(page, text, opts, def, cb)
        dd.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, dd)
        return dd
    end

    function self:AddMultiSelect(text, opts, defs, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local ms = MultiSelect.new(page, text, opts, defs, cb)
        ms.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, ms)
        return ms
    end

    function self:AddKeybind(text, def, cb)
        self.LayoutOrder = self.LayoutOrder + 1
        local kb = Keybind.new(page, text, def, cb)
        kb.Frame.LayoutOrder = self.LayoutOrder
        table.insert(self.Components, kb)
        return kb
    end

    self.Button = btn
    self.Indicator = indicator
    self.Page = page
    return self
end

-- ======================
-- Window
-- ======================
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    self.Title = title or "Sugar UI"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.Keybind = Enum.KeyCode.Insert
    self.Configs = {}  -- In-memory configs for testing
    self.Notifications = {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SugarUIUltimate"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    AddShadow(mainFrame, 4)
    AddGradient(mainFrame, Theme.Background, Theme.Surface, 90)

    -- Drag
    local dragging, dragInput, mousePos, framePos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 56)
    topBar.BackgroundColor3 = Theme.Surface
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner", topBar)
    topCorner.CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 24, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -48, 0.5, -20)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = topBar

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {TextColor3 = Theme.Error})
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {TextColor3 = Theme.TextSecondary})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, -56)
    sidebar.Position = UDim2.new(0, 0, 0, 56)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.Parent = mainFrame

    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local sidebarPadding = Instance.new("UIPadding", sidebar)
    sidebarPadding.PaddingTop = UDim.new(0, 16)
    sidebarPadding.PaddingLeft = UDim.new(0, 16)
    sidebarPadding.PaddingRight = UDim.new(0, 16)

    -- Pages Holder
    local pagesHolder = Instance.new("Frame")
    pagesHolder.Size = UDim2.new(1, -180, 1, -56)
    pagesHolder.Position = UDim2.new(0, 180, 0, 56)
    pagesHolder.BackgroundTransparency = 1
    pagesHolder.ClipsDescendants = true
    pagesHolder.Parent = mainFrame

    -- Notification Holder
    local notifHolder = Instance.new("Frame")
    notifHolder.Size = UDim2.new(1, 0, 1, 0)
    notifHolder.BackgroundTransparency = 1
    notifHolder.Parent = screenGui

    function self:AddTab(name)
        local tab = Tab.new(self, name)
        table.insert(self.Tabs, tab)
        if not self.ActiveTab then
            self:SwitchTab(name)
        end
        return tab
    end

    function self:SwitchTab(name)
        if self.ActiveTab == name then return end
        local oldTab = self:GetTab(self.ActiveTab)
        local newTab = self:GetTab(name)

        if oldTab then
            oldTab.Indicator.Visible = false
            oldTab.Button.TextColor3 = Theme.TextSecondary
            Tween(oldTab.Page, {CanvasPosition = Vector2.new(0, 0)})
            Tween(oldTab.Page, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function() oldTab.Page.Visible = false end)
        end

        if newTab then
            newTab.Page.Visible = true
            newTab.Page.BackgroundTransparency = 1
            Tween(newTab.Page, {BackgroundTransparency = 0}, 0.3)
            newTab.Indicator.Visible = true
            newTab.Button.TextColor3 = Theme.Text
            -- Slide animation
            newTab.Page.Position = UDim2.new(1, 0, 0, 0)
            Tween(newTab.Page, {Position = UDim2.new(0, 0, 0, 0)})
        end

        self.ActiveTab = name
    end

    function self:GetTab(name)
        for _, tab in ipairs(self.Tabs) do
            if tab.Name == name then return tab end
        end
        return nil
    end

    function self:ToggleVisibility()
        self.Visible = not self.Visible
        mainFrame.Visible = self.Visible
    end

    function self:SetKeybind(key)
        self.Keybind = key
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Keybind then
            self:ToggleVisibility()
        end
    end)

    function self:Notify(text, duration, color)
        Notification.new(notifHolder, text, duration, color)
    end

    -- Config Logic (In-memory for testing, serialize to JSON)
    function self:SaveConfig(name)
        local config = {}
        for _, tab in ipairs(self.Tabs) do
            config[tab.Name] = {}
            for _, comp in ipairs(tab.Components) do
                if comp.Get then
                    config[tab.Name][comp.Frame:FindFirstChild("TextLabel").Text] = comp:Get()
                end
            end
        end
        self.Configs[name] = config
        local json = HttpService:JSONEncode(config)
        print("Saved Config '" .. name .. "': " .. json)  -- For testing, print JSON
        self:Notify("Config '" .. name .. "' saved!")
        return json
    end

    function self:LoadConfig(name)
        local config = self.Configs[name]
        if not config then return end
        for tabName, tabConfig in pairs(config) do
            local tab = self:GetTab(tabName)
            if tab then
                for _, comp in ipairs(tab.Components) do
                    local key = comp.Frame:FindFirstChild("TextLabel").Text
                    if tabConfig[key] ~= nil and comp.Set then
                        comp:Set(tabConfig[key])
                    end
                end
            end
        end
        self:Notify("Config '" .. name .. "' loaded!")
    end

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Sidebar = sidebar
    self.PagesHolder = pagesHolder
    self.NotifHolder = notifHolder
    return self
end

function UILib:CreateWindow(title)
    return Window.new(title)
end

return UILib

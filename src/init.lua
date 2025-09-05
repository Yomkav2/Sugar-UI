-- init.lua (Sugar UI Ultimate Redesign: Modern Material-inspired, animations, keybinds, configs, new components, notifications)

local UILib = {}
UILib.__index = UILib

-- ======================
-- Modern Material Theme with gradients and depths
-- ======================
local Theme = {
    Primary = Color3.fromRGB(103, 58, 183),  -- Deep Purple
    PrimaryDark = Color3.fromRGB(69, 39, 160),
    PrimaryLight = Color3.fromRGB(126, 87, 194),
    Accent = Color3.fromRGB(255, 64, 129),   -- Pink Accent
    Background = Color3.fromRGB(18, 18, 18),
    Surface = Color3.fromRGB(33, 33, 33),
    SurfaceVariant = Color3.fromRGB(48, 48, 48),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(189, 189, 189),
    TextDisabled = Color3.fromRGB(117, 117, 117),
    Divider = Color3.fromRGB(66, 66, 66),
    Shadow = Color3.fromRGB(0, 0, 0),
    Error = Color3.fromRGB(211, 47, 47),
    Success = Color3.fromRGB(46, 125, 50),
}

-- ======================
-- Tween Helper with Cubic easing for smoothness
-- ======================
local TweenService = game:GetService("TweenService")
local function TweenInstance(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Cubic
    dir = dir or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

-- ======================
-- Shadow Helper with blur effect simulation
-- ======================
local function AddShadow(frame, depth)
    depth = depth or 4
    local shadow = Instance.new("UIStroke")
    shadow.Transparency = 0.6
    shadow.Color = Theme.Shadow
    shadow.Thickness = depth / 2
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
-- Ripple Effect Helper
-- ======================
local function CreateRipple(parent, color)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = color or Theme.Accent
    ripple.BackgroundTransparency = 0.7
    ripple.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    return ripple
end

-- ======================
-- Notification System
-- ======================
local NotificationManager = {}
do
    local notifications = {}
    local screenGui

    function NotificationManager.Init(gui)
        screenGui = gui
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, 300, 1, 0)
        holder.Position = UDim2.new(1, -320, 0, 0)
        holder.BackgroundTransparency = 1
        holder.Parent = screenGui
        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
        list.Padding = UDim.new(0, 8)
        list.Parent = holder
        NotificationManager.Holder = holder
    end

    function NotificationManager.Notify(title, desc, duration, callback)
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 80)
        notif.BackgroundColor3 = Theme.Surface
        notif.BorderSizePixel = 0
        notif.LayoutOrder = #notifications + 1
        notif.Parent = NotificationManager.Holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notif

        AddShadow(notif, 6)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -16, 0, 24)
        titleLabel.Position = UDim2.new(0, 8, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title or "Notification"
        titleLabel.TextColor3 = Theme.TextPrimary
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notif

        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -16, 0, 40)
        descLabel.Position = UDim2.new(0, 8, 0, 32)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc or ""
        descLabel.TextColor3 = Theme.TextSecondary
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 14
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = notif

        notif.Position = UDim2.new(1, 0, 0, 0)  -- Start off-screen
        TweenInstance(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

        table.insert(notifications, notif)

        task.delay(duration or 5, function()
            if notif then
                TweenInstance(notif, {Position = UDim2.new(1, 0, 0, 0)}, 0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
                task.delay(0.4, function() notif:Destroy() end)
                table.remove(notifications, table.find(notifications, notif))
                if callback then pcall(callback) end
            end
        end)

        return notif
    end
end

-- ======================
-- Button Component (Material style with elevation)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Primary
    frame.Text = text or "Button"
    frame.TextColor3 = Theme.TextPrimary
    frame.Font = Enum.Font.GothamSemibold
    frame.TextSize = 16
    frame.BorderSizePixel = 0
    frame.AutoButtonColor = false
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)  -- Pill shape
    corner.Parent = frame

    AddShadow(frame, 2)

    local rippleHolder = Instance.new("Frame")
    rippleHolder.Size = UDim2.new(1, 0, 1, 0)
    rippleHolder.BackgroundTransparency = 1
    rippleHolder.ClipsDescendants = true
    rippleHolder.Parent = frame

    frame.MouseEnter:Connect(function()
        TweenInstance(frame, {BackgroundColor3 = Theme.PrimaryLight}, 0.2)
    end)
    frame.MouseLeave:Connect(function()
        TweenInstance(frame, {BackgroundColor3 = Theme.Primary}, 0.2)
    end)
    frame.MouseButton1Down:Connect(function(x, y)
        local ripple = CreateRipple(rippleHolder, Theme.TextPrimary)
        ripple.Position = UDim2.new(0, x - frame.AbsolutePosition.X, 0, y - frame.AbsolutePosition.Y)
        TweenInstance(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.5)
        task.delay(0.5, function() ripple:Destroy() end)
    end)
    frame.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    self.Frame = frame
    return self
end

function ButtonComponent:SetText(text)
    self.Frame.Text = text
end

-- ======================
-- Toggle Component (Material switch)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback)
    local self = setmetatable({}, ToggleComponent)
    local state = default or false

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 56)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 52, 0, 32)
    switch.Position = UDim2.new(1, -52, 0.5, -16)
    switch.BackgroundColor3 = state and Theme.Primary or Theme.Divider
    switch.Parent = wrapper

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 28, 0, 28)
    thumb.Position = UDim2.new(state and 0.5 or 0, 2, 0.5, -14)
    thumb.BackgroundColor3 = Theme.TextPrimary
    thumb.Parent = switch

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    AddShadow(thumb, 3)

    local function setState(newState, fireCallback)
        state = newState
        TweenInstance(thumb, {Position = UDim2.new(state and 0.5 or 0, 2, 0.5, -14)}, 0.2)
        TweenInstance(switch, {BackgroundColor3 = state and Theme.Primary or Theme.Divider}, 0.2)
        if fireCallback and callback then pcall(callback, state) end
    end

    wrapper.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state, true)
        end
    end)

    self.Set = setState
    self.Get = function() return state end
    self.Wrapper = wrapper
    setState(state, false)
    return self
end

-- ======================
-- Slider Component
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback)
    local self = setmetatable({}, SliderComponent)
    local value = default or min

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 72)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 24)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Theme.TextSecondary
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = wrapper

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 40)
    track.BackgroundColor3 = Theme.Divider
    track.Parent = wrapper

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new((value - min) / (max - min), -8, 0, -6)
    thumb.BackgroundColor3 = Theme.Primary
    thumb.Parent = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    AddShadow(thumb, 4)

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = min + relativeX * (max - min)
            value = math.round(value)  -- Assuming integer values
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            thumb.Position = UDim2.new(relativeX, -8, 0, -6)
            valueLabel.Text = tostring(value)
            if callback then pcall(callback, value) end
        end
    end)

    self.Set = function(newValue)
        newValue = math.clamp(newValue, min, max)
        local relative = (newValue - min) / (max - min)
        TweenInstance(fill, {Size = UDim2.new(relative, 0, 1, 0)}, 0.2)
        TweenInstance(thumb, {Position = UDim2.new(relative, -8, 0, -6)}, 0.2)
        valueLabel.Text = tostring(newValue)
        value = newValue
    end
    self.Get = function() return value end
    self.Wrapper = wrapper
    return self
end

-- ======================
-- Dropdown Component (Single Select List)
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent

function DropdownComponent.new(parent, text, options, default, callback)
    local self = setmetatable({}, DropdownComponent)
    local selected = default or options[1]

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 48)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Theme.Surface
    button.Text = selected
    button.TextColor3 = Theme.TextPrimary
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextWrapped = true
    button.Parent = wrapper

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    AddShadow(button, 2)

    local expanded = false
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 4)
    listFrame.BackgroundColor3 = Theme.Surface
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 40)
    listFrame.Visible = false
    listFrame.Parent = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listFrame

    AddShadow(listFrame, 4)

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = listFrame

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 40)
        optBtn.BackgroundColor3 = Theme.Surface
        optBtn.Text = opt
        optBtn.TextColor3 = Theme.TextPrimary
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 16
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.Parent = listFrame

        local optPadding = Instance.new("UIPadding")
        optPadding.PaddingLeft = UDim.new(0, 12)
        optPadding.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            TweenInstance(optBtn, {BackgroundColor3 = Theme.SurfaceVariant}, 0.2)
        end)
        optBtn.MouseLeave:Connect(function()
            TweenInstance(optBtn, {BackgroundColor3 = Theme.Surface}, 0.2)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            button.Text = opt
            expanded = false
            listFrame.Visible = false
            TweenInstance(wrapper, {Size = UDim2.new(1, 0, 0, 48)}, 0.3)
            if callback then pcall(callback, selected) end
        end)
    end

    button.MouseButton1Click:Connect(function()
        expanded = not expanded
        listFrame.Visible = expanded
        TweenInstance(wrapper, {Size = UDim2.new(1, 0, 0, expanded and 48 + math.min(#options * 40, 200) or 48)}, 0.3)
    end)

    self.Set = function(newSelected)
        if table.find(options, newSelected) then
            selected = newSelected
            button.Text = newSelected
        end
    end
    self.Get = function() return selected end
    self.Wrapper = wrapper
    return self
end

-- ======================
-- MultiSelect Component
-- ======================
local MultiSelectComponent = {}
MultiSelectComponent.__index = MultiSelectComponent

function MultiSelectComponent.new(parent, text, options, defaults, callback)
    local self = setmetatable({}, MultiSelectComponent)
    local selected = defaults or {}

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 48)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Theme.Surface
    button.Text = #selected > 0 and table.concat(selected, ", ") or "Select options"
    button.TextColor3 = Theme.TextPrimary
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextWrapped = true
    button.Parent = wrapper

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    AddShadow(button, 2)

    local expanded = false
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 4)
    listFrame.BackgroundColor3 = Theme.Surface
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 40)
    listFrame.Visible = false
    listFrame.Parent = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listFrame

    AddShadow(listFrame, 4)

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = listFrame

    local optionToggles = {}
    for _, opt in ipairs(options) do
        local optWrapper = Instance.new("Frame")
        optWrapper.Size = UDim2.new(1, 0, 0, 40)
        optWrapper.BackgroundTransparency = 1
        optWrapper.Parent = listFrame

        local optLabel = Instance.new("TextLabel")
        optLabel.Size = UDim2.new(0.8, 0, 1, 0)
        optLabel.BackgroundTransparency = 1
        optLabel.Text = opt
        optLabel.TextColor3 = Theme.TextPrimary
        optLabel.Font = Enum.Font.Gotham
        optLabel.TextSize = 16
        optLabel.TextXAlignment = Enum.TextXAlignment.Left
        optLabel.Parent = optWrapper

        local check = Instance.new("Frame")
        check.Size = UDim2.new(0, 24, 0, 24)
        check.Position = UDim2.new(1, -36, 0.5, -12)
        check.BackgroundColor3 = table.find(selected, opt) and Theme.Primary or Theme.Divider
        check.Parent = optWrapper

        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 4)
        checkCorner.Parent = check

        optWrapper.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if table.find(selected, opt) then
                    table.remove(selected, table.find(selected, opt))
                else
                    table.insert(selected, opt)
                end
                check.BackgroundColor3 = table.find(selected, opt) and Theme.Primary or Theme.Divider
                button.Text = #selected > 0 and table.concat(selected, ", ") or "Select options"
                if callback then pcall(callback, selected) end
            end
        end)

        optionToggles[opt] = check
    end

    button.MouseButton1Click:Connect(function()
        expanded = not expanded
        listFrame.Visible = expanded
        TweenInstance(wrapper, {Size = UDim2.new(1, 0, 0, expanded and 48 + math.min(#options * 40, 200) or 48)}, 0.3)
    end)

    self.Set = function(newSelected)
        selected = newSelected
        for opt, check in pairs(optionToggles) do
            check.BackgroundColor3 = table.find(selected, opt) and Theme.Primary or Theme.Divider
        end
        button.Text = #selected > 0 and table.concat(selected, ", ") or "Select options"
    end
    self.Get = function() return selected end
    self.Wrapper = wrapper
    return self
end

-- ======================
-- Section Component
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = Theme.TextSecondary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, 4)
    divider.BackgroundColor3 = Theme.Divider
    divider.BorderSizePixel = 0
    divider.Parent = frame

    self.Frame = frame
    return self
end

-- ======================
-- Window Class
-- ======================
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Config = {}  -- Simulated config table
    self.Keybind = Enum.KeyCode.RightShift  -- Default keybind
    self.Visible = true

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUIUltimate"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui end

    NotificationManager.Init(ScreenGui)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame

    AddShadow(MainFrame, 8)

    -- Drag functionality
    local dragging, dragInput, startPos, startMouse
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = MainFrame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.BackgroundColor3 = Theme.Surface
    TopBar.Parent = MainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 24, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Sugar UI Ultimate"
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -48, 0.5, -20)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Theme.TextSecondary
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 24
    CloseButton.Parent = TopBar

    CloseButton.MouseEnter:Connect(function()
        TweenInstance(CloseButton, {TextColor3 = Theme.Error}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenInstance(CloseButton, {TextColor3 = Theme.TextSecondary}, 0.2)
    end)
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab Bar (Horizontal tabs for modern look)
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 48)
    TabBar.Position = UDim2.new(0, 0, 0, 56)
    TabBar.BackgroundColor3 = Theme.Surface
    TabBar.Parent = MainFrame

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 8)
    tabList.VerticalAlignment = Enum.VerticalAlignment.Center
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabList.Parent = TabBar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 16)
    tabPadding.Parent = TabBar

    -- Pages Holder
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, 0, 1, -104)
    Pages.Position = UDim2.new(0, 0, 0, 104)
    Pages.BackgroundTransparency = 1
    Pages.ClipsDescendants = true
    Pages.Parent = MainFrame

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.TabBar = TabBar
    self.Pages = Pages
    self.Notify = NotificationManager.Notify

    -- Keybind toggle
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.Keybind then
            self.Visible = not self.Visible
            MainFrame.Visible = self.Visible
        end
    end)

    -- Config methods (simulated with table, print for "save/load")
    function self:SaveConfig()
        print("Saving config:", self.Config)  -- In real env, serialize to file
        NotificationManager.Notify("Config Saved", "Configuration has been saved.", 3)
    end

    function self:LoadConfig()
        -- Simulate loading
        for name, val in pairs(self.Config) do
            print("Loading", name, val)
        end
        NotificationManager.Notify("Config Loaded", "Configuration has been loaded.", 3)
    end

    -- Set Keybind method
    function self:SetKeybind(key)
        self.Keybind = key
        NotificationManager.Notify("Keybind Changed", "New keybind: " .. key.Name, 3)
    end

    return self
end

function Window:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextSecondary
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 16
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabBar

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(1, 0, 0, 2)
    indicator.Position = UDim2.new(0, 0, 1, -2)
    indicator.BackgroundColor3 = Theme.Primary
    indicator.Visible = false
    indicator.Parent = tabButton

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -32, 1, -32)
    page.Position = UDim2.new(0, 16, 0, 16)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Divider
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self.Pages

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page

    tab.Page = page
    tab.Button = tabButton
    tab.Indicator = indicator

    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Indicator.Visible = false
            TweenInstance(t.Button, {TextColor3 = Theme.TextSecondary}, 0.2)
        end
        page.Visible = true
        indicator.Visible = true
        TweenInstance(tabButton, {TextColor3 = Theme.TextPrimary}, 0.2)
        -- Tab switch animation
        page.Transparency = 1
        TweenInstance(page, {Transparency = 0}, 0.4)
        self.ActiveTab = tab
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        tabButton.TextColor3 = Theme.TextPrimary
        indicator.Visible = true
        page.Visible = true
        page.Transparency = 0
        self.ActiveTab = tab
    end

    -- Add components to tab
    function tab:AddSection(title)
        local sec = SectionComponent.new(page, title)
        return sec
    end

    function tab:AddButton(text, callback)
        local btn = ButtonComponent.new(page, text, callback)
        return btn
    end

    function tab:AddToggle(text, default, callback)
        local tog = ToggleComponent.new(page, text, default, callback)
        self.Config[text] = tog.Get()  -- Add to config
        return tog
    end

    function tab:AddSlider(text, min, max, default, callback)
        local slider = SliderComponent.new(page, text, min, max, default, callback)
        self.Config[text] = slider.Get()
        return slider
    end

    function tab:AddDropdown(text, options, default, callback)
        local drop = DropdownComponent.new(page, text, options, default, callback)
        self.Config[text] = drop.Get()
        return drop
    end

    function tab:AddMultiSelect(text, options, defaults, callback)
        local multi = MultiSelectComponent.new(page, text, options, defaults, callback)
        self.Config[text] = multi.Get()
        return multi
    end

    return tab
end

function UILib:CreateWindow(title)
    return Window.new(title)
end

return UILib

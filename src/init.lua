-- init.lua (Sugar UI - Fixed & Enhanced)
-- Полная версия, синтаксически исправлена (все функции закрыты)
-- Включает: Preset themes, Button, Toggle, Slider, Dropdown (multi), Section,
-- Notifications, TextBox, Keybind, ColorPicker (RGB sliders + HEX), Image, Window, CreateWindow
-- Лёгкий, современный минималистичный стиль и плавные анимации.

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
-- Preset Themes
-- ======================
SugarUI.Presets = {
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
        ToggleBox = Color3.fromRGB(200,200,200),
        Button = Color3.fromRGB(30,30,30),
        ButtonHover = Color3.fromRGB(50,50,50),
    },
    Amethyst = {
        Background = Color3.fromRGB(16, 10, 28),
        Panel = Color3.fromRGB(26, 18, 42),
        Accent = Color3.fromRGB(153, 102, 204),
        AccentSoft = Color3.fromRGB(170, 140, 210),
        AccentDark = Color3.fromRGB(90, 60, 120),
        Text = Color3.fromRGB(240, 240, 250),
        Muted = Color3.fromRGB(160, 150, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(48, 40, 60),
        Highlight = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        ToggleBox = Color3.fromRGB(200,200,200),
        Button = Color3.fromRGB(24,18,36),
        ButtonHover = Color3.fromRGB(42,35,60),
    },
    White = {
        Background = Color3.fromRGB(245,245,245),
        Panel = Color3.fromRGB(230,230,230),
        Accent = Color3.fromRGB(40,120,200),
        AccentSoft = Color3.fromRGB(80,140,220),
        AccentDark = Color3.fromRGB(10,70,140),
        Text = Color3.fromRGB(18,18,18),
        Muted = Color3.fromRGB(100,100,100),
        Shadow = Color3.fromRGB(0,0,0),
        Border = Color3.fromRGB(200,200,200),
        Highlight = Color3.fromRGB(255,255,255),
        Success = Color3.fromRGB(76,175,80),
        Warning = Color3.fromRGB(255,193,7),
        Error = Color3.fromRGB(244,67,54),
        ToggleBox = Color3.fromRGB(40,40,40),
        Button = Color3.fromRGB(245,245,245),
        ButtonHover = Color3.fromRGB(230,230,230),
    }
}

-- Default theme copy
SugarUI.Theme = {}
for k,v in pairs(SugarUI.Presets.Dark) do SugarUI.Theme[k] = v end

-- Apply preset
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
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, dir)
    local ok, t = pcall(function() return TweenService:Create(instance, info, props) end)
    if ok and t then
        pcall(function() t:Play() end)
        return t
    end
    return nil
end

function SugarUI.AddShadow(frame, transparency, size)
    local img = Instance.new("ImageLabel")
    img.Name = "Shadow"
    img.Size = UDim2.new(1, (size or 12), 1, (size or 12))
    img.Position = UDim2.new(0, -((size or 12)/2), 0, -((size or 12)/2))
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://5554236805"
    img.ImageColor3 = SugarUI.Theme.Shadow
    img.ImageTransparency = transparency or 0.8
    img.ScaleType = Enum.ScaleType.Slice
    img.SliceCenter = Rect.new(10,10,118,118)
    img.Parent = frame
    return img
end

-- find parent ScreenGui for modal components
local function findScreenGui(inst)
    local cur = inst
    while cur and not cur:IsA("ScreenGui") do
        cur = cur.Parent
    end
    return cur
end

-- ======================
-- Button Component
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent
function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = SugarUI.Theme.Button
    btn.Text = text or "Button"
    btn.TextColor3 = SugarUI.Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent
    SugarUI.RoundCorner(10).Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    stroke.Parent = btn
    btn.MouseEnter:Connect(function() SugarUI.Tween(btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    btn.MouseLeave:Connect(function() SugarUI.Tween(btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.12) end)
    btn.MouseButton1Click:Connect(function()
        local ok, _ = pcall(function()
            local ripple = Instance.new("ImageLabel")
            ripple.Size = UDim2.new(0,12,0,12)
            ripple.Position = UDim2.new(0.5,0,0.5,0)
            ripple.AnchorPoint = Vector2.new(0.5,0.5)
            ripple.BackgroundTransparency = 1
            ripple.Image = "rbxassetid://7663593618"
            ripple.ImageColor3 = SugarUI.Theme.Highlight
            ripple.Parent = btn
            SugarUI.Tween(ripple, {Size = UDim2.new(2.4,0,2.4,0), ImageTransparency = 1}, 0.36)
            task.delay(0.36, function() if ripple and ripple.Parent then ripple:Destroy() end end)
        end)
        pcall(function() if callback then callback() end end)
    end)
    function self:UpdateTheme()
        btn.BackgroundColor3 = SugarUI.Theme.Button
        btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = btn
    return self
end

-- ======================
-- Toggle Component
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent
function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default and true or false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = frame
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.75,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("Frame", frame)
    box.Size = UDim2.new(0,26,0,26)
    box.Position = UDim2.new(1, -38, 0.5, -13)
    box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
    SugarUI.RoundCorner(8).Parent = box
    local check = Instance.new("ImageLabel", box)
    check.Size = UDim2.new(1,0,1,0)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://6031094667"
    check.ImageColor3 = SugarUI.Theme.Highlight
    check.Visible = self.State
    SugarUI.AddShadow(box, 0.6, 6)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(box, {BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox}, 0.15)
            SugarUI.Tween(check, {ImageTransparency = self.State and 0 or 1}, 0.15)
            check.Visible = true
            task.delay(0.15, function() if not self.State then check.Visible = false end end)
            if callback then pcall(callback, self.State) end
            if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = self.State end
        end
    end)
    function self:Set(v, fire)
        self.State = not not v
        box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        check.Visible = self.State
        if fire and callback then pcall(callback, self.State) end
        if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = self.State end
    end
    function self:Get() return self.State end
    function self:UpdateTheme()
        frame.BackgroundColor3 = SugarUI.Theme.Panel
        label.TextColor3 = SugarUI.Theme.Text
        box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or SugarUI.Theme.ToggleBox
        check.ImageColor3 = SugarUI.Theme.Highlight
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
end

-- ======================
-- Slider Component
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent
function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    min = min or 0
    max = max or 100
    local value = tonumber(default) or min
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 54)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = frame
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7,0,0,20)
    label.Position = UDim2.new(0,12,0,8)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    local valueLbl = Instance.new("TextLabel", frame)
    valueLbl.Size = UDim2.new(0.3,-12,0,20)
    valueLbl.Position = UDim2.new(0.7,0,0,8)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(math.floor(value))
    valueLbl.TextColor3 = SugarUI.Theme.Muted
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = 14
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0,12,0,34)
    track.BackgroundColor3 = Color3.fromRGB(60,60,60)
    SugarUI.RoundCorner(4).Parent = track
    local fill = Instance.new("Frame", track)
    local ratio = 0
    if max - min ~= 0 then ratio = (value - min) / (max - min) end
    fill.Size = UDim2.new(ratio,0,1,0)
    fill.BackgroundColor3 = SugarUI.Theme.Accent
    SugarUI.RoundCorner(4).Parent = fill
    local handle = Instance.new("Frame", track)
    handle.Size = UDim2.new(0,16,0,16)
    handle.Position = UDim2.new(ratio, -8, 0.5, -8)
    handle.BackgroundColor3 = SugarUI.Theme.Highlight
    SugarUI.RoundCorner(8).Parent = handle
    local dragging = false
    local function set_value(newValue, fire)
        newValue = tonumber(newValue) or newValue
        if type(newValue) ~= "number" then return end
        newValue = math.clamp(newValue, min, max)
        value = newValue
        valueLbl.Text = tostring(math.floor(value))
        local f = 0
        if max - min ~= 0 then f = (value - min) / (max - min) end
        SugarUI.Tween(fill, {Size = UDim2.new(f,0,1,0)}, 0.12)
        SugarUI.Tween(handle, {Position = UDim2.new(f, -8, 0.5, -8)}, 0.12)
        if fire and callback then pcall(callback, value) end
        if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = value end
    end
    local function update_from_input(input)
        local posX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local newValue = min + (posX / track.AbsoluteSize.X) * (max - min)
        set_value(newValue, true)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update_from_input(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update_from_input(input) end
    end)
    function self:GetValue() return value end
    function self:SetValue(v, fire) set_value(v, fire) end
    function self:UpdateTheme()
        frame.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
        label.TextColor3 = SugarUI.Theme.Text
        valueLbl.TextColor3 = SugarUI.Theme.Muted
        fill.BackgroundColor3 = SugarUI.Theme.Accent
        handle.BackgroundColor3 = SugarUI.Theme.Highlight
    end
    self.Instance = frame
    return self
end

-- ======================
-- Dropdown Component (supports multiSelect)
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent
function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    options = options or {}
    multiSelect = multiSelect or false
    local selected = multiSelect and (default or {}) or (default or options[1] or "None")
    local isOpen = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = SugarUI.Theme.Button
    frame.Parent = parent
    SugarUI.RoundCorner(10).Parent = frame
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0.3, -12, 1, 0)
    valueLabel.Position = UDim2.new(0.7, -6, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = multiSelect and "None" or tostring(selected)
    valueLabel.TextColor3 = SugarUI.Theme.Muted
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local headerBtn = Instance.new("TextButton", frame)
    headerBtn.Size = UDim2.new(1,0,0,40)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = false
    local optionsFrame = Instance.new("ScrollingFrame", frame)
    optionsFrame.Position = UDim2.new(0,0,0,40)
    optionsFrame.Size = UDim2.new(1,0,0,0)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    optionsFrame.ScrollBarImageTransparency = 0.5
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ClipsDescendants = true
    local list = Instance.new("UIListLayout", optionsFrame)
    list.Padding = UDim.new(0,4)
    local optionObjects = {}
    local function update_value_display()
        if multiSelect then
            local cnt = #selected
            if cnt == 0 then valueLabel.Text = "None"
            elseif cnt <= 2 then valueLabel.Text = table.concat(selected, ", ")
            else valueLabel.Text = selected[1] .. ", " .. selected[2] .. " + " .. (cnt - 2) end
        else
            valueLabel.Text = tostring(selected)
        end
    end
    local function apply_config()
        if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = (multiSelect and selected) or selected end
    end
    local function toggle_option(opt)
        if multiSelect then
            local idx = table.find(selected, opt)
            if idx then table.remove(selected, idx) else table.insert(selected, opt) end
        else
            selected = opt
            isOpen = false
            SugarUI.Tween(optionsFrame, {Size = UDim2.new(1,0,0,0)}, 0.14)
            SugarUI.Tween(frame, {Size = UDim2.new(1, -10, 0, 40)}, 0.14)
            task.delay(0.15, function() optionsFrame.ZIndex = 60 end)
        end
        update_value_display()
        if callback then pcall(callback, multiSelect and selected or opt) end
        apply_config()
    end
    local function rebuild_options()
        for _, c in ipairs(optionsFrame:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("ImageLabel") then pcall(function() c:Destroy() end) end
        end
        optionObjects = {}
        local order = 1
        if multiSelect then
            local control = Instance.new("Frame", optionsFrame)
            control.Size = UDim2.new(1,0,0,38)
            control.BackgroundTransparency = 1
            control.LayoutOrder = order; order = order + 1
            local sel = Instance.new("TextButton", control)
            sel.Size = UDim2.new(0.48, -4, 1,0)
            sel.BackgroundColor3 = SugarUI.Theme.Button
            sel.Text = "Select All"
            sel.TextColor3 = SugarUI.Theme.Text
            sel.Font = Enum.Font.Gotham
            sel.TextSize = 14
            sel.AutoButtonColor = false
            SugarUI.RoundCorner(6).Parent = sel
            local clr = Instance.new("TextButton", control)
            clr.Size = UDim2.new(0.48, -4, 1,0)
            clr.Position = UDim2.new(0.52, 0, 0,0)
            clr.BackgroundColor3 = SugarUI.Theme.Button
            clr.Text = "Clear"
            clr.TextColor3 = SugarUI.Theme.Text
            clr.Font = Enum.Font.Gotham
            clr.TextSize = 14
            clr.AutoButtonColor = false
            SugarUI.RoundCorner(6).Parent = clr
            sel.MouseButton1Click:Connect(function()
                selected = {}
                for _, v in ipairs(options) do table.insert(selected, v) end
                update_value_display()
                apply_config()
                for _, o in ipairs(optionObjects) do if o.check then o.check.BackgroundColor3 = SugarUI.Theme.Accent; if o.icon then o.icon.Visible = true end end end
            end)
            clr.MouseButton1Click:Connect(function()
                selected = {}
                update_value_display()
                apply_config()
                for _, o in ipairs(optionObjects) do if o.check then o.check.BackgroundColor3 = SugarUI.Theme.Panel; if o.icon then o.icon.Visible = false end end end
            end)
        end
        for i,opt in ipairs(options) do
            local of = Instance.new("Frame", optionsFrame)
            of.Size = UDim2.new(1,0,0,34)
            of.BackgroundTransparency = 1
            of.LayoutOrder = order; order = order + 1
            local btn = Instance.new("TextButton", of)
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundColor3 = SugarUI.Theme.Panel
            btn.Text = tostring(opt)
            btn.TextColor3 = SugarUI.Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            SugarUI.RoundCorner(8).Parent = btn
            local pad = Instance.new("UIPadding", btn)
            pad.PaddingLeft = UDim.new(0,8)
            local stroke2 = Instance.new("UIStroke", btn)
            stroke2.Color = SugarUI.Theme.Border
            stroke2.Transparency = 0.9
            stroke2.Thickness = 1
            if multiSelect then
                local check = Instance.new("Frame", btn)
                check.Size = UDim2.new(0,20,0,20)
                check.Position = UDim2.new(1,-26,0.5,-10)
                check.BackgroundColor3 = table.find(selected, opt) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                SugarUI.RoundCorner(6).Parent = check
                local icon = Instance.new("ImageLabel", check)
                icon.Size = UDim2.new(1,0,1,0)
                icon.BackgroundTransparency = 1
                icon.Image = "rbxassetid://6031094667"
                icon.ImageColor3 = SugarUI.Theme.Highlight
                icon.Visible = table.find(selected, opt) ~= nil
                btn.MouseButton1Click:Connect(function()
                    toggle_option(opt)
                    check.BackgroundColor3 = table.find(selected, opt) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                    icon.Visible = table.find(selected, opt) ~= nil
                end)
                optionObjects[#optionObjects+1] = {btn = btn, check = check, icon = icon, stroke = stroke2}
            else
                btn.BackgroundColor3 = (selected == opt) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel
                btn.MouseButton1Click:Connect(function()
                    toggle_option(opt)
                    for _, o in ipairs(optionObjects) do
                        SugarUI.Tween(o.btn, {BackgroundColor3 = (selected == o.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
                    end
                end)
                optionObjects[#optionObjects+1] = {btn = btn, stroke = stroke2}
            end
            btn.MouseEnter:Connect(function() SugarUI.Tween(btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.09) end)
            btn.MouseLeave:Connect(function()
                local target = (multiSelect and SugarUI.Theme.Panel) or ((selected == opt) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel)
                SugarUI.Tween(btn, {BackgroundColor3 = target}, 0.09)
            end)
        end
    end
    rebuild_options()
    update_value_display()
    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            label.Visible = false
            valueLabel.Visible = false
            local height = math.min((#options * 34 + (multiSelect and 38 or 0) + 8), 220)
            SugarUI.Tween(optionsFrame, {Size = UDim2.new(1,0,0,height)}, 0.18)
            SugarUI.Tween(frame, {Size = UDim2.new(1, -10, 0, 40 + height)}, 0.18)
            optionsFrame.ZIndex = 1000
        else
            label.Visible = true
            valueLabel.Visible = true
            SugarUI.Tween(optionsFrame, {Size = UDim2.new(1,0,0,0)}, 0.18)
            SugarUI.Tween(frame, {Size = UDim2.new(1,-10,0,40)}, 0.18)
            task.delay(0.2, function() optionsFrame.ZIndex = 60 end)
        end
    end)
    function self:GetValue() return selected end
    function self:SetValue(v)
        if multiSelect then selected = v or {} else selected = v or options[1] or "None" end
        update_value_display()
        for _,o in ipairs(optionObjects) do
            if o.check then
                o.check.BackgroundColor3 = table.find(selected, o.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                if o.icon then o.icon.Visible = table.find(selected, o.btn.Text) ~= nil end
            else
                SugarUI.Tween(o.btn, {BackgroundColor3 = (selected == o.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
            end
        end
        apply_config()
    end
    function self:UpdateOptions(newOptions)
        options = newOptions or {}
        rebuild_options()
        update_value_display()
        apply_config()
    end
    function self:IsOpen() return isOpen end
    function self:UpdateTheme()
        frame.BackgroundColor3 = SugarUI.Theme.Button
        stroke.Color = SugarUI.Theme.Border
        label.TextColor3 = SugarUI.Theme.Text
        valueLabel.TextColor3 = SugarUI.Theme.Muted
        optionsFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
end

-- ======================
-- Section Component
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent
function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1,0,0,38)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent
    local label = Instance.new("TextLabel", wrapper)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = SugarUI.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", wrapper)
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0,10,1,-6)
    line.BackgroundColor3 = SugarUI.Theme.Border
    line.BorderSizePixel = 0
    self._wrapper = wrapper
    function self:UpdateTheme()
        label.TextColor3 = SugarUI.Theme.Muted
        line.BackgroundColor3 = SugarUI.Theme.Border
    end
    return self
end

-- ======================
-- Notification System
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 340, 0, 380)
    self.Container.Position = UDim2.new(1, -360, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 900
    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 12)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    self.Notifications = {}
    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.LayoutOrder = -(#self.Container:GetChildren() + 1)
    frame.Parent = self.Container
    SugarUI.RoundCorner(12).Parent = frame
    SugarUI.AddShadow(frame, 0.28, 8)
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0,6,1,0)
    local byType = { Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error }
    accent.BackgroundColor3 = byType[notifType] or SugarUI.Theme.Accent
    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0,24,0,24)
    icon.Position = UDim2.new(0,16,0,16)
    icon.BackgroundTransparency = 1
    local iconsMap = { Info = "rbxassetid://6031280882", Success = "rbxassetid://6031094667", Warning = "rbxassetid://6031094687", Error = "rbxassetid://6031094688" }
    icon.Image = iconsMap[notifType] or iconsMap.Info
    icon.ImageColor3 = SugarUI.Theme.Text
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -70, 0, 24)
    titleLbl.Position = UDim2.new(0,50,0,14)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Notification"
    titleLbl.TextColor3 = SugarUI.Theme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local messageLbl = Instance.new("TextLabel", frame)
    messageLbl.Size = UDim2.new(1, -70, 0, 0)
    messageLbl.Position = UDim2.new(0,50,0,38)
    messageLbl.BackgroundTransparency = 1
    messageLbl.Text = message or ""
    messageLbl.TextColor3 = SugarUI.Theme.Muted
    messageLbl.Font = Enum.Font.Gotham
    messageLbl.TextSize = 12
    messageLbl.TextWrapped = true
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,24,0,24)
    closeBtn.Position = UDim2.new(1, -34, 0,10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = SugarUI.Theme.Muted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(260,1000))
        textHeight = size.Y
    end
    local totalHeight = math.clamp(60 + textHeight, 64, 150)
    messageLbl.Size = UDim2.new(1, -70, 0, textHeight)
    SugarUI.Tween(frame, {Size = UDim2.new(1,0,0,totalHeight)}, 0.22)
    closeBtn.MouseButton1Click:Connect(function() pcall(function() SugarUI.Tween(frame, {Size = UDim2.new(1,0,0,0)}, 0.18); task.delay(0.18, function() if frame and frame.Parent then frame:Destroy() end end) end) end)
    if duration > 0 then
        task.delay(duration, function() if frame and frame.Parent then pcall(function() SugarUI.Tween(frame, {Size = UDim2.new(1,0,0,0)}, 0.18); task.delay(0.18, function() if frame and frame.Parent then frame:Destroy() end end) end) end)
    end
    table.insert(self.Notifications, frame)
    return frame
end

-- ======================
-- TextBox Component
-- ======================
local TextBoxComponent = {}
TextBoxComponent.__index = TextBoxComponent
function TextBoxComponent.new(parent, placeholder, default, callback, configKey)
    local self = setmetatable({}, TextBoxComponent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundColor3 = SugarUI.Theme.Panel
    box.Text = default or ""
    box.PlaceholderText = placeholder or ""
    box.TextColor3 = SugarUI.Theme.Text
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    SugarUI.RoundCorner(8).Parent = box
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    box.FocusLost:Connect(function(enter)
        if callback then pcall(callback, box.Text, enter) end
        if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = box.Text end
    end)
    function self:GetText() return box.Text end
    function self:SetText(t, fire) box.Text = tostring(t or ""); if fire and callback then pcall(callback, box.Text) end; if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = box.Text end end
    function self:UpdateTheme()
        box.BackgroundColor3 = SugarUI.Theme.Panel
        box.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
end

-- ======================
-- Keybind Component
-- ======================
local KeybindComponent = {}
KeybindComponent.__index = KeybindComponent
function KeybindComponent.new(parent, text, defaultKey, callback, configKey)
    local self = setmetatable({}, KeybindComponent)
    local currentKey = defaultKey or Enum.KeyCode.V
    local listening = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.Parent = parent
    SugarUI.RoundCorner(8).Parent = frame
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.Position = UDim2.new(1, -12, 0.15, 0)
    btn.AnchorPoint = Vector2.new(1,0)
    btn.BackgroundColor3 = SugarUI.Theme.Button
    btn.Text = tostring(currentKey.Name or tostring(currentKey))
    btn.TextColor3 = SugarUI.Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    SugarUI.RoundCorner(6).Parent = btn
    local conn
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        btn.Text = "Press any key..."
        if conn then conn:Disconnect() end
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode then
                currentKey = input.KeyCode
                listening = false
                btn.Text = tostring(currentKey.Name or tostring(currentKey))
                if callback then pcall(callback, currentKey) end
                if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = currentKey.Name end
                if conn then conn:Disconnect() end
            elseif input.KeyCode == Enum.KeyCode.Escape then
                listening = false
                btn.Text = tostring(currentKey.Name or tostring(currentKey))
                if conn then conn:Disconnect() end
            end
        end)
    end)
    function self:GetKey() return currentKey end
    function self:SetKey(k) if typeof(k) == "EnumItem" then currentKey = k; btn.Text = tostring(currentKey.Name or tostring(currentKey)); if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = currentKey.Name end end end
    function self:UpdateTheme()
        frame.BackgroundColor3 = SugarUI.Theme.Panel
        label.TextColor3 = SugarUI.Theme.Text
        btn.BackgroundColor3 = SugarUI.Theme.Button
        btn.TextColor3 = SugarUI.Theme.Text
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
end

-- ======================
-- ColorPicker Component (RGB sliders + HEX)
-- ======================
local ColorPickerComponent = {}
ColorPickerComponent.__index = ColorPickerComponent
function ColorPickerComponent.new(parent, text, defaultColor, callback, configKey)
    local self = setmetatable({}, ColorPickerComponent)
    local color = defaultColor or Color3.fromRGB(120, 120, 120)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 44)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.Parent = parent
    SugarUI.RoundCorner(8).Parent = frame
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.55,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Color"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    local preview = Instance.new("Frame", frame)
    preview.Size = UDim2.new(0,36,0,36)
    preview.Position = UDim2.new(1, -46, 0.5, -18)
    preview.BackgroundColor3 = color
    SugarUI.RoundCorner(6).Parent = preview
    local pickBtn = Instance.new("TextButton", frame)
    pickBtn.Size = UDim2.new(0,80,0,28)
    pickBtn.Position = UDim2.new(1, -140, 0.12, 0)
    pickBtn.BackgroundColor3 = SugarUI.Theme.Button
    pickBtn.Text = "Pick"
    pickBtn.TextColor3 = SugarUI.Theme.Text
    pickBtn.Font = Enum.Font.Gotham
    SugarUI.RoundCorner(6).Parent = pickBtn

    local function openModal()
        local scg = findScreenGui(parent) or parent
        if not scg then return end
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.45
        overlay.ZIndex = 999
        overlay.Parent = scg
        local panel = Instance.new("Frame", overlay)
        panel.Size = UDim2.new(0,360,0,220)
        panel.Position = UDim2.new(0.5, -180, 0.5, -110)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        SugarUI.RoundCorner(12).Parent = panel
        SugarUI.AddShadow(panel, 0.36, 12)
        local title = Instance.new("TextLabel", panel)
        title.Size = UDim2.new(1,-24,0,28)
        title.Position = UDim2.new(0,12,0,12)
        title.BackgroundTransparency = 1
        title.Text = "Color Picker"
        title.TextColor3 = SugarUI.Theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        local inner = Instance.new("Frame", panel)
        inner.Size = UDim2.new(1,-24,1,-80)
        inner.Position = UDim2.new(0,12,0,44)
        inner.BackgroundTransparency = 1

        -- R G B sliders
        local r = SliderComponent.new(inner, "R", 0, 255, math.floor(color.R * 255), function(v)
            color = Color3.fromRGB(math.floor(v), math.floor(color.G*255), math.floor(color.B*255))
            preview.BackgroundColor3 = color
        end)
        r.Instance.Parent = inner
        r.Instance.LayoutOrder = 1

        local g = SliderComponent.new(inner, "G", 0, 255, math.floor(color.G*255), function(v)
            color = Color3.fromRGB(math.floor(color.R*255), math.floor(v), math.floor(color.B*255))
            preview.BackgroundColor3 = color
        end)
        g.Instance.Parent = inner
        g.Instance.LayoutOrder = 2
        g.Instance.Position = UDim2.new(0,0,0,64)

        local b = SliderComponent.new(inner, "B", 0, 255, math.floor(color.B*255), function(v)
            color = Color3.fromRGB(math.floor(color.R*255), math.floor(color.G*255), math.floor(v))
            preview.BackgroundColor3 = color
        end)
        b.Instance.Parent = inner
        b.Instance.LayoutOrder = 3
        b.Instance.Position = UDim2.new(0,0,0,128)

        local hexBox = Instance.new("TextBox", panel)
        hexBox.Size = UDim2.new(0,160,0,30)
        hexBox.Position = UDim2.new(0,12,1,-44)
        hexBox.BackgroundColor3 = SugarUI.Theme.Button
        hexBox.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
        hexBox.TextColor3 = SugarUI.Theme.Text
        hexBox.Font = Enum.Font.Gotham
        hexBox.TextSize = 14
        SugarUI.RoundCorner(6).Parent = hexBox
        local applyBtn = Instance.new("TextButton", panel)
        applyBtn.Size = UDim2.new(0,88,0,30)
        applyBtn.Position = UDim2.new(1, -100, 1, -44)
        applyBtn.BackgroundColor3 = SugarUI.Theme.Button
        applyBtn.Text = "Apply"
        applyBtn.TextColor3 = SugarUI.Theme.Text
        applyBtn.Font = Enum.Font.GothamBold
        SugarUI.RoundCorner(6).Parent = applyBtn
        local cancelBtn = Instance.new("TextButton", panel)
        cancelBtn.Size = UDim2.new(0,88,0,30)
        cancelBtn.Position = UDim2.new(1, -196, 1, -44)
        cancelBtn.BackgroundColor3 = SugarUI.Theme.Button
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = SugarUI.Theme.Text
        cancelBtn.Font = Enum.Font.GothamBold
        SugarUI.RoundCorner(6).Parent = cancelBtn

        applyBtn.MouseButton1Click:Connect(function()
            local hex = hexBox.Text:gsub("#","")
            if #hex == 6 then
                local rr = tonumber(hex:sub(1,2),16) or 0
                local gg = tonumber(hex:sub(3,4),16) or 0
                local bb = tonumber(hex:sub(5,6),16) or 0
                color = Color3.fromRGB(rr,gg,bb)
                preview.BackgroundColor3 = color
                r.SetValue(rr, true); g.SetValue(gg, true); b.SetValue(bb, true)
                if callback then pcall(callback, color) end
                if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = {rr,gg,bb} end
                overlay:Destroy()
            else
                hexBox.Text = "Invalid HEX"
            end
        end)
        cancelBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)
    end

    pickBtn.MouseButton1Click:Connect(openModal)
    function self:SetColor(c, fire)
        if typeof(c) == "Color3" then color = c; preview.BackgroundColor3 = color; if fire and callback then pcall(callback, color) end; if configKey then SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}; SugarUI.CurrentConfig[configKey] = {math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)} end end
    function self:GetColor() return color end
    function self:UpdateTheme()
        frame.BackgroundColor3 = SugarUI.Theme.Panel
        label.TextColor3 = SugarUI.Theme.Text
        pickBtn.BackgroundColor3 = SugarUI.Theme.Button
        preview.BackgroundColor3 = color
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
end

-- ======================
-- Image Component
-- ======================
local ImageComponent = {}
ImageComponent.__index = ImageComponent
function ImageComponent.new(parent, imageId, size)
    local self = setmetatable({}, ImageComponent)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, -10, 0, 120)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(1,0,1,0)
    img.Position = UDim2.new(0,0,0,0)
    img.BackgroundColor3 = SugarUI.Theme.Panel
    img.BackgroundTransparency = 0
    img.Image = tostring(imageId or "")
    img.ScaleType = Enum.ScaleType.Crop
    SugarUI.RoundCorner(8).Parent = img
    local stroke = Instance.new("UIStroke", img)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    function self:SetImage(id) img.Image = tostring(id) end
    function self:GetImage() return img.Image end
    function self:UpdateTheme()
        img.BackgroundColor3 = SugarUI.Theme.Panel
        stroke.Color = SugarUI.Theme.Border
    end
    self.Instance = frame
    return self
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
    btnWrap.Size = UDim2.new(1,0,0,48)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar
    local tabBtn = Instance.new("TextButton", btnWrap)
    tabBtn.Size = UDim2.new(1, -28, 1, 0)
    tabBtn.Position = UDim2.new(0,14,0,0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextColor3 = SugarUI.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local indicator = Instance.new("Frame", tabBtn)
    indicator.Size = UDim2.new(0,4,1,-8)
    indicator.Position = UDim2.new(0, -6, 0, 4)
    indicator.BackgroundColor3 = SugarUI.Theme.Accent
    indicator.Visible = false
    SugarUI.RoundCorner(2).Parent = indicator
    local page = Instance.new("Frame", selfObj.PagesHolder)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    local scrollingFrame = Instance.new("ScrollingFrame", page)
    scrollingFrame.Size = UDim2.new(1, -28, 1, -28)
    scrollingFrame.Position = UDim2.new(0,14,0,14)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = SugarUI.Theme.Border
    scrollingFrame.ScrollBarImageTransparency = 0.5
    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0,12)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0,12)
    padding.PaddingBottom = UDim.new(0,12)
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)

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
            local b = ButtonComponent.new(scrollingFrame, txt, cb)
            b.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="button", obj=b})
            table.insert(selfObj.Components, {type="button", obj=b})
            return b
        end,
        AddToggle = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local t = ToggleComponent.new(scrollingFrame, txt, def, cb, configKey)
            t.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="toggle", key=configKey, obj=t})
            table.insert(selfObj.Components, {type="toggle", key=configKey, obj=t})
            return t
        end,
        AddSlider = function(_, txt, min, max, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local s = SliderComponent.new(scrollingFrame, txt, min, max, def, cb, configKey)
            s.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="slider", key=configKey, obj=s})
            table.insert(selfObj.Components, {type="slider", key=configKey, obj=s})
            return s
        end,
        AddDropdown = function(_, txt, opts, def, cb, multi, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local d = DropdownComponent.new(scrollingFrame, txt, opts, def, cb, multi, configKey)
            d.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="dropdown", key=configKey, obj=d})
            table.insert(selfObj.Components, {type="dropdown", key=configKey, obj=d})
            return d
        end,
        AddTextBox = function(_, placeholder, default, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local tb = TextBoxComponent.new(scrollingFrame, placeholder, default, cb, configKey)
            tb.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="textbox", key=configKey, obj=tb})
            table.insert(selfObj.Components, {type="textbox", key=configKey, obj=tb})
            return tb
        end,
        AddKeybind = function(_, txt, defaultKey, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local kb = KeybindComponent.new(scrollingFrame, txt, defaultKey, cb, configKey)
            kb.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="keybind", key=configKey, obj=kb})
            table.insert(selfObj.Components, {type="keybind", key=configKey, obj=kb})
            return kb
        end,
        AddColorPicker = function(_, txt, defaultColor, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local cp = ColorPickerComponent.new(scrollingFrame, txt, defaultColor, cb, configKey)
            cp.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="colorpicker", key=configKey, obj=cp})
            table.insert(selfObj.Components, {type="colorpicker", key=configKey, obj=cp})
            return cp
        end,
        AddImage = function(_, imageId, size)
            layoutOrderCounter = layoutOrderCounter + 1
            local img = ImageComponent.new(scrollingFrame, imageId, size)
            img.Instance.LayoutOrder = layoutOrderCounter
            table.insert(tabComponents, {type="image", obj=img})
            table.insert(selfObj.Components, {type="image", obj=img})
            return img
        end
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

    local OuterFrame = Instance.new("Frame", ScreenGui)
    OuterFrame.Size = UDim2.new(0, 560, 0, 460)
    OuterFrame.Position = UDim2.new(0.5, -280, 0.5, -230)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    local ShadowFrame = Instance.new("ImageLabel", OuterFrame)
    ShadowFrame.Size = UDim2.new(1,30,1,30)
    ShadowFrame.Position = UDim2.new(0, -15, 0, -15)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = SugarUI.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.72
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10,10,118,118)
    local Frame = Instance.new("Frame", OuterFrame)
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    SugarUI.RoundCorner(14).Parent = Frame
    SugarUI.AddShadow(Frame, 0.28, 12)

    local TopBar = Instance.new("Frame", Frame)
    TopBar.Size = UDim2.new(1,0,0,60)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    SugarUI.RoundCorner(14).Parent = TopBar
    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = SugarUI.Theme.Border
    topStroke.Transparency = 0.9
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local TitleLbl = Instance.new("TextLabel", TopBar)
    TitleLbl.Size = UDim2.new(0.8, -24, 1, 0)
    TitleLbl.Position = UDim2.new(0,16,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Size = UDim2.new(0.2, -24, 1, 0)
    Subtitle.Position = UDim2.new(0.8, 12, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "v1.0"
    Subtitle.TextColor3 = SugarUI.Theme.Muted
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.new(0,36,0,36)
    MinimizeBtn.Position = UDim2.new(1, -104, 0.5, -18)
    MinimizeBtn.BackgroundColor3 = SugarUI.Theme.Warning or Color3.fromRGB(255,193,7)
    MinimizeBtn.Text = "—"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.TextColor3 = SugarUI.Theme.Highlight
    MinimizeBtn.BorderSizePixel = 0
    SugarUI.RoundCorner(10).Parent = MinimizeBtn
    MinimizeBtn.MouseEnter:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    MinimizeBtn.MouseLeave:Connect(function() SugarUI.Tween(MinimizeBtn, {BackgroundColor3 = SugarUI.Theme.Warning}, 0.12) end)

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0,36,0,36)
    CloseBtn.Position = UDim2.new(1, -56, 0.5, -18)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = SugarUI.Theme.Highlight
    CloseBtn.BorderSizePixel = 0
    SugarUI.RoundCorner(10).Parent = CloseBtn
    CloseBtn.MouseEnter:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() SugarUI.Tween(CloseBtn, {BackgroundColor3 = SugarUI.Theme.Error}, 0.12) end)

    local Sidebar = Instance.new("Frame", Frame)
    Sidebar.Size = UDim2.new(0,180,1,-60)
    Sidebar.Position = UDim2.new(0,0,0,60)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    SugarUI.RoundCorner(0).Parent = Sidebar
    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = SugarUI.Theme.Border
    sideStroke.Transparency = 0.9
    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0,8)
    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0,18)
    tabsPadding.PaddingLeft = UDim.new(0,12)
    tabsPadding.PaddingRight = UDim.new(0,12)
    tabsPadding.PaddingBottom = UDim.new(0,16)

    local PagesHolder = Instance.new("Frame", Frame)
    PagesHolder.Size = UDim2.new(1, -180, 1, -60)
    PagesHolder.Position = UDim2.new(0,180,0,60)
    PagesHolder.BackgroundTransparency = 1

    local Notifications = NotificationSystem.new(ScreenGui)

    -- adaptive sizing
    local function getViewport()
        Camera = Camera or Workspace.CurrentCamera
        if Camera and Camera.ViewportSize then return Camera.ViewportSize end
        return Vector2.new(1280,720)
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

    -- drag
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

    -- resize
    local resizeBtn = Instance.new("Frame", Frame)
    resizeBtn.Size = UDim2.new(0,20,0,20)
    resizeBtn.Position = UDim2.new(1,0,1,0)
    resizeBtn.AnchorPoint = Vector2.new(1,1)
    resizeBtn.BackgroundTransparency = 1
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

    -- toggle key
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

    -- show / hide animations
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        local target = selfObj._desiredSize or OuterFrame.Size
        OuterFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
        OuterFrame.Size = UDim2.new(0,0,0,0)
        Frame.BackgroundTransparency = 1
        ShadowFrame.ImageTransparency = 1
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5,0,0.5,0), Size = target}, 0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        SugarUI.Tween(Frame, {BackgroundTransparency = 0.06}, 0.36)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 0.72}, 0.36)
    end
    function selfObj:Hide()
        selfObj.Visible = false
        SugarUI.Tween(OuterFrame, {Position = UDim2.new(0.5,0,0.6,0), Size = UDim2.new(0,0,0,0)}, 0.36, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.36)
        SugarUI.Tween(ShadowFrame, {ImageTransparency = 1}, 0.36)
        task.delay(0.4, function()
            if not selfObj.Visible then OuterFrame.Visible = false end
            pcall(function() Notifications:Notify("Info", "GUI hidden. Press " .. (selfObj.ToggleKey and selfObj.ToggleKey.Name or "V") .. " to show.", 3, "Info") end)
        end)
    end

    -- init show
    task.defer(function() wait(0.05); selfObj:Show() end)

    -- confirm dialog (fixed hover-size bug by not changing sizes on hover)
    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function()
            pcall(function() ScreenGui:Destroy() end)
        end, function() end)
    end)

    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame", ScreenGui)
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.52
        overlay.ZIndex = 999
        local panel = Instance.new("Frame", overlay)
        panel.Size = UDim2.new(0,360,0,180)
        panel.Position = UDim2.new(0.5, -180, 0.5, -90)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        SugarUI.RoundCorner(10).Parent = panel
        SugarUI.AddShadow(panel, 0.42, 12)
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = SugarUI.Theme.Border
        stroke.Transparency = 0.8
        local titleLbl = Instance.new("TextLabel", panel)
        titleLbl.Size = UDim2.new(1,-20,0,36)
        titleLbl.Position = UDim2.new(0,10,0,10)
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16
        titleLbl.BackgroundTransparency = 1
        local msgLbl = Instance.new("TextLabel", panel)
        msgLbl.Size = UDim2.new(1,-20,0,80)
        msgLbl.Position = UDim2.new(0,10,0,46)
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextWrapped = true
        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.4,0,0,34)
        yesBtn.Instance.Position = UDim2.new(0.09,0,1,-48)
        local noBtn = ButtonComponent.new(panel, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.4,0,0,34)
        noBtn.Instance.Position = UDim2.new(0.51,0,1,-48)
    end

    -- expose references
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
    function selfObj:Notify(title, message, duration, type)
        return Notifications:Notify(title, message, duration, type)
    end
    function selfObj:ApplyConfig(config)
        if not config or type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local val = comp.key and config[comp.key] or nil
            if val ~= nil then
                if comp.type == "toggle" and type(comp.obj.Set) == "function" then comp.obj.Set(val, false)
                elseif comp.type == "slider" and type(comp.obj.SetValue) == "function" then comp.obj.SetValue(tonumber(val) or val, false)
                elseif comp.type == "dropdown" and type(comp.obj.SetValue) == "function" then comp.obj.SetValue(val)
                elseif comp.type == "textbox" and type(comp.obj.SetText) == "function" then comp.obj.SetText(val, false)
                elseif comp.type == "keybind" and type(comp.obj.SetKey) == "function" then
                    if type(val) == "string" then local key = Enum.KeyCode[val]; if key then comp.obj.SetKey(key) end end
                elseif comp.type == "colorpicker" and type(comp.obj.SetColor) == "function" then
                    if type(val) == "table" then comp.obj.SetColor(Color3.fromRGB(val[1], val[2], val[3]), false) end
                end
            end
        end
        if config["ToggleKey"] then
            local key = Enum.KeyCode[config["ToggleKey"]]
            if key then selfObj:SetToggleKey(key) end
        end
        if config["Theme"] then pcall(function() SugarUI.ApplyPreset(config["Theme"]) end) end
        task.defer(function() pcall(function() selfObj:Notify("Info", "Configuration applied.", 3, "Info") end) end)
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
            tab.pageInner.ScrollBarImageColor3 = SugarUI.Theme.Border
            for _, comp in ipairs(tab.components) do
                if comp.obj and comp.obj.UpdateTheme then pcall(function() comp.obj:UpdateTheme() end) end
            end
        end
        for _, shadow in ipairs(ScreenGui:GetDescendants()) do
            if shadow and shadow.Name == "Shadow" and shadow:IsA("ImageLabel") then
                shadow.ImageColor3 = SugarUI.Theme.Shadow
            end
        end
    end

    SugarUI.CurrentWindow = selfObj
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    return selfObj
end

function SugarUI:CreateWindow(title)
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    local window = Window.new(title)
    if SugarUI.CurrentConfig["Theme"] then pcall(function() SugarUI.ApplyPreset(SugarUI.CurrentConfig["Theme"]) end) end
    return window
end

-- expose utility
SugarUI.ApplyTheme = SugarUI.ApplyPreset
SugarUI.GetAvailableThemes = function()
    local keys = {}
    for k,_ in pairs(SugarUI.Presets) do table.insert(keys, k) end
    return keys
end

return SugarUI

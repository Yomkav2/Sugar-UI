-- init.lua (Sugar UI - Полностью переработанный с расширенными функциями)
local UILib = {}
UILib.__index = UILib

-- Сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- ======================
-- Тема
-- ======================
UILib.Theme = {
    Background = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(30, 32, 36),
    Accent = Color3.fromRGB(100, 181, 246),
    AccentSoft = Color3.fromRGB(66, 153, 233),
    Text = Color3.fromRGB(240, 240, 240),
    Muted = Color3.fromRGB(150, 150, 150),
    Shadow = Color3.fromRGB(0, 0, 0),
    Border = Color3.fromRGB(45, 48, 52),
    Highlight = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(244, 67, 54),
    Toggle = Color3.fromRGB(28, 30, 34),
    ToggleBox = Color3.fromRGB(200, 200, 200),
    Button = Color3.fromRGB(34, 36, 40),
    ButtonHover = Color3.fromRGB(50, 52, 56),
}

-- ======================
-- Вспомогательные функции
-- ======================
function UILib.RoundCorner(cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    return corner
end

function UILib.Tween(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Sine
    dir = dir or Enum.EasingDirection.InOut
    local info = TweenInfo.new(duration or 0.2, style, dir)
    local tw = TweenService:Create(instance, info, props)
    tw:Play()
    return tw
end

function UILib.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 10, 1, size or 10)
    shadow.Position = UDim2.new(0, -(size or 10)/2, 0, -(size or 10)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = UILib.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Button
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 34)
    Btn.BackgroundColor3 = UILib.Theme.Button
    Btn.BackgroundTransparency = 0
    Btn.Text = text or "Button"
    Btn.TextColor3 = UILib.Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    UILib.RoundCorner(8).Parent = Btn

    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.9
    stroke.Thickness = 1

    Btn.MouseEnter:Connect(function() UILib.Tween(Btn, {BackgroundColor3 = UILib.Theme.ButtonHover}, 0.12) end)
    Btn.MouseLeave:Connect(function() UILib.Tween(Btn, {BackgroundColor3 = UILib.Theme.Button}, 0.12) end)
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    self.Instance = Btn
    return self
end

-- ======================
-- Toggle
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default and true or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 34)
    Frame.BackgroundColor3 = UILib.Theme.Panel
    Frame.Parent = parent
    UILib.RoundCorner(8).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.9

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.75, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 28, 0, 24)
    Box.Position = UDim2.new(1, -36, 0.5, -12)
    Box.BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox
    Box.Parent = Frame
    UILib.RoundCorner(6).Parent = Box

    UILib.AddShadow(Box, 0.6, 4)

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            UILib.Tween(Box, {BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox}, 0.12)
            if callback then pcall(callback, self.State) end
            if configKey then UILib.CurrentConfig[configKey] = self.State end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        UILib.Tween(Box, {BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox}, 0.12)
        if fire and callback then pcall(callback, self.State) end
        if configKey then UILib.CurrentConfig[configKey] = self.State end
    end
    self.Get = function() return self.State end

    return self
end

-- ======================
-- Slider
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    min = min or 0
    max = max or 100
    local value = default or min

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 54)
    Frame.BackgroundColor3 = UILib.Theme.Panel
    Frame.Parent = parent
    UILib.RoundCorner(8).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 18)
    Label.Position = UDim2.new(0, 8, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -8, 0, 18)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = UILib.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -16, 0, 10)
    Track.Position = UDim2.new(0, 8, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(48, 50, 54)
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    UILib.RoundCorner(6).Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min) / math.max(1,(max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = UILib.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    UILib.RoundCorner(6).Parent = Fill

    local dragging = false

    local function set_value(newValue, fire)
        newValue = tonumber(newValue) or newValue
        if type(newValue) ~= "number" then return end
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = (value - min) / math.max(1,(max - min))
        UILib.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.12)
        if fire and callback then pcall(callback, value) end
        if configKey then UILib.CurrentConfig[configKey] = value end
    end

    local function update_from_mouse(input)
        local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
        local newValue = min + (posX / Track.AbsoluteSize.X) * (max - min)
        set_value(newValue, true)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update_from_mouse(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update_from_mouse(input) end
    end)

    self.Instance = Frame
    self.SetValue = set_value
    self.GetValue = function() return value end
    return self
end

-- ======================
-- Dropdown (переработанный)
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent

function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    options = options or {}
    multiSelect = not not multiSelect
    local selected = nil
    if multiSelect then selected = default or {} else selected = default or options[1] or "None" end
    local isOpen = false
    local optionObjects = {}

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = UILib.Theme.Panel
    Frame.Parent = parent
    UILib.RoundCorner(8).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Parent = Frame

    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 18, 0, 18)
    Arrow.Position = UDim2.new(1, -32, 0.5, -9)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6031094678"
    Arrow.ImageColor3 = UILib.Theme.Muted
    Arrow.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.35, -12, 1, 0)
    ValueLabel.Position = UDim2.new(0.65, 8, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "None" or tostring(selected)
    ValueLabel.TextColor3 = UILib.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ValueLabel.Parent = Frame

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Parent = Frame

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 36)
    OptionsFrame.BackgroundColor3 = UILib.Theme.Panel
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsFrame.ScrollBarThickness = 6
    OptionsFrame.Parent = Frame
    UILib.RoundCorner(8).Parent = OptionsFrame

    local optsStroke = Instance.new("UIStroke", OptionsFrame)
    optsStroke.Color = UILib.Theme.Border

    local listLayout = Instance.new("UIListLayout", OptionsFrame)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", OptionsFrame)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)

    local function update_value_display()
        if multiSelect then
            if #selected == 0 then
                ValueLabel.Text = "None"
            elseif #selected <= 3 then
                ValueLabel.Text = table.concat(selected, ", ")
            else
                ValueLabel.Text = selected[1] .. ", " .. selected[2] .. " +" .. (#selected - 2)
            end
        else
            ValueLabel.Text = tostring(selected)
        end
    end

    local function persist()
        if configKey then UILib.CurrentConfig[configKey] = multiSelect and selected or selected end
    end

    local function createOption(optionText, order)
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Size = UDim2.new(1, 0, 0, 34)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.LayoutOrder = order
        OptionFrame.Parent = OptionsFrame

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.Position = UDim2.new(0, 0, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 42, 46)
        Btn.AutoButtonColor = false
        Btn.Text = tostring(optionText)
        Btn.TextColor3 = UILib.Theme.Text
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.Parent = OptionFrame
        UILib.RoundCorner(6).Parent = Btn

        local check = nil
        if multiSelect then
            check = Instance.new("Frame")
            check.Size = UDim2.new(0, 16, 0, 16)
            check.Position = UDim2.new(1, -22, 0.5, -8)
            check.BackgroundColor3 = UILib.Theme.Accent
            check.Visible = table.find(selected, optionText) ~= nil
            check.Parent = Btn
            UILib.RoundCorner(4).Parent = check

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 12, 0, 12)
            icon.Position = UDim2.new(0.5, -6, 0.5, -6)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://6031094667"
            icon.ImageColor3 = UILib.Theme.Highlight
            icon.Parent = check
        else
            Btn.BackgroundColor3 = (selected == optionText) and Color3.fromRGB(50,50,54) or Color3.fromRGB(40,42,46)
        end

        Btn.MouseButton1Click:Connect(function()
            if multiSelect then
                local idx = table.find(selected, optionText)
                if idx then table.remove(selected, idx) else table.insert(selected, optionText) end
                check.Visible = table.find(selected, optionText) ~= nil
            else
                selected = optionText
                -- update visuals
                for _, child in ipairs(OptionsFrame:GetChildren()) do
                    if child:IsA("Frame") then
                        local b = child:FindFirstChildWhichIsA("TextButton")
                        if b then
                            b.BackgroundColor3 = (b.Text == selected) and Color3.fromRGB(50,50,54) or Color3.fromRGB(40,42,46)
                        end
                    end
                end
                -- close
                isOpen = false
                UILib.Tween(Arrow, {Rotation = 0}, 0.12)
                UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
                UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 36)}, 0.12)
            end
            update_value_display()
            persist()
            if callback then pcall(callback, multiSelect and selected or selected) end
        end)

        Btn.MouseEnter:Connect(function() UILib.Tween(Btn, {BackgroundColor3 = Color3.fromRGB(50,52,56)}, 0.08) end)
        Btn.MouseLeave:Connect(function() UILib.Tween(Btn, {BackgroundColor3 = (multiSelect and Color3.fromRGB(40,42,46) or ((selected == Btn.Text) and Color3.fromRGB(50,50,54) or Color3.fromRGB(40,42,46)))}, 0.08) end)

        optionObjects[#optionObjects + 1] = {frame = OptionFrame, btn = Btn, check = check}
    end

    local function rebuildOptions(newOptions)
        options = newOptions or {}
        for _, c in ipairs(OptionsFrame:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        optionObjects = {}
        local order = 1
        if multiSelect then
            local ctrl = Instance.new("Frame")
            ctrl.Size = UDim2.new(1, 0, 0, 36)
            ctrl.BackgroundTransparency = 1
            ctrl.LayoutOrder = order
            ctrl.Parent = OptionsFrame

            local selAll = Instance.new("TextButton")
            selAll.Size = UDim2.new(0.5, -6, 1, 0)
            selAll.Position = UDim2.new(0, 6, 0, 0)
            selAll.BackgroundColor3 = Color3.fromRGB(40,42,46)
            selAll.Text = "Select All"
            selAll.Font = Enum.Font.Gotham
            selAll.TextColor3 = UILib.Theme.Text
            selAll.TextSize = 14
            selAll.Parent = ctrl
            UILib.RoundCorner(6).Parent = selAll

            local clear = Instance.new("TextButton")
            clear.Size = UDim2.new(0.5, -6, 1, 0)
            clear.Position = UDim2.new(0.5, 6, 0, 0)
            clear.BackgroundColor3 = Color3.fromRGB(40,42,46)
            clear.Text = "Clear"
            clear.Font = Enum.Font.Gotham
            clear.TextColor3 = UILib.Theme.Text
            clear.TextSize = 14
            clear.Parent = ctrl
            UILib.RoundCorner(6).Parent = clear

            selAll.MouseButton1Click:Connect(function()
                selected = {}
                for _, o in ipairs(options) do table.insert(selected, o) end
                update_value_display()
                persist()
                for _, obj in ipairs(optionObjects) do if obj.check then obj.check.Visible = true end end
            end)
            clear.MouseButton1Click:Connect(function()
                selected = {}
                update_value_display()
                persist()
                for _, obj in ipairs(optionObjects) do if obj.check then obj.check.Visible = false end end
            end)
            order = order + 1
        end

        if #options == 0 then
            options = {"No Options"}
        end

        for i, opt in ipairs(options) do
            createOption(opt, order)
            order = order + 1
        end

        -- Sync selected with new options
        if not multiSelect then
            if selected == nil or not table.find(options, selected) then
                selected = options[1] or "None"
            end
        else
            local filtered = {}
            for _, s in ipairs(selected) do
                if table.find(options, s) then table.insert(filtered, s) end
            end
            selected = filtered
        end
        -- update checks/visuals
        for _, obj in ipairs(optionObjects) do
            if obj.check then
                obj.check.Visible = table.find(selected, obj.btn.Text) ~= nil
            else
                obj.btn.BackgroundColor3 = (selected == obj.btn.Text) and Color3.fromRGB(50,50,54) or Color3.fromRGB(40,42,46)
            end
        end
        update_value_display()
    end

    function self:Toggle()
        isOpen = not isOpen
        if isOpen then
            UILib.Tween(Arrow, {Rotation = 180}, 0.12)
            local height = math.min(#options * 36 + (multiSelect and 44 or 0), 260)
            UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.12)
            UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 36 + height)}, 0.12)
        else
            UILib.Tween(Arrow, {Rotation = 0}, 0.12)
            UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
            UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 36)}, 0.12)
        end
    end

    HeaderBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    function self:UpdateOptions(newOptions)
        rebuildOptions(newOptions)
    end

    function self:SetValue(val)
        if multiSelect then
            selected = val or {}
        else
            selected = val or options[1] or "None"
        end
        update_value_display()
        -- update visuals
        for _, obj in ipairs(optionObjects) do
            if obj.check then
                obj.check.Visible = table.find(selected, obj.btn.Text) ~= nil
            else
                obj.btn.BackgroundColor3 = (selected == obj.btn.Text) and Color3.fromRGB(50,50,54) or Color3.fromRGB(40,42,46)
            end
        end
        persist()
    end

    function self:GetValue() return selected end

    -- initial build
    rebuildOptions(options)
    update_value_display()

    self.Instance = Frame
    return self
end

-- ======================
-- Section
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 26)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = UILib.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -16, 0, 1)
    line.Position = UDim2.new(0, 8, 1, -1)
    line.BackgroundColor3 = UILib.Theme.Border
    line.Parent = wrapper

    self._wrapper = wrapper
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
    self.Container.Size = UDim2.new(0, 320, 0, 360)
    self.Container.Position = UDim2.new(1, -340, 0, 18)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 999

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 10)
    return self
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 4
    notifType = notifType or "Info"

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = UILib.Theme.Panel
    notif.BackgroundTransparency = 0
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notif.Parent = self.Container
    UILib.RoundCorner(8).Parent = notif
    UILib.AddShadow(notif, 0.35, 8)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 6, 1, 0)
    accent.BackgroundColor3 = ({
        Info = UILib.Theme.Accent,
        Success = UILib.Theme.Success,
        Warning = UILib.Theme.Warning,
        Error = UILib.Theme.Error
    })[notifType] or UILib.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notif

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 14, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = ({
        Info = "rbxassetid://6031280882",
        Success = "rbxassetid://6031094667",
        Warning = "rbxassetid://6031094687",
        Error = "rbxassetid://6031094688"
    })[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = UILib.Theme.Text
    icon.Parent = notif

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 18)
    titleLabel.Position = UDim2.new(0, 40, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = UILib.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -80, 0, 0)
    messageLabel.Position = UDim2.new(0, 40, 0, 28)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = UILib.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notif

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 26, 0, 26)
    close.Position = UDim2.new(1, -36, 0, 8)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = UILib.Theme.Muted
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.Parent = notif

    local sizeY = 48
    if message and message ~= "" then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(240,1000))
        sizeY = 36 + size.Y
    end
    messageLabel.Size = UDim2.new(1, -80, 0, sizeY - 36)
    UILib.Tween(notif, {Size = UDim2.new(1, 0, 0, sizeY)}, 0.18)

    close.MouseButton1Click:Connect(function() 
        UILib.Tween(notif, {Size = UDim2.new(1,0,0,0)}, 0.12)
        task.delay(0.12, function() if notif.Parent then notif:Destroy() end end)
    end)

    if duration > 0 then
        task.delay(duration, function()
            if notif.Parent then
                UILib.Tween(notif, {Size = UDim2.new(1,0,0,0)}, 0.12)
                task.delay(0.12, function() if notif.Parent then notif:Destroy() end end)
            end
        end)
    end

    table.insert(self.Notifications, notif)
    return notif
end

function NotificationSystem:Remove(notification)
    if notification and notification.Parent then
        UILib.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
        task.delay(0.12, function() if notification.Parent then notification:Destroy() end end)
    end
    for i,v in ipairs(self.Notifications) do if v == notification then table.remove(self.Notifications, i); break end end
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
    btnWrap.Size = UDim2.new(1, 0, 0, 38)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -28, 1, 0)
    tabBtn.Position = UDim2.new(0, 12, 0, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextColor3 = UILib.Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 1, 0)
    indicator.Position = UDim2.new(0, -6, 0, 0)
    indicator.BackgroundColor3 = UILib.Theme.Accent
    indicator.Visible = false
    indicator.Parent = tabBtn
    UILib.RoundCorner(2).Parent = indicator

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = selfObj.PagesHolder

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -24, 1, -24)
    scrollingFrame.Position = UDim2.new(0, 12, 0, 12)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            UILib.Tween(t.button, {TextColor3 = (t.name == name) and UILib.Theme.Text or UILib.Theme.Muted}, 0.12)
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
            return sec
        end,
        AddButton = function(_, txt, cb)
            layoutOrderCounter = layoutOrderCounter + 1
            local btn = ButtonComponent.new(scrollingFrame, txt, cb)
            btn.Instance.LayoutOrder = layoutOrderCounter
            return btn
        end,
        AddToggle = function(_, txt, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local tog = ToggleComponent.new(scrollingFrame, txt, def, cb, configKey)
            tog.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type="toggle", key=configKey, obj=tog})
                table.insert(selfObj.Components, {type="toggle", key=configKey, obj=tog})
            end
            return tog
        end,
        AddSlider = function(_, txt, min, max, def, cb, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local s = SliderComponent.new(scrollingFrame, txt, min, max, def, cb, configKey)
            s.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type="slider", key=configKey, obj=s})
                table.insert(selfObj.Components, {type="slider", key=configKey, obj=s})
            end
            return s
        end,
        AddDropdown = function(_, txt, opts, def, cb, multi, configKey)
            layoutOrderCounter = layoutOrderCounter + 1
            local d = DropdownComponent.new(scrollingFrame, txt, opts, def, cb, multi, configKey)
            d.Instance.LayoutOrder = layoutOrderCounter
            if configKey then
                table.insert(tabComponents, {type="dropdown", key=configKey, obj=d})
                table.insert(selfObj.Components, {type="dropdown", key=configKey, obj=d})
            end
            return d
        end
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = UILib.Theme.Text
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
    selfObj.Visible = false
    selfObj.Components = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILibEnhanced"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.DisplayOrder = 1000 end)
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok or not ScreenGui.Parent then
        local pl = Players.LocalPlayer
        if pl and pl:FindFirstChild("PlayerGui") then ScreenGui.Parent = pl.PlayerGui else ScreenGui.Parent = game:GetService("CoreGui") end
    end

    local OuterFrame = Instance.new("Frame")
    OuterFrame.Size = UDim2.new(0, 560, 0, 420)
    OuterFrame.Position = UDim2.new(0.5, -280, 0.5, -220 + 22)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 26, 1, 26)
    ShadowFrame.Position = UDim2.new(0, -13, 0, -13)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = UILib.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.7
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10,10,118,118)
    ShadowFrame.Parent = OuterFrame

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = UILib.Theme.Background
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    UILib.RoundCorner(10).Parent = Frame
    UILib.AddShadow(Frame, 0.28, 8)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = UILib.Theme.Panel
    TopBar.Parent = Frame
    UILib.RoundCorner(10).Parent = TopBar

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -120, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = UILib.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    -- Hide button (скрыть)
    local HideBtn = Instance.new("TextButton")
    HideBtn.Size = UDim2.new(0, 32, 0, 32)
    HideBtn.Position = UDim2.new(1, -84, 0.5, -16)
    HideBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    HideBtn.Text = "▢"
    HideBtn.Font = Enum.Font.GothamBold
    HideBtn.TextSize = 16
    HideBtn.TextColor3 = Color3.new(1,1,1)
    HideBtn.BorderSizePixel = 0
    HideBtn.Parent = TopBar
    UILib.RoundCorner(8).Parent = HideBtn

    HideBtn.MouseEnter:Connect(function() UILib.Tween(HideBtn, {BackgroundColor3 = Color3.fromRGB(100,100,100)}, 0.12) end)
    HideBtn.MouseLeave:Connect(function() UILib.Tween(HideBtn, {BackgroundColor3 = Color3.fromRGB(80,80,80)}, 0.12) end)
    HideBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    -- Close (полное закрытие) с подтверждением
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    UILib.RoundCorner(8).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function() UILib.Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(170,50,50)}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() UILib.Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(200,70,70)}, 0.12) end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = UILib.Theme.Panel
    Sidebar.Parent = Frame
    UILib.RoundCorner(8).Parent = Sidebar

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -180, 1, -48)
    PagesHolder.Position = UDim2.new(0, 180, 0, 48)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    -- Dragging
    local dragging = false
    local dragInput, mousePos, framePos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = OuterFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            UILib.Tween(OuterFrame, {Position = newPos}, 0.05, Enum.EasingStyle.Linear)
        end
    end)

    -- Resize
    local resizeBtn = Instance.new("Frame")
    resizeBtn.Size = UDim2.new(0, 20, 0, 20)
    resizeBtn.Position = UDim2.new(1, 0, 1, 0)
    resizeBtn.AnchorPoint = Vector2.new(1,1)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Parent = Frame

    local resizing = false
    local resizeMousePos, resizeFrameSize
    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMousePos = input.Position
            resizeFrameSize = OuterFrame.Size
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeMousePos
            local newSize = UDim2.new(0, math.max(360, resizeFrameSize.X.Offset + delta.X), 0, math.max(220, resizeFrameSize.Y.Offset + delta.Y))
            OuterFrame.Size = newSize
            ShadowFrame.Size = UDim2.new(1, 26, 1, 26)
        end
    end)

    -- Toggle key handling
    local toggleConnection
    local function setupToggleKey(key)
        if toggleConnection then toggleConnection:Disconnect() end
        toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == key then
                if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
            end
        end)
    end
    setupToggleKey(Enum.KeyCode.RightShift)

    -- Show/Hide with animation
    function selfObj:Show()
        selfObj.Visible = true
        OuterFrame.Visible = true
        UILib.Tween(OuterFrame, {Position = UDim2.new(0.5, -280, 0.5, -220)}, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        UILib.Tween(Frame, {BackgroundTransparency = 0.12}, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    function selfObj:Hide()
        selfObj.Visible = false
        UILib.Tween(OuterFrame, {Position = UDim2.new(0.5, -280, 0.5, -220 + 22)}, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        UILib.Tween(Frame, {BackgroundTransparency = 1}, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.16, function() if not selfObj.Visible then OuterFrame.Visible = false end end)
    end

    -- Confirmation modal for close
    local function showCloseConfirm()
        local modal = Instance.new("Frame")
        modal.Size = UDim2.new(0, 340, 0, 140)
        modal.Position = UDim2.new(0.5, -170, 0.5, -70)
        modal.BackgroundColor3 = UILib.Theme.Panel
        modal.Parent = Frame
        modal.ZIndex = 1001
        UILib.RoundCorner(10).Parent = modal
        UILib.AddShadow(modal, 0.28, 10)

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -24, 0, 70)
        txt.Position = UDim2.new(0, 12, 0, 12)
        txt.BackgroundTransparency = 1
        txt.Text = "Are you sure you want to close the UI?"
        txt.TextColor3 = UILib.Theme.Text
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 16
        txt.TextWrapped = true
        txt.Parent = modal

        local btnYes = Instance.new("TextButton")
        btnYes.Size = UDim2.new(0.45, -8, 0, 36)
        btnYes.Position = UDim2.new(0, 12, 1, -48)
        btnYes.BackgroundColor3 = UILib.Theme.Button
        btnYes.Text = "Close"
        btnYes.Font = Enum.Font.GothamBold
        btnYes.TextColor3 = UILib.Theme.Text
        btnYes.Parent = modal
        UILib.RoundCorner(8).Parent = btnYes

        local btnNo = Instance.new("TextButton")
        btnNo.Size = UDim2.new(0.45, -8, 0, 36)
        btnNo.Position = UDim2.new(1, -12 - (0.45 * 340), 1, -48)
        btnNo.BackgroundColor3 = UILib.Theme.Button
        btnNo.Text = "Cancel"
        btnNo.Font = Enum.Font.GothamBold
        btnNo.TextColor3 = UILib.Theme.Text
        btnNo.Parent = modal
        UILib.RoundCorner(8).Parent = btnNo

        btnYes.MouseButton1Click:Connect(function()
            if ScreenGui and ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
        btnNo.MouseButton1Click:Connect(function()
            if modal and modal.Parent then modal:Destroy() end
        end)
    end

    CloseBtn.MouseButton1Click:Connect(function() showCloseConfirm() end)

    -- initial show
    task.delay(0.04, function() selfObj:Show() end)

    -- Expose references
    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications
    selfObj.GlobalContainer = PagesHolder

    function selfObj:AddTab(name) local t = createTab(selfObj, name); return t end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end
    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs) do if t.name == selfObj.ActiveTab then return t end end
        return nil
    end

    function selfObj:SetToggleKey(key)
        if type(key) == "EnumItem" or typeof(key) == "EnumItem" then
            setupToggleKey(key)
            UILib.CurrentConfig["ToggleKey"] = tostring(key)
        elseif typeof(key) == "Enum.KeyCode" or type(key) == "userdata" then
            setupToggleKey(key)
            UILib.CurrentConfig["ToggleKey"] = tostring(key)
        else
            -- allow string
            local ok, k = pcall(function() return Enum.KeyCode[key] end)
            if ok and k then setupToggleKey(k); UILib.CurrentConfig["ToggleKey"] = key end
        end
    end

    function selfObj:Notify(title, message, duration, type)
        return Notifications:Notify(title, message, duration, type)
    end

    function selfObj:ApplyConfig(config)
        if not config or type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local val = config[comp.key]
            if val ~= nil then
                if comp.type == "toggle" and comp.obj and comp.obj.Set then
                    comp.obj:Set(val, false)
                elseif comp.type == "slider" and comp.obj and comp.obj.SetValue then
                    local num = tonumber(val)
                    comp.obj:SetValue(num == nil and val or num, false)
                elseif comp.type == "dropdown" and comp.obj and comp.obj.SetValue then
                    comp.obj:SetValue(val)
                end
            end
        end
        -- restore toggle key
        if config["ToggleKey"] then
            local ok, key = pcall(function() return Enum.KeyCode[config["ToggleKey"]] end)
            if ok and key then selfObj:SetToggleKey(key) end
        end
    end

    return selfObj
end

function UILib:CreateWindow(title)
    UILib.CurrentConfig = {}
    local window = Window.new(title)
    return window
end

return UILib

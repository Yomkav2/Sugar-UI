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
-- Расширенная тема
-- ======================
UILib.Theme = {
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
    Toggle = Color3.fromRGB(30, 30, 30),
    ToggleBox = Color3.fromRGB(200, 200, 200),
    Button = Color3.fromRGB(30, 30, 30),
    ButtonHover = Color3.fromRGB(50, 50, 50),
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
    local tweenInfo = TweenInfo.new(duration or 0.2, style, dir)
    local tween = TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function UILib.AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 10, 1, size or 10)
    shadow.Position = UDim2.new(0, -(size or 10)/2, 0, -(size or 10)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = UILib.Theme.Shadow
    shadow.ImageTransparency = transparency or 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Компонент кнопки
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    -- убрал ручное позиционирование, используем LayoutOrder у родителя
    Btn.BackgroundColor3 = UILib.Theme.Button
    Btn.BackgroundTransparency = 0.2
    Btn.Text = text or "Button"
    Btn.TextColor3 = UILib.Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    UILib.RoundCorner(6).Parent = Btn

    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    Btn.MouseEnter:Connect(function()
        UILib.Tween(Btn, {BackgroundColor3 = UILib.Theme.ButtonHover}, 0.2)
    end)

    Btn.MouseLeave:Connect(function()
        UILib.Tween(Btn, {BackgroundColor3 = UILib.Theme.Button}, 0.2)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = UILib.Theme.Highlight
            ripple.BackgroundTransparency = 0.7
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Parent = Btn
            UILib.RoundCorner(100).Parent = ripple

            UILib.Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad)
            task.delay(0.4, function() if ripple.Parent then ripple:Destroy() end end)

            pcall(callback)
        end
    end)

    self.Instance = Btn
    return self
end

-- ======================
-- Компонент переключателя
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback, configKey)
    local self = setmetatable({}, ToggleComponent)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 30)
    Frame.BackgroundColor3 = UILib.Theme.Toggle
    Frame.BackgroundTransparency = 0.2
    Frame.Parent = parent
    UILib.RoundCorner(6).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Toggle"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(0.9, 0, 0.5, -10)
    Box.BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox
    Box.Parent = Frame
    UILib.RoundCorner(10).Parent = Box

    UILib.AddShadow(Box, 0.5, 4)

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            UILib.Tween(Box, {
                BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox
            }, 0.2)
            if callback then
                pcall(callback, self.State)
            end
            if configKey then
                UILib.CurrentConfig[configKey] = self.State
            end
        end
    end)

    self.Instance = Frame
    self.Set = function(newState, fire)
        self.State = not not newState
        UILib.Tween(Box, {
            BackgroundColor3 = self.State and UILib.Theme.Accent or UILib.Theme.ToggleBox
        }, 0.2)
        if fire and callback then
            pcall(callback, self.State)
        end
        if configKey then
            UILib.CurrentConfig[configKey] = self.State
        end
    end
    self.Get = function() return self.State end

    return self
end

-- ======================
-- Компонент слайдера
-- ======================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, text, min, max, default, callback, configKey)
    local self = setmetatable({}, SliderComponent)
    local value = default or min
    min = min or 0
    max = max or 100

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = UILib.Theme.Panel
    Frame.BackgroundTransparency = 0.2
    Frame.Parent = parent
    UILib.RoundCorner(6).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Slider"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.8, 0, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(math.floor(value))
    ValueLabel.TextColor3 = UILib.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 6)
    Track.Position = UDim2.new(0, 5, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Track.BorderSizePixel = 0
    Track.Parent = Frame
    UILib.RoundCorner(3).Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = UILib.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    UILib.RoundCorner(3).Parent = Fill

    local dragging = false

    local function set_value(newValue, fire)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        ValueLabel.Text = tostring(math.floor(value))
        local fillSize = (value - min) / (max - min)
        UILib.Tween(Fill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.1)
        if fire and callback then
            pcall(callback, value)
        end
        if configKey then
            UILib.CurrentConfig[configKey] = value
        end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
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

    return self
end

-- ======================
-- Компонент выпадающего списка
-- ======================
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent

function DropdownComponent.new(parent, text, options, default, callback, multiSelect, configKey)
    local self = setmetatable({}, DropdownComponent)
    local isOpen = false
    options = options or {}
    multiSelect = multiSelect or false
    local selected
    if multiSelect then
        selected = default or {}
    else
        selected = default or options[1] or "None"
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 30)
    Frame.BackgroundColor3 = UILib.Theme.Panel
    Frame.BackgroundTransparency = 0.2
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    UILib.RoundCorner(6).Parent = Frame

    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = UILib.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Dropdown"
    Label.TextColor3 = UILib.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -28, 0.5, -8)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6031094678"
    Arrow.ImageColor3 = UILib.Theme.Muted
    Arrow.Rotation = 0
    Arrow.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    ValueLabel.Position = UDim2.new(0.75, -12, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = multiSelect and "Multiple" or tostring(selected)
    ValueLabel.TextColor3 = UILib.Theme.Muted
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 30)
    OptionsFrame.BackgroundColor3 = UILib.Theme.Panel
    OptionsFrame.BackgroundTransparency = 0.2
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = Frame
    UILib.RoundCorner(6).Parent = OptionsFrame

    local optionsStroke = Instance.new("UIStroke", OptionsFrame)
    optionsStroke.Color = UILib.Theme.Border
    optionsStroke.Transparency = 0.8
    optionsStroke.Thickness = 1

    local optionsList = Instance.new("UIListLayout", OptionsFrame)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Padding = UDim.new(0, 5)

    local function update_value_display()
        if multiSelect then
            local count = #selected
            ValueLabel.Text = count > 0 and ("Selected: " .. count) or "None"
        else
            ValueLabel.Text = tostring(selected)
        end
    end

    local function toggle_option(option)
        if multiSelect then
            local index = table.find(selected, option)
            if index then
                table.remove(selected, index)
            else
                table.insert(selected, option)
            end
        else
            selected = option
            -- закрываем список после выбора в одиночном режиме
            if isOpen then
                isOpen = false
                UILib.Tween(Arrow, {Rotation = 0}, 0.15)
                UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 30)}, 0.15)
            end
        end

        update_value_display()

        if callback then
            pcall(callback, multiSelect and selected or option)
        end

        if configKey then
            UILib.CurrentConfig[configKey] = multiSelect and selected or option
        end
    end

    local function create_option(optionText, index)
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Size = UDim2.new(1, 0, 0, 32)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.LayoutOrder = index
        OptionFrame.Parent = OptionsFrame

        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -12, 1, -8)
        OptionButton.Position = UDim2.new(0, 6, 0, 4)
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        OptionButton.BackgroundTransparency = 0.2
        OptionButton.Text = tostring(optionText)
        OptionButton.TextColor3 = UILib.Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionFrame
        UILib.RoundCorner(4).Parent = OptionButton

        local optionStroke = Instance.new("UIStroke", OptionButton)
        optionStroke.Color = UILib.Theme.Border
        optionStroke.Transparency = 0.8
        optionStroke.Thickness = 1

        if multiSelect then
            local Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 16, 0, 16)
            Check.Position = UDim2.new(1, -22, 0.5, -8)
            Check.BackgroundColor3 = UILib.Theme.Accent
            Check.Visible = table.find(selected, optionText) ~= nil
            Check.BorderSizePixel = 0
            Check.Parent = OptionButton
            UILib.RoundCorner(4).Parent = Check

            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(0, 12, 0, 12)
            CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = UILib.Theme.Highlight
            CheckIcon.Parent = Check

            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                Check.Visible = table.find(selected, optionText) ~= nil
            end)
        else
            OptionButton.BackgroundColor3 = (selected == optionText) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)
            OptionButton.MouseButton1Click:Connect(function()
                toggle_option(optionText)
                -- обновляем цвета других кнопок
                for _, child in ipairs(OptionsFrame:GetChildren()) do
                    if child:IsA("Frame") then
                        local btn = child:FindFirstChildWhichIsA("TextButton")
                        if btn then
                            UILib.Tween(btn, {BackgroundColor3 = (selected == btn.Text) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)}, 0.1)
                        end
                    end
                end
            end)
        end

        OptionButton.MouseEnter:Connect(function()
            UILib.Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.1)
        end)

        OptionButton.MouseLeave:Connect(function()
            local targetColor = multiSelect and Color3.fromRGB(40, 40, 40) or ((selected == optionText) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40))
            UILib.Tween(OptionButton, {BackgroundColor3 = targetColor}, 0.1)
        end)
    end

    function self:Toggle()
        isOpen = not isOpen
        if isOpen then
            UILib.Tween(Arrow, {Rotation = 180}, 0.2)
            local height = math.min(#options * 32, 192)
            UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
            UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 30 + height)}, 0.2)
        else
            UILib.Tween(Arrow, {Rotation = 0}, 0.2)
            UILib.Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            UILib.Tween(Frame, {Size = UDim2.new(1, -10, 0, 30)}, 0.2)
        end
    end

    function self:UpdateOptions(newOptions)
        options = newOptions or {}
        -- удаляем только фреймы-опции
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for i, option in ipairs(options) do
            create_option(option, i)
        end
        -- если выбранный элемент больше не существует — сбрасываем
        if not multiSelect then
            if selected ~= "None" and not table.find(options, selected) then
                selected = options[1] or "None"
            end
        else
            -- фильтруем selected
            local filtered = {}
            for _, s in ipairs(selected) do
                if table.find(options, s) then
                    table.insert(filtered, s)
                end
            end
            selected = filtered
        end
        update_value_display()
    end

    -- инициализация опций
    for i, option in ipairs(options) do
        create_option(option, i)
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Toggle()
        end
    end)

    update_value_display()

    self.Instance = Frame
    self.IsOpen = function() return isOpen end
    self.SetValue = function(value)
        if multiSelect then
            selected = value or {}
        else
            selected = value or options[1] or "None"
        end
        update_value_display()
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("Frame") then
                local btn = child:FindFirstChildWhichIsA("TextButton")
                if btn then
                    if multiSelect then
                        local check = btn:FindFirstChildWhichIsA("Frame")
                        if check then
                            check.Visible = table.find(selected, btn.Text) ~= nil
                        end
                    else
                        UILib.Tween(btn, {BackgroundColor3 = (selected == btn.Text) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)}, 0.1)
                    end
                end
            end
        end
    end
    self.GetValue = function() return selected end
    self.UpdateOptions = function(n) self:UpdateOptions(n) end

    return self
end

-- ======================
-- Компонент секции
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 30)
    wrapper.BackgroundTransparency = 1
    -- убрал Position
    wrapper.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = UILib.Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0, 5, 1, -1)
    line.BackgroundColor3 = UILib.Theme.Border
    line.BorderSizePixel = 0
    line.Parent = wrapper

    self._wrapper = wrapper
    return self
end

-- ======================
-- Система уведомлений
-- ======================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Notifications = {}
    -- контейнер теперь фиксированной высоты и сверху вправо
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 300, 0, 320)
    self.Container.Position = UDim2.new(1, -320, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 50

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
    notification.BackgroundColor3 = UILib.Theme.Panel
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    -- чтобы новые уведомления были сверху, ставим отрицательный LayoutOrder
    notification.LayoutOrder = -(#self.Container:GetChildren() + 1)
    notification.Parent = self.Container
    UILib.RoundCorner(6).Parent = notification
    notification.ZIndex = 51

    UILib.AddShadow(notification, 0.3, 8)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = ( {
        Info = UILib.Theme.Accent,
        Success = UILib.Theme.Success,
        Warning = UILib.Theme.Warning,
        Error = UILib.Theme.Error
    } )[notifType] or UILib.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    accent.ZIndex = 52

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = ( {
        Info = "rbxassetid://6031280882",
        Success = "rbxassetid://6031094667",
        Warning = "rbxassetid://6031094687",
        Error = "rbxassetid://6031094688"
    } )[notifType] or "rbxassetid://6031280882"
    icon.ImageColor3 = UILib.Theme.Text
    icon.Parent = notification
    icon.ZIndex = 52

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -48, 0, 20)
    titleLabel.Position = UDim2.new(0, 44, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = UILib.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    titleLabel.ZIndex = 52

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -48, 0, 0)
    messageLabel.Position = UDim2.new(0, 44, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = UILib.Theme.Muted
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    messageLabel.ZIndex = 52

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -32, 0, 8)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = UILib.Theme.Muted
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = notification
    closeButton.ZIndex = 52

    local textHeight = 0
    if message then
        local size = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(240, 1000))
        textHeight = size.Y
    end

    local totalHeight = math.clamp(52 + textHeight, 60, 120)
    messageLabel.Size = UDim2.new(1, -48, 0, textHeight)

    UILib.Tween(notification, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3)

    closeButton.MouseButton1Click:Connect(function()
        self:Remove(notification)
    end)

    closeButton.MouseEnter:Connect(function()
        UILib.Tween(closeButton, {TextColor3 = UILib.Theme.Text}, 0.1)
    end)

    closeButton.MouseLeave:Connect(function()
        UILib.Tween(closeButton, {TextColor3 = UILib.Theme.Muted}, 0.1)
    end)

    if duration > 0 then
        task.delay(duration, function()
            if notification.Parent then
                self:Remove(notification)
            end
        end)
    end

    table.insert(self.Notifications, notification)
    return notification
end

function NotificationSystem:Remove(notification)
    UILib.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
    task.delay(0.3, function()
        if notification.Parent then
            notification:Destroy()
        end
    end)

    for i, notif in ipairs(self.Notifications) do
        if notif == notification then
            table.remove(self.Notifications, i)
            break
        end
    end
end

-- ======================
-- Окно и вкладки
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0
    local tabComponents = {}

    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, 0, 0, 40)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #selfObj.Tabs + 1
    btnWrap.Parent = selfObj.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -24, 1, 0)
    tabBtn.Position = UDim2.new(0, 12, 0, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamMedium
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
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn
    UILib.RoundCorner(1.5).Parent = indicator

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = selfObj.PagesHolder

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -24, 1, -24)
    scrollingFrame.Position = UDim2.new(0, 12, 0, 12)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = UILib.Theme.Border
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(selfObj.Pages) do
            v.Visible = false
        end
        page.Visible = true

        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            UILib.Tween(t.button, {TextColor3 = (t.name == name) and UILib.Theme.Text or UILib.Theme.Muted}, 0.15)
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
    selfObj.Visible = true
    selfObj.Components = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILibEnhanced"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    -- ставим DisplayOrder чтобы быть выше большинства GUI
    if pcall(function() ScreenGui.DisplayOrder = 1000 end) then end
    local ok, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok or not ScreenGui.Parent then
        local player = Players.LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            ScreenGui.Parent = player.PlayerGui
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end

    local OuterFrame = Instance.new("Frame")
    OuterFrame.Size = UDim2.new(0, 500, 0, 400)
    OuterFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    local ShadowFrame = Instance.new("ImageLabel")
    ShadowFrame.Size = UDim2.new(1, 20, 1, 20)
    ShadowFrame.Position = UDim2.new(0, -10, 0, -10)
    ShadowFrame.BackgroundTransparency = 1
    ShadowFrame.Image = "rbxassetid://5554236805"
    ShadowFrame.ImageColor3 = UILib.Theme.Shadow
    ShadowFrame.ImageTransparency = 0.7
    ShadowFrame.ScaleType = Enum.ScaleType.Slice
    ShadowFrame.SliceCenter = Rect.new(10, 10, 118, 118)
    ShadowFrame.Parent = OuterFrame

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = UILib.Theme.Background
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame
    UILib.RoundCorner(8).Parent = Frame

    UILib.AddShadow(Frame, 0.3, 6)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = UILib.Theme.Panel
    TopBar.BackgroundTransparency = 0.2
    TopBar.Parent = Frame
    UILib.RoundCorner(8).Parent = TopBar

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = UILib.Theme.Border
    topStroke.Transparency = 0.9
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -60, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = UILib.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 77, 77)
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    UILib.RoundCorner(8).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        UILib.Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.15)
    end)

    CloseBtn.MouseLeave:Connect(function()
        UILib.Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 77, 77)}, 0.15)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = UILib.Theme.Panel
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.Parent = Frame

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = UILib.Theme.Border
    sideStroke.Transparency = 0.9

    local tabsLayout = Instance.new("UIListLayout", Sidebar)
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", Sidebar)
    tabsPadding.PaddingTop = UDim.new(0, 16)
    tabsPadding.PaddingLeft = UDim.new(0, 8)
    tabsPadding.PaddingRight = UDim.new(0, 8)
    tabsPadding.PaddingBottom = UDim.new(0, 16)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -160, 1, -48)
    PagesHolder.Position = UDim2.new(0, 160, 0, 48)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    local Notifications = NotificationSystem.new(ScreenGui)

    local dragging = false
    local dragInput, mousePos, framePos

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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local newPos = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
            UILib.Tween(OuterFrame, {Position = newPos}, 0.05, Enum.EasingStyle.Linear)
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
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeMousePos
            local newSize = UDim2.new(
                0, math.max(300, resizeFrameSize.X.Offset + delta.X),
                0, math.max(200, resizeFrameSize.Y.Offset + delta.Y)
            )
            OuterFrame.Size = newSize
            ShadowFrame.Size = UDim2.new(1, 20, 1, 20)
        end
    end)

    local toggleConnection
    local function setupToggleKey(key)
        if toggleConnection then
            toggleConnection:Disconnect()
        end

        toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == key then
                selfObj.Visible = not selfObj.Visible
                OuterFrame.Visible = selfObj.Visible
            end
        end)
    end

    setupToggleKey(Enum.KeyCode.RightShift)

    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.OuterFrame = OuterFrame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.Notifications = Notifications
    selfObj.GlobalContainer = PagesHolder

    function selfObj:AddTab(name)
        local tab = createTab(selfObj, name)
        return tab
    end

    function selfObj:AddPage(name)
        return selfObj:AddTab(name)
    end

    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs) do
            if t.name == selfObj.ActiveTab then
                return t
            end
        end
        return nil
    end

    function selfObj:SetToggleKey(key)
        setupToggleKey(key)
        UILib.CurrentConfig["ToggleKey"] = tostring(key)
    end

    function selfObj:Notify(title, message, duration, type)
        return Notifications:Notify(title, message, duration, type)
    end

    function selfObj:ApplyConfig(config)
        for _, comp in ipairs(selfObj.Components) do
            local val = config[comp.key]
            if val ~= nil then
                if comp.type == "toggle" then
                    comp.obj:Set(val, false)
                elseif comp.type == "slider" then
                    comp.obj:SetValue(val, false)
                elseif comp.type == "dropdown" then
                    comp.obj:SetValue(val)
                end
            end
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

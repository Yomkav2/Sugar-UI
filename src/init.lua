-- init.lua (Sugar UI - Полностью переработанный с расширенными функциями)
local SugarUI = {}
SugarUI.__index = SugarUI

-- Сервисы
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local TextService        = game:GetService("TextService")
local RunService         = game:GetService("RunService")

-- Тема
SugarUI.Theme = {
    Background   = Color3.fromRGB(20,20,20),
    Panel        = Color3.fromRGB(30,30,30),
    Accent       = Color3.fromRGB(100,181,246),
    AccentSoft   = Color3.fromRGB(66,153,233),
    Text         = Color3.fromRGB(240,240,240),
    Muted        = Color3.fromRGB(150,150,150),
    Border       = Color3.fromRGB(50,50,50),
    Highlight    = Color3.fromRGB(255,255,255),
    Success      = Color3.fromRGB(76,175,80),
    Warning      = Color3.fromRGB(255,193,7),
    Error        = Color3.fromRGB(244,67,54),
    Button       = Color3.fromRGB(30,30,30),
    ButtonHover  = Color3.fromRGB(50,50,50),
}

-- Утилиты
function SugarUI.RoundCorner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

function SugarUI.Tween(instance, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.InOut)
    local tw = TweenService:Create(instance, info, props)
    tw:Play()
    return tw
end

function SugarUI.AddShadow(parent, transp, size)
    local img = Instance.new("ImageLabel")
    img.Name = "Shadow"
    img.Size = UDim2.new(1, size or 10, 1, size or 10)
    img.Position = UDim2.new(0, -(size or 10)/2, 0, -(size or 10)/2)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://5554236805"
    img.ImageTransparency = transp or 0.8
    img.ScaleType = Enum.ScaleType.Slice
    img.SliceCenter = Rect.new(10,10,118,118)
    img.Parent = parent
    return img
end

-- Компоненты: Button, Toggle, Slider — (сохраняем API)
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent
function ButtonComponent.new(parent, text, cb)
    local self = setmetatable({}, ButtonComponent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = SugarUI.Theme.Button
    btn.BackgroundTransparency = 0.2
    btn.Text = text or "Button"
    btn.TextColor3 = SugarUI.Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent
    SugarUI.RoundCorner(6).Parent = btn

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = SugarUI.Theme.Border
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function() SugarUI.Tween(btn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.12) end)
    btn.MouseLeave:Connect(function() SugarUI.Tween(btn, {BackgroundColor3 = SugarUI.Theme.Button}, 0.12) end)
    btn.MouseButton1Click:Connect(function()
        if cb then
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0,0,0,0)
            ripple.Position = UDim2.new(0.5,0,0.5,0)
            ripple.AnchorPoint = Vector2.new(0.5,0.5)
            ripple.BackgroundColor3 = SugarUI.Theme.Highlight
            ripple.BackgroundTransparency = 0.7
            ripple.Parent = btn
            SugarUI.RoundCorner(100).Parent = ripple
            SugarUI.Tween(ripple, {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Quad)
            task.delay(0.36, function() if ripple.Parent then ripple:Destroy() end end)
            pcall(cb)
        end
    end)

    self.Instance = btn
    return self
end

local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent
function ToggleComponent.new(parent, text, default, cb, key)
    local self = setmetatable({}, ToggleComponent)
    self.State = default and true or false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    SugarUI.RoundCorner(6).Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.8,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Toggle"
    lbl.TextColor3 = SugarUI.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0,20,0,20)
    box.Position = UDim2.new(0.9,0,0.5,-10)
    box.BackgroundColor3 = self.State and SugarUI.Theme.Accent or Color3.fromRGB(200,200,200)
    box.Parent = frame
    SugarUI.RoundCorner(10).Parent = box

    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            SugarUI.Tween(box, {BackgroundColor3 = (self.State and SugarUI.Theme.Accent or Color3.fromRGB(200,200,200))}, 0.12)
            if cb then pcall(cb, self.State) end
            if key then SugarUI.CurrentConfig[key] = self.State end
        end
    end)

    self.Instance = frame
    self.Set = function(val, fire)
        self.State = not not val
        SugarUI.Tween(box, {BackgroundColor3 = (self.State and SugarUI.Theme.Accent or Color3.fromRGB(200,200,200))}, 0.12)
        if fire and cb then pcall(cb, self.State) end
        if key then SugarUI.CurrentConfig[key] = self.State end
    end
    self.Get = function() return self.State end
    return self
end

local SliderComponent = {}
SliderComponent.__index = SliderComponent
function SliderComponent.new(parent, text, min, max, default, cb, key)
    local self = setmetatable({}, SliderComponent)
    min = min or 0; max = max or 100
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = SugarUI.Theme.Panel
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    SugarUI.RoundCorner(6).Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.8,0,0,20)
    lbl.Position = UDim2.new(0,5,0,5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Slider"
    lbl.TextColor3 = SugarUI.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0.2,0,0,20)
    valueLbl.Position = UDim2.new(0.8,0,0,5)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(math.floor(value))
    valueLbl.TextColor3 = SugarUI.Theme.Muted
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = 14
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 6)
    track.Position = UDim2.new(0,5,0,30)
    track.BackgroundColor3 = Color3.fromRGB(60,60,60)
    track.Parent = frame
    SugarUI.RoundCorner(3).Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = SugarUI.Theme.Accent
    fill.Parent = track
    SugarUI.RoundCorner(3).Parent = fill

    local dragging = false
    local function set_val(v, fire)
        v = tonumber(v) or v
        if type(v) ~= "number" then return end
        v = math.clamp(v, min, max)
        value = v
        valueLbl.Text = tostring(math.floor(value))
        local s = (max - min) ~= 0 and (value - min)/(max - min) or 0
        SugarUI.Tween(fill, {Size = UDim2.new(s,0,1,0)}, 0.12)
        if fire and cb then pcall(cb, value) end
        if key then SugarUI.CurrentConfig[key] = value end
    end

    local function update_from_input(input)
        local px = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local newV = min + (px/track.AbsoluteSize.X) * (max - min)
        set_val(newV, true)
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update_from_input(inp)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update_from_input(inp)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    self.Instance = frame
    self.SetValue = set_val
    self.GetValue = function() return value end
    return self
end

-- Dropdown (убрана стрелка, адаптирован для экрана)
local DropdownComponent = {}
DropdownComponent.__index = DropdownComponent
function DropdownComponent.new(parent, text, options, default, cb, multi, key)
    local self = setmetatable({}, DropdownComponent)
    options = options or {}
    multi = multi or false
    local selected = multi and (default or {}) or (default or options[1] or "None")
    local isOpen = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = SugarUI.Theme.Button
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    SugarUI.RoundCorner(6).Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = SugarUI.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- стрелка убрана

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.35, -12, 1, 0)
    valueLabel.Position = UDim2.new(0.65, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = multi and "None" or tostring(selected)
    valueLabel.TextColor3 = SugarUI.Theme.Muted
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.Parent = frame

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1,0,0,30)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = false
    headerBtn.Parent = frame
    headerBtn.ZIndex = 50

    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Size = UDim2.new(1,0,0,0)
    optionsFrame.Position = UDim2.new(0,0,0,30)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Parent = frame
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ZIndex = 60

    local listLayout = Instance.new("UIListLayout", optionsFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0,4)

    local function update_display()
        if multi then
            local n = #selected
            if n == 0 then valueLabel.Text = "None"
            elseif n <= 2 then valueLabel.Text = table.concat(selected, ", ")
            else valueLabel.Text = selected[1] .. ", " .. selected[2] .. " +" .. (n - 2)
            end
        else
            valueLabel.Text = tostring(selected)
        end
    end

    local optionObjects = {}
    local function create_option(txt, idx)
        local optFrame = Instance.new("Frame")
        optFrame.Size = UDim2.new(1,0,0,28)
        optFrame.LayoutOrder = idx
        optFrame.BackgroundTransparency = 1
        optFrame.Parent = optionsFrame

        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1,0,1,0)
        optBtn.BackgroundColor3 = SugarUI.Theme.Panel
        optBtn.BackgroundTransparency = 0.1
        optBtn.Text = tostring(txt)
        optBtn.TextColor3 = SugarUI.Theme.Text
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 14
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.Parent = optFrame
        SugarUI.RoundCorner(4).Parent = optBtn

        local pad = Instance.new("UIPadding", optBtn)
        pad.PaddingLeft = UDim.new(0,8)

        local check
        if multi then
            check = Instance.new("Frame")
            check.Size = UDim2.new(0,18,0,18)
            check.Position = UDim2.new(1,-26,0.5,-9)
            check.BackgroundColor3 = table.find(selected, txt) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
            check.Parent = optBtn
            SugarUI.RoundCorner(4).Parent = check

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1,0,1,0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://6031094667"
            img.ImageColor3 = SugarUI.Theme.Highlight
            img.Visible = table.find(selected, txt) ~= nil
            img.Parent = check

            optBtn.MouseButton1Click:Connect(function()
                if table.find(selected, txt) then
                    table.remove(selected, table.find(selected, txt))
                else
                    table.insert(selected, txt)
                end
                check.BackgroundColor3 = table.find(selected, txt) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                img.Visible = table.find(selected, txt) ~= nil
                update_display()
                if key then SugarUI.CurrentConfig[key] = selected end
                if cb then pcall(cb, selected) end
            end)
        else
            optBtn.BackgroundColor3 = (selected == txt) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel
            optBtn.MouseButton1Click:Connect(function()
                selected = txt
                for _, o in ipairs(optionObjects) do
                    SugarUI.Tween(o.btn, {BackgroundColor3 = (o.btn.Text == selected) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
                end
                update_display()
                if key then SugarUI.CurrentConfig[key] = selected end
                if cb then pcall(cb, selected) end
                -- закрыть
                self:Toggle()
            end)
        end

        optBtn.MouseEnter:Connect(function() SugarUI.Tween(optBtn, {BackgroundColor3 = SugarUI.Theme.ButtonHover}, 0.09) end)
        optBtn.MouseLeave:Connect(function()
            local tc = (not multi) and ((selected == txt) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel) or SugarUI.Theme.Panel
            SugarUI.Tween(optBtn, {BackgroundColor3 = tc}, 0.09)
        end)

        optionObjects[#optionObjects+1] = {frame = optFrame, btn = optBtn, check = check}
    end

    local function rebuild()
        for _, c in ipairs(optionsFrame:GetChildren()) do if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end end
        optionObjects = {}
        local order = 1
        if multi then
            local ctrl = Instance.new("Frame")
            ctrl.Size = UDim2.new(1,0,0,28)
            ctrl.BackgroundTransparency = 1
            ctrl.LayoutOrder = order
            ctrl.Parent = optionsFrame
            order = order + 1

            local selAll = Instance.new("TextButton")
            selAll.Size = UDim2.new(0.48,0,1,0)
            selAll.BackgroundColor3 = SugarUI.Theme.Button
            selAll.Text = "Select All"
            selAll.TextColor3 = SugarUI.Theme.Text
            selAll.Font = Enum.Font.Gotham
            selAll.TextSize = 14
            selAll.Parent = ctrl
            SugarUI.RoundCorner(4).Parent = selAll
            local pad = Instance.new("UIPadding", selAll); pad.PaddingLeft = UDim.new(0,8)

            local clear = Instance.new("TextButton")
            clear.Size = UDim2.new(0.48,0,1,0)
            clear.Position = UDim2.new(0.52,0,0,0)
            clear.BackgroundColor3 = SugarUI.Theme.Button
            clear.Text = "Clear"
            clear.TextColor3 = SugarUI.Theme.Text
            clear.Font = Enum.Font.Gotham
            clear.TextSize = 14
            clear.Parent = ctrl
            SugarUI.RoundCorner(4).Parent = clear
            local pad2 = Instance.new("UIPadding", clear); pad2.PaddingLeft = UDim.new(0,8)

            selAll.MouseButton1Click:Connect(function()
                selected = table.clone(options)
                update_display()
                if key then SugarUI.CurrentConfig[key] = selected end
                if cb then pcall(cb, selected) end
                for _, o in ipairs(optionObjects) do
                    if o.check then
                        o.check.BackgroundColor3 = SugarUI.Theme.Accent
                        local i = o.check:FindFirstChildWhichIsA("ImageLabel"); if i then i.Visible = true end
                    end
                end
            end)

            clear.MouseButton1Click:Connect(function()
                selected = {}
                update_display()
                if key then SugarUI.CurrentConfig[key] = selected end
                if cb then pcall(cb, selected) end
                for _, o in ipairs(optionObjects) do
                    if o.check then
                        o.check.BackgroundColor3 = SugarUI.Theme.Panel
                        local i = o.check:FindFirstChildWhichIsA("ImageLabel"); if i then i.Visible = false end
                    end
                end
            end)
        end

        for i,opt in ipairs(options) do
            create_option(opt, order)
            order = order + 1
        end
    end

    function self:Toggle()
        isOpen = not isOpen
        if isOpen then
            label.Visible = false
            valueLabel.Visible = false
            local h = math.min(((#options * 28) + (multi and 28 or 0) + 8), 180)
            SugarUI.Tween(optionsFrame, {Size = UDim2.new(1,0,0,h)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            SugarUI.Tween(frame, {Size = UDim2.new(1, -10, 0, 30 + h)}, 0.18)
            optionsFrame.ZIndex = 1000
        else
            label.Visible = true
            valueLabel.Visible = true
            SugarUI.Tween(optionsFrame, {Size = UDim2.new(1,0,0,0)}, 0.18)
            SugarUI.Tween(frame, {Size = UDim2.new(1, -10, 0, 30)}, 0.18)
            task.delay(0.2, function() optionsFrame.ZIndex = 60 end)
        end
    end

    function self:UpdateOptions(newOptions)
        options = newOptions or {}
        rebuild()
        if not multi then
            if not table.find(options, selected) then selected = options[1] or "None" end
        else
            local filt = {}
            for _, s in ipairs(selected) do if table.find(options, s) then table.insert(filt, s) end end
            selected = filt
        end
        for _, o in ipairs(optionObjects) do
            if o.check then
                o.check.BackgroundColor3 = table.find(selected, o.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                local i = o.check:FindFirstChildWhichIsA("ImageLabel"); if i then i.Visible = table.find(selected, o.btn.Text) ~= nil end
            else
                SugarUI.Tween(o.btn, {BackgroundColor3 = (selected == o.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
            end
        end
        update_display()
        if key then SugarUI.CurrentConfig[key] = multi and selected or selected end
    end

    rebuild()
    update_display()
    headerBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    self.Instance = frame
    self.IsOpen = function() return isOpen end
    self.SetValue = function(v)
        if multi then selected = v or {} else selected = v or options[1] or "None" end
        update_display()
        for _, o in ipairs(optionObjects) do
            if o.check then
                o.check.BackgroundColor3 = table.find(selected, o.btn.Text) and SugarUI.Theme.Accent or SugarUI.Theme.Panel
                local i = o.check:FindFirstChildWhichIsA("ImageLabel"); if i then i.Visible = table.find(selected, o.btn.Text) ~= nil end
            else
                SugarUI.Tween(o.btn, {BackgroundColor3 = (selected == o.btn.Text) and SugarUI.Theme.AccentSoft or SugarUI.Theme.Panel}, 0.12)
            end
        end
        if key then SugarUI.CurrentConfig[key] = multi and selected or selected end
    end
    self.GetValue = function() return selected end

    return self
end

-- Секция
local SectionComponent = {}
SectionComponent.__index = SectionComponent
function SectionComponent.new(parent, title)
    local s = setmetatable({}, SectionComponent)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1,0,0,30)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0,5,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title or "Section"
    lbl.TextColor3 = SugarUI.Theme.Muted
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = wrap

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0,5,1,-1)
    line.BackgroundColor3 = SugarUI.Theme.Border
    line.Parent = wrap

    s._wrapper = wrap
    return s
end

-- Notifications
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0,300,0,320)
    self.Container.Position = UDim2.new(1, -320, 0, 20)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    self.Container.ZIndex = 900

    local list = Instance.new("UIListLayout", self.Container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,10)
    return self
end

function NotificationSystem:Notify(title, message, duration, ntype)
    duration = duration or 4
    ntype = ntype or "Info"

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1,0,0,0)
    notif.BackgroundColor3 = SugarUI.Theme.Panel
    notif.BackgroundTransparency = 0.2
    notif.ClipsDescendants = true
    notif.Parent = self.Container
    SugarUI.RoundCorner(6).Parent = notif
    notif.ZIndex = 901

    SugarUI.AddShadow(notif, 0.3, 8)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0,4,1,0)
    accent.BackgroundColor3 = ({Info = SugarUI.Theme.Accent, Success = SugarUI.Theme.Success, Warning = SugarUI.Theme.Warning, Error = SugarUI.Theme.Error})[ntype] or SugarUI.Theme.Accent
    accent.Parent = notif

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0,24,0,24)
    icon.Position = UDim2.new(0,12,0,12)
    icon.BackgroundTransparency = 1
    icon.Image = ({Info="rbxassetid://6031280882", Success="rbxassetid://6031094667", Warning="rbxassetid://6031094687", Error="rbxassetid://6031094688"})[ntype] or "rbxassetid://6031280882"
    icon.Parent = notif

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-48,0,20)
    titleLbl.Position = UDim2.new(0,44,0,12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Notification"
    titleLbl.TextColor3 = SugarUI.Theme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1,-48,0,0)
    msgLbl.Position = UDim2.new(0,44,0,32)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message or ""
    msgLbl.TextColor3 = SugarUI.Theme.Muted
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 12
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.Parent = notif

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-32,0,8)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = SugarUI.Theme.Muted
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.Parent = notif

    local sizeText = TextService:GetTextSize(message or "", 12, Enum.Font.Gotham, Vector2.new(240,1000))
    local total = math.clamp(52 + sizeText.Y, 60, 120)
    msgLbl.Size = UDim2.new(1,-48,0,sizeText.Y)

    SugarUI.Tween(notif, {Size = UDim2.new(1,0,0,total)}, 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    close.MouseButton1Click:Connect(function() self:Remove(notif) end)
    if duration > 0 then task.delay(duration, function() if notif.Parent then self:Remove(notif) end end) end
    return notif
end

function NotificationSystem:Remove(notif)
    SugarUI.Tween(notif, {Size = UDim2.new(1,0,0,0)}, 0.18)
    task.delay(0.18, function() if notif.Parent then notif:Destroy() end end)
end

-- Window
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local order = 0
    local components = {}

    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1,0,0,40)
    wrap.BackgroundTransparency = 1
    wrap.LayoutOrder = #selfObj.Tabs + 1
    wrap.Parent = selfObj.Sidebar

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 1, 0)
    btn.Position = UDim2.new(0,12,0,0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = SugarUI.Theme.Muted
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = wrap

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,3,1,0)
    indicator.Position = UDim2.new(0,-6,0,0)
    indicator.BackgroundColor3 = SugarUI.Theme.Accent
    indicator.Visible = false
    indicator.Parent = btn
    SugarUI.RoundCorner(1.5).Parent = indicator

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = selfObj.PagesHolder

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0,12,0,12)
    scroll.BackgroundTransparency = 1
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.Parent = page

    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,8)

    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0,4)
    padding.PaddingLeft = UDim.new(0,4)
    padding.PaddingRight = UDim.new(0,4)
    padding.PaddingBottom = UDim.new(0,4)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(selfObj.Pages) do p.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            SugarUI.Tween(t.button, {TextColor3 = (t.name == name) and SugarUI.Theme.Text or SugarUI.Theme.Muted}, 0.12)
        end
        selfObj.ActiveTab = name
    end)

    local obj = {
        name = name,
        button = btn,
        indicator = indicator,
        page = page,
        pageInner = scroll,
        layoutOrderCounter = order,
        components = components,
        AddSection = function(_, ttl)
            order = order + 1
            local sec = SectionComponent.new(scroll, ttl)
            sec._wrapper.LayoutOrder = order
            return sec
        end,
        AddButton = function(_, txt, cb)
            order = order + 1
            local b = ButtonComponent.new(scroll, txt, cb)
            b.Instance.LayoutOrder = order
            return b
        end,
        AddToggle = function(_, txt, def, cb, key)
            order = order + 1
            local t = ToggleComponent.new(scroll, txt, def, cb, key)
            t.Instance.LayoutOrder = order
            if key then
                table.insert(components, {type="toggle", key=key, obj=t})
                table.insert(selfObj.Components, {type="toggle", key=key, obj=t})
            end
            return t
        end,
        AddSlider = function(_, txt, a,b,c,cb,key)
            order = order + 1
            local s = SliderComponent.new(scroll, txt, a,b,c,cb,key)
            s.Instance.LayoutOrder = order
            if key then
                table.insert(components, {type="slider", key=key, obj=s})
                table.insert(selfObj.Components, {type="slider", key=key, obj=s})
            end
            return s
        end,
        AddDropdown = function(_, txt, opts, def, cb, multi, key)
            order = order + 1
            local d = DropdownComponent.new(scroll, txt, opts, def, cb, multi, key)
            d.Instance.LayoutOrder = order
            if key then
                table.insert(components, {type="dropdown", key=key, obj=d})
                table.insert(selfObj.Components, {type="dropdown", key=key, obj=d})
            end
            return d
        end,
    }

    table.insert(selfObj.Tabs, obj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        btn.TextColor3 = SugarUI.Theme.Text
        indicator.Visible = true
        page.Visible = true
        selfObj.ActiveTab = name
    end

    return obj
end

function Window.new(title)
    local selfObj = {}
    selfObj.Tabs = {}
    selfObj.Pages = {}
    selfObj.Components = {}
    selfObj.ActiveTab = nil
    selfObj.Visible = true
    selfObj.ToggleKey = Enum.KeyCode.V
    selfObj.MinSize = Vector2.new(300,200)
    selfObj.MaxSize = Vector2.new(800,800)
    selfObj.LastSize = UDim2.new(0.6,0,0.6,0) -- сохраняем

    local player = Players.LocalPlayer
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        if player and player:FindFirstChild("PlayerGui") then ScreenGui.Parent = player.PlayerGui else ScreenGui.Parent = game:GetService("CoreGui") end
    end

    -- OuterFrame: адаптивный размер (scale) с возможностью pixel resize
    local Outer = Instance.new("Frame")
    Outer.Name = "OuterFrame"
    Outer.AnchorPoint = Vector2.new(0.5,0.5)
    Outer.Position = UDim2.new(0.5,0,0.5,0)
    Outer.Size = selfObj.LastSize
    Outer.BackgroundTransparency = 1
    Outer.Parent = ScreenGui

    SugarUI.AddShadow(Outer, 0.7, 12)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = SugarUI.Theme.Background
    Frame.BackgroundTransparency = 0.06 -- лёгкая прозрачность
    Frame.ClipsDescendants = true
    Frame.Parent = Outer
    SugarUI.RoundCorner(8).Parent = Frame
    selfObj.ScreenGui = ScreenGui
    selfObj.OuterFrame = Outer
    selfObj.Frame = Frame

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,48)
    TopBar.BackgroundColor3 = SugarUI.Theme.Panel
    TopBar.BackgroundTransparency = 0.2
    TopBar.Parent = Frame
    SugarUI.RoundCorner(8).Parent = TopBar

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1,-100,1,0)
    TitleLbl.Position = UDim2.new(0,16,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = SugarUI.Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,32,0,32)
    MinBtn.Position = UDim2.new(1, -80, 0.5, -16)
    MinBtn.BackgroundColor3 = SugarUI.Theme.Warning
    MinBtn.Text = "-"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18
    MinBtn.TextColor3 = SugarUI.Theme.Highlight
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    SugarUI.RoundCorner(8).Parent = MinBtn
    MinBtn.MouseButton1Click:Connect(function() selfObj:Hide() end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,32,0,32)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
    CloseBtn.BackgroundColor3 = SugarUI.Theme.Error
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = SugarUI.Theme.Highlight
    CloseBtn.Parent = TopBar
    SugarUI.RoundCorner(8).Parent = CloseBtn
    CloseBtn.MouseButton1Click:Connect(function()
        selfObj:Confirm("Confirm Close", "Are you sure you want to close the UI?", function() ScreenGui:Destroy() end, function() end)
    end)

    -- Sidebar & PagesHolder (зависит от Outer.Size)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -48)
    Sidebar.Position = UDim2.new(0,0,0,48)
    Sidebar.BackgroundColor3 = SugarUI.Theme.Panel
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.Parent = Frame
    SugarUI.RoundCorner(6).Parent = Sidebar

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -160, 1, -48)
    PagesHolder.Position = UDim2.new(0,160,0,48)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder

    local Notifications = NotificationSystem.new(ScreenGui)
    selfObj.Notifications = Notifications

    -- Перетаскивание окна (центрируем всегда)
    local dragging = false
    local dragInput, startPos, startOuterPos
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragInput = inp
            startPos = inp.Position
            startOuterPos = Outer.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp == dragInput and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - startPos
            -- перевод пикселей в offset, оставляем scale прежним
            local newPos = UDim2.new(startOuterPos.X.Scale, startOuterPos.X.Offset + delta.X, startOuterPos.Y.Scale, startOuterPos.Y.Offset + delta.Y)
            Outer.Position = newPos
        end
    end)

    -- Resize: изменяем в пикселях но держим centered Anchor
    local resizing = false
    local resizeMouse, startSize
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Size = UDim2.new(0,20,0,20)
    resizeHandle.AnchorPoint = Vector2.new(1,1)
    resizeHandle.Position = UDim2.new(1,0,1,0)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Parent = Frame

    resizeHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMouse = inp.Position
            startSize = Outer.AbsoluteSize
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - resizeMouse
            local newW = math.clamp(startSize.X + delta.X, selfObj.MinSize.X, math.max(selfObj.MinSize.X, workspace.CurrentCamera.ViewportSize.X - 40))
            local newH = math.clamp(startSize.Y + delta.Y, selfObj.MinSize.Y, math.max(selfObj.MinSize.Y, workspace.CurrentCamera.ViewportSize.Y - 40))
            Outer.Size = UDim2.new(0, newW, 0, newH)
            selfObj.LastSize = Outer.Size
            -- сохранить пиксельный размер
        end
    end)

    -- ToggleKey setup
    local toggleConn
    local function setupToggleKey(key)
        if toggleConn then toggleConn:Disconnect() end
        toggleConn = UserInputService.InputBegan:Connect(function(inp, processed)
            if not processed and inp.KeyCode == key then
                if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
            end
        end)
    end
    setupToggleKey(selfObj.ToggleKey)

    -- Mobile support: создаём кнопку для мобильных устройств
    local mobileButton, mobileLockBtn
    local mobileLocked = true
    local mobileDragging = false
    local mobileDragInput, mobileStartPos, mobileStartPosFrame

    if UserInputService.TouchEnabled then
        mobileButton = Instance.new("TextButton")
        mobileButton.Size = UDim2.new(0,100,0,36)
        mobileButton.Position = UDim2.new(0, 20, 1, -80)
        mobileButton.AnchorPoint = Vector2.new(0,0)
        mobileButton.Text = "Toggle UI"
        mobileButton.Font = Enum.Font.GothamBold
        mobileButton.TextSize = 14
        mobileButton.BackgroundColor3 = SugarUI.Theme.Panel
        mobileButton.TextColor3 = SugarUI.Theme.Text
        mobileButton.Parent = ScreenGui
        SugarUI.RoundCorner(8).Parent = mobileButton
        mobileButton.ZIndex = 1100

        mobileLockBtn = Instance.new("TextButton")
        mobileLockBtn.Size = UDim2.new(0,36,0,36)
        mobileLockBtn.Position = UDim2.new(0, 130, 1, -80)
        mobileLockBtn.AnchorPoint = Vector2.new(0,0)
        mobileLockBtn.Text = "🔒"
        mobileLockBtn.Font = Enum.Font.Gotham
        mobileLockBtn.TextSize = 18
        mobileLockBtn.BackgroundColor3 = SugarUI.Theme.Panel
        mobileLockBtn.TextColor3 = SugarUI.Theme.Text
        mobileLockBtn.Parent = ScreenGui
        SugarUI.RoundCorner(8).Parent = mobileLockBtn
        mobileLockBtn.ZIndex = 1100

        mobileButton.InputBegan:Connect(function(inp)
            if mobileLocked then
                if inp.UserInputType == Enum.UserInputType.Touch then
                    -- short tap toggles UI
                    mobileButton.MouseButton1Click:Wait()
                end
                return
            end
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                mobileDragging = true
                mobileDragInput = inp
                mobileStartPos = inp.Position
                mobileStartPosFrame = mobileButton.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then mobileDragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if mobileDragging and inp == mobileDragInput and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - mobileStartPos
                mobileButton.Position = UDim2.new(mobileStartPosFrame.X.Scale, mobileStartPosFrame.X.Offset + delta.X, mobileStartPosFrame.Y.Scale, mobileStartPosFrame.Y.Offset + delta.Y)
            end
        end)

        mobileButton.MouseButton1Click:Connect(function()
            if selfObj.Visible then selfObj:Hide() else selfObj:Show() end
        end)
        mobileLockBtn.MouseButton1Click:Connect(function()
            mobileLocked = not mobileLocked
            mobileLockBtn.Text = mobileLocked and "🔒" or "🔓"
        end)
    end

    -- Простая show/hide: всё одновременно, центрируемся и сохраняем размер
    function selfObj:Show()
        selfObj.Visible = true
        -- при показе центрируем
        Outer.AnchorPoint = Vector2.new(0.5,0.5)
        Outer.Position = UDim2.new(0.5,0,0.5,0)
        -- если ранее был pixel-Size, сохраняем, иначе используем LastSize
        if selfObj.LastSize then Outer.Size = selfObj.LastSize end
        SugarUI.Tween(Outer, {Position = UDim2.new(0.5,0,0.5,0)}, 0.18)
        SugarUI.Tween(Frame, {BackgroundTransparency = 0.06}, 0.18)
        -- уведомление о загрузке UI, при первом открытии
        pcall(function() Notifications:Notify("Sugar UI", "Loaded. Press " .. selfObj.ToggleKey.Name .. " to toggle.", 3, "Info") end)
    end

    function selfObj:Hide()
        selfObj.Visible = false
        -- сохраняем текущ размер
        selfObj.LastSize = Outer.Size
        SugarUI.Tween(Frame, {BackgroundTransparency = 1}, 0.18)
        -- смещаем вниз немного и скрываем после твина
        SugarUI.Tween(Outer, {Position = UDim2.new(0.5,0,0.5,24)}, 0.18)
        task.delay(0.2, function()
            if not selfObj.Visible then
                Outer.Position = UDim2.new(0.5,0,0.5,0)
                Outer.Visible = false
            end
        end)
        pcall(function() Notifications:Notify("Info", "GUI hidden. Press " .. selfObj.ToggleKey.Name .. " to show.", 3, "Info") end)
    end

    -- Confirm
    function selfObj:Confirm(title, msg, yesCb, noCb)
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3 = Color3.new(0,0,0)
        overlay.BackgroundTransparency = 0.5
        overlay.Parent = ScreenGui
        overlay.ZIndex = 2000

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0,300,0,150)
        panel.Position = UDim2.new(0.5,-150,0.5,-75)
        panel.BackgroundColor3 = SugarUI.Theme.Panel
        panel.Parent = overlay
        SugarUI.RoundCorner(8).Parent = panel
        SugarUI.AddShadow(panel, 0.5, 8)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,-20,0,30)
        titleLbl.Position = UDim2.new(0,10,0,10)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = SugarUI.Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16
        titleLbl.Parent = panel

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1,-20,0,60)
        msgLbl.Position = UDim2.new(0,10,0,40)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = msg
        msgLbl.TextColor3 = SugarUI.Theme.Muted
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 14
        msgLbl.TextWrapped = true
        msgLbl.Parent = panel

        local yesBtn = ButtonComponent.new(panel, "Yes", function()
            overlay:Destroy()
            if yesCb then yesCb() end
        end)
        yesBtn.Instance.Size = UDim2.new(0.4,0,0,30)
        yesBtn.Instance.Position = UDim2.new(0.1,0,1,-40)

        local noBtn = ButtonComponent.new(panel, "No", function()
            overlay:Destroy()
            if noCb then noCb() end
        end)
        noBtn.Instance.Size = UDim2.new(0.4,0,0,30)
        noBtn.Instance.Position = UDim2.new(0.5,0,1,-40)
    end

    -- API
    function selfObj:AddTab(name) return createTab(selfObj, name) end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end
    function selfObj:GetActiveTab() for _, t in ipairs(selfObj.Tabs) do if t.name == selfObj.ActiveTab then return t end end return nil end
    function selfObj:SetToggleKey(k) setupToggleKey(k); selfObj.ToggleKey = k; SugarUI.CurrentConfig["ToggleKey"] = k.Name end
    function selfObj:Notify(t,m,d,ty) return Notifications:Notify(t,m,d,ty) end

    function selfObj:ApplyConfig(config)
        if type(config) ~= "table" then return end
        for _, comp in ipairs(selfObj.Components) do
            local v = config[comp.key]
            if v ~= nil then
                if comp.type == "toggle" and comp.obj.Set then
                    comp.obj.Set(v, false)
                elseif comp.type == "slider" and comp.obj.SetValue then
                    comp.obj.SetValue(tonumber(v) or v, false)
                elseif comp.type == "dropdown" and comp.obj.SetValue then
                    comp.obj.SetValue(v)
                end
            end
        end
        if config["ToggleKey"] then
            local k = Enum.KeyCode[config["ToggleKey"]]
            if k then selfObj:SetToggleKey(k) end
        end
        -- уведомление после применения конфига
        pcall(function() selfObj:Notify("Config", "Configuration applied.", 3, "Info") end)
    end

    -- Центрировать при изменении размера экрана
    RunService:GetPropertyChangedSignal("RenderStepped"):Connect(function() end) -- noop to ensure RunService load
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() end) -- noop
    -- Лучше подписаться на изменение viewport:
    RunService.Heartbeat:Connect(function()
        -- гарантируем что окно не уезжает за пределы экрана: оставляем центр
        if Outer and Outer.Parent then
            Outer.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end)

    -- Показываем по умолчанию
    task.defer(function() wait(0.05) selfObj:Show() end)

    return selfObj
end

function SugarUI:CreateWindow(title)
    SugarUI.CurrentConfig = SugarUI.CurrentConfig or {}
    local window = Window.new(title)
    return window
end

return SugarUI

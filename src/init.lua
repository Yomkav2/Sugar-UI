-- init.lua (Sugar UI, enhanced redesign: improved layout, aesthetics, shadows, sections, better theming)
local UILib = {}
UILib.__index = UILib

-- ======================
-- Enhanced Theme with more depth
-- ======================
local Theme = {
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
}

-- ======================
-- Tween helper with better defaults
-- ======================
local Tween = {}
do
    local TweenService = game:GetService("TweenService")
    function Tween.To(instance, props, duration, style, dir)
        style = style or Enum.EasingStyle.Sine
        dir = dir or Enum.EasingDirection.InOut
        local ok, t = pcall(function()
            return TweenService:Create(instance, TweenInfo.new(duration or 0.2, style, dir), props)
        end)
        if ok and t then t:Play() end
        return t
    end
end

-- ======================
-- Shadow helper
-- ======================
local function AddShadow(frame, transparency)
    local shadow = Instance.new("UIStroke")
    shadow.Transparency = transparency or 0.7
    shadow.Color = Theme.Shadow
    shadow.Thickness = 1
    shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Rotation = 90
    gradient.Parent = shadow
    shadow.Parent = frame
    return shadow
end

-- ======================
-- Button component (enhanced with ripple effect)
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 40)
    wrapper.BackgroundTransparency = 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Theme.Panel
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Text = text or "Button"
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = wrapper

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Border
    stroke.Transparency = 0.8

    -- Ripple effect
    local rippleHolder = Instance.new("Frame")
    rippleHolder.Size = UDim2.new(1, 0, 1, 0)
    rippleHolder.BackgroundTransparency = 1
    rippleHolder.ClipsDescendants = true
    rippleHolder.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween.To(btn, {BackgroundColor3 = Theme.AccentSoft}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween.To(btn, {BackgroundColor3 = Theme.Panel}, 0.15)
    end)

    if type(callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            -- Ripple animation
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = Theme.Highlight
            ripple.BackgroundTransparency = 0.7
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Parent = rippleHolder
            local rippleCorner = Instance.new("UICorner", ripple)
            rippleCorner.CornerRadius = UDim.new(1, 0)
            Tween.To(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad)
            task.delay(0.4, function() if ripple then ripple:Destroy() end end)

            pcall(callback)
            Tween.To(btn, {BackgroundColor3 = Theme.AccentDark}, 0.1)
            task.delay(0.1, function()
                if btn and btn.Parent then Tween.To(btn, {BackgroundColor3 = Theme.AccentSoft}, 0.15) end
            end)
        end)
    end

    wrapper.Parent = parent
    self._wrapper = wrapper
    self._button = btn
    return self
end

function ButtonComponent:SetText(text)
    if self._button then self._button.Text = text end
end

-- ======================
-- Toggle component (enhanced with smooth slide)
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback)
    local self = setmetatable({}, ToggleComponent)
    local state = (default == true)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 40)
    wrapper.BackgroundTransparency = 1

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Theme.Panel
    bg.BorderSizePixel = 0
    bg.Parent = wrapper

    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", bg)
    stroke.Color = Theme.Border
    stroke.Transparency = 0.8

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local toggleHolder = Instance.new("Frame")
    toggleHolder.Size = UDim2.new(0, 50, 0, 24)
    toggleHolder.Position = UDim2.new(1, -62, 0.5, -12)
    toggleHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleHolder.Parent = bg

    local toggleCorner = Instance.new("UICorner", toggleHolder)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(state and 0.55 or 0.05, 0, 0.5, -11)
    knob.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(200, 200, 200)
    knob.Parent = toggleHolder

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    local knobShadow = AddShadow(knob, 0.5)

    local function set_state(newState, fire)
        state = not not newState
        Tween.To(knob, {Position = UDim2.new(state and 0.55 or 0.05, 0, 0.5, -11)}, 0.15)
        Tween.To(knob, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(200, 200, 200)}, 0.15)
        if fire and type(callback) == "function" then pcall(callback, state) end
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            set_state(not state, true)
        end
    end)

    wrapper.Parent = parent
    self._wrapper = wrapper
    self._state = state
    set_state(state, false)
    return self
end

function ToggleComponent:Set(state)
    self._state = state
    -- Update visuals accordingly (similar to set_state without fire)
end

function ToggleComponent:Get() return self._state end

-- ======================
-- Section component (new: for grouping elements)
-- ======================
local SectionComponent = {}
SectionComponent.__index = SectionComponent

function SectionComponent.new(parent, title)
    local self = setmetatable({}, SectionComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 30)
    wrapper.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Section"
    label.TextColor3 = Theme.Muted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    wrapper.Parent = parent
    return self
end

-- ======================
-- Window & Tabs (enhanced with better spacing, shadows)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local layoutOrderCounter = 0

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
    tabBtn.TextColor3 = Theme.Muted
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = btnWrap

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 1, 0)
    indicator.Position = UDim2.new(0, -6, 0, 0)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.Visible = false
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn

    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 3)

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
    scrollingFrame.ScrollBarImageColor3 = Theme.Border
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.Parent = page

    local list = Instance.new("UIListLayout", scrollingFrame)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local padding = Instance.new("UIPadding", scrollingFrame)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)

    tabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(selfObj.Pages) do v.Visible = false end
        page.Visible = true
        for _, t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            t.button.TextColor3 = (t.name == name) and Theme.Text or Theme.Muted
            Tween.To(t.button, {TextColor3 = (t.name == name) and Theme.Text or Theme.Muted}, 0.15)
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
        AddSection = function(_, ttl) 
            layoutOrderCounter = layoutOrderCounter + 1
            local sec = SectionComponent.new(scrollingFrame, ttl)
            sec._wrapper.LayoutOrder = layoutOrderCounter
            return sec 
        end,
        AddButton = function(_, txt, cb)
            layoutOrderCounter = layoutOrderCounter + 1
            local btn = ButtonComponent.new(scrollingFrame, txt, cb)
            btn._wrapper.LayoutOrder = layoutOrderCounter
            return btn
        end,
        AddToggle = function(_, txt, def, cb)
            layoutOrderCounter = layoutOrderCounter + 1
            local tog = ToggleComponent.new(scrollingFrame, txt, def, cb)
            tog._wrapper.LayoutOrder = layoutOrderCounter
            return tog
        end,
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = Theme.Text
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

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILibEnhanced"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    local ok, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok or not ScreenGui.Parent then
        local player = game:GetService("Players").LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then ScreenGui.Parent = player.PlayerGui else ScreenGui.Parent = game:GetService("CoreGui") end
    end

    local OuterFrame = Instance.new("Frame")
    OuterFrame.Size = UDim2.new(0, 460, 0, 340)
    OuterFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
    OuterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Parent = ScreenGui

    -- Drop shadow
    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Size = UDim2.new(1, 20, 1, 20)
    ShadowFrame.Position = UDim2.new(0, -10, 0, -10)
    ShadowFrame.BackgroundColor3 = Theme.Shadow
    ShadowFrame.BackgroundTransparency = 0.5
    ShadowFrame.Parent = OuterFrame
    local shadowCorner = Instance.new("UICorner", ShadowFrame)
    shadowCorner.CornerRadius = UDim.new(0, 16)
    local shadowGradient = Instance.new("UIGradient", ShadowFrame)
    shadowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    }
    shadowGradient.Rotation = 45

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 1, -20)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = OuterFrame

    local frameCorner = Instance.new("UICorner", Frame)
    frameCorner.CornerRadius = UDim.new(0, 12)

    AddShadow(Frame, 0.3)

    -- Drag support (unchanged)
    local dragging = false
    local dragInput, mousePos, framePos
    local UserInputService = game:GetService("UserInputService")
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = OuterFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            OuterFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                            framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    -- Top bar with title and close (enhanced)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = Theme.Panel
    TopBar.Parent = Frame

    local topCorner = Instance.new("UICorner", TopBar)
    topCorner.CornerRadius = UDim.new(0, 12)

    local topStroke = Instance.new("UIStroke", TopBar)
    topStroke.Color = Theme.Border
    topStroke.Transparency = 0.9
    topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -60, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Sugar UI"
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 77, 77)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cc = Instance.new("UICorner", CloseBtn)
    cc.CornerRadius = UDim.new(0, 8)

    CloseBtn.MouseEnter:Connect(function()
        Tween.To(CloseBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween.To(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 77, 77)}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Sidebar (enhanced)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = Theme.Panel
    Sidebar.Parent = Frame

    local sideStroke = Instance.new("UIStroke", Sidebar)
    sideStroke.Color = Theme.Border
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

    -- Pages holder
    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -160, 1, -48)
    PagesHolder.Position = UDim2.new(0, 160, 0, 48)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = Frame

    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Frame
    selfObj.Sidebar = Sidebar
    selfObj.PagesHolder = PagesHolder
    selfObj.GlobalContainer = PagesHolder

    function selfObj:AddTab(name) return createTab(selfObj, name) end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end
    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs) do if t.name == selfObj.ActiveTab then return t end end
        return nil
    end

    return selfObj
end

function UILib:CreateWindow(title)
    return Window.new(title)
end

return UILib

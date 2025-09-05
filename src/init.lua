-- init.lua (single-file, injector-friendly, with Tabs + improved design)
-- Sugar UI (single-file bundle)
-- Включает: UILib, Window, Utils (Tween, Theme), Components (Button, Toggle), Tabs API

local UILib = {}
UILib.__index = UILib

-- ======================
-- Utils: Theme
-- ======================
local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Panel = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(54, 137, 255),
    AccentSoft = Color3.fromRGB(39, 107, 200),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(170, 170, 170),
    Shadow = Color3.fromRGB(0,0,0)
}

-- ======================
-- Utils: Tween wrapper
-- ======================
local Tween = {}
do
    local TweenService = game:GetService("TweenService")
    function Tween.To(instance, properties, duration, style, dir)
        style = style or Enum.EasingStyle.Quad
        dir = dir or Enum.EasingDirection.Out
        local ok, result = pcall(function()
            return TweenService:Create(instance, TweenInfo.new(duration or 0.18, style, dir), properties)
        end)
        if ok and result then
            result:Play()
            return result
        end
        return nil
    end
end

-- ======================
-- Components: Button
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(parent, text, callback)
    local self = setmetatable({}, ButtonComponent)

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 34)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.LayoutOrder = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 1, -8)
    btn.Position = UDim2.new(0, 6, 0, 4)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = Theme.Panel
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = tostring(text or "Button")
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.Parent = wrapper

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(0,0,0)
    stroke.Transparency = 0.75
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Thickness = 1

    -- hover animation
    btn.MouseEnter:Connect(function()
        Tween.To(btn, {BackgroundColor3 = Theme.AccentSoft}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween.To(btn, {BackgroundColor3 = Theme.Panel}, 0.12)
    end)

    -- click connection
    if type(callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(callback)
            if not ok then warn("Button callback error:", err) end
            -- quick press animation
            Tween.To(btn, {BackgroundColor3 = Theme.Accent}, 0.06)
            task.delay(0.06, function()
                if btn and btn.Parent then Tween.To(btn, {BackgroundColor3 = Theme.AccentSoft}, 0.08) end
            end)
        end)
    end

    wrapper.Parent = parent
    self._wrapper = wrapper
    self._button = btn

    return self
end

function ButtonComponent:SetText(text)
    if self._button then self._button.Text = tostring(text) end
end

-- ======================
-- Components: Toggle
-- ======================
local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent

function ToggleComponent.new(parent, text, default, callback)
    local self = setmetatable({}, ToggleComponent)
    local state = (default == true)

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 34)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.LayoutOrder = 1

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -12, 1, -8)
    bg.Position = UDim2.new(0, 6, 0, 4)
    bg.BackgroundColor3 = Theme.Panel
    bg.BorderSizePixel = 0
    bg.Parent = wrapper
    bg.Name = "ToggleBg"
    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text or "Toggle")
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 56, 0, 22)
    toggleBtn.Position = UDim2.new(1, -66, 0.5, -11)
    toggleBtn.AnchorPoint = Vector2.new(0, 0)
    toggleBtn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(90, 90, 90)
    toggleBtn.Text = state and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamSemibold
    toggleBtn.TextSize = 12
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = bg

    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0, 6)

    local function set_state(newState, fire)
        state = not not newState
        if toggleBtn then
            Tween.To(toggleBtn, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(90,90,90)}, 0.12)
            toggleBtn.Text = state and "ON" or "OFF"
        end
        if fire and type(callback) == "function" then
            local ok, err = pcall(callback, state)
            if not ok then warn("Toggle callback error:", err) end
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        set_state(not state, true)
    end)

    wrapper.Parent = parent
    self._wrapper = wrapper
    self._state = state
    self._button = toggleBtn

    set_state(state, false)
    return self
end

function ToggleComponent:Set(state)
    if self._button then
        local ok,_ = pcall(function()
            self._button.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(90,90,90)
            self._button.Text = state and "ON" or "OFF"
            self._state = state and true or false
        end)
    end
end

function ToggleComponent:Get()
    return self._state
end

-- ======================
-- Window + Tabs
-- ======================
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    -- try set parent to CoreGui, else PlayerGui
    do
        local setok, seterr = pcall(function()
            ScreenGui.Parent = game:GetService("CoreGui")
        end)
        if not setok or not ScreenGui.Parent then
            local player = game:GetService("Players").LocalPlayer
            if player and player:FindFirstChild("PlayerGui") then
                ScreenGui.Parent = player.PlayerGui
            else
                ScreenGui.Parent = game:GetService("CoreGui") -- last resort
            end
        end
    end

    -- Shadow (simple subtle shadow behind main frame)
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(0, 420, 0, 300)
    Shadow.Position = UDim2.new(0.5, -210+6, 0.5, -150+6) -- offset for shadow
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundColor3 = Theme.Shadow
    Shadow.BackgroundTransparency = 0.78
    Shadow.ZIndex = 0
    Shadow.Parent = ScreenGui
    local shadowCorner = Instance.new("UICorner", Shadow)
    shadowCorner.CornerRadius = UDim.new(0, 14)

    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Name = "SugarUI_Main"
    Frame.Size = UDim2.new(0, 420, 0, 300)
    Frame.Position = UDim2.new(0.5, -210, 0.5, -150)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.ClipsDescendants = true
    Frame.ZIndex = 1

    local frameCorner = Instance.new("UICorner", Frame)
    frameCorner.CornerRadius = UDim.new(0, 12)

    -- Top bar with title + controls
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, -8, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = tostring(title or "Sugar UI")
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0.3, -12, 1, 0)
    Controls.Position = UDim2.new(0.7, 0, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 32, 0, 28)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -14)
    CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 77, 77)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    local closeCorner = Instance.new("UICorner", CloseBtn)
    closeCorner.CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function()
        pcall(function() if ScreenGui then ScreenGui:Destroy() end end)
    end)
    CloseBtn.MouseEnter:Connect(function() Tween.To(CloseBtn, {BackgroundColor3 = Color3.fromRGB(235,65,65)}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() Tween.To(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255,77,77)}, 0.12) end)

    -- Left sidebar (tabs)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Frame

    local sideBg = Instance.new("Frame")
    sideBg.Size = UDim2.new(1, 0, 1, 0)
    sideBg.Position = UDim2.new(0, 0, 0, 0)
    sideBg.BackgroundColor3 = Theme.Panel
    sideBg.BorderSizePixel = 0
    sideBg.Parent = Sidebar
    local sideCorner = Instance.new("UICorner", sideBg)
    sideCorner.CornerRadius = UDim.new(0, 12)

    local tabsLayout = Instance.new("UIListLayout", sideBg)
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local tabsPadding = Instance.new("UIPadding", sideBg)
    tabsPadding.PaddingTop = UDim.new(0, 10)
    tabsPadding.PaddingLeft = UDim.new(0, 6)
    tabsPadding.PaddingRight = UDim.new(0, 6)

    -- Content area (pages)
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -120, 1, -40)
    Content.Position = UDim2.new(0, 120, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Frame

    local contentBg = Instance.new("Frame")
    contentBg.Size = UDim2.new(1, -24, 1, -24)
    contentBg.Position = UDim2.new(0, 12, 0, 12)
    contentBg.BackgroundColor3 = Theme.Panel
    contentBg.BorderSizePixel = 0
    contentBg.Parent = Content
    local contentCorner = Instance.new("UICorner", contentBg)
    contentCorner.CornerRadius = UDim.new(0, 10)

    -- global container (for window:AddButton etc)
    local GlobalContainer = Instance.new("Frame")
    GlobalContainer.Size = UDim2.new(1, -24, 0, 0)
    GlobalContainer.Position = UDim2.new(0, 12, 0, 12)
    GlobalContainer.AutomaticSize = Enum.AutomaticSize.Y
    GlobalContainer.BackgroundTransparency = 1
    GlobalContainer.Parent = contentBg
    local globalLayout = Instance.new("UIListLayout", GlobalContainer)
    globalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    globalLayout.Padding = UDim.new(0, 8)

    -- pages holder
    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -24, 1, -40)
    PagesHolder.Position = UDim2.new(0, 12, 0, 12)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = contentBg

    local pagesPadding = Instance.new("UIPadding", PagesHolder)
    pagesPadding.PaddingTop = UDim.new(0, 8)

    -- store data in self
    self.ScreenGui = ScreenGui
    self.Frame = Frame
    self.Title = Title
    self.Sidebar = sideBg
    self.Tabs = {}         -- list of tabs
    self.Pages = {}        -- name -> page frame
    self.PagesHolder = PagesHolder
    self.GlobalContainer = GlobalContainer
    self.ActiveTab = nil

    -- draggable Title area
    do
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Tween.To(Frame, {Position = newPos}, 0.12)
            Tween.To(Shadow, {Position = UDim2.new(newPos.X.Scale, newPos.X.Offset+6, newPos.Y.Scale, newPos.Y.Offset+6)}, 0.12)
        end

        Title.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        Title.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    setmetatable(self, Window)
    return self
end

-- Internal helper to create a tab button + page
local function createTab(self, name)
    -- tab button
    local btnWrap = Instance.new("Frame")
    btnWrap.Size = UDim2.new(1, -12, 0, 36)
    btnWrap.BackgroundTransparency = 1
    btnWrap.LayoutOrder = #self.Tabs + 1
    btnWrap.Parent = self.Sidebar

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextColor3 = Theme.Text
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = btnWrap
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Position = UDim2.new(0, 12, 0, 0)

    -- selected indicator (small bar at left)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0.7, 0)
    indicator.Position = UDim2.new(0, 6, 0.15, 0)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.Visible = false
    indicator.BorderSizePixel = 0
    indicator.Parent = btnWrap
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 3)

    -- hover effect
    tabBtn.MouseEnter:Connect(function()
        Tween.To(tabBtn, {TextColor3 = Theme.Accent}, 0.12)
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            Tween.To(tabBtn, {TextColor3 = Theme.Text}, 0.12)
        else
            Tween.To(tabBtn, {TextColor3 = Theme.Text}, 0.12)
        end
    end)

    -- page frame
    local page = Instance.new("Frame")
    page.Name = "Page_" .. tostring(name)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.PagesHolder

    local pageInner = Instance.new("Frame")
    pageInner.Size = UDim2.new(1, -24, 1, -24)
    pageInner.Position = UDim2.new(0, 12, 0, 12)
    pageInner.BackgroundTransparency = 1
    pageInner.Parent = page

    local list = Instance.new("UIListLayout", pageInner)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    -- connect click
    tabBtn.MouseButton1Click:Connect(function()
        -- switch
        for k,v in pairs(self.Pages) do
            if v == page then
                v.Visible = true
                Tween.To(v, {ImageTransparency = 0}, 0.12) -- no-op but keeps style
            else
                v.Visible = false
            end
        end
        -- update ActiveTab visuals
        for _, t in ipairs(self.Tabs) do
            t.indicator.Visible = (t.name == name)
            t.button.TextColor3 = (t.name == name) and Theme.Text or Theme.Muted
        end
        self.ActiveTab = name
    end)

    -- add to registry
    local tabObj = {
        name = name,
        button = tabBtn,
        wrapper = btnWrap,
        indicator = indicator,
        page = page,
        pageInner = pageInner,
        AddButton = function(_, text, cb)
            return ButtonComponent.new(pageInner, text, cb)
        end,
        AddToggle = function(_, text, def, cb)
            return ToggleComponent.new(pageInner, text, def, cb)
        end,
        -- alias
        Add = function(_, compType, ...)
            if compType == "Button" then return ButtonComponent.new(pageInner, ...) end
            if compType == "Toggle" then return ToggleComponent.new(pageInner, ...) end
            return nil
        end
    }

    table.insert(self.Tabs, tabObj)
    self.Pages[name] = page
    return tabObj
end

-- Public API: AddTab / AddPage (alias)
function Window:AddTab(name)
    assert(type(name) == "string", "tab name must be string")
    local tab = createTab(self, name)
    -- if first tab, activate it
    if not self.ActiveTab then
        tab.button.TextColor3 = Theme.Text
        tab.indicator.Visible = true
        tab.page.Visible = true
        self.ActiveTab = name
    else
        tab.button.TextColor3 = Theme.Muted
    end
    return tab
end
Window.AddPage = Window.AddTab

-- Public API: AddButton (global, outside tabs)
function Window:AddButton(text, callback)
    return ButtonComponent.new(self.GlobalContainer, text, callback)
end

-- Public API: AddToggle (global)
function Window:AddToggle(text, default, callback)
    return ToggleComponent.new(self.GlobalContainer, text, default, callback)
end

-- Convenience: get active tab object
function Window:GetActiveTab()
    for _, t in ipairs(self.Tabs) do
        if t.name == self.ActiveTab then return t end
    end
    return nil
end

-- API exporter
function UILib:CreateWindow(title)
    return Window.new(title)
end

pcall(function() print("[SugarUI] single-file init (tabs + UI) loaded.") end)
return UILib

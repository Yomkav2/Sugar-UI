-- init.lua (Sugar UI — full redesign)
-- Требует: клиентский LocalScript. Подходит для стандартного Roblox и для exploit сред (если доступны writefile/readfile).

local UILib = {}
UILib.__index = UILib

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ======================
-- Theme (refined)
-- ======================
local Theme = {
    Background = Color3.fromRGB(18,18,18),
    Panel = Color3.fromRGB(28,28,28),
    Accent = Color3.fromRGB(98,182,246),
    AccentSoft = Color3.fromRGB(70,150,230),
    AccentDark = Color3.fromRGB(1,106,170),
    Text = Color3.fromRGB(235,235,235),
    Muted = Color3.fromRGB(150,150,150),
    Shadow = Color3.fromRGB(0,0,0),
    Border = Color3.fromRGB(45,45,45),
    Highlight = Color3.fromRGB(255,255,255),
}

-- ======================
-- Tween helper
-- ======================
local function TweenTo(instance, props, duration, style, dir)
    style = style or Enum.EasingStyle.Sine
    dir = dir or Enum.EasingDirection.InOut
    duration = duration or 0.18
    local info = TweenInfo.new(duration, style, dir)
    local ok, t = pcall(function() return TweenService:Create(instance, info, props) end)
    if ok and t then t:Play(); return t end
    return nil
end

-- ======================
-- Utilities
-- ======================
local function make(name, class, props)
    local obj = Instance.new(class)
    obj.Name = name
    if props then
        for k,v in pairs(props) do obj[k] = v end
    end
    return obj
end

local function addShadow(element, transparency)
    -- subtle border shadow using UIStroke + gradient overlay
    local stroke = make("ShadowStroke", "UIStroke", {Color = Theme.Shadow, Transparency = transparency or 0.7, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    stroke.Parent = element
    return stroke
end

-- ======================
-- File-based config storage (with fallback)
-- ======================
local Config = {}
do
    local supported = (type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function")
    local folder = "SugarUIConfigs"
    local sessionStoreFolder = "_SugarUIConfigsSession"
    -- ensure ReplicatedStorage fallback folder
    if not ReplicatedStorage:FindFirstChild(sessionStoreFolder) then
        local f = Instance.new("Folder")
        f.Name = sessionStoreFolder
        f.Parent = ReplicatedStorage
    end

    local function safeMakeFolder()
        if supported and type(makefolder) == "function" then
            pcall(function() makefolder(folder) end)
        end
    end

    function Config.Save(name, tbl)
        local json = HttpService:JSONEncode(tbl or {})
        if supported then
            safeMakeFolder()
            local ok, err = pcall(function() writefile(folder.."/"..name..".json", json) end)
            return ok, err
        else
            -- fallback to ReplicatedStorage StringValue
            local container = ReplicatedStorage[sessionStoreFolder]
            local sv = container:FindFirstChild(name)
            if not sv then
                sv = Instance.new("StringValue")
                sv.Name = name
                sv.Parent = container
            end
            sv.Value = json
            return true
        end
    end

    function Config.Load(name)
        if supported then
            if isfile(folder.."/"..name..".json") then
                local ok, content = pcall(function() return readfile(folder.."/"..name..".json") end)
                if ok and content then
                    local ok2, tbl = pcall(function() return HttpService:JSONDecode(content) end)
                    if ok2 then return true, tbl end
                    return false, "decode error"
                end
                return false, "read error"
            end
            return false, "not found"
        else
            local container = ReplicatedStorage[sessionStoreFolder]
            local sv = container:FindFirstChild(name)
            if sv then
                local ok, tbl = pcall(function() return HttpService:JSONDecode(sv.Value) end)
                if ok then return true, tbl end
                return false, "decode error"
            end
            return false, "not found"
        end
    end

    function Config.List()
        if supported then
            -- limited: attempt to use listfiles if available; otherwise attempt to list by scanning typical filesystem not available
            if type(listfiles) == "function" then
                local ok, files = pcall(function() return listfiles(folder) end)
                if ok and type(files) == "table" then
                    local out = {}
                    for _,f in ipairs(files) do
                        local nm = f:match("([^/\\]+)%.json$")
                        if nm then table.insert(out, nm) end
                    end
                    return out
                end
            end
            -- fallback: not available
            return {}
        else
            local out = {}
            for _,v in ipairs(ReplicatedStorage["_SugarUIConfigsSession"]:GetChildren()) do
                if v:IsA("StringValue") then table.insert(out, v.Name) end
            end
            return out
        end
    end

    function Config.Remove(name)
        if supported then
            if isfile(folder.."/"..name..".json") then
                pcall(function() delfile(folder.."/"..name..".json") end)
                return true
            end
            return false
        else
            local container = ReplicatedStorage["_SugarUIConfigsSession"]
            local sv = container:FindFirstChild(name)
            if sv then sv:Destroy(); return true end
            return false
        end
    end
end

-- ======================
-- Notifications system
-- ======================
local Notification = {}
Notification.__index = Notification
do
    local notifFolder = nil
    function Notification.init(parent)
        if notifFolder and notifFolder.Parent then return notifFolder end
        notifFolder = make("SugarNotifs", "Frame", {
            Size = UDim2.new(0, 320, 0, 200),
            Position = UDim2.new(1, -340, 0, 20),
            BackgroundTransparency = 1,
            Parent = parent,
            ZIndex = 9999
        })
        local layout = make("Layout", "UIListLayout", {Padding = UDim.new(0,8), FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Right})
        layout.Parent = notifFolder
        return notifFolder
    end

    function Notification.show(parent, title, text, timeout)
        timeout = timeout or 4
        local container = Notification.init(parent)
        local card = make("Card", "Frame", {Size = UDim2.new(1,0,0,70), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Parent = container})
        local corner = make("Corner", "UICorner", {CornerRadius = UDim.new(0,8)}); corner.Parent = card
        local stroke = make("Stroke", "UIStroke", {Color = Theme.Border, Transparency = 0.9}); stroke.Parent = card
        addShadow(card, 0.35)

        local titleLbl = make("Title", "TextLabel", {Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1, Text = title or "Info", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        titleLbl.Parent = card
        local textLbl = make("Text", "TextLabel", {Size = UDim2.new(1,-16,0,36), Position = UDim2.new(0,8,0,30), BackgroundTransparency = 1, Text = text or "", TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left})
        textLbl.Parent = card

        card.AnchorPoint = Vector2.new(1,0)
        card.Position = UDim2.new(1, 0, 0, 0)
        card.BackgroundTransparency = 1
        TweenTo(card, {BackgroundTransparency = 0}, 0.12)
        TweenTo(card, {Position = UDim2.new(1, -320, 0, 0)}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        -- auto-dismiss
        task.delay(timeout, function()
            if card and card.Parent then
                TweenTo(card, {BackgroundTransparency = 1}, 0.12)
                TweenTo(card, {Position = UDim2.new(1, 0, 0, 0)}, 0.18)
                task.delay(0.18, function() if card and card.Parent then card:Destroy() end end)
            end
        end)
        return card
    end
end

-- ======================
-- Components
-- ======================
-- Button
local Button = {}
Button.__index = Button
function Button.new(parent, text, cb)
    local wrap = make("BtnWrap", "Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Parent = parent})
    local btn = make("Btn", "TextButton", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = Theme.Panel, Text = text or "Button", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = Theme.Text, BorderSizePixel = 0, AutoButtonColor = false, Parent = wrap})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,8)}).Parent = btn
    make("Stroke","UIStroke",{Color = Theme.Border, Transparency = 0.85}).Parent = btn
    btn.MouseEnter:Connect(function() TweenTo(btn, {BackgroundColor3 = Theme.AccentSoft}, 0.12) end)
    btn.MouseLeave:Connect(function() TweenTo(btn, {BackgroundColor3 = Theme.Panel}, 0.12) end)
    btn.MouseButton1Click:Connect(function()
        -- ripple
        local ripple = make("Ripple", "Frame", {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Theme.Highlight, BackgroundTransparency = 0.7, Parent = btn})
        make("Corner","UICorner",{CornerRadius = UDim.new(1,0)}).Parent = ripple
        TweenTo(ripple, {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1}, 0.45, Enum.EasingStyle.Quad)
        task.delay(0.45, function() if ripple and ripple.Parent then ripple:Destroy() end end)
        pcall(cb)
    end)
    return {Wrap = wrap, Button = btn, SetText = function(_,t) btn.Text = t end}
end

-- Toggle
local Toggle = {}
Toggle.__index = Toggle
function Toggle.new(parent, text, default, cb)
    local wrap = make("ToggleWrap","Frame",{Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Parent = parent})
    local bg = make("BG", "Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Parent = wrap})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,8)}).Parent = bg
    make("Stroke","UIStroke",{Color = Theme.Border, Transparency = 0.85}).Parent = bg
    local label = make("Label","TextLabel",{Size = UDim2.new(0.7,0,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = text or "Toggle", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = bg})
    local holder = make("Holder","Frame",{Size = UDim2.new(0,50,0,26), Position = UDim2.new(1,-64,0.5,-13), BackgroundColor3 = Color3.fromRGB(44,44,44), Parent = bg})
    make("Corner","UICorner",{CornerRadius = UDim.new(1,0)}).Parent = holder
    local knob = make("Knob","Frame",{Size = UDim2.new(0,22,0,22), Position = UDim2.new(default and 0.55 or 0.05,0,0.5,-11), BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(200,200,200), Parent = holder})
    make("Corner","UICorner",{CornerRadius = UDim.new(1,0)}).Parent = knob
    addShadow(knob, 0.5)
    local state = not not default
    local function setState(s, fire)
        state = not not s
        TweenTo(knob, {Position = UDim2.new(state and 0.55 or 0.05,0,0.5,-11)}, 0.14)
        TweenTo(knob, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(200,200,200)}, 0.14)
        if fire and type(cb) == "function" then pcall(cb, state) end
    end
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then setState(not state, true) end
    end)
    return {Wrap = wrap, Set = setState, Get = function() return state end}
end

-- Slider
local Slider = {}
Slider.__index = Slider
function Slider.new(parent, text, min, max, default, cb)
    min = min or 0; max = max or 100; default = default or min
    local wrap = make("SliderWrap","Frame",{Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1, Parent = parent})
    local label = make("Label","TextLabel",{Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Text = text or "Slider", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap})
    local valueLbl = make("Val","TextLabel",{Size = UDim2.new(0,60,0,16), Position = UDim2.new(1,-68,0,4), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 13, Parent = wrap})
    local bar = make("Bar","Frame",{Size = UDim2.new(1,-16,0,12), Position = UDim2.new(0,8,0,28), BackgroundColor3 = Color3.fromRGB(50,50,50), BorderSizePixel = 0, Parent = wrap})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,6)}).Parent = bar
    local fill = make("Fill","Frame",{Size = UDim2.new(0,0,1,0), BackgroundColor3 = Theme.Accent, Parent = bar})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,6)}).Parent = fill
    local knob = make("Knob","Frame",{Size = UDim2.new(0,16,0,16), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0.5,0), BackgroundColor3 = Theme.Highlight, Parent = bar})
    make("Corner","UICorner",{CornerRadius = UDim.new(1,0)}).Parent = knob
    local dragging = false
    local function setValue(val, fire)
        val = math.clamp(val, min, max)
        local pct = (val - min) / (max - min)
        fill.Size = UDim2.new(pct,0,1,0)
        knob.Position = UDim2.new(pct,0,0.5,0)
        valueLbl.Text = tostring(math.round(val*100)/100)
        if fire and type(cb) == "function" then pcall(cb, val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = input.Position
            local barAbsPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local pct = (abs.X - barAbsPos) / barSize
            setValue(min + pct*(max-min), true)
        end
    end)
    -- click on bar
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local abs = input.Position
            local barAbsPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local pct = (abs.X - barAbsPos) / barSize
            setValue(min + pct*(max-min), true)
        end
    end)
    setValue(default, false)
    return {Wrap = wrap, Set = setValue, Get = function()
        local num = tonumber(valueLbl.Text) or default
        return num
    end}
end

-- List (single select)
local List = {}
List.__index = List
function List.new(parent, title, options, default, cb)
    options = options or {}
    local wrap = make("ListWrap","Frame",{Size = UDim2.new(1,0,0,26 + #options*28), BackgroundTransparency = 1, Parent = parent})
    make("Label","TextLabel",{Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = title or "List", Font = Enum.Font.GothamBold, TextColor3 = Theme.Text, TextSize = 13, Parent = wrap})
    local container = make("Container","Frame",{Size = UDim2.new(1,0,0, #options*28), Position = UDim2.new(0,0,0,26), BackgroundTransparency = 1, Parent = wrap})
    local selected = default
    local buttons = {}
    for i,opt in ipairs(options) do
        local b = make("Opt"..i,"TextButton",{Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,0,(i-1)*28), BackgroundColor3 = Theme.Panel, Text = tostring(opt), TextColor3 = (opt==default) and Theme.Text or Theme.Muted, Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0, Parent = container})
        make("Corner","UICorner",{CornerRadius = UDim.new(0,6)}).Parent = b
        b.MouseButton1Click:Connect(function()
            selected = opt
            for _,bb in ipairs(buttons) do bb.TextColor3 = Theme.Muted end
            b.TextColor3 = Theme.Text
            pcall(cb, selected)
        end)
        table.insert(buttons, b)
    end
    return {Wrap = wrap, Get = function() return selected end, SetOptions = function(_,opts)
        -- not implemented for brevity
    end}
end

-- MultiList (multiple select)
local MultiList = {}
MultiList.__index = MultiList
function MultiList.new(parent, title, options, defaultTable, cb)
    options = options or {}
    defaultTable = defaultTable or {}
    local wrap = make("MultiWrap","Frame",{Size = UDim2.new(1,0,0,26 + #options*28), BackgroundTransparency = 1, Parent = parent})
    make("Label","TextLabel",{Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = title or "MultiList", Font = Enum.Font.GothamBold, TextColor3 = Theme.Text, TextSize = 13, Parent = wrap})
    local container = make("Container","Frame",{Size = UDim2.new(1,0,0, #options*28), Position = UDim2.new(0,0,0,26), BackgroundTransparency = 1, Parent = wrap})
    local selected = {}
    for _,v in ipairs(defaultTable) do selected[v] = true end
    for i,opt in ipairs(options) do
        local b = make("Opt"..i,"TextButton",{Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,0,(i-1)*28), BackgroundColor3 = Theme.Panel, Text = tostring(opt), TextColor3 = selected[opt] and Theme.Text or Theme.Muted, Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0, Parent = container})
        make("Corner","UICorner",{CornerRadius = UDim.new(0,6)}).Parent = b
        b.MouseButton1Click:Connect(function()
            selected[opt] = not selected[opt]
            b.TextColor3 = selected[opt] and Theme.Text or Theme.Muted
            local out = {}
            for k,v in pairs(selected) do if v then table.insert(out, k) end end
            pcall(cb, out)
        end)
    end
    return {Wrap = wrap, Get = function()
        local out = {}
        for k,v in pairs(selected) do if v then table.insert(out,k) end end
        return out
    end}
end

-- ======================
-- Window & Tabs (with animated tab switching)
-- ======================
local Window = {}
Window.__index = Window

local function createTab(selfObj, name)
    local idx = #selfObj.Tabs + 1
    local btnWrap = make("TabWrap"..idx, "Frame", {Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1, LayoutOrder = idx, Parent = selfObj.SidebarInner})
    local tabBtn = make("TabBtn"..idx, "TextButton", {Size = UDim2.new(1,-24,0,36), Position = UDim2.new(0,12,0,4), BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamMedium, TextColor3 = Theme.Muted, TextSize = 14, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = btnWrap})
    local indicator = make("Indicator","Frame",{Size = UDim2.new(0,4,0,36), Position = UDim2.new(0,-6,0,4), BackgroundColor3 = Theme.Accent, Visible = false, BorderSizePixel = 0, Parent = btnWrap})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,4)}).Parent = indicator

    local page = make("Page"..idx, "Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, Parent = selfObj.PagesHolder})
    local scrolling = make("Scroll","ScrollingFrame",{Size = UDim2.new(1,-24,1,-24), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, ScrollBarImageTransparency = 0.6, Parent = page})
    make("List","UIListLayout",{Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center}).Parent = scrolling
    make("Padding","UIPadding",{PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}).Parent = scrolling

    local function activate()
        -- animated switch: fade out active, slide new in
        if selfObj.ActivePage and selfObj.ActivePage ~= page then
            local old = selfObj.ActivePage
            TweenTo(old, {Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1}, 0.18)
            task.delay(0.18, function() if old and old.Parent then old.Visible = false end end)
        end
        page.Position = UDim2.new(0, -20, 0, 0)
        page.Visible = true
        TweenTo(page, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Quad)
        -- update tab visuals
        for _,t in ipairs(selfObj.Tabs) do
            t.indicator.Visible = (t.name == name)
            TweenTo(t.button, {TextColor3 = (t.name == name) and Theme.Text or Theme.Muted}, 0.14)
        end
        selfObj.ActivePage = page
        selfObj.ActiveTab = name
    end

    tabBtn.MouseButton1Click:Connect(activate)

    local tabObj = {
        name = name,
        button = tabBtn,
        wrapper = btnWrap,
        indicator = indicator,
        page = page,
        pageInner = scrolling,
        AddSection = function(_, ttl)
            local secWrap = make("Section", "Frame", {Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Parent = scrolling})
            local lbl = make("Lbl","TextLabel",{Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ttl or "Section", TextColor3 = Theme.Muted, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = secWrap})
            secWrap.LayoutOrder = #scrolling:GetChildren()
            return {Wrap = secWrap}
        end,
        AddButton = function(_, txt, cb)
            local btn = Button.new(scrolling, txt, cb)
            btn.Wrap.LayoutOrder = #scrolling:GetChildren()
            return btn
        end,
        AddToggle = function(_, txt, def, cb)
            local tog = Toggle.new(scrolling, txt, def, cb)
            tog.Wrap.LayoutOrder = #scrolling:GetChildren()
            return tog
        end,
        AddSlider = function(_, txt, mn, mx, df, cb)
            local s = Slider.new(scrolling, txt, mn, mx, df, cb)
            s.Wrap.LayoutOrder = #scrolling:GetChildren()
            return s
        end,
        AddList = function(_, txt, opts, def, cb)
            local l = List.new(scrolling, txt, opts, def, cb)
            l.Wrap.LayoutOrder = #scrolling:GetChildren()
            return l
        end,
        AddMultiList = function(_, txt, opts, defTbl, cb)
            local l = MultiList.new(scrolling, txt, opts, defTbl, cb)
            l.Wrap.LayoutOrder = #scrolling:GetChildren()
            return l
        end,
    }

    table.insert(selfObj.Tabs, tabObj)
    selfObj.Pages[name] = page

    if not selfObj.ActiveTab then
        tabBtn.TextColor3 = Theme.Text
        indicator.Visible = true
        page.Visible = true
        selfObj.ActiveTab = name
        selfObj.ActivePage = page
    end

    return tabObj
end

function Window.new(title)
    local selfObj = {}
    selfObj.Tabs = {}
    selfObj.Pages = {}
    selfObj.ActiveTab = nil
    selfObj.Keybind = Enum.KeyCode.RightControl -- default toggle key

    -- ScreenGui parent robust
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

    -- Outer container
    local Outer = make("Outer","Frame",{Size = UDim2.new(0,720,0,420), Position = UDim2.new(0.5,-360,0.5,-210), AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Parent = ScreenGui})
    -- drop shadow
    local Shadow = make("Shadow","Frame",{Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Theme.Shadow, BackgroundTransparency = 0.5, Parent = Outer})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,18)}).Parent = Shadow
    local Main = make("Main","Frame",{Size = UDim2.new(1,-12,1,-12), Position = UDim2.new(0,6,0,6), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = Outer})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,14)}).Parent = Main
    addShadow(Main, 0.3)

    -- Top bar
    local TopBar = make("Top","Frame",{Size = UDim2.new(1,0,0,52), BackgroundColor3 = Theme.Panel, Parent = Main})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,14)}).Parent = TopBar
    make("Stroke","UIStroke",{Color = Theme.Border, Transparency = 0.9}).Parent = TopBar
    local TitleLbl = make("Title", "TextLabel", {Size = UDim2.new(1,-120,1,0), Position = UDim2.new(0,16,0,0), BackgroundTransparency = 1, Text = title or "Sugar UI", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar})
    local kbLbl = make("KB","TextLabel",{Size = UDim2.new(0,120,0,20), Position = UDim2.new(1,-140,0.5,-10), BackgroundTransparency = 1, Text = "Toggle: "..tostring(selfObj.Keybind.Name), TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 12, Parent = TopBar})

    local CloseBtn = make("Close","TextButton",{Size = UDim2.new(0,36,0,36), Position = UDim2.new(1,-72,0.5,-18), BackgroundColor3 = Color3.fromRGB(255,77,77), Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = TopBar})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,8)}).Parent = CloseBtn
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    CloseBtn.MouseEnter:Connect(function() TweenTo(CloseBtn, {BackgroundColor3 = Color3.fromRGB(200,50,50)}, 0.12) end)
    CloseBtn.MouseLeave:Connect(function() TweenTo(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255,77,77)}, 0.12) end)

    -- Keybind editor
    local EditKbBtn = make("EditKb","TextButton",{Size = UDim2.new(0,86,0,28), Position = UDim2.new(1,-200,0.5,-14), BackgroundColor3 = Theme.Panel, Text = "Change Key", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text, BorderSizePixel = 0, Parent = TopBar})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,8)}).Parent = EditKbBtn
    local waitingForKey = false
    EditKbBtn.MouseButton1Click:Connect(function()
        waitingForKey = true
        EditKbBtn.Text = "Press any key..."
        EditKbBtn.BackgroundColor3 = Theme.AccentSoft
        local conn
        conn = UserInputService.InputBegan:Connect(function(i,gameProcessed)
            if gameProcessed then return end
            if i.KeyCode and i.KeyCode ~= Enum.KeyCode.Unknown then
                selfObj.Keybind = i.KeyCode
                kbLbl.Text = "Toggle: "..tostring(selfObj.Keybind.Name)
                EditKbBtn.Text = "Change Key"
                EditKbBtn.BackgroundColor3 = Theme.Panel
                waitingForKey = false
                conn:Disconnect()
            end
        end)
        -- cancel after 6s
        task.delay(6, function() if waitingForKey then waitingForKey = false; EditKbBtn.Text = "Change Key"; EditKbBtn.BackgroundColor3 = Theme.Panel; if conn and conn.Connected then conn:Disconnect() end end)
    end)

    -- Sidebar and pages
    local Sidebar = make("Sidebar","Frame",{Size = UDim2.new(0,200,1,-52), Position = UDim2.new(0,0,0,52), BackgroundColor3 = Theme.Panel, Parent = Main})
    make("Stroke","UIStroke",{Color = Theme.Border, Transparency = 0.9}).Parent = Sidebar
    local SidebarInner = make("SidebarInner","Frame",{Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = Sidebar})
    local tabsLayout = make("TabsLayout","UIListLayout",{Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top})
    tabsLayout.Parent = SidebarInner
    make("Pad","UIPadding",{PaddingTop = UDim.new(0,12), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}).Parent = SidebarInner

    local PagesHolder = make("Pages","Frame",{Size = UDim2.new(1,-200,1,-52), Position = UDim2.new(0,200,0,52), BackgroundTransparency = 1, Parent = Main})

    -- expose
    selfObj.ScreenGui = ScreenGui
    selfObj.Frame = Main
    selfObj.Sidebar = Sidebar
    selfObj.SidebarInner = SidebarInner
    selfObj.PagesHolder = PagesHolder
    selfObj.GlobalContainer = PagesHolder

    -- save kb label update helper
    local function updateKbLabel()
        kbLbl.Text = "Toggle: "..tostring(selfObj.Keybind.Name)
    end

    -- global keybind to toggle visibility
    local guiVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == selfObj.Keybind then
            guiVisible = not guiVisible
            TweenTo(Outer, {Position = guiVisible and UDim2.new(0.5,-360,0.5,-210) or UDim2.new(0.5,-360,0.5,-230)}, 0.18)
            if not guiVisible then
                TweenTo(Outer, {BackgroundTransparency = 1}, 0.18)
            else
                TweenTo(Outer, {BackgroundTransparency = 0}, 0.18)
            end
        end
    end)

    -- expose useful functions
    function selfObj:AddTab(name) return createTab(selfObj, name) end
    function selfObj:GetActiveTab()
        for _,t in ipairs(selfObj.Tabs) do if t.name == selfObj.ActiveTab then return t end end
        return nil
    end
    function selfObj:SetKeybind(keyEnum)
        if typeof(keyEnum) == "EnumItem" and keyEnum.EnumType == Enum.KeyCode then
            selfObj.Keybind = keyEnum
            updateKbLabel()
            return true
        end
        return false
    end

    -- convenience: add notification
    function selfObj:Notify(title, text, timeout) Notification.show(selfObj.ScreenGui, title, text, timeout) end

    return selfObj
end

function UILib:CreateWindow(title)
    return Window.new(title)
end

-- ======================
-- Quick test/demo setup
-- ======================
local function buildDemo()
    local UI = UILib:CreateWindow("Sugar UI — Redesigned")
    local tab1 = UI:AddTab("Main")
    local tab2 = UI:AddTab("Settings")
    local tab3 = UI:AddTab("Config")

    -- Main tab: interactive elements
    tab1:AddSection("Controls")
    tab1:AddButton("Show Notification", function() UI:Notify("Hello","Это тестовое уведомление. Всё работает.",3) end)
    local tog = tab1:AddToggle("Test Toggle", false, function(v) UI:Notify("Toggle", "Состояние: "..tostring(v), 2) end)
    local sldr = tab1:AddSlider("Speed", 0, 10, 5, function(v) end)
    tab1:AddList("Choose one", {"Alpha","Beta","Gamma"}, "Alpha", function(v) UI:Notify("List", "Вы выбрали "..tostring(v), 2) end)
    tab1:AddMultiList("Choose several", {"Red","Green","Blue","Yellow"}, {"Red","Blue"}, function(tbl) UI:Notify("Multi", "Выбрано: "..table.concat(tbl, ", "), 2) end)

    -- Settings tab: keybind + theme small controls + save test
    tab2:AddSection("Interface")
    tab2:AddButton("Show/Hide UI (use keybind or change it)", function() UI:Notify("Info","Нажмите Change Key чтобы сменить кейбинд.",3) end)
    tab2:AddButton("Trigger notification", function() UI:Notify("Test","Notification system OK", 3) end)

    -- Config tab: save/load
    tab3:AddSection("Configs")
    local cfgNameInputWrap = make("CfgInputWrap", "Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Parent = tab3.pageInner})
    local cfgInput = make("CfgInput", "TextBox", {Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0,8,0,0), Text = "default", PlaceholderText = "config name", BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, BorderSizePixel = 0, Parent = cfgNameInputWrap})
    make("Corner","UICorner",{CornerRadius = UDim.new(0,8)}).Parent = cfgInput
    local saveBtn = Button.new(cfgNameInputWrap, "Save", function()
        local name = cfgInput.Text or "default"
        local ok, err = pcall(function()
            local dump = {
                keybind = UI.Keybind.Name,
                testToggle = tog:Get(),
                speed = sldr:Get(),
            }
            local success, res = Config.Save(name, dump)
            if success then UI:Notify("Config","Saved: "..name, 2) else UI:Notify("Config","Save failed: "..tostring(res), 3) end
        end)
    end)
    saveBtn.Wrap.Position = UDim2.new(1,-88,0,0)
    saveBtn.Wrap.Size = UDim2.new(0,80,1,0)
    saveBtn.Button.Font = Enum.Font.Gotham
    saveBtn.Button.TextSize = 12

    local loadBtn = Button.new(tab3.pageInner, "Load selected", function()
        local name = cfgInput.Text or "default"
        local ok, res = Config.Load(name)
        if ok then
            local cfg = res
            if cfg.keybind then
                local okSet
                for _,k in ipairs(Enum.KeyCode:GetEnumItems()) do
                    if k.Name == cfg.keybind then okSet = k; break end
                end
                if okSet then UI:SetKeybind(okSet) end
            end
            if cfg.testToggle ~= nil and tog then tog.Set(cfg.testToggle, true) end
            if cfg.speed and sldr then sldr.Set(cfg.speed, true) end
            UI:Notify("Config","Loaded: "..name, 2)
        else
            UI:Notify("Config","Load failed: "..tostring(res), 3)
        end
    end)

    -- list existing configs
    local listBtn = Button.new(tab3.pageInner, "List configs", function()
        local names = Config.List()
        if #names == 0 then UI:Notify("Configs","Нет локальных конфига (или filesystem недоступен).", 3) else UI:Notify("Configs","Найдено: "..table.concat(names,", "), 4) end
    end)

    -- quick demo notif
    UI:Notify("Готово","Инструменты добавлены. Проверьте вкладки.", 4)
end

-- expose library and build demo
_G.SugarUI = UILib
buildDemo()

return UILib

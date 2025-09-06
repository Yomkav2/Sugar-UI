-- init.lua
-- Sugar UI (refreshed) - lightweight rework inspired by provided GUI
-- API: SugarUI:CreateWindow(title, opts) -> window
-- window:AddTab(title) -> tab
-- tab:AddSection(title) -> section
-- section:AddButton(title, callback)
-- section:AddToggle(title, default, callback, id)
-- section:AddSlider(title, min, max, default, callback, id)
-- section:AddDropdown(title, list, default, callback, editable, id)
-- section:AddKeybind(title, defaultKey, callback)
-- window:Notify(title, text, duration, kind)
-- window:SetToggleKey(keycode)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:FindFirstChild("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local SugarUI = {}
SugarUI.__index = SugarUI

-- Public state
SugarUI.CurrentConfig = {}
SugarUI.Theme = {
    Background = Color3.fromRGB(28, 30, 34),
    Panel = Color3.fromRGB(36, 39, 46),
    Accent = Color3.fromRGB(148, 87, 255),
    Text = Color3.fromRGB(235, 235, 235),
    Warning = Color3.fromRGB(255, 170, 0),
}
SugarUI._availableThemes = {
    Default = SugarUI.Theme,
    Pastel = {
        Background = Color3.fromRGB(245, 247, 250),
        Panel = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(120, 200, 250),
        Text = Color3.fromRGB(28,28,28),
        Warning = Color3.fromRGB(230, 120, 120),
    }
}

-- small util
local function new(name, class)
    local inst = Instance.new(class)
    inst.Name = name or class
    return inst
end

function SugarUI.GetAvailableThemes()
    local keys = {}
    for k in pairs(SugarUI._availableThemes) do table.insert(keys, k) end
    return keys
end

function SugarUI.ApplyTheme(name)
    local t = SugarUI._availableThemes[name]
    if not t then return false end
    SugarUI.Theme = t
    return true
end

function SugarUI.RoundCorner(radius)
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, radius or 6)
    return uc
end

-- Create notification container (shared)
local notifContainer
local function ensureNotif()
    if notifContainer and notifContainer.Parent then return notifContainer end
    notifContainer = new("Sugar_Notifications","ScreenGui")
    notifContainer.ResetOnSpawn = false
    notifContainer.IgnoreGuiInset = true
    notifContainer.ZIndexBehavior = Enum.ZIndexBehavior.Global
    notifContainer.Parent = CoreGui

    local frame = new("Container","Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(0.98, 0, 0.02, 0)
    frame.Size = UDim2.new(0.26, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Name = "NotifStack"
    frame.Parent = notifContainer

    return notifContainer
end

-- Internal helper: create base window
function SugarUI:CreateWindow(title, opts)
    opts = opts or {}
    local win = {}
    win.Title = title or "Sugar UI"
    win.Toggled = true
    win.Keybind = opts.ToggleKey or Enum.KeyCode.RightControl
    win.CurrentConfig = self.CurrentConfig

    -- ScreenGui
    local sg = new("SugarScreenGui","ScreenGui")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.Parent = CoreGui

    -- Main window
    local main = new("Main","Frame")
    main.Size = UDim2.new(0, 720, 0, 440)
    main.Position = UDim2.new(0.5, -360, 0.5, -220)
    main.AnchorPoint = Vector2.new(0,0)
    main.BackgroundColor3 = SugarUI.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = sg
    main.Active = true
    main.Draggable = false

    SugarUI.RoundCorner(12).Parent = main

    -- header
    local header = new("Header","Frame")
    header.Size = UDim2.new(1,0,0,56)
    header.BackgroundTransparency = 1
    header.Parent = main

    local titleLabel = new("Title","TextLabel")
    titleLabel.Parent = header
    titleLabel.Position = UDim2.new(0, 18, 0, 12)
    titleLabel.Size = UDim2.new(0.6, 0, 0, 32)
    titleLabel.Text = win.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = SugarUI.Theme.Text
    titleLabel.TextSize = 20
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- left tab column
    local tabsFrame = new("Tabs","Frame")
    tabsFrame.Parent = main
    tabsFrame.Position = UDim2.new(0, 16, 0, 72)
    tabsFrame.Size = UDim2.new(0, 180, 0, 352)
    tabsFrame.BackgroundColor3 = SugarUI.Theme.Panel
    tabsFrame.BorderSizePixel = 0
    SugarUI.RoundCorner(8).Parent = tabsFrame

    local tabsList = new("TabList","ScrollingFrame")
    tabsList.Parent = tabsFrame
    tabsList.Size = UDim2.new(1, -12, 1, -12)
    tabsList.Position = UDim2.new(0,6,0,6)
    tabsList.BackgroundTransparency = 1
    tabsList.ScrollBarThickness = 6
    tabsList.CanvasSize = UDim2.new(0,0,0,0)
    local UIList = Instance.new("UIListLayout", tabsList)
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tabsList:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        tabsList.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 12)
    end)

    -- right content area
    local content = new("Content","Frame")
    content.Parent = main
    content.Position = UDim2.new(0, 212, 0, 72)
    content.Size = UDim2.new(0, 492, 0, 352)
    content.BackgroundColor3 = SugarUI.Theme.Panel
    content.BorderSizePixel = 0
    SugarUI.RoundCorner(8).Parent = content

    local contentInner = new("ContentInner","Frame")
    contentInner.Parent = content
    contentInner.Size = UDim2.new(1, -14, 1, -14)
    contentInner.Position = UDim2.new(0, 7, 0, 7)
    contentInner.BackgroundTransparency = 1

    -- tab management
    win._tabs = {}
    win._selected = nil

    function win:AddTab(tabTitle)
        local tab = {}
        tab.Title = tabTitle or "Tab"

        -- button on left
        local btn = new("TabBtn","TextButton")
        btn.Parent = tabsList
        btn.Size = UDim2.new(1, -12, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = 0.9
        btn.Text = tabTitle
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = SugarUI.Theme.Text
        btn.TextSize = 16
        btn.AutoButtonColor = false
        SugarUI.RoundCorner(6).Parent = btn

        -- page
        local page = new("Page","Frame")
        page.Parent = contentInner
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 8)

        function tab:AddSection(secTitle)
            local section = {}
            -- section frame
            local sf = new("Section","Frame")
            sf.Parent = page
            sf.Size = UDim2.new(1, -8, 0, 120)
            sf.BackgroundColor3 = SugarUI.Theme.Background
            sf.BorderSizePixel = 0
            SugarUI.RoundCorner(6).Parent = sf
            local header = new("SecTitle","TextLabel")
            header.Parent = sf
            header.Position = UDim2.new(0, 12, 0, 8)
            header.Size = UDim2.new(1, -24, 0, 22)
            header.Font = Enum.Font.GothamBold
            header.TextColor3 = SugarUI.Theme.Text
            header.Text = secTitle or "Section"
            header.BackgroundTransparency = 1
            header.TextSize = 14
            -- content holder
            local holder = new("Holder","Frame")
            holder.Parent = sf
            holder.Position = UDim2.new(0, 12, 0, 36)
            holder.Size = UDim2.new(1, -24, 1, -44)
            holder.BackgroundTransparency = 1
            local holderLayout = Instance.new("UIListLayout", holder)
            holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
            holderLayout.Padding = UDim.new(0, 6)

            -- API functions
            function section:AddButton(text, callback)
                local frame = new("BtnWrap","Frame")
                frame.Parent = holder
                frame.Size = UDim2.new(1, 0, 0, 36)
                frame.BackgroundTransparency = 1

                local b = new("Btn","TextButton")
                b.Parent = frame
                b.Size = UDim2.new(1,0,1,0)
                b.BackgroundColor3 = SugarUI.Theme.Accent
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.GothamBold
                b.Text = text or "Button"
                b.TextSize = 14
                b.AutoButtonColor = true
                SugarUI.RoundCorner(6).Parent = b

                b.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                return {Instance = b}
            end

            function section:AddToggle(text, default, callback, id)
                local wrap = new("ToggleWrap","Frame")
                wrap.Parent = holder
                wrap.Size = UDim2.new(1, 0, 0, 32)
                wrap.BackgroundTransparency = 1

                local lbl = new("TLabel","TextLabel")
                lbl.Parent = wrap
                lbl.Position = UDim2.new(0, 8, 0, 0)
                lbl.Size = UDim2.new(0.75, 0, 1, 0)
                lbl.Text = text or "Toggle"
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = SugarUI.Theme.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local btn = new("ToggleBtn","TextButton")
                btn.Parent = wrap
                btn.Position = UDim2.new(1, -68, 0, 4)
                btn.Size = UDim2.new(0, 60, 1, -8)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.AutoButtonColor = true
                btn.Text = default and "ON" or "OFF"
                btn.BackgroundColor3 = default and SugarUI.Theme.Accent or Color3.fromRGB(70,70,70)
                btn.TextColor3 = Color3.new(1,1,1)
                SugarUI.RoundCorner(6).Parent = btn

                local state = default and true or false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = state and "ON" or "OFF"
                    btn.BackgroundColor3 = state and SugarUI.Theme.Accent or Color3.fromRGB(70,70,70)
                    pcall(callback, state)
                    if id then win.CurrentConfig[id] = state end
                end)

                if id then win.CurrentConfig[id] = default end

                return {
                    Set = function(v) state = v; btn.Text = state and "ON" or "OFF"; btn.BackgroundColor3 = state and SugarUI.Theme.Accent or Color3.fromRGB(70,70,70); pcall(callback, state); if id then win.CurrentConfig[id] = state end end
                }
            end

            function section:AddSlider(text, min, max, default, callback, id)
                min = min or 0; max = max or 100; default = default or min
                local wrap = new("SliderWrap","Frame")
                wrap.Parent = holder
                wrap.Size = UDim2.new(1, 0, 0, 48)
                wrap.BackgroundTransparency = 1

                local lbl = new("SLabel","TextLabel")
                lbl.Parent = wrap
                lbl.Position = UDim2.new(0, 8, 0, 0)
                lbl.Size = UDim2.new(0.6, 0, 0, 18)
                lbl.Text = text or "Slider"
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = SugarUI.Theme.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local valLabel = new("Val","TextLabel")
                valLabel.Parent = wrap
                valLabel.Position = UDim2.new(1, -72, 0, 0)
                valLabel.Size = UDim2.new(0, 64, 0, 18)
                valLabel.Text = tostring(default)
                valLabel.BackgroundTransparency = 1
                valLabel.Font = Enum.Font.Gotham
                valLabel.TextSize = 14
                valLabel.TextColor3 = SugarUI.Theme.Text
                valLabel.TextXAlignment = Enum.TextXAlignment.Right

                local bar = new("Bar","Frame")
                bar.Parent = wrap
                bar.Position = UDim2.new(0, 8, 0, 22)
                bar.Size = UDim2.new(1, -16, 0, 12)
                bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
                bar.BorderSizePixel = 0
                SugarUI.RoundCorner(6).Parent = bar

                local fill = new("Fill","Frame")
                fill.Parent = bar
                fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
                fill.BackgroundColor3 = SugarUI.Theme.Accent
                SugarUI.RoundCorner(6).Parent = fill

                local dragging = false
                local function updateFromInput(input)
                    local x = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(x,0,1,0)
                    local value = math.floor(min + x * (max - min) + 0.5)
                    valLabel.Text = tostring(value)
                    pcall(callback, value)
                    if id then win.CurrentConfig[id] = value end
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateFromInput(input)
                    end
                end)
                bar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromInput(input)
                    end
                end)
                if id then win.CurrentConfig[id] = default end
                return {
                    Set = function(v) v = math.clamp(v, min, max); fill.Size = UDim2.new((v-min)/(max-min),0,1,0); valLabel.Text = tostring(math.floor(v+0.5)); pcall(callback, v); if id then win.CurrentConfig[id] = v end end
                }
            end

            function section:AddDropdown(text, list, default, callback, editable, id)
                list = list or {}
                default = default or (list[1] or "")
                local wrap = new("DDWrap","Frame")
                wrap.Parent = holder
                wrap.Size = UDim2.new(1,0,0,36)
                wrap.BackgroundTransparency = 1

                local lbl = new("DDLabel","TextLabel")
                lbl.Parent = wrap
                lbl.Position = UDim2.new(0,8,0,0)
                lbl.Size = UDim2.new(0.5,0,1,0)
                lbl.Text = text or "Dropdown"
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.TextColor3 = SugarUI.Theme.Text
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local sel = new("Sel","TextButton")
                sel.Parent = wrap
                sel.Position = UDim2.new(1, -160, 0, 6)
                sel.Size = UDim2.new(0, 150, 1, -12)
                sel.BackgroundColor3 = Color3.fromRGB(60,60,60)
                sel.Font = Enum.Font.Gotham
                sel.TextColor3 = SugarUI.Theme.Text
                sel.Text = tostring(default)
                sel.AutoButtonColor = true
                SugarUI.RoundCorner(6).Parent = sel

                -- popup
                local popup = new("Popup","Frame")
                popup.Size = UDim2.new(0, 150, 0, 0)
                popup.Position = UDim2.new(0, 0, 1, 6)
                popup.BackgroundColor3 = SugarUI.Theme.Panel
                popup.BorderSizePixel = 0
                popup.Visible = false
                SugarUI.RoundCorner(6).Parent = popup
                popup.Parent = sel

                local listFr = new("List","ScrollingFrame")
                listFr.Parent = popup
                listFr.Size = UDim2.new(1,0,1,0)
                listFr.CanvasSize = UDim2.new(0,0,0,0)
                listFr.BackgroundTransparency = 1
                listFr.ScrollBarThickness = 6
                local ll = Instance.new("UIListLayout", listFr)
                ll.Padding = UDim.new(0,2)

                local function rebuild()
                    for i,v in pairs(listFr:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    for _,val in ipairs(list) do
                        local it = new("Item","TextButton")
                        it.Parent = listFr
                        it.Size = UDim2.new(1,0,0,28)
                        it.Text = tostring(val)
                        it.Font = Enum.Font.Gotham
                        it.TextColor3 = SugarUI.Theme.Text
                        it.BackgroundTransparency = 1
                        it.AutoButtonColor = true
                        it.MouseButton1Click:Connect(function()
                            sel.Text = tostring(val)
                            popup.Visible = false
                            pcall(callback, val)
                            if id then win.CurrentConfig[id] = val end
                        end)
                    end
                    RunService.Heartbeat:Wait()
                    listFr.CanvasSize = UDim2.new(0,0,0,ll.AbsoluteContentSize.Y)
                    popup.Size = UDim2.new(0, 150, 0, math.clamp(ll.AbsoluteContentSize.Y, 0, 200))
                end

                sel.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    if popup.Visible then rebuild() end
                end)

                if id then win.CurrentConfig[id] = default end

                return {
                    UpdateOptions = function(tbl) list = tbl or {}; rebuild() end,
                    GetValue = function() return sel.Text end,
                    SetValue = function(v) sel.Text = v; pcall(callback, v); if id then win.CurrentConfig[id] = v end end,
                }
            end

            function section:AddKeybind(title, defaultKey, callback)
                local wrap = new("KBWrap","Frame")
                wrap.Parent = holder
                wrap.Size = UDim2.new(1,0,0,36)
                wrap.BackgroundTransparency = 1

                local lbl = new("KBLabel","TextLabel")
                lbl.Parent = wrap
                lbl.Position = UDim2.new(0,8,0,0)
                lbl.Size = UDim2.new(0.5,0,1,0)
                lbl.Text = title or "Keybind"
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.TextColor3 = SugarUI.Theme.Text
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local btn = new("KBBtn","TextButton")
                btn.Parent = wrap
                btn.Position = UDim2.new(1, -150, 0, 6)
                btn.Size = UDim2.new(0, 140, 1, -12)
                btn.Font = Enum.Font.GothamBold
                btn.Text = (typeof(defaultKey) == "EnumItem" and defaultKey.Name) or tostring(defaultKey or "None")
                btn.AutoButtonColor = true
                btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                btn.TextColor3 = SugarUI.Theme.Text
                SugarUI.RoundCorner(6).Parent = btn

                local listening = false
                local con
                btn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    btn.Text = "Press a key..."
                    con = UserInputService.InputBegan:Connect(function(inp, processed)
                        if processed then return end
                        if inp.KeyCode then
                            btn.Text = inp.KeyCode.Name
                            pcall(callback, inp.KeyCode)
                            listening = false
                            if con then con:Disconnect(); con = nil end
                        end
                    end)
                end)

                return {
                    Set = function(k) btn.Text = (typeof(k) == "EnumItem" and k.Name) or tostring(k) end
                }
            end

            return section
        end

        -- button click behaviour
        btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(win._tabs) do
                t.page.Visible = false
                t.btn.BackgroundTransparency = 0.9
            end
            page.Visible = true
            btn.BackgroundTransparency = 0.2
            win._selected = tab
        end)

        table.insert(win._tabs, {btn = btn, page = page, title = tabTitle, tab = tab})
        -- auto-select first
        if #win._tabs == 1 then
            btn.MouseButton1Click:Fire()
        end

        return tab
    end

    -- toggle key
    UserInputService.InputBegan:Connect(function(inp, processed)
        if processed then return end
        if inp.KeyCode == win.Keybind then
            win.Toggled = not win.Toggled
            main.Visible = win.Toggled
        end
    end)

    function win:Notify(title, text, duration, kind)
        duration = duration or 4
        ensureNotif()
        local stack = notifContainer:FindFirstChild("NotifStack")
        if not stack then return end

        local nframe = new("Note","Frame")
        nframe.Parent = stack
        nframe.Size = UDim2.new(0, 240, 0, 64)
        nframe.BackgroundColor3 = SugarUI.Theme.Panel
        nframe.BorderSizePixel = 0
        nframe.LayoutOrder = 999
        SugarUI.RoundCorner(8).Parent = nframe

        local tit = new("NTitle","TextLabel")
        tit.Parent = nframe
        tit.Position = UDim2.new(0, 12, 0, 8)
        tit.Size = UDim2.new(1, -24, 0, 20)
        tit.BackgroundTransparency = 1
        tit.Text = title or "Notice"
        tit.Font = Enum.Font.GothamBold
        tit.TextColor3 = SugarUI.Theme.Text
        tit.TextSize = 14
        tit.TextXAlignment = Enum.TextXAlignment.Left

        local desc = new("NDesc","TextLabel")
        desc.Parent = nframe
        desc.Position = UDim2.new(0, 12, 0, 30)
        desc.Size = UDim2.new(1, -24, 0, 26)
        desc.BackgroundTransparency = 1
        desc.Text = text or ""
        desc.Font = Enum.Font.Gotham
        desc.TextColor3 = SugarUI.Theme.Text
        desc.TextSize = 12
        desc.TextWrapped = true
        desc.TextXAlignment = Enum.TextXAlignment.Left

        -- simple auto-remove
        delay(duration, function()
            if nframe and nframe.Parent then
                nframe:Destroy()
            end
        end)
    end

    function win:SetToggleKey(keycode)
        win.Keybind = keycode
    end

    function win:Close()
        if sg and sg.Parent then sg:Destroy() end
    end

    -- return API
    return setmetatable(win, {__index = SugarUI})
end

return SugarUI

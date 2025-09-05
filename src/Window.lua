-- Modified Window.lua with tab support

local Tween = require(script.Parent.Utils.Tween)
local Theme = require(script.Parent.Utils.Theme)

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 200)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Theme.Accent
    Title.Text = title
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Frame

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 30)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -60)
    Container.Position = UDim2.new(0, 0, 0, 60)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame

    self.Frame = Frame
    self.Container = Container
    self.TabBar = TabBar
    self.TabButtons = {}
    self.TabContents = {}

    return self
end

function Window:AddButton(text, callback)
    local Button = require(script.Parent.Components.Button)
    return Button.new(self.Container, text, callback)
end

function Window:AddToggle(text, default, callback)
    local Toggle = require(script.Parent.Components.Toggle)
    return Toggle.new(self.Container, text, default, callback)
end

function Window:AddTab(text)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = self.Container

    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Theme.Button
    btn.BorderSizePixel = 0
    btn.Parent = self.TabBar

    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 == Theme.Button then
            Tween(btn, {BackgroundColor3 = Theme.ButtonHover}, 0.2)
        end
    end)

    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 == Theme.ButtonHover then
            Tween(btn, {BackgroundColor3 = Theme.Button}, 0.2)
        end
    end)

    table.insert(self.TabButtons, btn)
    table.insert(self.TabContents, content)

    local index = #self.TabButtons

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(index)
    end)

    -- Resize all tab buttons to fill equally
    local num = #self.TabButtons
    for _, b in ipairs(self.TabButtons) do
        b.Size = UDim2.new(1 / num, 0, 1, 0)
    end

    -- Select the first tab automatically
    if num == 1 then
        self:SelectTab(1)
    end

    -- Return tab object with methods
    local tabObj = {}
    function tabObj:AddButton(t, cb)
        local Button = require(script.Parent.Components.Button)
        return Button.new(content, t, cb)
    end

    function tabObj:AddToggle(t, def, cb)
        local Toggle = require(script.Parent.Components.Toggle)
        return Toggle.new(content, t, def, cb)
    end

    return tabObj
end

function Window:SelectTab(index)
    for i, c in ipairs(self.TabContents) do
        c.Visible = (i == index)
    end

    for i, b in ipairs(self.TabButtons) do
        local target = (i == index) and Theme.Accent or Theme.Button
        Tween(b, {BackgroundColor3 = target}, 0.2)
    end
end

return Window

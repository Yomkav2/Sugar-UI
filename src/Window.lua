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

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -30)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame

    self.Frame = Frame
    self.Container = Container

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

return Window

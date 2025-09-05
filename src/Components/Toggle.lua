local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Parent.Utils.Theme)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, text, default, callback)
    local self = setmetatable({}, Toggle)
    self.State = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 30)
    Frame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    Frame.BackgroundColor3 = Theme.Toggle
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Parent = Frame

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(0.9, 0, 0.5, -10)
    Box.BackgroundColor3 = self.State and Theme.Accent or Theme.ToggleBox
    Box.Parent = Frame

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State = not self.State
            Tween(Box, {
                BackgroundColor3 = self.State and Theme.Accent or Theme.ToggleBox
            }, 0.2)
            if callback then
                callback(self.State)
            end
        end
    end)

    self.Instance = Frame
    return self
end

return Toggle

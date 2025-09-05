local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Parent.Utils.Theme)

local Button = {}
Button.__index = Button

function Button.new(parent, text, callback)
    local self = setmetatable({}, Button)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    Btn.BackgroundColor3 = Theme.Button
    Btn.Text = text
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = parent

    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.ButtonHover}, 0.2)
    end)

    Btn.MouseLeave:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.Button}, 0.2)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    self.Instance = Btn
    return self
end

return Button

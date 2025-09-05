-- init.lua (single-file, injector-friendly)
-- Sugar UI (single-file bundle)
-- Включает: UILib, Window, Utils (Tween, Theme), Components (Button, Toggle)
-- Плейсхолдеры сделаны аккуратно — работают в большинстве инжектор-сценариев.

local UILib = {}
UILib.__index = UILib

-- ======================
-- Utils: Theme
-- ======================
local Theme = {
    Background = Color3.fromRGB(24, 24, 24),
    Accent = Color3.fromRGB(44, 120, 220),
    Text = Color3.fromRGB(245, 245, 245),
    SecondaryText = Color3.fromRGB(200, 200, 200),
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
            return TweenService:Create(instance, TweenInfo.new(duration or 0.2, style, dir), properties)
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

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = Theme.Accent
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = tostring(text or "Button")
    btn.AutoButtonColor = true
    btn.BorderSizePixel = 0
    btn.LayoutOrder = 1

    -- container padding: keep a small margin
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 30)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    btn.Parent = wrapper

    -- click connection
    if type(callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(callback, btn)
            if not ok then
                warn("Button callback error:", err)
            end
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
    wrapper.Size = UDim2.new(1, 0, 0, 28)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.LayoutOrder = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text or "Toggle")
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, -8, 0.6, 0)
    btn.Position = UDim2.new(0.8, 0, 0.2, 0)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(70,70,70)
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = wrapper

    local function set_state(newState, fire)
        state = not not newState
        if btn then
            btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(70,70,70)
            btn.Text = state and "ON" or "OFF"
        end
        if fire and type(callback) == "function" then
            local ok, err = pcall(callback, state)
            if not ok then warn("Toggle callback error:", err) end
        end
    end

    btn.MouseButton1Click:Connect(function()
        set_state(not state, true)
    end)

    wrapper.Parent = parent
    self._wrapper = wrapper
    self._button = btn
    self._state = state

    -- set initial
    set_state(state, false)

    return self
end

function ToggleComponent:Set(state)
    if self._button then
        -- toggle's callback won't be fired by Set
        local ok, _ = pcall(function()
            self._button.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(70,70,70)
            self._button.Text = state and "ON" or "OFF"
            self._state = state and true or false
        end)
    end
end

function ToggleComponent:Get()
    return self._state
end

-- ======================
-- Window (adapted)
-- ======================
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SugarUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    -- Попытка поставить в CoreGui, иначе в PlayerGui
    local setok, seterr = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not setok or not ScreenGui.Parent then
        -- fallback к PlayerGui (если LocalPlayer доступен)
        local player = game:GetService("Players").LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            ScreenGui.Parent = player.PlayerGui
        else
            -- как крайний вариант — в workspace (маловероятно пригодно), но не оставим без Parent
            ScreenGui.Parent = game:GetService("CoreGui") -- всё равно пробуем
        end
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 360, 0, 260)
    Frame.Position = UDim2.new(0.5, -180, 0.5, -130)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.ClipsDescendants = true
    Frame.Name = "SugarUI_Frame"
    Frame.Active = true

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 34)
    Title.BackgroundColor3 = Theme.Accent
    Title.Text = tostring(title or "Sugar UI")
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BorderSizePixel = 0
    Title.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -34)
    Container.Position = UDim2.new(0, 0, 0, 34)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    Container.Name = "Container"

    -- Автоматическая вертикальная раскладка элементов
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = Container
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() end)

    -- Внешняя обертка для скролла (при желании расширить)
    local selfObj = {
        ScreenGui = ScreenGui,
        Frame = Frame,
        Container = Container,
        Title = Title,
    }
    setmetatable(selfObj, Window)

    -- Простая перетаскиваемость окна (draggable)
    do
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Tween.To(Frame, {Position = newPos}, 0.12)
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

    return selfObj
end

function Window:AddButton(text, callback)
    return ButtonComponent.new(self.Container, text, callback)
end

function Window:AddToggle(text, default, callback)
    return ToggleComponent.new(self.Container, text, default, callback)
end

-- ======================
-- UILib API
-- ======================
function UILib:CreateWindow(title)
    return Window.new(title)
end

-- Debug
pcall(function() print("[SugarUI] single-file init loaded.") end)

return UILib

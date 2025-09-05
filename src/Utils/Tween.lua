local TweenService = game:GetService("TweenService")

local function Tween(obj, props, duration)
    duration = duration or 0.25
    local tween = TweenService:Create(obj, TweenInfo.new(duration), props)
    tween:Play()
    return tween
end

return Tween

local UILib = {}
UILib.__index = UILib

local Window = require(script.Window)

function UILib:CreateWindow(title)
    return Window.new(title)
end

return UILib

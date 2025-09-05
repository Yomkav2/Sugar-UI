-- init.lua (robust for both ModuleScript and loadstring/http get usage)
local UILib = {}
UILib.__index = UILib

local function safe_require(m)
    if not m then return nil end
    local ok, res = pcall(require, m)
    return ok and res or nil
end

local function try_require_from_script()
    -- безопасно проверяем script и его детей
    local ok, res = pcall(function()
        if type(script) == "Instance" or (type(script) == "table" and script.FindFirstChild) then
            local child = script:FindFirstChild and script:FindFirstChild("Window")
            if child then
                return require(child)
            end
        end
    end)
    return ok and res or nil
end

local function try_require_common_locations()
    local searchPaths = {
        function()
            local rs = game:GetService("ReplicatedStorage")
            if rs and rs:FindFirstChild("SugarUI") and rs.SugarUI:FindFirstChild("Window") then
                return require(rs.SugarUI.Window)
            end
        end,
        function()
            local ss = game:GetService("ServerStorage")
            if ss and ss:FindFirstChild("SugarUI") and ss.SugarUI:FindFirstChild("Window") then
                return require(ss.SugarUI.Window)
            end
        end,
        function()
            if _G and _G.SugarUI and _G.SugarUI.Window then
                return _G.SugarUI.Window
            end
        end,
    }
    for _, fn in ipairs(searchPaths) do
        local ok, res = pcall(fn)
        if ok and res then return res end
    end
    return nil
end

local function try_download_window()
    -- Настройте URL под ваш репозиторий, если нужно
    local urls = {
        "https://raw.githubusercontent.com/Yomkav2/Sugar-UI/main/src/Window.lua",
        "https://raw.githubusercontent.com/Yomkav2/Sugar-UI/refs/heads/main/src/Window.lua",
    }
    for _, url in ipairs(urls) do
        local ok, code = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(code) == "string" and #code > 20 then
            local ok2, module = pcall(function() return loadstring(code)() end)
            if ok2 and module then
                return module
            end
        end
    end
    return nil
end

-- Попытки получить модуль Window
local Window = try_require_from_script() or try_require_common_locations()

if not Window then
    -- Попробуем скачать (если HttpGet доступен)
    local ok, res = pcall(try_download_window)
    Window = ok and res or Window
end

if not Window then
    error(
        ("UILib init error: не удалось найти модуль Window.\n"
        .. "Возможные причины:\n"
        .. "- Вы загрузили init.lua через инжектор (loadstring). Тогда 'script' не содержит дочернего ModuleScript 'Window'.\n"
        .. "- HttpGet отключён или URL неверный.\n\n"
        .. "Решения:\n"
        .. "1) Положите ModuleScript 'Window' рядом с init.lua (как child) и загрузите как ModuleScript.\n"
        .. "2) Положите 'Window' в ReplicatedStorage/ServerStorage под папкой 'SugarUI'.\n"
        .. "3) Включите HttpGet и убедитесь, что URL к Window.lua корректен.\n")
    )
end

-- API
function UILib:CreateWindow(title, ...)
    -- ожидаем, что Window предоставляет конструктор .new
    if not Window.new and Window.Create then
        -- немного гибкости — попробуем другие имена
        return Window.Create(title, ...)
    end
    return Window.new(title, ...)
end

return UILib

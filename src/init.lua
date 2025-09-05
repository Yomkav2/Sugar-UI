-- init.lua (robust для loadstring / ModuleScript / инжекторов)
local UILib = {}
UILib.__index = UILib

local function safe_require(obj)
    if not obj then return nil end
    local ok, res = pcall(require, obj)
    return ok and res or nil
end

local function try_require_from_script()
    if typeof(script) == "Instance" then
        local child = script:FindFirstChild("Window")
        if child then
            return safe_require(child)
        end
    end
    return nil
end

local function try_require_common_locations()
    local try = function()
        local rs = game:GetService("ReplicatedStorage")
        if rs and rs:FindFirstChild("SugarUI") and rs.SugarUI:FindFirstChild("Window") then
            return safe_require(rs.SugarUI.Window)
        end
    end
    local ok, res = pcall(try)
    if ok and res then return res end

    local try2 = function()
        local ss = game:GetService("ServerStorage")
        if ss and ss:FindFirstChild("SugarUI") and ss.SugarUI:FindFirstChild("Window") then
            return safe_require(ss.SugarUI.Window)
        end
    end
    ok, res = pcall(try2)
    if ok and res then return res end

    if _G and _G.SugarUI and _G.SugarUI.Window then
        return _G.SugarUI.Window
    end

    return nil
end

local function try_download_window()
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

-- Попытки найти/получить модуль Window
local Window = try_require_from_script() or try_require_common_locations()

if not Window then
    local ok, downloaded = pcall(try_download_window)
    if ok and downloaded then
        Window = downloaded
    end
end

-- Отладочная информация (можно закомментировать)
if not Window then
    error([[
UILib init error: не удалось найти модуль Window.

Возможные причины:
 - Вы запускаете init.lua через loadstring/injector: тогда 'script' не содержит дочерний ModuleScript 'Window'.
 - HttpGet отключён в вашем инжекторе или URL неверный.
 - В репозитории Window.lua отсутствует/возвращает некорректный модуль.

Решения:
 1) Положите Window.lua рядом с init.lua и загружайте как ModuleScript (если вы используете ModuleScript).
 2) Положите Window в ReplicatedStorage/ServerStorage в папку 'SugarUI' (ReplicatedStorage.SugarUI.Window).
 3) Убедитесь, что HttpGet доступен, и URL на Window.lua корректен.
 4) (Рекомендация) Сделайте single-file: вставьте код Window.lua прямо в init.lua (убирая require).
]])
end

-- Создатель окна (гибкость на случай разных API)
function UILib:CreateWindow(title, ...)
    if Window.new then
        return Window.new(title, ...)
    elseif Window.Create then
        return Window.Create(title, ...)
    else
        error("Window module не содержит .new или .Create (проверьте экспорт).")
    end
end

return UILib

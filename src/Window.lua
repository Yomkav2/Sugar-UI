-- Замените вашу функцию Window.new на эту (вставить вместо старой Window.new)
function Window.new(title)
    local selfObj = setmetatable({}, Window) -- временно, на случай если метатаблицы работают

    -- (вся логика создания ScreenGui/Frame/TopBar/Sidebar/Content как раньше)
    -- ... (копируйте блок создания UI из текущей версии init.lua)
    -- Для краткости я обозначу, что нужно скопировать весь блок создания GUI
    -- из вашей текущей версии сюда, без изменений, до момента, где вы делаете `setmetatable(self, Window)`.

    -- Ниже — примерная структура (у вас в файле должен быть полный код создания UI).
    -- После того, как вы создали все элементы и получили:
    -- selfObj.ScreenGui, selfObj.Frame, selfObj.Sidebar, selfObj.PagesHolder, selfObj.GlobalContainer и др.

    -- *** ВАЖНО: после создания UI, привяжем методы напрямую к объекту ***
    -- Это защитит API от окружений, где метатаблица недоступна/игнорируется.
    function selfObj:AddTab(name)
        -- вызываем общую функцию createTab (она объявлена ниже в том же файле)
        return createTab(selfObj, name)
    end

    function selfObj:AddPage(name) -- alias
        return selfObj:AddTab(name)
    end

    function selfObj:AddButton(text, callback)
        return ButtonComponent.new(selfObj.GlobalContainer, text, callback)
    end

    function selfObj:AddToggle(text, default, callback)
        return ToggleComponent.new(selfObj.GlobalContainer, text, default, callback)
    end

    function selfObj:GetActiveTab()
        for _, t in ipairs(selfObj.Tabs or {}) do
            if t.name == selfObj.ActiveTab then return t end
        end
        return nil
    end

    -- Если метатаблицы работают, пусть они остаются, но методы уже есть и напрямую.
    setmetatable(selfObj, Window)

    -- Небольшой отладочный вывод (можно удалить позже)
    pcall(function() print("[SugarUI] Window created. Methods bound: AddTab, AddButton, AddToggle") end)

    return selfObj
end

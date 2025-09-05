# MyUILib

Универсальная UI-библиотека для Roblox.

## 🚀 Подключение
```lua
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yomka/MyUILib/main/src/init.lua"))()
```

## 📖 Пример
```lua
local Window = UILib:CreateWindow("Пример окна")

Window:AddButton("Нажми меня", function()
    print("Кнопка нажата!")
end)

Window:AddToggle("Тумблер", false, function(state)
    print("Состояние:", state)
end)
```

## 📂 Структура
- **init.lua** — точка входа
- **Window.lua** — управление окнами
- **Components/**
  - `Button.lua` — кнопка
  - `Toggle.lua` — тумблер
- **Utils/**
  - `Tween.lua` — твины
  - `Theme.lua` — темы

-- init.lua (Sugar UI single-file, injector-friendly, tabs + improved UI)
local UILib = {}
UILib.__index = UILib

-- ======================
-- Theme
-- ======================
local Theme = {
    Background = Color3.fromRGB(18,18,18),
    Panel = Color3.fromRGB(28,28,28),
    Accent = Color3.fromRGB(54,137,255),
    AccentSoft = Color3.fromRGB(39,107,200),
    Text = Color3.fromRGB(245,245,245),
    Muted = Color3.fromRGB(170,170,170),
    Shadow = Color3.fromRGB(0,0,0)
}

-- ======================
-- Tween Utility
-- ======================
local Tween = {}
do
    local TweenService = game:GetService("TweenService")
    function Tween.To(instance, props, duration, style, dir)
        style = style or Enum.EasingStyle.Quad
        dir = dir or Enum.EasingDirection.Out
        local ok, t = pcall(function()
            return TweenService:Create(instance,TweenInfo.new(duration or 0.18,style,dir),props)
        end)
        if ok and t then t:Play() end
        return t
    end
end

-- ======================
-- Components
-- ======================
local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent
function ButtonComponent.new(parent,text,callback)
    local self = setmetatable({},ButtonComponent)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1,0,0,34)
    wrapper.BackgroundTransparency = 1
    wrapper.LayoutOrder = 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-12,1,-8)
    btn.Position = UDim2.new(0,6,0,4)
    btn.BackgroundColor3 = Theme.Panel
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text or "Button"
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.Parent = wrapper
    local corner = Instance.new("UICorner",btn)
    corner.CornerRadius = UDim.new(0,8)
    btn.MouseEnter:Connect(function() Tween.To(btn,{BackgroundColor3 = Theme.AccentSoft},0.12) end)
    btn.MouseLeave:Connect(function() Tween.To(btn,{BackgroundColor3 = Theme.Panel},0.12) end)
    if type(callback)=="function" then
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
            Tween.To(btn,{BackgroundColor3 = Theme.Accent},0.06)
            task.delay(0.06,function() Tween.To(btn,{BackgroundColor3 = Theme.AccentSoft},0.08) end)
        end)
    end
    wrapper.Parent = parent
    self._wrapper = wrapper
    self._button = btn
    return self
end
function ButtonComponent:SetText(text) if self._button then self._button.Text=text end end

local ToggleComponent = {}
ToggleComponent.__index = ToggleComponent
function ToggleComponent.new(parent,text,default,callback)
    local self=setmetatable({},ToggleComponent)
    local state=(default==true)
    local wrapper=Instance.new("Frame")
    wrapper.Size=UDim2.new(1,0,0,34)
    wrapper.BackgroundTransparency=1
    wrapper.LayoutOrder=1
    local bg=Instance.new("Frame")
    bg.Size=UDim2.new(1,-12,1,-8)
    bg.Position=UDim2.new(0,6,0,4)
    bg.BackgroundColor3=Theme.Panel
    bg.BorderSizePixel=0
    bg.Parent=wrapper
    local bgCorner=Instance.new("UICorner",bg)
    bgCorner.CornerRadius=UDim.new(0,8)
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(0.7,0,1,0)
    label.Position=UDim2.new(0,10,0,0)
    label.BackgroundTransparency=1
    label.Text=text or "Toggle"
    label.TextColor3=Theme.Text
    label.Font=Enum.Font.Gotham
    label.TextSize=14
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.Parent=bg
    local toggleBtn=Instance.new("TextButton")
    toggleBtn.Size=UDim2.new(0,56,0,22)
    toggleBtn.Position=UDim2.new(1,-66,0.5,-11)
    toggleBtn.BackgroundColor3=state and Theme.Accent or Color3.fromRGB(90,90,90)
    toggleBtn.Text=state and "ON" or "OFF"
    toggleBtn.TextColor3=Color3.new(1,1,1)
    toggleBtn.Font=Enum.Font.GothamSemibold
    toggleBtn.TextSize=12
    toggleBtn.BorderSizePixel=0
    toggleBtn.Parent=bg
    local toggleCorner=Instance.new("UICorner",toggleBtn)
    toggleCorner.CornerRadius=UDim.new(0,6)
    local function set_state(newState,fire)
        state=not not newState
        Tween.To(toggleBtn,{BackgroundColor3=state and Theme.Accent or Color3.fromRGB(90,90,90)},0.12)
        toggleBtn.Text=state and "ON" or "OFF"
        if fire and type(callback)=="function" then pcall(callback,state) end
    end
    toggleBtn.MouseButton1Click:Connect(function() set_state(not state,true) end)
    wrapper.Parent=parent
    self._wrapper=wrapper
    self._state=state
    self._button=toggleBtn
    set_state(state,false)
    return self
end
function ToggleComponent:Set(state)
    if self._button then
        self._button.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(90,90,90)
        self._button.Text = state and "ON" or "OFF"
        self._state=state and true or false
    end
end
function ToggleComponent:Get() return self._state end

-- ======================
-- Window
-- ======================
local Window={}
Window.__index=Window

local function createTab(selfObj,name)
    local btnWrap=Instance.new("Frame")
    btnWrap.Size=UDim2.new(1,-12,0,36)
    btnWrap.BackgroundTransparency=1
    btnWrap.LayoutOrder=#selfObj.Tabs+1
    btnWrap.Parent=selfObj.Sidebar
    local tabBtn=Instance.new("TextButton")
    tabBtn.Size=UDim2.new(1,0,1,0)
    tabBtn.BackgroundTransparency=1
    tabBtn.Text=name
    tabBtn.Font=Enum.Font.Gotham
    tabBtn.TextColor3=Theme.Text
    tabBtn.TextSize=14
    tabBtn.AutoButtonColor=false
    tabBtn.BorderSizePixel=0
    tabBtn.Parent=btnWrap
    tabBtn.TextXAlignment=Enum.TextXAlignment.Left
    tabBtn.Position=UDim2.new(0,12,0,0)
    local indicator=Instance.new("Frame")
    indicator.Size=UDim2.new(0,4,0.7,0)
    indicator.Position=UDim2.new(0,6,0.15,0)
    indicator.BackgroundColor3=Theme.Accent
    indicator.Visible=false
    indicator.BorderSizePixel=0
    indicator.Parent=btnWrap
    local indCorner=Instance.new("UICorner",indicator)
    indCorner.CornerRadius=UDim.new(0,3)
    local page=Instance.new("Frame")
    page.Size=UDim2.new(1,0,1,0)
    page.Position=UDim2.new(0,0,0,0)
    page.BackgroundTransparency=1
    page.Visible=false
    page.Parent=selfObj.PagesHolder
    local pageInner=Instance.new("Frame")
    pageInner.Size=UDim2.new(1,-24,1,-24)
    pageInner.Position=UDim2.new(0,12,0,12)
    pageInner.BackgroundTransparency=1
    pageInner.Parent=page
    local list=Instance.new("UIListLayout",pageInner)
    list.Padding=UDim.new(0,8)
    list.SortOrder=Enum.SortOrder.LayoutOrder
    tabBtn.MouseButton1Click:Connect(function()
        for k,v in pairs(selfObj.Pages) do v.Visible=false end
        page.Visible=true
        for _,t in ipairs(selfObj.Tabs) do
            t.indicator.Visible=(t.name==name)
            t.button.TextColor3=(t.name==name) and Theme.Text or Theme.Muted
        end
        selfObj.ActiveTab=name
    end)
    local tabObj={name=name,button=tabBtn,wrapper=btnWrap,indicator=indicator,page=page,pageInner=pageInner,
        AddButton=function(_,txt,cb) return ButtonComponent.new(pageInner,txt,cb) end,
        AddToggle=function(_,txt,def,cb) return ToggleComponent.new(pageInner,txt,def,cb) end,
    }
    table.insert(selfObj.Tabs,tabObj)
    selfObj.Pages[name]=page
    if not selfObj.ActiveTab then
        tabBtn.TextColor3=Theme.Text
        indicator.Visible=true
        page.Visible=true
        selfObj.ActiveTab=name
    else
        tabBtn.TextColor3=Theme.Muted
    end
    return tabObj
end

function Window.new(title)
    local selfObj={}
    selfObj.Tabs={}
    selfObj.Pages={}
    selfObj.ActiveTab=nil

    local ScreenGui=Instance.new("ScreenGui")
    ScreenGui.Name="SugarUILib"
    ScreenGui.ResetOnSpawn=false
    ScreenGui.IgnoreGuiInset=true
    local ok,err=pcall(function() ScreenGui.Parent=game:GetService("CoreGui") end)
    if not ok or not ScreenGui.Parent then
        local player=game:GetService("Players").LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then ScreenGui.Parent=player.PlayerGui else ScreenGui.Parent=game:GetService("CoreGui") end
    end

    local Shadow=Instance.new("Frame")
    Shadow.Size=UDim2.new(0,420,0,300)
    Shadow.Position=UDim2.new(0.5,-210+6,0.5,-150+6)
    Shadow.AnchorPoint=Vector2.new(0.5,0.5)
    Shadow.BackgroundColor3=Theme.Shadow
    Shadow.BackgroundTransparency=0.78
    Shadow.ZIndex=0
    Shadow.Parent=ScreenGui
    local sc=Instance.new("UICorner",Shadow)
    sc.CornerRadius=UDim.new(0,14)

    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.new(0,420,0,300)
    Frame.Position=UDim2.new(0.5,-210,0.5,-150)
    Frame.AnchorPoint=Vector2.new(0.5,0.5)
    Frame.BackgroundColor3=Theme.Background
    Frame.BorderSizePixel=0
    Frame.Parent=ScreenGui
    Frame.ClipsDescendants=true
    Frame.ZIndex=1
    local fc=Instance.new("UICorner",Frame)
    fc.CornerRadius=UDim.new(0,12)

    local TopBar=Instance.new("Frame")
    TopBar.Size=UDim2.new(1,0,0,40)
    TopBar.Position=UDim2.new(0,0,0,0)
    TopBar.BackgroundTransparency=1
    TopBar.Parent=Frame

    local TitleLbl=Instance.new("TextLabel")
    TitleLbl.Size=UDim2.new(0.7,-8,1,0)
    TitleLbl.Position=UDim2.new(0,12,0,0)
    TitleLbl.BackgroundTransparency=1
    TitleLbl.Text=title or "Sugar UI"
    TitleLbl.TextColor3=Theme.Text
    TitleLbl.Font=Enum.Font.GothamBold
    TitleLbl.TextSize=16
    TitleLbl.TextXAlignment=Enum.TextXAlignment.Left
    TitleLbl.Parent=TopBar

    local CloseBtn=Instance.new("TextButton")
    CloseBtn.Size=UDim2.new(0,32,0,28)
    CloseBtn.Position=UDim2.new(1,-44,0.5,-14)
    CloseBtn.AnchorPoint=Vector2.new(1,0.5)
    CloseBtn.BackgroundColor3=Color3.fromRGB(255,77,77)
    CloseBtn.Text="X"
    CloseBtn.Font=Enum.Font.GothamBold
    CloseBtn.TextSize=14
    CloseBtn.TextColor3=Color3.new(1,1,1)
    CloseBtn.BorderSizePixel=0
    CloseBtn.Parent=TopBar
    local ccorner=Instance.new("UICorner",CloseBtn)
    ccorner.CornerRadius=UDim.new(0,6)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Sidebar=Instance.new("Frame")
    Sidebar.Size=UDim2.new(0,120,1,0)
    Sidebar.Position=UDim2.new(0,0,0,0)
    Sidebar.BackgroundTransparency=1
    Sidebar.Parent=Frame
    local sideBg=Instance.new("Frame")
    sideBg.Size=UDim2.new(1,0,1,0)
    sideBg.BackgroundColor3=Theme.Panel
    sideBg.BorderSizePixel=0
    sideBg.Parent=Sidebar
    local sideCorner=Instance.new("UICorner",sideBg)
    sideCorner.CornerRadius=UDim.new(0,12)
    local tabsLayout=Instance.new("UIListLayout",sideBg)
    tabsLayout.Padding=UDim.new(0,6)
    tabsLayout.SortOrder=Enum.SortOrder.LayoutOrder
    tabsLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    tabsLayout.VerticalAlignment=Enum.VerticalAlignment.Top
    local tabsPadding=Instance.new("UIPadding",sideBg)
    tabsPadding.PaddingTop=UDim.new(0,10)
    tabsPadding.PaddingLeft=UDim.new(0,6)
    tabsPadding.PaddingRight=UDim.new(0,6)

    local PagesHolder=Instance.new("Frame")
    PagesHolder.Size=UDim2.new(1,-120,1,0)
    PagesHolder.Position=UDim2.new(0,120,0,0)
    PagesHolder.BackgroundTransparency=1
    PagesHolder.Parent=Frame

    selfObj.ScreenGui=ScreenGui
    selfObj.Frame=Frame
    selfObj.Sidebar=sideBg
    selfObj.PagesHolder=PagesHolder
    selfObj.GlobalContainer=PagesHolder

    -- Direct method binding
    function selfObj:AddTab(name) return createTab(selfObj,name) end
    function selfObj:AddPage(name) return selfObj:AddTab(name) end
    function selfObj:AddButton(text,cb) return ButtonComponent.new(selfObj.GlobalContainer,text,cb) end
    function selfObj:AddToggle(text,def,cb) return ToggleComponent.new(selfObj.GlobalContainer,text,def,cb) end
    function selfObj:GetActiveTab()
        for _,t in ipairs(selfObj.Tabs) do if t.name==selfObj.ActiveTab then return t end end
        return nil
    end

    return selfObj
end

function UILib:CreateWindow(title)
    return Window.new(title)
end

return UILib

--[[
    ███╗   ███╗ ██████╗ ██████╗  ██████╗ ██╗     ██╗   ██╗███╗   ███╗██╗███╗   ██╗ █████╗
    ████╗ ████║██╔═══██╗██╔══██╗██╔═══██╗██║     ██║   ██║████╗ ████║██║████╗  ██║██╔══██╗
    ██╔████╔██║██║   ██║██████╔╝██║   ██║██║     ██║   ██║██╔████╔██║██║██╔██╗ ██║███████║
    ██║╚██╔╝██║██║   ██║██╔══██╗██║   ██║██║     ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██╔══██║
    ██║ ╚═╝ ██║╚██████╔╝██║  ██║╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║██║  ██║
    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
    A modern emerald-themed Luau UI Framework. Pure GuiObjects + TweenService.
--]]

--[[ MoroLumina UI — Emerald Edition (Fixed + Polished) ]]--
local Library = {}
Library.__index = Library

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")

local Theme = {
    Background    = Color3.fromRGB(12, 14, 13),
    BackgroundAlt = Color3.fromRGB(9, 11, 10),
    Element       = Color3.fromRGB(20, 23, 21),
    ElementHover  = Color3.fromRGB(26, 31, 28),
    Section       = Color3.fromRGB(16, 19, 17),
    Stroke        = Color3.fromRGB(30, 36, 33),
    StrokeAccent  = Color3.fromRGB(0, 225, 134),
    Accent        = Color3.fromRGB(0, 225, 134),
    AccentDim     = Color3.fromRGB(0, 150, 90),
    ToggleOff     = Color3.fromRGB(42, 47, 44),
    Text          = Color3.fromRGB(240, 245, 243),
    TextDim       = Color3.fromRGB(135, 142, 139),
    Glow          = Color3.fromRGB(0, 225, 134),
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
}

local TW = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then inst[k] = v end end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end
local function corner(p, r) return create("UICorner", {CornerRadius=UDim.new(0,r or 12), Parent=p}) end
local function stroke(p, c, t, tr) return create("UIStroke", {Color=c or Theme.Stroke, Thickness=t or 1, Transparency=tr or 0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=p}) end
local function padding(p, a) return create("UIPadding", {PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,a),PaddingLeft=UDim.new(0,a),PaddingRight=UDim.new(0,a), Parent=p}) end

-- ✨ красивый градиент для элементов
local function gradient(p, c1, c2, rot)
    return create("UIGradient", {
        Color = ColorSequence.new(c1 or Theme.Element, c2 or Theme.BackgroundAlt),
        Rotation = rot or 90, Parent = p,
    })
end

local function addGlow(parent)
    return create("ImageLabel", {
        Name="Glow", BackgroundTransparency=1,
        Image="rbxassetid://5028857084", ImageColor3=Theme.Glow, ImageTransparency=0.85,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276),
        Size=UDim2.new(1,60,1,60), Position=UDim2.new(0,-30,0,-30), ZIndex=0, Parent=parent,
    })
end

local function ripple(button)
    local s = button:FindFirstChildOfClass("UIStroke")
    button.MouseEnter:Connect(function()
        if s then TweenService:Create(s, TW.Fast, {Color=Theme.StrokeAccent, Transparency=0.3}):Play() end
        TweenService:Create(button, TW.Fast, {BackgroundColor3=Theme.ElementHover}):Play()
    end)
    button.MouseLeave:Connect(function()
        if s then TweenService:Create(s, TW.Fast, {Color=Theme.Stroke, Transparency=0}):Play() end
        TweenService:Create(button, TW.Fast, {BackgroundColor3=Theme.Element}):Play()
    end)
end
local function clickPop(obj)
    local base = obj.Size
    obj.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            TweenService:Create(obj, TW.Fast, {Size=UDim2.new(base.X.Scale,base.X.Offset-4,base.Y.Scale,base.Y.Offset-3)}):Play()
        end
    end)
    obj.InputEnded:Connect(function() TweenService:Create(obj, TW.Fast, {Size=base}):Play() end)
    obj.MouseLeave:Connect(function() TweenService:Create(obj, TW.Fast, {Size=base}):Play() end)
end

----------------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------------
local NotifyGui
local function getNotifyContainer()
    if NotifyGui and NotifyGui.Parent then return NotifyGui end
    NotifyGui = create("ScreenGui", {
        Name="MoroLumina_Notify", DisplayOrder=2147483647,
        ResetOnSpawn=false, IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() NotifyGui.Parent = CoreGui end)
    if not NotifyGui.Parent then NotifyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local holder = create("Frame", {
        Name="Holder", BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-16,1,-16),
        Size=UDim2.new(0,300,1,-32), Parent=NotifyGui,
    })
    create("UIListLayout", {
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,10), Parent=holder,
    })
    return NotifyGui
end

local TYPE_COLORS = {
    Success = Color3.fromRGB(0, 225, 134),
    Info    = Color3.fromRGB(70, 170, 255),
    Warning = Color3.fromRGB(255, 190, 60),
    Error   = Color3.fromRGB(255, 80, 90),
}
local TYPE_ICONS = { Success="✓", Info="i", Warning="!", Error="✕" }

-- Универсальный нотиф (работает и как Library:Notify, и как Window:Notify)
local function showNotify(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4
    local nType    = opts.Type or "Success"
    local accent   = TYPE_COLORS[nType] or Theme.Accent

    local holder = getNotifyContainer().Holder

    local card = create("Frame", {
        Name="Notify", BackgroundColor3=Theme.Background, BackgroundTransparency=0,
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        ClipsDescendants=true, Parent=holder,
    })
    corner(card, 14)
    stroke(card, accent, 1.2, 0.4)
    gradient(card, Theme.Background, Theme.BackgroundAlt, 90)
    addGlow(card).ImageTransparency = 0.88

    local inner = create("Frame", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y, Parent=card,
    })
    padding(inner, 14)

    local badge = create("Frame", {
        BackgroundColor3=Color3.fromRGB(14,22,18),
        Size=UDim2.new(0,38,0,38), Parent=inner,
    })
    corner(badge, 10)
    stroke(badge, accent, 1, 0.3)
    create("TextLabel", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
        Text=TYPE_ICONS[nType] or "i", TextColor3=accent,
        Font=Theme.FontBold, TextSize=20, Parent=badge,
    })

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,50,0,0),
        Size=UDim2.new(1,-50,0,20), Text=title, TextColor3=Theme.Text,
        Font=Theme.FontBold, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=inner,
    })
    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,50,0,22),
        Size=UDim2.new(1,-50,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        Text=content, TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=13,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=inner,
    })

    local bar = create("Frame", {
        BackgroundColor3=accent, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), Parent=card,
    })
    corner(bar, 2)

    card.Position = UDim2.new(1,20,0,0)
    card.BackgroundTransparency = 1
    TweenService:Create(card, TW.Slow, {Position=UDim2.new(0,0,0,0), BackgroundTransparency=0}):Play()
    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,0,2)}):Play()

    task.delay(duration, function()
        local out = TweenService:Create(card, TW.Slow, {Position=UDim2.new(1,30,0,0), BackgroundTransparency=1})
        out:Play(); out.Completed:Wait(); card:Destroy()
    end)
end

-- Доступно как Library:Notify{...}
function Library:Notify(opts) showNotify(opts) end

----------------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or config.Name or "MoroLumina"
    local subTitle    = config.SubTitle or "v1.0"
    local toggleKey   = config.ToggleKey or Enum.KeyCode.RightControl

    local Window = {}

    -- ✅ Notify теперь на уровне окна — Win:Notify{...} работает!
    function Window:Notify(opts) showNotify(opts) end

    local screenGui = create("ScreenGui", {
        Name="MoroLumina", ResetOnSpawn=false, DisplayOrder=999,
        IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    Window.Gui = screenGui

    local root = create("CanvasGroup", {
        Name="Root", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,620,0,420),
        BackgroundTransparency=1, Parent=screenGui,
    })
    addGlow(root)

    local main = create("Frame", {
        Name="Main", BackgroundColor3=Theme.Background,
        Size=UDim2.new(1,0,1,0), Parent=root,
    })
    corner(main, 16)
    stroke(main, Theme.Stroke, 1.2, 0)
    gradient(main, Theme.Background, Theme.BackgroundAlt, 90)

    -- Шапка
    local topBar = create("Frame", {
        Name="TopBar", BackgroundColor3=Theme.BackgroundAlt,
        Size=UDim2.new(1,0,0,56), Parent=main,
    })
    corner(topBar, 16)
    create("Frame", {BackgroundColor3=Theme.BackgroundAlt, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,-16), Parent=topBar})

    local logo = create("Frame", {
        BackgroundColor3=Theme.Accent, Size=UDim2.new(0,10,0,24),
        Position=UDim2.new(0,18,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=topBar,
    })
    corner(logo, 3)

    create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,38,0,10),
        Size=UDim2.new(0,300,0,20), Text=windowTitle, TextColor3=Theme.Text,
        Font=Theme.FontBold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, Parent=topBar})
    create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,38,0,30),
        Size=UDim2.new(0,300,0,16), Text=subTitle, TextColor3=Theme.TextDim,
        Font=Theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=topBar})

    local closeBtn = create("TextButton", {
        BackgroundColor3=Theme.Element, Size=UDim2.new(0,70,0,30),
        Position=UDim2.new(1,-86,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Text="Close", TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=13,
        AutoButtonColor=false, Parent=topBar,
    })
    corner(closeBtn, 10)
    stroke(closeBtn, Theme.Stroke, 1, 0)
    ripple(closeBtn)

    -- Сайдбар
    local sidebar = create("Frame", {
        Name="Sidebar", BackgroundColor3=Theme.BackgroundAlt,
        Position=UDim2.new(0,12,0,68), Size=UDim2.new(0,168,1,-80), Parent=main,
    })
    corner(sidebar, 14)
    stroke(sidebar, Theme.Stroke, 1, 0)

    local tabList = create("ScrollingFrame", {
        BackgroundTransparency=1, Position=UDim2.new(0,8,0,8),
        Size=UDim2.new(1,-16,1,-16), ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=sidebar,
    })
    create("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabList})

    -- Контент
    local content = create("Frame", {
        Name="Content", BackgroundColor3=Theme.BackgroundAlt,
        Position=UDim2.new(0,192,0,68), Size=UDim2.new(1,-204,1,-80), Parent=main,
    })
    corner(content, 14)
    stroke(content, Theme.Stroke, 1, 0)

    local pages = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=content})

    -- Перетаскивание окна
    do
        local dragging, dragStart, startPos
        topBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=i.Position; startPos=root.Position
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                root.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
    end

    -- Видимость / toggle
    local isVisible = true
    local floatLogo
    local function setVisible(state)
        isVisible = state
        if state then
            root.Visible=true; root.GroupTransparency=1; root.Size=UDim2.new(0,580,0,380)
            TweenService:Create(root, TW.Normal, {GroupTransparency=0, Size=UDim2.new(0,620,0,420)}):Play()
            if floatLogo then TweenService:Create(floatLogo, TW.Fast, {Rotation=0}):Play() end
        else
            local t=TweenService:Create(root, TW.Normal, {GroupTransparency=1, Size=UDim2.new(0,580,0,380)})
            t:Play(); t.Completed:Connect(function() if not isVisible then root.Visible=false end end)
            if floatLogo then TweenService:Create(floatLogo, TW.Fast, {Rotation=90}):Play() end
        end
    end
    Window.SetVisible = function(_, s) setVisible(s) end

    -- Плавающая кнопка
    local floatBtn = create("TextButton", {
        Name="FloatToggle", BackgroundColor3=Theme.Background,
        Size=UDim2.new(0,52,0,52), Position=UDim2.new(0,20,0,20),
        Text="", AutoButtonColor=false, Parent=screenGui,
    })
    corner(floatBtn, 26)
    stroke(floatBtn, Theme.StrokeAccent, 1.4, 0)
    addGlow(floatBtn).ImageTransparency = 0.8
    floatLogo = create("TextLabel", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="M",
        TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=24, Parent=floatBtn,
    })
    floatBtn.MouseEnter:Connect(function() TweenService:Create(floatBtn, TW.Fast, {Size=UDim2.new(0,58,0,58)}):Play() end)
    floatBtn.MouseLeave:Connect(function() TweenService:Create(floatBtn, TW.Fast, {Size=UDim2.new(0,52,0,52)}):Play() end)

    do
        local dragging, dragStart, startPos, moved
        floatBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; moved=false; dragStart=i.Position; startPos=floatBtn.Position
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-dragStart
                if d.Magnitude>5 then moved=true end
                floatBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
        floatBtn.MouseButton1Click:Connect(function() if not moved then setVisible(not isVisible) end end)
    end

    closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode==toggleKey then setVisible(not isVisible) end
    end)

    local tabs = {}
    local activeTab
    ----------------------------------------------------------------
    -- TAB SYSTEM
    ----------------------------------------------------------------
    function Window:CreateTab(name, icon)
        local Tab = {}

        local tabBtn = create("TextButton", {
            BackgroundColor3=Theme.Element, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,36), Text="", AutoButtonColor=false, Parent=tabList,
        })
        corner(tabBtn, 10)
        local tabStroke = stroke(tabBtn, Theme.Stroke, 1, 1)
        local indicator = create("Frame", {
            BackgroundColor3=Theme.Accent, Size=UDim2.new(0,3,0,0),
            Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=tabBtn,
        })
        corner(indicator, 2)
        local tabLabel = create("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,14,0,0),
            Size=UDim2.new(1,-20,1,0), Text=name, TextColor3=Theme.TextDim,
            Font=Theme.Font, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=tabBtn,
        })

        local page = create("ScrollingFrame", {
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent, ScrollBarImageTransparency=0.3,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false, Parent=pages,
        })
        padding(page, 12)
        create("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=page})

        local function select()
            if activeTab==Tab then return end
            if activeTab then
                activeTab.Page.Visible=false
                TweenService:Create(activeTab.Btn, TW.Fast, {BackgroundTransparency=1}):Play()
                TweenService:Create(activeTab.Stroke, TW.Fast, {Transparency=1}):Play()
                TweenService:Create(activeTab.Label, TW.Fast, {TextColor3=Theme.TextDim}):Play()
                TweenService:Create(activeTab.Indicator, TW.Fast, {Size=UDim2.new(0,3,0,0)}):Play()
            end
            activeTab=Tab; page.Visible=true; page.Position=UDim2.new(0,0,0,10)
            TweenService:Create(page, TW.Normal, {Position=UDim2.new(0,0,0,0)}):Play()
            TweenService:Create(tabBtn, TW.Fast, {BackgroundTransparency=0.6}):Play()
            TweenService:Create(tabStroke, TW.Fast, {Transparency=0.4, Color=Theme.StrokeAccent}):Play()
            TweenService:Create(tabLabel, TW.Fast, {TextColor3=Theme.Text}):Play()
            TweenService:Create(indicator, TW.Bounce, {Size=UDim2.new(0,3,0,20)}):Play()
        end
        tabBtn.MouseButton1Click:Connect(select)
        tabBtn.MouseEnter:Connect(function() if activeTab~=Tab then TweenService:Create(tabBtn,TW.Fast,{BackgroundTransparency=0.85}):Play() end end)
        tabBtn.MouseLeave:Connect(function() if activeTab~=Tab then TweenService:Create(tabBtn,TW.Fast,{BackgroundTransparency=1}):Play() end end)

        Tab.Btn=tabBtn; Tab.Stroke=tabStroke; Tab.Label=tabLabel; Tab.Indicator=indicator; Tab.Page=page
        table.insert(tabs, Tab)
        if #tabs==1 then select() end

        local function baseElement(h)
            local el = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,0,0,h or 40), Parent=page})
            corner(el, 10)
            return el, stroke(el, Theme.Stroke, 1, 0)
        end

        --// SECTION
        function Tab:CreateSection(text)
            local h = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), Parent=page})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,4,0,0),
                Text=string.upper(text), TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=h})
            return h
        end

        --// LABEL
        function Tab:CreateLabel(text)
            local el = baseElement(36)
            local lbl = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0),
                Position=UDim2.new(0,12,0,0), Text=text, TextColor3=Theme.TextDim, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=el})
            return {SetText=function(_,t) lbl.Text=t end, Instance=el}
        end

        --// BUTTON
        function Tab:CreateButton(cfg)
            cfg=cfg or {}; local el=baseElement(42)
            local btn=create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Button", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=btn})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,30,1,0), Position=UDim2.new(1,-38,0,0),
                Text="→", TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=16, Parent=btn})
            ripple(el); clickPop(el)
            btn.MouseButton1Click:Connect(function() if cfg.Callback then task.spawn(cfg.Callback) end end)
            return el
        end

        --// TOGGLE
        function Tab:CreateToggle(cfg)
            cfg=cfg or {}; local state=cfg.Default or false; local el=baseElement(42)
            local btn=create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Toggle", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=btn})
            local track=create("Frame", {BackgroundColor3=state and Theme.Accent or Theme.ToggleOff,
                Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-54,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(track,11)
            local knob=create("Frame", {BackgroundColor3=Color3.fromRGB(255,255,255), Size=UDim2.new(0,16,0,16),
                Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=track})
            corner(knob,8); ripple(el)
            local function set(v,fire)
                state=v
                TweenService:Create(track,TW.Fast,{BackgroundColor3=state and Theme.Accent or Theme.ToggleOff}):Play()
                TweenService:Create(knob,TW.Bounce,{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play()
                if fire and cfg.Callback then task.spawn(cfg.Callback,state) end
            end
            btn.MouseButton1Click:Connect(function() set(not state,true) end)
            if state and cfg.Callback then task.spawn(cfg.Callback,true) end
            return {Set=function(_,v) set(v,true) end, Get=function() return state end, Instance=el}
        end

        --// SLIDER
        function Tab:CreateSlider(cfg)
            cfg=cfg or {}; local min=cfg.Min or 0; local max=cfg.Max or 100
            local default=math.clamp(cfg.Default or min,min,max); local decimals=cfg.Decimals or 0
            local suffix=cfg.Suffix or ""; local value=default; local el=baseElement(56)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-70,0,22), Position=UDim2.new(0,12,0,6),
                Text=cfg.Name or "Slider", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local valLabel=create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-68,0,6),
                Text=tostring(default)..suffix, TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=el})
            local barBack=create("Frame", {BackgroundColor3=Theme.ToggleOff, Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,1,-16), Parent=el})
            corner(barBack,3)
            local fill=create("Frame", {BackgroundColor3=Theme.Accent, Size=UDim2.new((default-min)/(max-min),0,1,0), Parent=barBack})
            corner(fill,3)
            local knob=create("Frame", {BackgroundColor3=Color3.fromRGB(255,255,255), Size=UDim2.new(0,12,0,12),
                Position=UDim2.new((default-min)/(max-min),0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Parent=barBack})
            corner(knob,6)
            local dragging=false
            local function round(n) local m=10^decimals return math.floor(n*m+0.5)/m end
            local function update(x)
                local rel=math.clamp((x-barBack.AbsolutePosition.X)/barBack.AbsoluteSize.X,0,1)
                value=round(min+(max-min)*rel); local pct=(value-min)/(max-min)
                TweenService:Create(fill,TW.Fast,{Size=UDim2.new(pct,0,1,0)}):Play()
                TweenService:Create(knob,TW.Fast,{Position=UDim2.new(pct,0,0.5,0)}):Play()
                valLabel.Text=tostring(value)..suffix
                if cfg.Callback then task.spawn(cfg.Callback,value) end
            end
            barBack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; update(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)
            ripple(el)
            return {Set=function(_,v)
                value=math.clamp(v,min,max); local pct=(value-min)/(max-min)
                fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
                valLabel.Text=tostring(value)..suffix
                if cfg.Callback then task.spawn(cfg.Callback,value) end
            end, Get=function() return value end, Instance=el}
        end

        --// DROPDOWN (с рабочим :Refresh)
        function Tab:CreateDropdown(cfg)
            cfg=cfg or {}; local options=cfg.Options or {}; local multi=cfg.Multi or false
            local selected=multi and {} or (cfg.Default or "Select..."); local open=false
            local el=baseElement(42); el.ClipsDescendants=true
            local header=create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,42), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Dropdown", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=header})
            local valueLbl=create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.5,-40,1,0), Position=UDim2.new(0.5,0,0,0),
                Text=type(selected)=="table" and "None" or tostring(selected), TextColor3=Theme.TextDim, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Right, TextTruncate=Enum.TextTruncate.AtEnd, Parent=header})
            local arrow=create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,-30,0,0),
                Text="▾", TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=14, Parent=header})
            local listHolder=create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,44),
                AutomaticSize=Enum.AutomaticSize.Y, Parent=el})
            create("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=listHolder})

            local function refreshText()
                if multi then
                    local picks={} for k,v in pairs(selected) do if v then table.insert(picks,k) end end
                    valueLbl.Text=#picks>0 and table.concat(picks,", ") or "None"
                else valueLbl.Text=tostring(selected) end
            end

            local optButtons={}
            local function buildOptions()
                for _,b in ipairs(optButtons) do b:Destroy() end
                table.clear(optButtons)
                for _,opt in ipairs(options) do
                    local oBtn=create("TextButton", {BackgroundColor3=Theme.Section, Size=UDim2.new(1,0,0,30),
                        Text="", AutoButtonColor=false, Parent=listHolder})
                    corner(oBtn,8); local oStroke=stroke(oBtn,Theme.Stroke,1,0.5)
                    local oLbl=create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,10,0,0),
                        Text=tostring(opt), TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=12,
                        TextXAlignment=Enum.TextXAlignment.Left, Parent=oBtn})
                    local function highlight()
                        local on=multi and selected[opt] or (selected==opt)
                        TweenService:Create(oStroke,TW.Fast,{Color=on and Theme.StrokeAccent or Theme.Stroke, Transparency=on and 0.2 or 0.5}):Play()
                        TweenService:Create(oLbl,TW.Fast,{TextColor3=on and Theme.Accent or Theme.TextDim}):Play()
                    end
                    highlight()
                    oBtn.MouseButton1Click:Connect(function()
                        if multi then selected[opt]=not selected[opt] else selected=opt end
                        refreshText()
                        for _,b in ipairs(optButtons) do if b.Refresh then b.Refresh() end end
                        if cfg.Callback then task.spawn(cfg.Callback,selected) end
                        if not multi then
                            open=false
                            TweenService:Create(el,TW.Normal,{Size=UDim2.new(1,0,0,42)}):Play()
                            TweenService:Create(arrow,TW.Fast,{Rotation=0}):Play()
                        end
                    end)
                    oBtn.Refresh=highlight
                    table.insert(optButtons,oBtn)
                end
            end
            buildOptions()

            header.MouseButton1Click:Connect(function()
                open=not open
                local target=open and (52+#options*34) or 42
                TweenService:Create(el,TW.Normal,{Size=UDim2.new(1,0,0,target)}):Play()
                TweenService:Create(arrow,TW.Fast,{Rotation=open and 180 or 0}):Play()
            end)
            ripple(el)

            return {
                Set=function(_,v) selected=v; refreshText(); for _,b in ipairs(optButtons) do b.Refresh() end end,
                Get=function() return selected end,
                Refresh=function(_,newOpts) options=newOpts or {}; buildOptions(); refreshText() end,
                Instance=el,
            }
        end

        --// TEXTBOX
        function Tab:CreateTextbox(cfg)
            cfg=cfg or {}; local el=baseElement(42)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.45,0,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Input", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local box=create("Frame", {BackgroundColor3=Theme.Section, Size=UDim2.new(0.5,-20,0,28),
                Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(box,8); local bStroke=stroke(box,Theme.Stroke,1,0)
            local input=create("TextBox", {BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
                Text=cfg.Default or "", PlaceholderText=cfg.Placeholder or "Type...", PlaceholderColor3=Theme.TextDim,
                TextColor3=Theme.Text, Font=Theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false, Parent=box})
            input.Focused:Connect(function() TweenService:Create(bStroke,TW.Fast,{Color=Theme.StrokeAccent,Transparency=0.2}):Play() end)
            input.FocusLost:Connect(function(enter)
                TweenService:Create(bStroke,TW.Fast,{Color=Theme.Stroke,Transparency=0}):Play()
                if cfg.Callback then task.spawn(cfg.Callback,input.Text,enter) end
            end)
            return {Set=function(_,t) input.Text=t end, Get=function() return input.Text end, Instance=el}
        end

        --// KEYBIND
        function Tab:CreateKeybind(cfg)
            cfg=cfg or {}; local currentKey=cfg.Default; local listening=false; local el=baseElement(42)
            local btn=create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-110,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Keybind", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=btn})
            local keyBox=create("Frame", {BackgroundColor3=Theme.Section, Size=UDim2.new(0,90,0,28),
                Position=UDim2.new(1,-102,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(keyBox,8); local kStroke=stroke(keyBox,Theme.Stroke,1,0)
            local keyLabel=create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                Text=currentKey and currentKey.Name or "None", TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=12, Parent=keyBox})
            btn.MouseButton1Click:Connect(function()
                listening=true; keyLabel.Text="..."
                TweenService:Create(kStroke,TW.Fast,{Color=Theme.StrokeAccent,Transparency=0.2}):Play()
            end)
            UserInputService.InputBegan:Connect(function(input,gpe)
                if listening and input.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; currentKey=input.KeyCode; keyLabel.Text=currentKey.Name
                    TweenService:Create(kStroke,TW.Fast,{Color=Theme.Stroke,Transparency=0}):Play()
                elseif not gpe and not listening and currentKey and input.KeyCode==currentKey then
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end
            end)
            ripple(el)
            return {Set=function(_,k) currentKey=k; keyLabel.Text=k.Name end, Get=function() return currentKey end, Instance=el}
        end

        --// COLOR PICKER (RGB слайдеры)
        function Tab:CreateColorPicker(cfg)
            cfg=cfg or {}; local color=cfg.Default or Color3.fromRGB(255,255,255)
            local open=false; local el=baseElement(42); el.ClipsDescendants=true
            local header=create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,42), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,12,0,0),
                Text=cfg.Name or "Color", TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=header})
            local preview=create("Frame", {BackgroundColor3=color, Size=UDim2.new(0,40,0,22),
                Position=UDim2.new(1,-52,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(preview,6); stroke(preview,Theme.Stroke,1,0)
            local holder=create("Frame", {BackgroundTransparency=1, Position=UDim2.new(0,12,0,48),
                Size=UDim2.new(1,-24,0,90), Parent=el})
            create("UIListLayout", {Padding=UDim.new(0,6), Parent=holder})

            local r,g,b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
            local function apply()
                color=Color3.fromRGB(r,g,b); preview.BackgroundColor3=color
                if cfg.Callback then task.spawn(cfg.Callback,color) end
            end

            local function makeChannel(name, getv, setv)
                local row=create("Frame", {BackgroundColor3=Theme.Section, Size=UDim2.new(1,0,0,24), Parent=holder})
                corner(row,6)
                create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,20,1,0), Position=UDim2.new(0,8,0,0),
                    Text=name, TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=12, Parent=row})
                local barBack=create("Frame", {BackgroundColor3=Theme.ToggleOff, Size=UDim2.new(1,-40,0,5),
                    Position=UDim2.new(0,32,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=row})
                corner(barBack,3)
                local fill=create("Frame", {BackgroundColor3=Theme.Accent, Size=UDim2.new(getv()/255,0,1,0), Parent=barBack})
                corner(fill,3)
                local dragging=false
                local function upd(x)
                    local rel=math.clamp((x-barBack.AbsolutePosition.X)/barBack.AbsoluteSize.X,0,1)
                    setv(math.floor(rel*255)); fill.Size=UDim2.new(rel,0,1,0); apply()
                end
                barBack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; upd(i.Position.X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
            end

            makeChannel("R", function() return r end, function(v) r=v end)
            makeChannel("G", function() return g end, function(v) g=v end)
            makeChannel("B", function() return b end, function(v) b=v end)

            header.MouseButton1Click:Connect(function()
                open=not open
                TweenService:Create(el,TW.Normal,{Size=UDim2.new(1,0,0,open and 146 or 42)}):Play()
            end)
            ripple(el)

            return {
                Set=function(_,c)
                    color=c; r,g,b=math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)
                    preview.BackgroundColor3=c
                end,
                Get=function() return color end,
                Instance=el,
            }
        end

        return Tab
    end -- конец Window:CreateTab

    return Window
end -- конец Library:CreateWindow

return Library

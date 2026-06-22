local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════
-- ЦВЕТОВАЯ СХЕМА (стиль izen.lol)
-- ═══════════════════════════════════════════
local colors = {
    bg = Color3.fromRGB(10, 10, 12),
    bg_secondary = Color3.fromRGB(16, 16, 20),
    bg_tertiary = Color3.fromRGB(22, 22, 28),
    accent = Color3.fromRGB(0, 230, 118),
    accent_dark = Color3.fromRGB(0, 180, 95),
    accent_glow = Color3.fromRGB(0, 255, 130),
    stroke = Color3.fromRGB(0, 230, 118),
    stroke_dim = Color3.fromRGB(0, 100, 50),
    text = Color3.fromRGB(255, 255, 255),
    text_dim = Color3.fromRGB(140, 140, 150),
    text_muted = Color3.fromRGB(90, 90, 100),
    toggle_on = Color3.fromRGB(0, 230, 118),
    toggle_off = Color3.fromRGB(45, 45, 52),
    element_bg = Color3.fromRGB(18, 18, 22),
    element_hover = Color3.fromRGB(25, 25, 32),
    danger = Color3.fromRGB(255, 60, 80),
    success = Color3.fromRGB(0, 230, 118),
}

-- ═══════════════════════════════════════════
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ═══════════════════════════════════════════
local function applyStyle(obj, radius, strokeColor, strokeTrans, strokeWidth)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    
    if strokeColor then
        local s = Instance.new("UIStroke")
        s.Thickness = strokeWidth or 1
        s.Color = strokeColor
        s.Transparency = strokeTrans or 0.7
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = obj
    end
end

local function makeDraggable(obj, dragHandle)
    local dragging, dragInput, dragStart, startPos
    local handle = dragHandle or obj
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function addClickEffect(obj, shrinkAmount)
    shrinkAmount = shrinkAmount or 3
    local originalSize = obj.Size
    local originalPos = obj.Position
    
    obj.MouseButton1Down:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - shrinkAmount, originalSize.Y.Scale, originalSize.Y.Offset - shrinkAmount),
            Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + shrinkAmount/2, originalPos.Y.Scale, originalPos.Y.Offset + shrinkAmount/2)
        }):Play()
    end)
    
    obj.MouseButton1Up:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 1), {
            Size = originalSize,
            Position = originalPos
        }):Play()
    end)
    
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.12, Enum.EasingStyle.Back), {
            Size = originalSize,
            Position = originalPos
        }):Play()
    end)
end

local function addHoverEffect(obj, hoverColor, originalColor)
    obj.MouseEnter:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor or colors.element_hover}):Play()
    end)
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = originalColor or colors.element_bg}):Play()
    end)
end

-- ═══════════════════════════════════════════
-- УВЕДОМЛЕНИЯ (стиль izen.lol)
-- ═══════════════════════════════════════════
function Library:Notify(title, text, duration)
    duration = duration or 3
    
    local notifyGui = game:GetService("CoreGui"):FindFirstChild("MoroNotifications_v2")
    if not notifyGui then
        notifyGui = Instance.new("ScreenGui")
        notifyGui.Name = "MoroNotifications_v2"
        notifyGui.Parent = game:GetService("CoreGui")
        notifyGui.DisplayOrder = 9999
        notifyGui.IgnoreGuiInset = true
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = notifyGui
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local padding = Instance.new("UIPadding")
        padding.Parent = notifyGui
        padding.PaddingTop = UDim.new(0, 60)
        padding.PaddingRight = UDim.new(0, 16)
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "Notify"
    frame.Parent = notifyGui
    frame.BackgroundColor3 = colors.bg_secondary
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.ClipsDescendants = true
    frame.LayoutOrder = tick()
    applyStyle(frame, 16, colors.stroke, 0.6, 1)
    
    -- Зелёная полоска слева
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Parent = frame
    accentBar.BackgroundColor3 = colors.accent
    accentBar.BackgroundTransparency = 0
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 16)
    barCorner.Parent = accentBar
    
    -- Иконка галочки
    local iconFrame = Instance.new("Frame")
    iconFrame.Parent = frame
    iconFrame.Size = UDim2.new(0, 28, 0, 28)
    iconFrame.Position = UDim2.new(0, 14, 0.5, 0)
    iconFrame.AnchorPoint = Vector2.new(0, 0.5)
    iconFrame.BackgroundColor3 = colors.accent
    iconFrame.BackgroundTransparency = 0.85
    applyStyle(iconFrame, 8, colors.accent, 0.3, 1)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = iconFrame
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "✓"
    iconLabel.TextColor3 = colors.accent
    iconLabel.TextSize = 16
    iconLabel.Font = Enum.Font.GothamBold
    
    -- Заголовок
    local t = Instance.new("TextLabel")
    t.Name = "Title"
    t.Parent = frame
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 52, 0, 10)
    t.Size = UDim2.new(1, -70, 0, 16)
    t.Font = Enum.Font.GothamBold
    t.Text = title
    t.TextColor3 = colors.text
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Описание
    local desc = Instance.new("TextLabel")
    desc.Name = "Desc"
    desc.Parent = frame
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.new(0, 52, 0, 28)
    desc.Size = UDim2.new(1, -70, 0, 30)
    desc.Font = Enum.Font.Gotham
    desc.Text = text
    desc.TextColor3 = colors.text_dim
    desc.TextSize = 11
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = frame
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = colors.text_muted
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.Gotham
    
    closeBtn.MouseButton1Click:Connect(function()
        local close = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        close:Play()
        close.Completed:Connect(function() frame:Destroy() end)
    end)
    
    -- Анимация появления
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, 0, 0, 0)
    
    local openTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.5), {
        Size = UDim2.new(0, 280, 0, 68)
    })
    openTween:Play()
    
    -- Авто-удаление
    task.delay(duration, function()
        if frame.Parent then
            local close = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, 68),
                BackgroundTransparency = 1
            })
            close:Play()
            close.Completed:Connect(function() frame:Destroy() end)
        end
    end)
end

-- ═══════════════════════════════════════════
-- СОЗДАНИЕ ОКНА
-- ═══════════════════════════════════════════
function Library:CreateWindow(hubName, btnText)
    local finalBtnText = btnText or hubName or "Menu"
    local targetParent = nil
    local success, err = pcall(function() targetParent = game:GetService("CoreGui") end)
    if not success then targetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    
    local screenGui = Instance.new("ScreenGui", targetParent)
    screenGui.Name = "MoroLumina_v2"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 2147483647
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- Детектор клика вне меню
    local outsideClick = Instance.new("TextButton", screenGui)
    outsideClick.Name = "OutsideDetector"
    outsideClick.Size = UDim2.new(1, 0, 1, 0)
    outsideClick.BackgroundTransparency = 1
    outsideClick.Text = ""
    outsideClick.Visible = false
    outsideClick.ZIndex = 1
    
    -- ═══════════════════════════════════════
    -- ОСНОВНОЕ ОКНО
    -- ══════════════════════════════════════
    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.new(0, 520, 0, 380)
    main.AnchorPoint = Vector2.new(0, 0.5)
    main.Position = UDim2.new(0, 10, 0.5, 0)
    main.BackgroundTransparency = 0
    main.BackgroundColor3 = colors.bg
    main.Visible = false
    main.ZIndex = 10
    main.ClipsDescendants = true
    applyStyle(main, 20, colors.stroke, 0.65, 1.2)
    
    -- Верхняя панель (header)
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = colors.bg_secondary
    header.BackgroundTransparency = 0
    header.BorderSizePixel = 0
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Убираем нижние углы у хедера
    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0, 20)
    headerFix.Position = UDim2.new(0, 0, 1, -20)
    headerFix.BackgroundColor3 = colors.bg_secondary
    headerFix.BorderSizePixel = 0
    
    -- Логотип/название
    local logoText = Instance.new("TextLabel", header)
    logoText.AutoLocalize = false
    logoText.Text = "◆ " .. hubName:upper()
    logoText.Size = UDim2.new(1, -100, 1, 0)
    logoText.Position = UDim2.new(0, 16, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.TextColor3 = colors.accent
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 13
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Статус индикатор (зелёная точка)
    local statusDot = Instance.new("Frame", header)
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -80, 0.5, 0)
    statusDot.AnchorPoint = Vector2.new(0, 0.5)
    statusDot.BackgroundColor3 = colors.accent
    statusDot.BorderSizePixel = 0
    applyStyle(statusDot, 4, nil, 0, 0)
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = colors.text_dim
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    addClickEffect(closeBtn, 2)
    
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        outsideClick.Visible = false
        openBtn.Visible = true
    end)
    
    -- Разделитель под хедером
    local divider = Instance.new("Frame", main)
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.Position = UDim2.new(0, 16, 0, 50)
    divider.BackgroundColor3 = colors.stroke
    divider.BackgroundTransparency = 0.8
    divider.BorderSizePixel = 0
    
    -- ══════════════════════════════════════
    -- ЛЕВАЯ ПАНЕЛЬ (ТАБЫ)
    -- ═══════════════════════════════════════
    local tabsFrame = Instance.new("Frame", main)
    tabsFrame.Size = UDim2.new(0, 140, 1, -58)
    tabsFrame.Position = UDim2.new(0, 12, 0, 56)
    tabsFrame.BackgroundColor3 = colors.bg_secondary
    tabsFrame.BackgroundTransparency = 0
    tabsFrame.Active = true
    applyStyle(tabsFrame, 16, colors.stroke, 0.8, 1)
    
    -- Заголовок табов
    local tabsTitle = Instance.new("TextLabel", tabsFrame)
    tabsTitle.AutoLocalize = false
    tabsTitle.Text = "NAVIGATION"
    tabsTitle.Size = UDim2.new(1, 0, 0, 30)
    tabsTitle.Position = UDim2.new(0, 0, 0, 8)
    tabsTitle.BackgroundTransparency = 1
    tabsTitle.TextColor3 = colors.text_muted
    tabsTitle.Font = Enum.Font.GothamBold
    tabsTitle.TextSize = 10
    tabsTitle.LetterSpacing = 1.5
    
    -- Список табов
    local tabBtns = Instance.new("ScrollingFrame", tabsFrame)
    tabBtns.Position = UDim2.new(0, 8, 0, 38)
    tabBtns.Size = UDim2.new(1, -16, 1, -46)
    tabBtns.BackgroundTransparency = 1
    tabBtns.ScrollBarThickness = 0
    tabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = Instance.new("UIListLayout", tabBtns)
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding", tabBtns)
    tabPadding.PaddingBottom = UDim.new(0, 8)
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabBtns.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- ═══════════════════════════════════════
    -- ПРАВАЯ ПАНЕЛЬ (КОНТЕНТ)
    -- ═══════════════════════════════════════
    local contentFrame = Instance.new("Frame", main)
    contentFrame.Position = UDim2.new(0, 162, 0, 56)
    contentFrame.Size = UDim2.new(1, -174, 1, -64)
    contentFrame.BackgroundColor3 = colors.bg_secondary
    contentFrame.BackgroundTransparency = 0
    contentFrame.Active = true
    applyStyle(contentFrame, 16, colors.stroke, 0.8, 1)
    
    -- Контейнер для страниц
    local container = Instance.new("Frame", contentFrame)
    container.Position = UDim2.new(0, 12, 0, 12)
    container.Size = UDim2.new(1, -24, 1, -24)
    container.BackgroundTransparency = 1
    
    -- ══════════════════════════════════════
    -- КНОПКА ОТКРЫТИЯ МЕНЮ
    -- ═══════════════════════════════════════
    local openBtn = Instance.new("TextButton", screenGui)
    openBtn.AutoLocalize = false
    openBtn.BackgroundColor3 = colors.bg_secondary
    openBtn.BackgroundTransparency = 0
    openBtn.Text = "◆ " .. tostring(finalBtnText)
    openBtn.TextColor3 = colors.accent
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 12
    local textLen = #openBtn.Text
    local fixedWidth = (textLen <= 5 and 50) or (textLen <= 9 and 90) or (textLen <= 13 and 120) or 150
    openBtn.Size = UDim2.new(0, fixedWidth, 0, 38)
    openBtn.Position = UDim2.new(0, 20, 0, 20)
    applyStyle(openBtn, 12, colors.stroke, 0.6, 1)
    makeDraggable(openBtn)
    addClickEffect(openBtn, 3)
    addHoverEffect(openBtn, colors.bg_tertiary, colors.bg_secondary)
    
    openBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        outsideClick.Visible = true
        openBtn.Visible = false
    end)
    
    outsideClick.MouseButton1Click:Connect(function()
        main.Visible = false
        outsideClick.Visible = false
        openBtn.Visible = true
    end)
    
    -- ═══════════════════════════════════════
    -- СИСТЕМА ТАБОВ
    -- ═══════════════════════════════════════
    local TabSystem = {}
    local first = true
    
    function TabSystem:CreateTab(name)
        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = colors.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Active = true
        
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local padding = Instance.new("UIPadding", page)
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)
        
        -- Кнопка таба
        local b = Instance.new("TextButton", tabBtns)
        b.AutoLocalize = false
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundTransparency = 1
        b.Text = "  " .. name
        b.TextColor3 = colors.text_dim
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        
        -- Индикатор активного таба (зелёная полоска слева)
        local tabIndicator = Instance.new("Frame", b)
        tabIndicator.Name = "TabIndicator"
        tabIndicator.Size = UDim2.new(0, 3, 0, 20)
        tabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        tabIndicator.BackgroundColor3 = colors.accent
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        applyStyle(tabIndicator, 2, nil, 0, 0)
        
        -- Фон активного таба
        local tabBg = Instance.new("Frame", b)
        tabBg.Name = "TabBg"
        tabBg.Size = UDim2.new(1, -8, 1, -4)
        tabBg.Position = UDim2.new(0, 4, 0, 2)
        tabBg.BackgroundColor3 = colors.accent
        tabBg.BackgroundTransparency = 1
        tabBg.BorderSizePixel = 0
        applyStyle(tabBg, 10, nil, 0, 0)
        
        b.MouseButton1Click:Connect(function()
            -- Скрыть все страницы
            for _, v in pairs(container:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            
            -- Сбросить все табы
            for _, btn in pairs(tabBtns:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = colors.text_dim
                    local ind = btn:FindFirstChild("TabIndicator")
                    local bg = btn:FindFirstChild("TabBg")
                    if ind then ind.BackgroundTransparency = 1 end
                    if bg then bg.BackgroundTransparency = 1 end
                end
            end
            
            -- Активировать текущий
            page.Visible = true
            b.TextColor3 = colors.text
            tabIndicator.BackgroundTransparency = 0
            tabBg.BackgroundTransparency = 0.88
        end)
        
        if first then
            page.Visible = true
            first = false
            b.TextColor3 = colors.text
            tabIndicator.BackgroundTransparency = 0
            tabBg.BackgroundTransparency = 0.88
        end

        local m = {}
        
        -- ═══════════════════════════════════════
        -- СЕКЦИЯ
        -- ═══════════════════════════════════════
        function m:AddSection(text)
            local sectionFrame = Instance.new("Frame", page)
            sectionFrame.Size = UDim2.new(1, 0, 0, 28)
            sectionFrame.BackgroundTransparency = 1
            
            local sectionLine = Instance.new("Frame", sectionFrame)
            sectionLine.Size = UDim2.new(1, 0, 0, 1)
            sectionLine.Position = UDim2.new(0, 0, 0.5, 0)
            sectionLine.BackgroundColor3 = colors.stroke
            sectionLine.BackgroundTransparency = 0.85
            sectionLine.BorderSizePixel = 0
            
            local sectionLabel = Instance.new("TextLabel", sectionFrame)
            sectionLabel.AutoLocalize = false
            sectionLabel.Size = UDim2.new(0, 200, 0, 20)
            sectionLabel.Position = UDim2.new(0, 8, 0.5, 0)
            sectionLabel.AnchorPoint = Vector2.new(0, 0.5)
            sectionLabel.BackgroundColor3 = colors.bg_secondary
            sectionLabel.BackgroundTransparency = 0
            sectionLabel.Text = text:upper()
            sectionLabel.TextColor3 = colors.accent
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextSize = 10
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.LetterSpacing = 1.2
            applyStyle(sectionLabel, 6, colors.stroke, 0.7, 0.8)
            
            return sectionFrame
        end
        
        -- ═══════════════════════════════════════
        -- ЛЕЙБЛ
        -- ═══════════════════════════════════════
        function m:AddLabel(text)
            local labelFrame = Instance.new("Frame", page)
            labelFrame.Size = UDim2.new(1, 0, 0, 24)
            labelFrame.BackgroundTransparency = 1
            
            local label = Instance.new("TextLabel", labelFrame)
            label.AutoLocalize = false
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = colors.text_dim
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            return labelFrame
        end
        
        -- ═══════════════════════════════════════
        -- КНОПКА
        -- ══════════════════════════════════════
        function m:AddButton(text, cb)
            local btnFrame = Instance.new("Frame", page)
            btnFrame.Size = UDim2.new(1, 0, 0, 38)
            btnFrame.BackgroundTransparency = 1
            
            local btn = Instance.new("TextButton", btnFrame)
            btn.AutoLocalize = false
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = colors.element_bg
            btn.BackgroundTransparency = 0
            btn.Text = text
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            applyStyle(btn, 12, colors.stroke, 0.75, 1)
            addClickEffect(btn, 2)
            addHoverEffect(btn, colors.element_hover, colors.element_bg)
            
            btn.MouseButton1Click:Connect(function()
                cb()
            end)
            
            return btnFrame
        end
        
        -- ══════════════════════════════════════
        -- КНОПКА (зелёная, акцентная)
        -- ═══════════════════════════════════════
        function m:AddAccentButton(text, cb)
            local btnFrame = Instance.new("Frame", page)
            btnFrame.Size = UDim2.new(1, 0, 0, 38)
            btnFrame.BackgroundTransparency = 1
            
            local btn = Instance.new("TextButton", btnFrame)
            btn.AutoLocalize = false
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = colors.accent
            btn.BackgroundTransparency = 0
            btn.Text = text
            btn.TextColor3 = colors.bg
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            applyStyle(btn, 12, colors.accent, 0.3, 1)
            addClickEffect(btn, 2)
            
            btn.MouseButton1Click:Connect(function()
                cb()
            end)
            
            return btnFrame
        end
        
        -- ═══════════════════════════════════════
        -- ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
        -- ═══════════════════════════════════════
        function m:AddToggle(text, cb)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 42)
            f.BackgroundColor3 = colors.element_bg
            f.BackgroundTransparency = 0
            applyStyle(f, 12, colors.stroke, 0.75, 1)
            
            local l = Instance.new("TextLabel", f)
            l.AutoLocalize = false
            l.Text = text
            l.Size = UDim2.new(1, -60, 1, 0)
            l.Position = UDim2.new(0, 14, 0, 0)
            l.BackgroundTransparency = 1
            l.TextColor3 = colors.text
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Переключатель
            local switch = Instance.new("Frame", f)
            switch.Size = UDim2.new(0, 38, 0, 20)
            switch.Position = UDim2.new(1, -48, 0.5, 0)
            switch.AnchorPoint = Vector2.new(0, 0.5)
            switch.BackgroundColor3 = colors.toggle_off
            switch.BackgroundTransparency = 0
            applyStyle(switch, 10, colors.stroke, 0.7, 1)
            
            -- Точка переключателя
            local dot = Instance.new("Frame", switch)
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(0, 3, 0.5, 0)
            dot.AnchorPoint = Vector2.new(0, 0.5)
            dot.BackgroundColor3 = colors.text_dim
            dot.BorderSizePixel = 0
            applyStyle(dot, 7, nil, 0, 0)
            
            local en = false
            local tbtn = Instance.new("TextButton", f)
            tbtn.Size = UDim2.new(1, 0, 1, 0)
            tbtn.BackgroundTransparency = 1
            tbtn.Text = ""
            
            tbtn.MouseButton1Click:Connect(function()
                en = not en
                TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundColor3 = en and colors.toggle_on or colors.toggle_off
                }):Play()
                TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, en and 21 or 3, 0.5, 0),
                    BackgroundColor3 = en and colors.bg or colors.text_dim
                }):Play()
                cb(en)
            end)
            
            return f
        end
        
        -- ═══════════════════════════════════════
        -- ТЕКСТОВОЕ ПОЛЕ
        -- ══════════════════════════════════════
        function m:AddTextBox(text, ph, cb)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 42)
            f.BackgroundColor3 = colors.element_bg
            f.BackgroundTransparency = 0
            applyStyle(f, 12, colors.stroke, 0.75, 1)
            
            local label = Instance.new("TextLabel", f)
            label.AutoLocalize = false
            label.Text = text
            label.Size = UDim2.new(1, -20, 0, 14)
            label.Position = UDim2.new(0, 14, 0, 6)
            label.BackgroundTransparency = 1
            label.TextColor3 = colors.text_muted
            label.Font = Enum.Font.Gotham
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local tb = Instance.new("TextBox", f)
            tb.AutoLocalize = false
            tb.Size = UDim2.new(1, -28, 0, 20)
            tb.Position = UDim2.new(0, 14, 0, 18)
            tb.Text = ""
            tb.PlaceholderText = ph
            tb.PlaceholderColor3 = colors.text_muted
            tb.TextColor3 = colors.text
            tb.BackgroundTransparency = 1
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 12
            tb.TextXAlignment = Enum.TextXAlignment.Left
            
            tb.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    cb(tb.Text)
                end
            end)
            
            return f
        end
        
        -- ══════════════════════════════════════
        -- ВЫПАДАЮЩИЙ СПИСОК
        -- ═══════════════════════════════════════
        function m:AddDropdown(text, list, cb)
            local isOpened = false
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 42)
            f.BackgroundColor3 = colors.element_bg
            f.BackgroundTransparency = 0
            f.ClipsDescendants = true
            applyStyle(f, 12, colors.stroke, 0.75, 1)
            
            local label = Instance.new("TextLabel", f)
            label.AutoLocalize = false
            label.Text = text
            label.Size = UDim2.new(1, -60, 0, 14)
            label.Position = UDim2.new(0, 14, 0, 6)
            label.BackgroundTransparency = 1
            label.TextColor3 = colors.text_muted
            label.Font = Enum.Font.Gotham
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local btn = Instance.new("TextButton", f)
            btn.AutoLocalize = false
            btn.Size = UDim2.new(1, -28, 0, 22)
            btn.Position = UDim2.new(0, 14, 0, 18)
            btn.BackgroundTransparency = 1
            btn.Text = "Select..."
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            
            local arrow = Instance.new("TextLabel", btn)
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -20, 0, 0)
            arrow.Text = "▼"
            arrow.TextColor3 = colors.text_dim
            arrow.BackgroundTransparency = 1
            arrow.TextSize = 9
            arrow.Font = Enum.Font.Gotham
            
            local drop = Instance.new("ScrollingFrame", f)
            drop.Name = "DropList"
            drop.Position = UDim2.new(0, 8, 0, 42)
            drop.Size = UDim2.new(1, -16, 0, 0)
            drop.BackgroundTransparency = 1
            drop.ScrollBarThickness = 2
            drop.ScrollBarImageColor3 = colors.accent
            drop.CanvasSize = UDim2.new(0, 0, 0, 0)
            drop.Active = true
            
            local dropLayout = Instance.new("UIListLayout", drop)
            dropLayout.Padding = UDim.new(0, 4)
            dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local dropPadding = Instance.new("UIPadding", drop)
            dropPadding.PaddingBottom = UDim.new(0, 8)
            
            dropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                drop.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 8)
            end)
            
            local function updateList()
                for _, item in pairs(drop:GetChildren()) do
                    if item:IsA("TextButton") then item:Destroy() end
                end
                for _, v in pairs(list) do
                    local o = Instance.new("TextButton", drop)
                    o.AutoLocalize = false
                    o.Size = UDim2.new(1, 0, 0, 30)
                    o.Text = "  " .. tostring(v)
                    o.BackgroundColor3 = colors.bg_tertiary
                    o.BackgroundTransparency = 0
                    o.TextColor3 = colors.text
                    o.Font = Enum.Font.Gotham
                    o.TextSize = 11
                    o.TextXAlignment = Enum.TextXAlignment.Left
                    o.BorderSizePixel = 0
                    applyStyle(o, 8, colors.stroke, 0.8, 0.8)
                    addClickEffect(o, 1)
                    addHoverEffect(o, colors.element_hover, colors.bg_tertiary)
                    
                    o.MouseButton1Click:Connect(function()
                        cb(v)
                        isOpened = false
                        btn.Text = tostring(v)
                        f:TweenSize(UDim2.new(1, 0, 0, 42), "Out", "Quart", 0.3, true)
                        drop:TweenSize(UDim2.new(1, -16, 0, 0), "Out", "Quart", 0.3, true)
                        TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end)
                end
            end
            
            btn.MouseButton1Click:Connect(function()
                isOpened = not isOpened
                if isOpened then updateList() end
                
                local targetDropHeight = isOpened and math.min(#list * 34, 150) or 0
                local targetFrameHeight = isOpened and (42 + targetDropHeight + 8) or 42
                
                f:TweenSize(UDim2.new(1, 0, 0, targetFrameHeight), "Out", "Quart", 0.3, true)
                drop:TweenSize(UDim2.new(1, -16, 0, targetDropHeight), "Out", "Quart", 0.3, true)
                
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = isOpened and 180 or 0}):Play()
            end)
            
            return {
                Refresh = function(self, newList)
                    list = newList
                    if isOpened then updateList() end
                end
            }
        end
        
        -- ═══════════════════════════════════════
        -- СЛАЙДЕР
        -- ═══════════════════════════════════════
        function m:AddSlider(text, min, max, default, cb)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 50)
            f.BackgroundColor3 = colors.element_bg
            f.BackgroundTransparency = 0
            applyStyle(f, 12, colors.stroke, 0.75, 1)
            
            local label = Instance.new("TextLabel", f)
            label.AutoLocalize = false
            label.Text = text
            label.Size = UDim2.new(1, -60, 0, 14)
            label.Position = UDim2.new(0, 14, 0, 6)
            label.BackgroundTransparency = 1
            label.TextColor3 = colors.text_muted
            label.Font = Enum.Font.Gotham
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local valueLabel = Instance.new("TextLabel", f)
            valueLabel.AutoLocalize = false
            valueLabel.Text = tostring(default)
            valueLabel.Size = UDim2.new(0, 50, 0, 14)
            valueLabel.Position = UDim2.new(1, -60, 0, 6)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = colors.accent
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 11
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Фон слайдера
            local sliderBg = Instance.new("Frame", f)
            sliderBg.Size = UDim2.new(1, -28, 0, 6)
            sliderBg.Position = UDim2.new(0, 14, 0, 28)
            sliderBg.BackgroundColor3 = colors.toggle_off
            sliderBg.BorderSizePixel = 0
            applyStyle(sliderBg, 3, nil, 0, 0)
            
            -- Заполненная часть
            local sliderFill = Instance.new("Frame", sliderBg)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = colors.accent
            sliderFill.BorderSizePixel = 0
            applyStyle(sliderFill, 3, nil, 0, 0)
            
            -- Ручка слайдера
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0, 14, 0, 14)
            sliderKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, 0)
            sliderKnob.AnchorPoint = Vector2.new(0, 0.5)
            sliderKnob.BackgroundColor3 = colors.text
            sliderKnob.BorderSizePixel = 0
            applyStyle(sliderKnob, 7, colors.accent, 0.3, 1)
            
            local dragging = false
            local sliderBtn = Instance.new("TextButton", f)
            sliderBtn.Size = UDim2.new(1, -28, 0, 20)
            sliderBtn.Position = UDim2.new(0, 14, 0, 23)
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Text = ""
            
            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            sliderBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local sliderAbs = sliderBg.AbsolutePosition.X
                    local sliderSize = sliderBg.AbsoluteSize.X
                    local posX = input.Position.X - sliderAbs
                    local percent = math.clamp(posX / sliderSize, 0, 1)
                    local value = math.floor(min + (max - min) * percent)
                    
                    sliderFill:TweenSize(UDim2.new(percent, 0, 1, 0), "Out", "Quad", 0.1, true)
                    sliderKnob:TweenPosition(UDim2.new(percent, -7, 0.5, 0), "Out", "Quad", 0.1, true)
                    valueLabel.Text = tostring(value)
                    cb(value)
                end
            end)
            
            return f
        end
        
        -- ═══════════════════════════════════════
        -- РАЗДЕЛИТЕЛЬ
        -- ═══════════════════════════════════════
        function m:AddDivider()
            local divider = Instance.new("Frame", page)
            divider.Size = UDim2.new(1, -20, 0, 1)
            divider.BackgroundColor3 = colors.stroke
            divider.BackgroundTransparency = 0.85
            divider.BorderSizePixel = 0
            divider.Position = UDim2.new(0, 10, 0, 0)
            return divider
        end
        
        return m
    end
    
    -- ═══════════════════════════════════════
    -- ТАБ GUI (по умолчанию)
    -- ═══════════════════════════════════════
    local GuiTab = TabSystem:CreateTab("GUI")
    local guiButton = tabBtns:GetChildren()[#tabBtns:GetChildren()]
    if guiButton:IsA("TextButton") then guiButton.LayoutOrder = 9999 end
    
    GuiTab:AddAccentButton("⟳ Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
    end)
    
    GuiTab:AddButton("✕ Unload Menu", function()
        screenGui:Destroy()
    end)
    
    return TabSystem
end

return Library
   

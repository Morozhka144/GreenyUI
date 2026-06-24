--[[
    ███╗   ███╗ ██████╗ ██████╗  ██████╗ ██╗     ██╗   ██╗███╗   ███╗██╗███╗   ██╗ █████╗
    ████╗ ████║██╔═══██╗██╔══██╗██╔═══██╗██║     ██║   ██║████╗ ████║██║████╗  ██║██╔══██╗
    ██╔████╔██║██║   ██║██████╔╝██║   ██║██║     ██║   ██║██╔████╔██║██║██╔██╗ ██║███████║
    ██║╚██╔╝██║██║   ██║██╔══██╗██║   ██║██║     ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██╔══██║
    ██║ ╚═╝ ██║╚██████╔╝██║  ██║╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║██║  ██║
    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
    A modern emerald-themed Luau UI Framework. Pure GuiObjects + TweenService.
--]]

local Library = {}
Library.__index = Library

--// Services
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")

--// Theme / Design System
local Theme = {
    Background      = Color3.fromRGB(10, 10, 10),
    BackgroundAlt   = Color3.fromRGB(8, 8, 8),
    Element         = Color3.fromRGB(18, 20, 19),
    ElementHover    = Color3.fromRGB(24, 28, 26),
    Section         = Color3.fromRGB(14, 16, 15),
    Stroke          = Color3.fromRGB(25, 30, 28),
    StrokeAccent    = Color3.fromRGB(0, 225, 134),
    Accent          = Color3.fromRGB(0, 225, 134),
    AccentDim       = Color3.fromRGB(0, 160, 95),
    ToggleOff       = Color3.fromRGB(40, 44, 42),
    Text            = Color3.fromRGB(240, 245, 243),
    TextDim         = Color3.fromRGB(140, 145, 145),
    TextDark        = Color3.fromRGB(8, 10, 9),
    Glow            = Color3.fromRGB(0, 225, 134),
    Font            = Enum.Font.Ubuntu,
    FontBold        = Enum.Font.GothamBold,
}

--// Tween presets
local TW = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.3,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

----------------------------------------------------------------------
-- Helper builders
----------------------------------------------------------------------
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(parent, rad)
    return create("UICorner", { CornerRadius = UDim.new(0, rad or 12), Parent = parent })
end

local function stroke(parent, color, thickness, trans)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, all)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all),
        PaddingRight = UDim.new(0, all),
        Parent = parent,
    })
end

-- Subtle emerald glow aura behind a frame
local function addGlow(parent)
    local glow = create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084", -- soft radial-ish shadow asset
        ImageColor3 = Theme.Glow,
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        ZIndex = 0,
        Parent = parent,
    })
    return glow
end

local function ripple(button)
    -- soft hover/click feedback
    local origStroke = button:FindFirstChildOfClass("UIStroke")
    button.MouseEnter:Connect(function()
        if origStroke then
            TweenService:Create(origStroke, TW.Fast, { Color = Theme.StrokeAccent, Transparency = 0.4 }):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if origStroke then
            TweenService:Create(origStroke, TW.Fast, { Color = Theme.Stroke, Transparency = 0 }):Play()
        end
    end)
end

local function clickPop(obj)
    local base = obj.Size
    obj.MouseButton1Down:Connect(function()
        TweenService:Create(obj, TW.Fast, {
            Size = UDim2.new(base.X.Scale, base.X.Offset - 4, base.Y.Scale, base.Y.Offset - 3)
        }):Play()
    end)
    local function up()
        TweenService:Create(obj, TW.Fast, { Size = base }):Play()
    end
    obj.MouseButton1Up:Connect(up)
    obj.MouseLeave:Connect(up)
end

----------------------------------------------------------------------
-- Notifications  ("Bypass complete" style)
----------------------------------------------------------------------
local NotifyGui
local function getNotifyContainer()
    if NotifyGui and NotifyGui.Parent then return NotifyGui end
    NotifyGui = create("ScreenGui", {
        Name = "MoroLumina_Notify",
        DisplayOrder = 2147483647,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() NotifyGui.Parent = CoreGui end)
    if not NotifyGui.Parent then NotifyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local holder = create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 1, -32),
        Parent = NotifyGui,
    })
    create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = holder,
    })
    return NotifyGui
end

local TYPE_COLORS = {
    Success = Color3.fromRGB(0, 225, 134),
    Info    = Color3.fromRGB(70, 170, 255),
    Warning = Color3.fromRGB(255, 190, 60),
    Error   = Color3.fromRGB(255, 80, 90),
}

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4
    local nType    = opts.Type or "Success"
    local accent   = TYPE_COLORS[nType] or Theme.Accent

    local gui = getNotifyContainer()
    local holder = gui.Holder

    local card = create("Frame", {
        Name = "Notify",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = holder,
    })
    corner(card, 14)
    stroke(card, Theme.Stroke, 1, 0)
    addGlow(card).ImageTransparency = 0.9

    local inner = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })
    padding(inner, 14)

    -- Checkmark badge
    local badge = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(14, 22, 18),
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = inner,
    })
    corner(badge, 10)
    stroke(badge, accent, 1, 0.3)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = nType == "Success" and "✓" or (nType == "Warning" and "!" or (nType == "Error" and "✕" or "i")),
        TextColor3 = accent,
        Font = Theme.FontBold,
        TextSize = 20,
        Parent = badge,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(1, -50, 0, 20),
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 22),
        Size = UDim2.new(1, -50, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = content,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })

    -- progress bar
    local bar = create("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = card,
    })
    corner(bar, 2)

    -- slide-in animation
    card.Position = UDim2.new(1, 20, 0, 0)
    card.BackgroundTransparency = 1
    TweenService:Create(card, TW.Slow, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 }):Play()
    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    task.delay(duration, function()
        local out = TweenService:Create(card, TW.Slow, {
            Position = UDim2.new(1, 30, 0, 0),
            BackgroundTransparency = 1,
        })
        out:Play()
        out.Completed:Wait()
        card:Destroy()
    end)
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or config.Name or "MoroLumina"
    local subTitle    = config.SubTitle or "v1.0"
    local toggleKey   = config.ToggleKey or Enum.KeyCode.RightControl

    local Window = {}

    -- ScreenGui
    local screenGui = create("ScreenGui", {
        Name = "MoroLumina",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    Window.Gui = screenGui

    -- CanvasGroup for fade/scale on toggle
    local root = create("CanvasGroup", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 620, 0, 420),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })

    -- Glow aura
    addGlow(root)

    -- Main window frame
    local main = create("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = root,
    })
    corner(main, 16)
    stroke(main, Theme.Stroke, 1.2, 0)

    -- Title bar (draggable handle)
    local topBar = create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.BackgroundAlt,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = main,
    })
    corner(topBar, 16)
    create("Frame", { -- mask bottom corners
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -16),
        Parent = topBar,
    })

    -- Logo mark
    local logo = create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 10, 0, 24),
        Position = UDim2.new(0, 18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = topBar,
    })
    corner(logo, 3)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 10),
        Size = UDim2.new(0, 300, 0, 20),
        Text = windowTitle,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 30),
        Size = UDim2.new(0, 300, 0, 16),
        Text = subTitle,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    -- Close button on bar
    local closeBtn = create("TextButton", {
        BackgroundColor3 = Theme.Element,
        Size = UDim2.new(0, 70, 0, 30),
        Position = UDim2.new(1, -86, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "Close",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = topBar,
    })
    corner(closeBtn, 10)
    stroke(closeBtn, Theme.Stroke, 1, 0)
    ripple(closeBtn)

    -- Tab side panel
    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.BackgroundAlt,
        Position = UDim2.new(0, 12, 0, 68),
        Size = UDim2.new(0, 168, 1, -80),
        Parent = main,
    })
    corner(sidebar, 14)
    stroke(sidebar, Theme.Stroke, 1, 0)

    local tabList = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })

    -- Content holder
    local content = create("Frame", {
        Name = "Content",
        BackgroundColor3 = Theme.BackgroundAlt,
        Position = UDim2.new(0, 192, 0, 68),
        Size = UDim2.new(1, -204, 1, -80),
        Parent = main,
    })
    corner(content, 14)
    stroke(content, Theme.Stroke, 1, 0)

    local pages = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = content,
    })

    ----------------------------------------------------------------
    -- Dragging
    ----------------------------------------------------------------
    do
        local dragging, dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                root.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    ----------------------------------------------------------------
    -- Minimize / Toggle key + Close
    ----------------------------------------------------------------
    local isVisible = true
    local function setVisible(state)
        isVisible = state
        if state then
            root.Visible = true
            root.GroupTransparency = 1
            root.Size = UDim2.new(0, 580, 0, 380)
            TweenService:Create(root, TW.Normal, {
                GroupTransparency = 0,
                Size = UDim2.new(0, 620, 0, 420),
            }):Play()
        else
            local t = TweenService:Create(root, TW.Normal, {
                GroupTransparency = 1,
                Size = UDim2.new(0, 580, 0, 380),
            })
            t:Play()
            t.Completed:Connect(function()
                if not isVisible then root.Visible = false end
            end)
        end
    end
    Window.SetVisible = function(_, s) setVisible(s) end

    closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            setVisible(not isVisible)
        end
    end)

    ----------------------------------------------------------------
    -- Tab system
    ----------------------------------------------------------------
    local tabs = {}
    local activeTab

    function Window:CreateTab(name, icon)
        local Tab = {}

        -- Tab button
        local tabBtn = create("TextButton", {
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
        })
        corner(tabBtn, 10)
        local tabStroke = stroke(tabBtn, Theme.Stroke, 1, 1)

        local indicator = create("Frame", {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Parent = tabBtn,
        })
        corner(indicator, 2)

        local tabLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Text = name,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabBtn,
        })

        -- Page (scrolling)
        local page = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = pages,
        })
        padding(page, 12)
        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })

        ------------------------------------------------------------
        -- Tab activation
        ------------------------------------------------------------
        local function select()
            if activeTab == Tab then return end
            if activeTab then
                activeTab.Page.Visible = false
                TweenService:Create(activeTab.Btn, TW.Fast, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(activeTab.Stroke, TW.Fast, { Transparency = 1 }):Play()
                TweenService:Create(activeTab.Label, TW.Fast, { TextColor3 = Theme.TextDim }):Play()
                TweenService:Create(activeTab.Indicator, TW.Fast, { Size = UDim2.new(0, 3, 0, 0) }):Play()
            end
            activeTab = Tab
            page.Visible = true
            page.Position = UDim2.new(0, 0, 0, 10)
            page.GroupTransparency = nil
            TweenService:Create(page, TW.Normal, { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(tabBtn, TW.Fast, { BackgroundTransparency = 0.6 }):Play()
            TweenService:Create(tabStroke, TW.Fast, { Transparency = 0.4, Color = Theme.StrokeAccent }):Play()
            TweenService:Create(tabLabel, TW.Fast, { TextColor3 = Theme.Text }):Play()
            TweenService:Create(indicator, TW.Bounce, { Size = UDim2.new(0, 3, 0, 20) }):Play()
        end

        tabBtn.MouseButton1Click:Connect(select)
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= Tab then
                TweenService:Create(tabBtn, TW.Fast, { BackgroundTransparency = 0.85 }):Play()
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= Tab then
                TweenService:Create(tabBtn, TW.Fast, { BackgroundTransparency = 1 }):Play()
            end
        end)

        Tab.Btn       = tabBtn
        Tab.Stroke    = tabStroke
        Tab.Label     = tabLabel
        Tab.Indicator = indicator
        Tab.Page      = page

        table.insert(tabs, Tab)
        if #tabs == 1 then select() end -- auto-select first tab

        ------------------------------------------------------------
        -- Generic element base builder
        ------------------------------------------------------------
        local function baseElement(height)
            local el = create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, height or 40),
                Parent = page,
            })
            corner(el, 10)
            local s = stroke(el, Theme.Stroke, 1, 0)
            return el, s
        end

        ------------------------------------------------------------
        -- SECTION
        ------------------------------------------------------------
        function Tab:CreateSection(text)
            local holder = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Parent = page,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                Text = string.upper(text),
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })
            return holder
        end

        ------------------------------------------------------------
        -- LABEL
        ------------------------------------------------------------
        function Tab:CreateLabel(text)
            local el = baseElement(36)
            local lbl = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Text = text,
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = el,
            })
            return {
                SetText = function(_, t) lbl.Text = t end,
                Instance = el,
            }
        end

        ------------------------------------------------------------
        -- BUTTON
        ------------------------------------------------------------
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local el = baseElement(42)
            local btn = create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false,
                Parent = el,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Text = cfg.Name or "Button",
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(1, -38, 0, 0),
                Text = "→",
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 16,
                Parent = btn,
            })
            ripple(el)
            clickPop(el)
            btn.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
            return el
        end

        ------------------------------------------------------------
        -- TOGGLE
        ------------------------------------------------------------
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or false
            local el = baseElement(42)
            local btn = create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false,
                Parent = el,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Text = cfg.Name or "Toggle",
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })

            local track = create("Frame", {
                BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff,
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -54, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = el,
            })
            corner(track, 11)
            local knob = create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = track,
            })
            corner(knob, 8)

            ripple(el)
            local function set(v, fire)
                state = v
                TweenService:Create(track, TW.Fast, {
                    BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
                }):Play()
                TweenService:Create(knob, TW.Bounce, {
                    Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                }):Play()
                if fire and cfg.Callback then task.spawn(cfg.Callback, state) end
            end
            btn.MouseButton1Click:Connect(function() set(not state, true) end)
            if state and cfg.Callback then task.spawn(cfg.Callback, true) end

            return {
                Set = function(_, v) set(v, true) end,
                Get = function() return state end,
                Instance = el,
            }
        end

        ------------------------------------------------------------
        -- SLIDER
        ------------------------------------------------------------
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local min      = cfg.Min or 0
            local max      = cfg.Max or 100
            local default  = math.clamp(cfg.Default or min, min, max)
            local decimals = cfg.Decimals or 0
            local suffix   = cfg.Suffix or ""
            local value    = default

            local el = baseElement(56)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -70, 0, 22),
                Position = UDim2.new(0, 12, 0, 6),
                Text = cfg.Name or "Slider",
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = el,
            })
            local valLabel = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -68, 0, 6),
                Text = tostring(default) .. suffix,
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = el,
            })

            local barBack = create("Frame", {
                BackgroundColor3 = Theme.ToggleOff,
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                Parent = el,
            })
            corner(barBack, 3)
            local fill = create("Frame", {
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = barBack,
            })
            corner(fill, 3)
            local knob = create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = barBack,
            })
            corner(knob, 6)

            local dragging = false
            local function round(n)
                local m = 10 ^ decimals
                return math.floor(n * m + 0.5) / m
            end
            local function update(x)
                local rel = math.clamp((x - barBack.AbsolutePosition.X) / barBack.AbsoluteSize.X, 0, 1)
                value = round(min + (max - min) * rel)
                local pct = (value - min) / (max - min)
                TweenService:Create(fill, TW.Fast, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
                TweenService:Create(knob, TW.Fast, { Position = UDim2.new(pct, 0, 0.5, 0) }):Play()
                valLabel.Text = tostring(value) .. suffix
                if cfg.Callback then task.spawn(cfg.Callback, value) end
            end

            barBack.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            ripple(el)

            return {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    local pct = (value - min) / (max - min)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    valLabel.Text = tostring(value) .. suffix
                    if cfg.Callback then task.spawn(cfg.Callback, value) end
                end,
                Get = function() return value end,
                Instance = el,
            }
        end

        ------------------------------------------------------------
        -- DROPDOWN
        ------------------------------------------------------------
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options  = cfg.Options or {}
            local multi    = cfg.Multi or false
            local selected = multi and {} or (cfg.Default or "Select...")
            local open     = false

            local el = baseElement(42)
            el.ClipsDescendants = true

            local header = create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = "",
                AutoButtonColor = false,
                Parent = el,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Text = cfg.Name or "Dropdown",
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })
            local valueLbl = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -40, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                Text = type(selected) == "table" and "None" or tostring(selected),
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = header,
            })
            local arrow = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                Text = "▾",
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 14,
                Parent = header,
            })

            local listHolder = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 44),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = el,
            })
            create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = listHolder,
            })

            local function refreshText()
                if multi then
                    local picks = {}
                    for k, v in pairs(selected) do if v then table.insert(picks, k) end end
                    valueLbl.Text = #picks > 0 and table.concat(picks, ", ") or "None"
                else
                    valueLbl.Text = tostring(selected)
                end
            end

            local optButtons = {}
            local function buildOptions()
                for _, b in ipairs(optButtons) do b:Destroy() end
                table.clear(optButtons)
                for _, opt in ipairs(options) do
                    local oBtn = create("TextButton", {
                        BackgroundColor3 = Theme.Section,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = listHolder,
                    })
                    corner(oBtn, 8)
                    local oStroke = stroke(oBtn, Theme.Stroke, 1, 0.5)
                    create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        Text = tostring(opt),
                        TextColor3 = Theme.TextDim,
                        Font = Theme.Font,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = oBtn,
                    })
                    local function highlight()
                        local on = multi and selected[opt] or (selected == opt)
                        TweenService:Create(oStroke, TW.Fast, {
                            Color = on and Theme.StrokeAccent or Theme.Stroke,
                            Transparency = on and 0.2 or 0.5,
                        }):Play()
                        TweenService:Create(oBtn:FindFirstChildOfClass("TextLabel"), TW.Fast, {
                            TextColor3 = on and Theme.Accent or Theme.TextDim
                        }):Play()
                    end
                    highlight()
                    oBtn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt]
                        else
                            selected = opt
                        end
                        refreshText()
                        for _, b in ipairs(optButtons) do
                            if b.Refresh then b.Refresh() end
                        end
                        if cfg.Callback then task.spawn(cfg.Callback, selected) end
                        if not multi then
                            open = false
                            TweenService:Create(el, TW.Normal, { Size = UDim2.new(1, 0, 0, 42) }):Play()
                            TweenService:Create(arrow, TW.Fast, { Rotation = 0 }):Play()
                        end
                    end)
                    oBtn.Refresh = highlight
                    table.insert(optButtons, oBtn)
                end
            end
            buildOptions()

            header.MouseButton1Click:Connect(function()
                open = not open
                local target = open and (52 + #options * 34) or 42
                TweenService:Create(el, TW.Normal, { Size = UDim2.new(1, 0, 0, target) }):Play()
                TweenService:Create(arrow, TW.Fast, { Rotation = open and 180 or 0 }):Play()
            end)
            ripple(el)

            return {
                Set = function(_, v) selected = v; refreshText(); for _, b in ipairs(optButtons) do b.Refresh() end end,
                Get = function() return selected end,
                Refresh = function(_, newOpts) options = newOpts; buildOptions() end,
                Instance = el,
            }
        end

        ------------------------------------------------------------
        -- TEXTBOX
        ------------------------------------------------------------
        function Tab:CreateTextbox(cfg)
            cfg = cfg or {}
            local el = baseElement(42)
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.45, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Text = cfg.Name or "Input",
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = el,
            })
            local box = create("Frame", {
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(0.5, -20, 0, 28),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = el,
            })
            corner(box, 8)
            local bStroke = stroke(box, Theme.Stroke, 1, 0)
            local input = create("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "Type...",
                PlaceholderColor3 = Theme.TextDim,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = box,
            })
            input.Focused:Connect(function()
                TweenService:Create(bStroke, TW.Fast, { Color = Theme.StrokeAccent, Transparency = 0.2 }):Play()
            end)
            input.FocusLost:Connect(function(enter)
                TweenService:Create(bStroke, TW.Fast, { Color = Theme.Stroke, Transparency = 0 }):Play()
                if cfg.Callback then task.spawn(cfg.Callback, input.Text, enter) end
            end)
            return {
                Set = function(_, t) input.Text = t end,
                Get = function() return input.Text end,
                Instance = el,
            }
        end

local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:CreateWindow({
    Title = "MoroLumina",
    SubTitle = "v1.0 • emerald build",
    ToggleKey = Enum.KeyCode.RightControl,
})

local Tab = Window:CreateTab("Main")

Tab:CreateSection("Combat")

Tab:CreateToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(v) print("Aimbot:", v) end,
})

Tab:CreateSlider({
    Name = "FOV",
    Min = 0, Max = 360, Default = 90, Suffix = "°",
    Callback = function(v) print("FOV:", v) end,
})

Tab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(o) print("Target:", o) end,
})

Tab:CreateKeybind({
    Name = "Panic Hide",
    Default = Enum.KeyCode.End,
    Callback = function() Window:SetVisible(false) end,
})

Tab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 225, 134),
    Callback = function(c) print(c) end,
})

Tab:CreateButton({
    Name = "Bypass complete",
    Callback = function()
        Window:Notify({
            Title = "Bypass complete",
            Content = "Close anytime · 33.52",
            Type = "Success",
            Duration = 5,
        })
    end,
})

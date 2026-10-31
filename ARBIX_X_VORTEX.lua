--[[
    ARBIX X VORTEX | Animated UI Library
    Client-side UI library for Roblox experiences and supported Luau environments.
    This file creates interface elements only; connect callbacks to your own game systems.

    Quick start:
        local Vortex = loadstring(readfile("ARBIX_X_VORTEX.lua"))() -- only if your environment supports this pattern
        local Window = Vortex:CreateWindow({Name = "ARBIX X VORTEX"})
        local Tab = Window:CreateTab("Main", "✦")
        local Section = Tab:CreateSection("Controls")
        Section:CreateButton({Name = "Click me", Callback = function() print("Suiii") end})
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Vortex = {}
Vortex.__index = Vortex
Vortex.Version = "1.0.0"

local Theme = {
    Background = Color3.fromRGB(8, 10, 18),
    Background2 = Color3.fromRGB(12, 16, 28),
    Panel = Color3.fromRGB(16, 21, 35),
    Panel2 = Color3.fromRGB(21, 28, 45),
    PanelHover = Color3.fromRGB(28, 38, 59),
    Stroke = Color3.fromRGB(48, 67, 94),
    Muted = Color3.fromRGB(133, 151, 178),
    Text = Color3.fromRGB(239, 246, 255),
    Cyan = Color3.fromRGB(48, 224, 255),
    Blue = Color3.fromRGB(67, 126, 255),
    Purple = Color3.fromRGB(166, 91, 255),
    Green = Color3.fromRGB(75, 235, 166),
    Red = Color3.fromRGB(255, 88, 117),
}

local function new(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    if parent then object.Parent = parent end
    return object
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function outline(parent, color, transparency, thickness)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, first, second, rotation)
    return new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, first),
            ColorSequenceKeypoint.new(1, second),
        }),
        Rotation = rotation or 0,
    }, parent)
end

local function label(parent, text, size, color, font)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 13,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function tween(object, duration, properties, style, direction)
    if not object or not object.Parent then return nil end
    local info = TweenInfo.new(
        duration or 0.22,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local function safeCallback(callback, ...)
    if type(callback) ~= "function" then return end
    local success, problem = pcall(callback, ...)
    if not success then warn("[ARBIX X VORTEX] Callback error: " .. tostring(problem)) end
end

local function makeButton(parent, text, size, position)
    local button = new("TextButton", {
        Name = "ActionButton",
        Size = size or UDim2.new(1, 0, 0, 42),
        Position = position or UDim2.new(),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text or "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
    }, parent)
    corner(button, 10)
    outline(button, Theme.Stroke, 0.35, 1)
    local scale = new("UIScale", {Scale = 1}, button)
    button.MouseEnter:Connect(function()
        tween(button, 0.16, {BackgroundColor3 = Theme.PanelHover})
        tween(scale, 0.16, {Scale = 1.025})
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.16, {BackgroundColor3 = Theme.Panel2})
        tween(scale, 0.16, {Scale = 1})
    end)
    button.MouseButton1Down:Connect(function()
        tween(scale, 0.08, {Scale = 0.965})
    end)
    button.MouseButton1Up:Connect(function()
        tween(scale, 0.12, {Scale = 1.025})
    end)
    return button
end

local function addList(parent, padding)
    return new("UIListLayout", {
        Padding = UDim.new(0, padding or 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    return player:WaitForChild("PlayerGui")
end

local function addStarField(parent, amount, seed)
    local random = Random.new(seed or math.random(1, 999999))
    local glyphs = {"✦", "✧", "⋆", "·", "✺"}
    for index = 1, amount or 38 do
        local star = new("TextLabel", {
            Name = "VortexStar_" .. index,
            BackgroundTransparency = 1,
            Text = glyphs[random:NextInteger(1, #glyphs)],
            TextColor3 = ({Theme.Cyan, Theme.Purple, Color3.fromRGB(224, 242, 255)})[random:NextInteger(1, 3)],
            TextSize = random:NextInteger(8, 20),
            Font = Enum.Font.GothamBold,
            TextTransparency = random:NextNumber(0.2, 0.75),
            Rotation = random:NextInteger(0, 360),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(random:NextNumber(0.02, 0.98), random:NextNumber(0.02, 0.98)),
            Size = UDim2.fromOffset(24, 24),
            ZIndex = 2,
        }, parent)
        local duration = random:NextNumber(2.4, 5.8)
        local destination = UDim2.new(
            star.Position.X.Scale + random:NextNumber(-0.045, 0.045), 0,
            star.Position.Y.Scale + random:NextNumber(-0.06, 0.06), 0
        )
        local animation = TweenService:Create(star, TweenInfo.new(
            duration,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            -1,
            true,
            random:NextNumber(0, 2)
        ), {
            Position = destination,
            Rotation = star.Rotation + random:NextInteger(-80, 80),
            TextTransparency = random:NextNumber(0.1, 0.9),
        })
        animation:Play()
    end
end

function Vortex:CreateWindow(settings)
    settings = settings or {}
    local window = {}
    window._tabs = {}
    window._components = {}
    window._keybinds = {}
    window._visible = true
    window._destroyed = false
    window._toggleKey = settings.ToggleKey or Enum.KeyCode.RightShift
    window._name = settings.Name or "ARBIX X VORTEX"

    local parent = getGuiParent()
    local old = parent:FindFirstChild("ARBIX_X_VORTEX_UI")
    if old then old:Destroy() end

    local gui = new("ScreenGui", {
        Name = "ARBIX_X_VORTEX_UI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    }, parent)
    window.Gui = gui

    local intro = new("Frame", {
        Name = "StarIntro",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, gui)
    local introGradient = gradient(intro, Color3.fromRGB(7, 12, 26), Color3.fromRGB(21, 10, 39), 35)
    tween(introGradient, 8, {Rotation = 395}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    addStarField(intro, 56)

    local introOrb = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.45),
        Size = UDim2.fromOffset(178, 178),
        BackgroundTransparency = 1,
        ZIndex = 53,
    }, intro)
    corner(introOrb, 100)
    local orbStroke = outline(introOrb, Theme.Cyan, 0.1, 2)
    local orbGradient = gradient(orbStroke, Theme.Cyan, Theme.Purple, 20)
    tween(orbGradient, 4, {Rotation = 360}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local orbInner = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(145, 145),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 54,
    }, introOrb)
    corner(orbInner, 100)
    outline(orbInner, Theme.Purple, 0.35, 1)

    local logo = label(orbInner, "A✦V", 38, Theme.Text, Enum.Font.GothamBlack)
    logo.Size = UDim2.fromScale(1, 1)
    logo.TextXAlignment = Enum.TextXAlignment.Center
    logo.ZIndex = 55
    local logoGradient = gradient(logo, Theme.Cyan, Theme.Purple, 0)
    tween(logoGradient, 2.4, {Rotation = 360}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local introTitle = label(intro, "ARBIX X VORTEX", 25, Theme.Text, Enum.Font.GothamBlack)
    introTitle.AnchorPoint = Vector2.new(0.5, 0)
    introTitle.Position = UDim2.new(0.5, 0, 0.45, 108)
    introTitle.Size = UDim2.fromOffset(420, 36)
    introTitle.TextXAlignment = Enum.TextXAlignment.Center
    introTitle.ZIndex = 54
    local titleGradient = gradient(introTitle, Theme.Cyan, Theme.Purple, 0)
    tween(titleGradient, 3, {Rotation = 360}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local introSubtitle = label(intro, settings.IntroSubtitle or "A DIFFERENT LEVEL OF CONTROL", 10, Theme.Muted, Enum.Font.GothamBold)
    introSubtitle.AnchorPoint = Vector2.new(0.5, 0)
    introSubtitle.Position = UDim2.new(0.5, 0, 0.45, 145)
    introSubtitle.Size = UDim2.fromOffset(340, 20)
    introSubtitle.TextXAlignment = Enum.TextXAlignment.Center
    introSubtitle.ZIndex = 54
    introSubtitle.TextTransparency = 0.2

    local progressBack = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.45, 183),
        Size = UDim2.fromOffset(250, 5),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 54,
    }, intro)
    corner(progressBack, 8)
    local progressFill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Cyan,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, progressBack)
    corner(progressFill, 8)
    gradient(progressFill, Theme.Cyan, Theme.Purple, 0)

    local loadingText = label(intro, "INITIALIZING INTERFACE", 9, Theme.Muted, Enum.Font.GothamBold)
    loadingText.AnchorPoint = Vector2.new(0.5, 0)
    loadingText.Position = UDim2.new(0.5, 0, 0.45, 198)
    loadingText.Size = UDim2.fromOffset(250, 18)
    loadingText.TextXAlignment = Enum.TextXAlignment.Center
    loadingText.ZIndex = 54

    local shadow = new("Frame", {
        Name = "WindowShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 20),
        Size = UDim2.fromOffset(670, 460),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.42,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, gui)
    corner(shadow, 18)

    local main = new("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 24),
        Size = UDim2.fromOffset(650, 440),
        BackgroundColor3 = Theme.Background2,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 11,
    }, gui)
    corner(main, 17)
    local mainStroke = outline(main, Theme.Cyan, 0.35, 1.2)
    gradient(mainStroke, Theme.Cyan, Theme.Purple, 25)
    local mainScale = new("UIScale", {Scale = 1}, main)

    local function resizeForViewport()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local scale = math.min(1, (viewport.X - 24) / 650, (viewport.Y - 24) / 440)
        mainScale.Scale = math.clamp(scale, 0.58, 1)
        shadow.Size = UDim2.fromOffset(670, 460)
    end
    resizeForViewport()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeForViewport)
    end

    local topLine = new("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Cyan,
        BorderSizePixel = 0,
        ZIndex = 15,
    }, main)
    gradient(topLine, Theme.Cyan, Theme.Purple, 0)

    local header = new("Frame", {
        Name = "Header",
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.new(1, 0, 0, 57),
        BackgroundColor3 = Theme.Background2,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, main)

    local logoMark = new("Frame", {
        Position = UDim2.fromOffset(16, 12),
        Size = UDim2.fromOffset(33, 33),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 14,
    }, header)
    corner(logoMark, 10)
    local logoMarkStroke = outline(logoMark, Theme.Cyan, 0.2, 1)
    gradient(logoMarkStroke, Theme.Cyan, Theme.Purple, 0)
    local logoMarkText = label(logoMark, "✦", 21, Theme.Cyan, Enum.Font.GothamBlack)
    logoMarkText.Size = UDim2.fromScale(1, 1)
    logoMarkText.TextXAlignment = Enum.TextXAlignment.Center
    logoMarkText.ZIndex = 15

    local appTitle = label(header, window._name, 14, Theme.Text, Enum.Font.GothamBold)
    appTitle.Position = UDim2.fromOffset(59, 9)
    appTitle.Size = UDim2.fromOffset(245, 20)
    appTitle.ZIndex = 14
    local appSubtitle = label(header, "PREMIUM INTERFACE  •  " .. Vortex.Version, 8, Theme.Muted, Enum.Font.GothamBold)
    appSubtitle.Position = UDim2.fromOffset(60, 29)
    appSubtitle.Size = UDim2.fromOffset(220, 15)
    appSubtitle.ZIndex = 14

    local searchBox = new("TextBox", {
        Name = "Search",
        PlaceholderText = "Search controls...",
        Text = "",
        ClearTextOnFocus = false,
        Position = UDim2.new(1, -230, 0, 14),
        Size = UDim2.fromOffset(135, 29),
        BackgroundColor3 = Theme.Panel,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Muted,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 14,
    }, header)
    corner(searchBox, 8)
    outline(searchBox, Theme.Stroke, 0.5, 1)

    local hideButton = makeButton(header, "—", UDim2.fromOffset(29, 29), UDim2.new(1, -84, 0, 14))
    hideButton.Name = "Minimize"
    hideButton.TextSize = 18
    hideButton.ZIndex = 15
    local closeButton = makeButton(header, "×", UDim2.fromOffset(29, 29), UDim2.new(1, -47, 0, 14))
    closeButton.Name = "Close"
    closeButton.TextSize = 19
    closeButton.TextColor3 = Theme.Red
    closeButton.ZIndex = 15

    local body = new("Frame", {
        Position = UDim2.fromOffset(0, 59),
        Size = UDim2.new(1, 0, 1, -59),
        BackgroundTransparency = 1,
        ZIndex = 12,
    }, main)

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 151, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, body)
    local sidebarLine = new("Frame", {
        Position = UDim2.new(1, -1, 0, 12),
        Size = UDim2.new(0, 1, 1, -24),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
    }, sidebar)

    local navTitle = label(sidebar, "NAVIGATION", 9, Theme.Muted, Enum.Font.GothamBold)
    navTitle.Position = UDim2.fromOffset(17, 17)
    navTitle.Size = UDim2.new(1, -28, 0, 18)

    local navScroll = new("ScrollingFrame", {
        Name = "Navigation",
        Position = UDim2.fromOffset(10, 43),
        Size = UDim2.new(1, -19, 1, -55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Cyan,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 13,
    }, sidebar)
    local navLayout = addList(navScroll, 7)

    local pageHolder = new("Frame", {
        Position = UDim2.fromOffset(151, 0),
        Size = UDim2.new(1, -151, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 12,
    }, body)

    local pageHeading = label(pageHolder, "WELCOME", 17, Theme.Text, Enum.Font.GothamBold)
    pageHeading.Position = UDim2.fromOffset(20, 14)
    pageHeading.Size = UDim2.new(1, -40, 0, 25)
    local pageSubheading = label(pageHolder, "Choose a tab to get started.", 10, Theme.Muted, Enum.Font.Gotham)
    pageSubheading.Position = UDim2.fromOffset(20, 38)
    pageSubheading.Size = UDim2.new(1, -40, 0, 18)

    local pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(13, 64),
        Size = UDim2.new(1, -26, 1, -76),
        BackgroundTransparency = 1,
        ZIndex = 12,
    }, pageHolder)

    local notificationHolder = new("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(300, 300),
        BackgroundTransparency = 1,
        ZIndex = 100,
    }, gui)

    local dragActive = false
    local dragStart, startPosition
    header.InputBegan:Connect(function(input)
        local rightSideStart = header.AbsolutePosition.X + header.AbsoluteSize.X - 250
        if input.Position.X >= rightSideStart then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragActive = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragActive = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            shadow.Position = main.Position + UDim2.fromOffset(0, 8)
        end
    end)

    local function setVisible(state)
        window._visible = state
        if state then
            shadow.Visible = true
            main.Visible = true
            shadow.Position = main.Position + UDim2.fromOffset(0, 8)
            main.Position = main.Position + UDim2.fromOffset(0, 10)
            tween(main, 0.24, {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset - 10)})
            tween(mainScale, 0.22, {Scale = mainScale.Scale})
            tween(shadow, 0.22, {BackgroundTransparency = 0.42})
        else
            tween(main, 0.18, {Position = main.Position + UDim2.fromOffset(0, 12)})
            tween(shadow, 0.18, {BackgroundTransparency = 1})
            task.delay(0.19, function()
                if not window._visible and main.Parent then
                    main.Visible = false
                    shadow.Visible = false
                end
            end)
        end
    end

    hideButton.MouseButton1Click:Connect(function()
        setVisible(false)
        window:Notify("ARBIX X VORTEX", "Interface minimized. Press " .. window._toggleKey.Name .. " to reopen.", 3)
    end)
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or window._destroyed then return end
        if input.KeyCode == window._toggleKey then
            setVisible(not window._visible)
            return
        end
        for _, binding in ipairs(window._keybinds) do
            if binding.Enabled and input.KeyCode == binding.Key and not binding.Listening then
                safeCallback(binding.Callback, input.KeyCode)
            end
        end
    end)

    function window:Notify(titleText, message, duration)
        if window._destroyed then return end
        local card = new("Frame", {
            Name = "Notification",
            Size = UDim2.fromOffset(280, 70),
            Position = UDim2.new(1, 310, 1, 0),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            ZIndex = 101,
        }, notificationHolder)
        corner(card, 12)
        local edge = outline(card, Theme.Cyan, 0.3, 1)
        gradient(edge, Theme.Cyan, Theme.Purple, 0)
        local bar = new("Frame", {
            Position = UDim2.fromOffset(0, 10),
            Size = UDim2.fromOffset(3, 50),
            BackgroundColor3 = Theme.Cyan,
            BorderSizePixel = 0,
            ZIndex = 102,
        }, card)
        corner(bar, 4)
        local heading = label(card, tostring(titleText or "Notification"), 12, Theme.Text, Enum.Font.GothamBold)
        heading.Position = UDim2.fromOffset(14, 10)
        heading.Size = UDim2.new(1, -24, 0, 19)
        heading.ZIndex = 102
        local bodyText = label(card, tostring(message or ""), 10, Theme.Muted, Enum.Font.Gotham)
        bodyText.Position = UDim2.fromOffset(14, 31)
        bodyText.Size = UDim2.new(1, -24, 0, 27)
        bodyText.TextWrapped = true
        bodyText.ZIndex = 102
        tween(card, 0.34, {Position = UDim2.new(1, 0, 1, 0)})
        task.delay(duration or 3, function()
            if card.Parent then
                tween(card, 0.24, {Position = UDim2.new(1, 310, 1, 0), BackgroundTransparency = 1})
                task.wait(0.26)
                if card.Parent then card:Destroy() end
            end
        end)
        return card
    end

    function window:SetVisible(state)
        setVisible(state == true)
    end

    function window:SetToggleKey(keyCode)
        if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
            window._toggleKey = keyCode
        end
    end

    function window:Destroy()
        if window._destroyed then return end
        window._destroyed = true
        tween(mainScale, 0.2, {Scale = 0.92})
        tween(main, 0.2, {BackgroundTransparency = 1})
        tween(intro, 0.2, {BackgroundTransparency = 1})
        task.delay(0.22, function()
            if gui.Parent then gui:Destroy() end
        end)
    end

    local function selectTab(tab)
        for _, item in ipairs(window._tabs) do
            local selected = item == tab
            item.Page.Visible = selected
            tween(item.Button, 0.16, {
                BackgroundColor3 = selected and Theme.PanelHover or Theme.Background,
                TextColor3 = selected and Theme.Cyan or Theme.Muted,
            })
            if item.Indicator then
                tween(item.Indicator, 0.16, {BackgroundTransparency = selected and 0 or 1})
            end
        end
        pageHeading.Text = tab.Name:upper()
        pageSubheading.Text = tab.Description or "Manage your " .. tab.Name:lower() .. " settings."
        tab.Page.Position = UDim2.fromOffset(8, 0)
        tween(tab.Page, 0.2, {Position = UDim2.fromOffset(0, 0)})
    end

    function window:CreateTab(name, iconText, description)
        local tab = {
            Name = name or "Tab",
            Description = description,
        }
        local navButton = new("TextButton", {
            Name = "Tab_" .. tostring(name or "Tab"),
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 14,
        }, navScroll)
        corner(navButton, 9)
        local indicator = new("Frame", {
            Position = UDim2.fromOffset(0, 8),
            Size = UDim2.fromOffset(3, 22),
            BackgroundColor3 = Theme.Cyan,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 15,
        }, navButton)
        corner(indicator, 5)
        local iconLabel = label(navButton, iconText or "✦", 15, Theme.Muted, Enum.Font.GothamBold)
        iconLabel.Position = UDim2.fromOffset(12, 0)
        iconLabel.Size = UDim2.fromOffset(23, 38)
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.ZIndex = 15
        local nameLabel = label(navButton, tostring(name or "Tab"), 11, Theme.Muted, Enum.Font.GothamSemibold)
        nameLabel.Position = UDim2.fromOffset(43, 0)
        nameLabel.Size = UDim2.new(1, -49, 1, 0)
        nameLabel.ZIndex = 15
        tab.Button = navButton
        tab.Indicator = indicator
        tab.Page = new("ScrollingFrame", {
            Name = "Page_" .. tostring(name or "Tab"),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Cyan,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 13,
        }, pages)
        addList(tab.Page, 11)
        new("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 1),
            PaddingRight = UDim.new(0, 7),
        }, tab.Page)
        table.insert(window._tabs, tab)
        navButton.MouseButton1Click:Connect(function() selectTab(tab) end)
        navButton.MouseEnter:Connect(function()
            if not tab.Page.Visible then tween(navButton, 0.14, {BackgroundColor3 = Theme.Panel}) end
        end)
        navButton.MouseLeave:Connect(function()
            if not tab.Page.Visible then tween(navButton, 0.14, {BackgroundColor3 = Theme.Background}) end
        end)
        if #window._tabs == 1 then selectTab(tab) end

        function tab:CreateSection(sectionName)
            local section = {}
            local holder = new("Frame", {
                Name = "Section_" .. tostring(sectionName or "Section"),
                Size = UDim2.new(1, -2, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                ZIndex = 14,
            }, tab.Page)
            corner(holder, 12)
            outline(holder, Theme.Stroke, 0.52, 1)
            local accent = new("Frame", {
                Position = UDim2.fromOffset(13, 12),
                Size = UDim2.fromOffset(3, 17),
                BackgroundColor3 = Theme.Cyan,
                BorderSizePixel = 0,
                ZIndex = 15,
            }, holder)
            corner(accent, 4)
            local sectionTitle = label(holder, tostring(sectionName or "Section"), 12, Theme.Text, Enum.Font.GothamBold)
            sectionTitle.Position = UDim2.fromOffset(24, 8)
            sectionTitle.Size = UDim2.new(1, -36, 0, 25)
            sectionTitle.ZIndex = 15
            local content = new("Frame", {
                Name = "Content",
                Position = UDim2.fromOffset(11, 39),
                Size = UDim2.new(1, -22, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 15,
            }, holder)
            addList(content, 7)
            new("UIPadding", {PaddingBottom = UDim.new(0, 11)}, content)

            local function register(frame, searchName)
                table.insert(window._components, {
                    Frame = frame,
                    Name = string.lower(tostring(searchName or "")),
                    Tab = tab,
                })
                return frame
            end

            local function basicRow(rowName, height)
                local row = new("Frame", {
                    Name = rowName or "Control",
                    Size = UDim2.new(1, 0, 0, height or 52),
                    BackgroundColor3 = Theme.Panel2,
                    BorderSizePixel = 0,
                    ZIndex = 16,
                }, content)
                corner(row, 9)
                outline(row, Theme.Stroke, 0.72, 1)
                return row
            end

            function section:CreateButton(options)
                options = options or {}
                local row = basicRow("Button_" .. tostring(options.Name or "Action"), 52)
                local title = label(row, options.Name or "Button", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 5)
                title.Size = UDim2.new(1, -58, 0, 20)
                local descriptionLabel = label(row, options.Description or "Press to run this action", 9, Theme.Muted, Enum.Font.Gotham)
                descriptionLabel.Position = UDim2.fromOffset(13, 26)
                descriptionLabel.Size = UDim2.new(1, -58, 0, 16)
                local action = new("TextButton", {
                    Size = UDim2.fromOffset(31, 30),
                    Position = UDim2.new(1, -43, 0.5, -15),
                    BackgroundColor3 = Color3.fromRGB(24, 49, 69),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "↗",
                    TextColor3 = Theme.Cyan,
                    TextSize = 16,
                    Font = Enum.Font.GothamBold,
                    ZIndex = 18,
                }, row)
                corner(action, 8)
                action.MouseEnter:Connect(function() tween(action, 0.14, {BackgroundColor3 = Color3.fromRGB(33, 69, 91)}) end)
                action.MouseLeave:Connect(function() tween(action, 0.14, {BackgroundColor3 = Color3.fromRGB(24, 49, 69)}) end)
                action.MouseButton1Click:Connect(function()
                    tween(action, 0.08, {Size = UDim2.fromOffset(27, 27)})
                    task.delay(0.08, function() if action.Parent then tween(action, 0.12, {Size = UDim2.fromOffset(31, 30)}) end end)
                    safeCallback(options.Callback)
                end)
                register(row, options.Name)
                return row
            end

            function section:CreateToggle(options)
                options = options or {}
                local state = options.Default == true
                local row = basicRow("Toggle_" .. tostring(options.Name or "Toggle"), 52)
                local title = label(row, options.Name or "Toggle", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 0)
                title.Size = UDim2.new(1, -80, 1, 0)
                local switch = new("TextButton", {
                    Position = UDim2.new(1, -53, 0.5, -11),
                    Size = UDim2.fromOffset(40, 22),
                    BackgroundColor3 = state and Theme.Cyan or Color3.fromRGB(56, 66, 83),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 18,
                }, row)
                corner(switch, 20)
                local knob = new("Frame", {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Color3.fromRGB(245, 250, 255),
                    BorderSizePixel = 0,
                    ZIndex = 19,
                }, switch)
                corner(knob, 20)
                local function setState(value, call)
                    state = value == true
                    tween(switch, 0.18, {BackgroundColor3 = state and Theme.Cyan or Color3.fromRGB(56, 66, 83)})
                    tween(knob, 0.18, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                    if call ~= false then safeCallback(options.Callback, state) end
                end
                switch.MouseButton1Click:Connect(function() setState(not state) end)
                register(row, options.Name)
                return {
                    Set = function(_, value) setState(value, true) end,
                    Get = function() return state end,
                }
            end

            function section:CreateSlider(options)
                options = options or {}
                local minimum = tonumber(options.Min) or 0
                local maximum = tonumber(options.Max) or 100
                local step = tonumber(options.Step) or 1
                local value = math.clamp(tonumber(options.Default) or minimum, minimum, maximum)
                local row = basicRow("Slider_" .. tostring(options.Name or "Slider"), 72)
                local title = label(row, options.Name or "Slider", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 7)
                title.Size = UDim2.new(1, -90, 0, 19)
                local valueLabel = label(row, tostring(value), 10, Theme.Cyan, Enum.Font.GothamBold)
                valueLabel.Position = UDim2.new(1, -67, 0, 7)
                valueLabel.Size = UDim2.fromOffset(54, 19)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                local track = new("Frame", {
                    Position = UDim2.new(0, 13, 0, 45),
                    Size = UDim2.new(1, -26, 0, 5),
                    BackgroundColor3 = Color3.fromRGB(49, 60, 79),
                    BorderSizePixel = 0,
                    ZIndex = 17,
                }, row)
                corner(track, 8)
                local ratio = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                local fill = new("Frame", {
                    Size = UDim2.new(ratio, 0, 1, 0),
                    BackgroundColor3 = Theme.Cyan,
                    BorderSizePixel = 0,
                    ZIndex = 18,
                }, track)
                corner(fill, 8)
                gradient(fill, Theme.Cyan, Theme.Purple, 0)
                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(ratio, 0, 0.5, 0),
                    Size = UDim2.fromOffset(13, 13),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 19,
                }, track)
                corner(knob, 20)
                outline(knob, Theme.Cyan, 0.1, 1)
                local dragging = false
                local function setValue(nextValue, call)
                    local snapped = minimum + math.floor(((nextValue - minimum) / step) + 0.5) * step
                    value = math.clamp(snapped, minimum, maximum)
                    local newRatio = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                    tween(fill, 0.08, {Size = UDim2.new(newRatio, 0, 1, 0)}, Enum.EasingStyle.Quad)
                    tween(knob, 0.08, {Position = UDim2.new(newRatio, 0, 0.5, 0)}, Enum.EasingStyle.Quad)
                    valueLabel.Text = tostring(value)
                    if call ~= false then safeCallback(options.Callback, value) end
                end
                local function updateFromX(x)
                    local width = math.max(track.AbsoluteSize.X, 1)
                    local ratioNow = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
                    setValue(minimum + (maximum - minimum) * ratioNow, true)
                end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromX(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromX(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end)
                register(row, options.Name)
                return {
                    Set = function(_, nextValue) setValue(tonumber(nextValue) or minimum, true) end,
                    Get = function() return value end,
                }
            end

            function section:CreateTextbox(options)
                options = options or {}
                local row = basicRow("Textbox_" .. tostring(options.Name or "Textbox"), 66)
                local title = label(row, options.Name or "Textbox", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 7)
                title.Size = UDim2.new(1, -20, 0, 18)
                local box = new("TextBox", {
                    Position = UDim2.fromOffset(12, 31),
                    Size = UDim2.new(1, -24, 0, 26),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = options.Default or "",
                    PlaceholderText = options.Placeholder or "Type here...",
                    PlaceholderColor3 = Theme.Muted,
                    TextColor3 = Theme.Text,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 18,
                }, row)
                corner(box, 7)
                outline(box, Theme.Stroke, 0.4, 1)
                new("UIPadding", {PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 8)}, box)
                box.FocusLost:Connect(function(enterPressed)
                    safeCallback(options.Callback, box.Text, enterPressed)
                end)
                register(row, options.Name)
                return {
                    Set = function(_, value) box.Text = tostring(value) end,
                    Get = function() return box.Text end,
                }
            end

            function section:CreateDropdown(options)
                options = options or {}
                local choices = options.Options or {}
                local selected = options.Default or choices[1] or "Select an option"
                local expanded = false
                local row = basicRow("Dropdown_" .. tostring(options.Name or "Dropdown"), 55)
                local title = label(row, options.Name or "Dropdown", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 5)
                title.Size = UDim2.new(1, -20, 0, 18)
                local pick = makeButton(row, tostring(selected) .. "   ▾", UDim2.new(1, -24, 0, 25), UDim2.fromOffset(12, 25))
                pick.TextSize = 10
                pick.TextXAlignment = Enum.TextXAlignment.Left
                new("UIPadding", {PaddingLeft = UDim.new(0, 9)}, pick)
                local optionsHolder = new("Frame", {
                    Position = UDim2.fromOffset(12, 55),
                    Size = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Visible = false,
                    ZIndex = 20,
                }, row)
                addList(optionsHolder, 4)
                local function refreshSize()
                    local height = expanded and (55 + #choices * 29 + 5) or 55
                    tween(row, 0.18, {Size = UDim2.new(1, 0, 0, height)})
                    optionsHolder.Visible = expanded
                    optionsHolder.Size = UDim2.new(1, -24, 0, #choices * 25 + math.max(0, #choices - 1) * 4)
                end
                for _, choice in ipairs(choices) do
                    local optionButton = makeButton(optionsHolder, tostring(choice), UDim2.new(1, 0, 0, 25))
                    optionButton.TextSize = 10
                    optionButton.MouseButton1Click:Connect(function()
                        selected = choice
                        pick.Text = tostring(selected) .. "   ▾"
                        expanded = false
                        refreshSize()
                        safeCallback(options.Callback, selected)
                    end)
                end
                pick.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    refreshSize()
                end)
                register(row, options.Name)
                return {
                    Set = function(_, value)
                        selected = value
                        pick.Text = tostring(selected) .. "   ▾"
                        safeCallback(options.Callback, selected)
                    end,
                    Get = function() return selected end,
                }
            end

            function section:CreateKeybind(options)
                options = options or {}
                local row = basicRow("Keybind_" .. tostring(options.Name or "Keybind"), 52)
                local title = label(row, options.Name or "Keybind", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 0)
                title.Size = UDim2.new(1, -105, 1, 0)
                local key = options.Default or Enum.KeyCode.E
                local listening = false
                local keyButton = makeButton(row, key.Name, UDim2.fromOffset(76, 28), UDim2.new(1, -88, 0.5, -14))
                keyButton.TextSize = 10
                local binding = {Key = key, Callback = options.Callback, Enabled = true, Listening = false}
                table.insert(window._keybinds, binding)
                keyButton.MouseButton1Click:Connect(function()
                    listening = true
                    binding.Listening = true
                    keyButton.Text = "..."
                    window:Notify("Keybind", "Press a key to bind it.", 2)
                end)
                local captureConnection
                captureConnection = UserInputService.InputBegan:Connect(function(input, processed)
                    if not listening or processed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            listening = false
                            binding.Listening = false
                            keyButton.Text = key.Name
                            return
                        end
                        key = input.KeyCode
                        binding.Key = key
                        listening = false
                        binding.Listening = false
                        keyButton.Text = key.Name
                    end
                end)
                register(row, options.Name)
                return {
                    Set = function(_, newKey)
                        if typeof(newKey) == "EnumItem" and newKey.EnumType == Enum.KeyCode then
                            key = newKey
                            binding.Key = newKey
                            keyButton.Text = newKey.Name
                        end
                    end,
                    Get = function() return key end,
                    Disconnect = function()
                        binding.Enabled = false
                        if captureConnection then captureConnection:Disconnect() end
                    end,
                }
            end

            function section:CreateColorPicker(options)
                options = options or {}
                local palette = options.Colors or {Theme.Cyan, Theme.Purple, Theme.Blue, Theme.Green, Theme.Red}
                local index = 1
                local current = options.Default or palette[index]
                for i, color in ipairs(palette) do if color == current then index = i break end end
                local row = basicRow("ColorPicker_" .. tostring(options.Name or "Color"), 52)
                local title = label(row, options.Name or "Accent color", 11, Theme.Text, Enum.Font.GothamSemibold)
                title.Position = UDim2.fromOffset(13, 0)
                title.Size = UDim2.new(1, -80, 1, 0)
                local swatch = makeButton(row, "", UDim2.fromOffset(40, 25), UDim2.new(1, -53, 0.5, -12))
                swatch.BackgroundColor3 = current
                swatch.MouseButton1Click:Connect(function()
                    index = index % #palette + 1
                    current = palette[index]
                    tween(swatch, 0.16, {BackgroundColor3 = current})
                    safeCallback(options.Callback, current)
                end)
                register(row, options.Name)
                return {
                    Set = function(_, color)
                        if typeof(color) == "Color3" then
                            current = color
                            swatch.BackgroundColor3 = color
                            safeCallback(options.Callback, color)
                        end
                    end,
                    Get = function() return current end,
                }
            end

            function section:CreateLabel(textValue)
                local row = basicRow("Label", 34)
                local textObject = label(row, tostring(textValue or "Label"), 10, Theme.Muted, Enum.Font.Gotham)
                textObject.Position = UDim2.fromOffset(12, 0)
                textObject.Size = UDim2.new(1, -24, 1, 0)
                register(row, textValue)
                return {Set = function(_, value) textObject.Text = tostring(value) end}
            end

            function section:CreateParagraph(options)
                options = options or {}
                local row = basicRow("Paragraph", options.Height or 66)
                local heading = label(row, options.Title or "Information", 11, Theme.Text, Enum.Font.GothamBold)
                heading.Position = UDim2.fromOffset(12, 7)
                heading.Size = UDim2.new(1, -24, 0, 17)
                local bodyText = label(row, options.Content or "", 9, Theme.Muted, Enum.Font.Gotham)
                bodyText.Position = UDim2.fromOffset(12, 25)
                bodyText.Size = UDim2.new(1, -24, 1, -30)
                bodyText.TextYAlignment = Enum.TextYAlignment.Top
                bodyText.TextWrapped = true
                bodyText.TextTruncate = Enum.TextTruncate.None
                register(row, (options.Title or "") .. " " .. (options.Content or ""))
                return {
                    SetTitle = function(_, value) heading.Text = tostring(value) end,
                    SetContent = function(_, value) bodyText.Text = tostring(value) end,
                }
            end

            function section:CreateDivider(textValue)
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    ZIndex = 16,
                }, content)
                local line = new("Frame", {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Stroke,
                    BackgroundTransparency = 0.25,
                    BorderSizePixel = 0,
                }, row)
                if textValue then
                    local tag = label(row, "  " .. tostring(textValue) .. "  ", 8, Theme.Muted, Enum.Font.GothamBold)
                    tag.AutomaticSize = Enum.AutomaticSize.X
                    tag.Size = UDim2.fromOffset(0, 18)
                    tag.Position = UDim2.new(0, 9, 0.5, -9)
                    tag.BackgroundColor3 = Theme.Panel
                    tag.BackgroundTransparency = 0
                end
                register(row, textValue or "divider")
                return row
            end

            return section
        end

        return tab
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        for _, component in ipairs(window._components) do
            local matches = query == "" or string.find(component.Name, query, 1, true) ~= nil
            component.Frame.Visible = matches
            if query ~= "" and matches then
                component.Tab.Page.Visible = true
            end
        end
        if query ~= "" then
            for _, item in ipairs(window._tabs) do
                tween(item.Button, 0.12, {BackgroundColor3 = item.Page.Visible and Theme.PanelHover or Theme.Background})
            end
        end
    end)

    if settings.Intro == false then
        intro:Destroy()
        shadow.Visible = true
        main.Visible = true
        main.Position = UDim2.fromScale(0.5, 0.5)
    else
        tween(progressFill, 2.15, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quart)
        task.spawn(function()
            task.wait(0.7)
            if loadingText.Parent then loadingText.Text = "LOADING COMPONENTS" end
            task.wait(0.7)
            if loadingText.Parent then loadingText.Text = "PREPARING YOUR EXPERIENCE" end
            task.wait(0.85)
            if not gui.Parent or window._destroyed then return end
            tween(intro, 0.42, {BackgroundTransparency = 1})
            for _, child in ipairs(intro:GetDescendants()) do
                if child:IsA("TextLabel") then tween(child, 0.25, {TextTransparency = 1}) end
                if child:IsA("Frame") then tween(child, 0.25, {BackgroundTransparency = 1}) end
                if child:IsA("UIStroke") then tween(child, 0.25, {Transparency = 1}) end
            end
            task.wait(0.3)
            if intro.Parent then intro:Destroy() end
            if window._destroyed then return end
            shadow.Visible = true
            main.Visible = true
            main.Position = UDim2.new(0.5, 0, 0.5, 22)
            mainScale.Scale = 0.94
            tween(main, 0.45, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back)
            tween(mainScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
            window:Notify("Welcome", "ARBIX X VORTEX is ready.", 3)
        end)
    end

    return window
end

-- Default demo: running this file immediately opens the ARBIX X VORTEX interface.
-- Add your own tabs, sections, and callbacks below this example.
local DemoWindow = Vortex:CreateWindow({
    Name = "ARBIX X VORTEX",
    Intro = true,
    IntroSubtitle = "A DIFFERENT LEVEL OF CONTROL",
    ToggleKey = Enum.KeyCode.RightShift,
})
Vortex.Window = DemoWindow

local MainTab = DemoWindow:CreateTab("Main", "✦", "Your main controls and examples.")
local MainSection = MainTab:CreateSection("Quick Actions")

MainSection:CreateButton({
    Name = "Clicks",
    Description = "Value: 5  •  Example callback",
    Callback = function()
        DemoWindow:Notify("Clicks", "Suiii", 2.5)
        print("Suiii")
    end,
})

MainSection:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(value)
        print("Example Toggle:", value)
    end,
})

MainSection:CreateSlider({
    Name = "Example Slider",
    Min = 0,
    Max = 100,
    Default = 5,
    Step = 1,
    Callback = function(value)
        print("Slider value:", value)
    end,
})

local ExtraTab = DemoWindow:CreateTab("Extras", "✧", "More interface components.")
local ExtraSection = ExtraTab:CreateSection("Components")
ExtraSection:CreateDropdown({
    Name = "Choose an option",
    Options = {"Option One", "Option Two", "Option Three"},
    Default = "Option One",
    Callback = function(value) print("Selected:", value) end,
})
ExtraSection:CreateTextbox({
    Name = "Your text",
    Placeholder = "Type something...",
    Callback = function(value) print("Text:", value) end,
})
ExtraSection:CreateKeybind({
    Name = "Demo Keybind",
    Default = Enum.KeyCode.G,
    Callback = function() DemoWindow:Notify("Keybind", "G was pressed", 2) end,
})
ExtraSection:CreateColorPicker({
    Name = "Accent preview",
    Callback = function(color) print("Selected accent:", color) end,
})
ExtraSection:CreateParagraph({
    Title = "ARBIX X VORTEX",
    Content = "Animated star intro, neon accents, draggable layout, mobile-friendly controls, search, notifications, and reusable components.",
})

-- The returned table can also be captured when this file is loaded as a module.
return Vortex

--[[
    NexUI Library — v7.0 (Production Rewrite)
    
    FIXES:
      • ALL elements registered in theme system
      • Notification queue (no overlaps/race conditions)
      • Connection tracking + cleanup on popup close
      • Safe Tw() checks object existence
      • Slider math with strict clamping (no NaN)
      • Dropdown positioned on Overlay (no clip issues)
      • Lerp drag with weight
      • Indicator properly centered with AnchorPoint
      • Tween.Completed used instead of task.delay where critical
]]

local Library    = {}
Library.__index  = Library
Library.Flags    = {}
Library.Elements = {}
Library.Windows  = {}
Library._themed  = {}

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local TS      = game:GetService("TweenService")
local Http    = game:GetService("HttpService")
local Light   = game:GetService("Lighting")
local Stats   = game:GetService("Stats")
local LP      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════
--  THEMES
-- ═══════════════════════════════════════════════════
Library.Themes = {
    Default = {
        BG=Color3.fromRGB(8,8,12),IconBar=Color3.fromRGB(10,10,15),Panel=Color3.fromRGB(14,14,20),
        Elevated=Color3.fromRGB(20,20,28),Hover=Color3.fromRGB(28,28,38),Active=Color3.fromRGB(35,35,48),
        Card=Color3.fromRGB(16,16,23),CardHead=Color3.fromRGB(20,20,28),
        Accent=Color3.fromRGB(45,125,255),AccentDim=Color3.fromRGB(20,65,150),AccentGlow=Color3.fromRGB(35,100,230),
        Text=Color3.fromRGB(230,230,242),TextSub=Color3.fromRGB(135,135,158),
        TextMut=Color3.fromRGB(70,70,90),TextDis=Color3.fromRGB(45,45,60),
        Border=Color3.fromRGB(26,26,36),BorderLight=Color3.fromRGB(40,40,54),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(22,22,30),ToggleKnob=Color3.fromRGB(85,85,105),
        SliderTrack=Color3.fromRGB(20,20,28),SliderFill=Color3.fromRGB(45,125,255),SliderKnob=Color3.fromRGB(210,220,255),
    },
    Midnight = {
        BG=Color3.fromRGB(10,8,18),IconBar=Color3.fromRGB(12,10,22),Panel=Color3.fromRGB(16,13,28),
        Elevated=Color3.fromRGB(24,20,40),Hover=Color3.fromRGB(32,28,52),Active=Color3.fromRGB(40,35,60),
        Card=Color3.fromRGB(18,15,30),CardHead=Color3.fromRGB(22,18,36),
        Accent=Color3.fromRGB(130,80,255),AccentDim=Color3.fromRGB(70,40,150),AccentGlow=Color3.fromRGB(100,60,220),
        Text=Color3.fromRGB(230,225,245),TextSub=Color3.fromRGB(140,130,165),
        TextMut=Color3.fromRGB(75,65,100),TextDis=Color3.fromRGB(50,42,70),
        Border=Color3.fromRGB(30,25,45),BorderLight=Color3.fromRGB(45,38,65),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(24,20,36),ToggleKnob=Color3.fromRGB(90,80,115),
        SliderTrack=Color3.fromRGB(22,18,34),SliderFill=Color3.fromRGB(130,80,255),SliderKnob=Color3.fromRGB(215,200,255),
    },
    Ocean = {
        BG=Color3.fromRGB(6,12,14),IconBar=Color3.fromRGB(8,14,18),Panel=Color3.fromRGB(10,18,24),
        Elevated=Color3.fromRGB(16,26,34),Hover=Color3.fromRGB(22,34,44),Active=Color3.fromRGB(28,42,54),
        Card=Color3.fromRGB(12,20,26),CardHead=Color3.fromRGB(16,24,32),
        Accent=Color3.fromRGB(30,190,180),AccentDim=Color3.fromRGB(15,100,95),AccentGlow=Color3.fromRGB(25,150,140),
        Text=Color3.fromRGB(220,240,238),TextSub=Color3.fromRGB(120,155,150),
        TextMut=Color3.fromRGB(55,80,78),TextDis=Color3.fromRGB(35,55,52),
        Border=Color3.fromRGB(20,32,38),BorderLight=Color3.fromRGB(32,48,56),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(14,24,30),ToggleKnob=Color3.fromRGB(60,95,100),
        SliderTrack=Color3.fromRGB(12,22,28),SliderFill=Color3.fromRGB(30,190,180),SliderKnob=Color3.fromRGB(180,245,240),
    },
    Rose = {
        BG=Color3.fromRGB(14,8,10),IconBar=Color3.fromRGB(18,10,13),Panel=Color3.fromRGB(24,14,18),
        Elevated=Color3.fromRGB(34,20,26),Hover=Color3.fromRGB(44,28,34),Active=Color3.fromRGB(54,35,42),
        Card=Color3.fromRGB(26,16,20),CardHead=Color3.fromRGB(30,18,24),
        Accent=Color3.fromRGB(235,65,100),AccentDim=Color3.fromRGB(140,30,55),AccentGlow=Color3.fromRGB(200,50,80),
        Text=Color3.fromRGB(242,228,232),TextSub=Color3.fromRGB(160,130,140),
        TextMut=Color3.fromRGB(95,65,75),TextDis=Color3.fromRGB(65,42,50),
        Border=Color3.fromRGB(38,24,30),BorderLight=Color3.fromRGB(55,36,44),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(30,18,22),ToggleKnob=Color3.fromRGB(110,75,85),
        SliderTrack=Color3.fromRGB(28,16,20),SliderFill=Color3.fromRGB(235,65,100),SliderKnob=Color3.fromRGB(255,200,215),
    },
    Sunset = {
        BG=Color3.fromRGB(14,10,8),IconBar=Color3.fromRGB(18,12,10),Panel=Color3.fromRGB(24,18,14),
        Elevated=Color3.fromRGB(34,26,20),Hover=Color3.fromRGB(44,34,28),Active=Color3.fromRGB(55,42,34),
        Card=Color3.fromRGB(26,20,16),CardHead=Color3.fromRGB(30,24,18),
        Accent=Color3.fromRGB(255,140,40),AccentDim=Color3.fromRGB(160,80,20),AccentGlow=Color3.fromRGB(220,110,30),
        Text=Color3.fromRGB(245,238,228),TextSub=Color3.fromRGB(165,148,130),
        TextMut=Color3.fromRGB(100,82,65),TextDis=Color3.fromRGB(68,55,42),
        Border=Color3.fromRGB(40,32,24),BorderLight=Color3.fromRGB(58,46,36),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(30,22,16),ToggleKnob=Color3.fromRGB(115,90,70),
        SliderTrack=Color3.fromRGB(28,20,14),SliderFill=Color3.fromRGB(255,140,40),SliderKnob=Color3.fromRGB(255,220,180),
    },
    Mono = {
        BG=Color3.fromRGB(10,10,10),IconBar=Color3.fromRGB(13,13,13),Panel=Color3.fromRGB(18,18,18),
        Elevated=Color3.fromRGB(26,26,26),Hover=Color3.fromRGB(34,34,34),Active=Color3.fromRGB(42,42,42),
        Card=Color3.fromRGB(20,20,20),CardHead=Color3.fromRGB(24,24,24),
        Accent=Color3.fromRGB(200,200,200),AccentDim=Color3.fromRGB(100,100,100),AccentGlow=Color3.fromRGB(150,150,150),
        Text=Color3.fromRGB(235,235,235),TextSub=Color3.fromRGB(150,150,150),
        TextMut=Color3.fromRGB(80,80,80),TextDis=Color3.fromRGB(50,50,50),
        Border=Color3.fromRGB(30,30,30),BorderLight=Color3.fromRGB(45,45,45),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(22,22,22),ToggleKnob=Color3.fromRGB(90,90,90),
        SliderTrack=Color3.fromRGB(20,20,20),SliderFill=Color3.fromRGB(200,200,200),SliderKnob=Color3.fromRGB(235,235,235),
    },
}

Library.CurrentTheme = "Default"
local T = {}
for k, v in pairs(Library.Themes.Default) do T[k] = v end

function Library:SetTheme(name)
    local theme = Library.Themes[name]
    if not theme then return end
    Library.CurrentTheme = name
    for k, v in pairs(theme) do T[k] = v end
    -- Clean dead refs and animate living ones
    local alive = {}
    for _, e in ipairs(Library._themed) do
        if e[1] and e[1].Parent then
            pcall(function()
                TS:Create(e[1], TweenInfo.new(.4, Enum.EasingStyle.Quint), {[e[2]] = T[e[3]]}):Play()
            end)
            table.insert(alive, e)
        end
    end
    Library._themed = alive
end

local function Reg(o, p, k)
    if not o then return o end
    table.insert(Library._themed, {o, p, k})
    pcall(function() o[p] = T[k] end)
    return o
end

-- ═══════════════════════════════════════════════════
--  SAFE UTILITIES
-- ═══════════════════════════════════════════════════

-- Safe tween: checks object exists + parent
local function Tw(o, p, t, s, d)
    if not o then return end
    pcall(function()
        if not o.Parent then return end
        TS:Create(o, TweenInfo.new(t or .2, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p):Play()
    end)
end

-- Safe tween that returns the tween object for :Wait()
local function TwWait(o, p, t, s, d)
    if not o or not o.Parent then return end
    local tw
    pcall(function()
        tw = TS:Create(o, TweenInfo.new(t or .2, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p)
        tw:Play()
    end)
    return tw
end

local function I(c, p, par)
    local ok, i = pcall(Instance.new, c)
    if not ok then return nil end
    for k, v in pairs(p or {}) do pcall(function() i[k] = v end) end
    if par then i.Parent = par end
    return i
end

local function Cn(r, p) return I("UICorner", {CornerRadius = UDim.new(0, r or 6)}, p) end

local function St(c, t, p)
    return I("UIStroke", {Color = c or T.Border, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p)
end

local function Pd(t, b, l, r, p)
    return I("UIPadding", {PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0)}, p)
end

local function Ls(par, gap)
    return I("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap or 0)}, par)
end

local function Shadow(p, z)
    I("ImageLabel", {
        Name = "_Sh", Size = UDim2.new(1, 48, 1, 48), Position = UDim2.new(0, -24, 0, -24),
        BackgroundTransparency = 1, Image = "rbxassetid://5554236805", ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = .4, ZIndex = (z or 1) - 1, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
    }, p)
end

local function KeyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.", "") end

local function IsOut(pos, f)
    if not f or not f.Parent then return true end
    local p, s = f.AbsolutePosition, f.AbsoluteSize
    return pos.X < p.X or pos.X > p.X + s.X or pos.Y < p.Y or pos.Y > p.Y + s.Y
end

local function Color3ToHex(c)
    return string.format("#%02X%02X%02X", math.floor(c.R * 255 + .5), math.floor(c.G * 255 + .5), math.floor(c.B * 255 + .5))
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

-- Connection manager: tracks connections per context and disconnects all
local function NewConnBag()
    local bag = {}
    function bag:Add(conn)
        if conn then table.insert(bag, conn) end
        return conn
    end
    function bag:DisconnectAll()
        for i, c in ipairs(bag) do
            pcall(function() c:Disconnect() end)
            bag[i] = nil
        end
    end
    return bag
end

-- ═══════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════
function Library.new(title, toggleKey)
    local win = setmetatable({}, Library)
    win.Title = title or "NexUI"
    win.Tabs = {}
    win.ActiveTab = nil
    win.Open = true
    win._popup = nil
    win._popupElem = nil
    win._popupConns = NewConnBag()
    win._dropdown = nil
    win._dropConns = NewConnBag()
    win.ToggleKey = toggleKey or Enum.KeyCode.RightShift
    win._globalConns = NewConnBag()

    local W, H = 780, 490
    local TB, IW, SW, GAP = 46, 46, 150, 10

    -- ScreenGui
    local gui = I("ScreenGui", {
        Name = "__NexUI_" .. math.random(1e4, 9e4),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = game.CoreGui
        elseif gethui then gui.Parent = gethui()
        else gui.Parent = LP:WaitForChild("PlayerGui") end
    end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
    win.Gui = gui

    -- Blur
    for _, v in ipairs(Light:GetChildren()) do
        if v.Name == "__NexBlur" then v:Destroy() end
    end
    local blur = I("BlurEffect", {Name = "__NexBlur", Size = 0, Enabled = true}, Light)
    win._blur = blur
    task.defer(function() Tw(blur, {Size = 8}, .7) end)

    -- Overlay (for popups — above everything)
    win.Overlay = I("Frame", {
        Name = "Ov", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 500,
    }, gui)

    -- Tooltip
    local tooltipLbl = I("TextLabel", {
        Text = "", Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = T.Elevated, TextColor3 = T.Text, TextSize = 10,
        Font = Enum.Font.Gotham, BorderSizePixel = 0, Visible = false, ZIndex = 999,
    }, gui)
    Cn(5, tooltipLbl); St(T.BorderLight, 1, tooltipLbl); Pd(0, 0, 8, 8, tooltipLbl)
    Reg(tooltipLbl, "BackgroundColor3", "Elevated")
    Reg(tooltipLbl, "TextColor3", "Text")
    win._tooltipLabel = tooltipLbl

    local tooltipConn
    function win:_showTooltip(text)
        if not text or text == "" then return end
        tooltipLbl.Text = text; tooltipLbl.Visible = true
        if tooltipConn then tooltipConn:Disconnect() end
        tooltipConn = RS.RenderStepped:Connect(function()
            local mp = UIS:GetMouseLocation()
            tooltipLbl.Position = UDim2.new(0, mp.X + 14, 0, mp.Y + 4)
        end)
    end
    function win:_hideTooltip()
        tooltipLbl.Visible = false
        if tooltipConn then tooltipConn:Disconnect(); tooltipConn = nil end
    end

    -- Main Frame
    local main = I("Frame", {
        Name = "W", Size = UDim2.new(0, W * .85, 0, H * .85),
        Position = UDim2.new(.5, 0, .5, 0), AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = T.BG, BorderSizePixel = 0,
        ClipsDescendants = true, BackgroundTransparency = .4,
    }, gui)
    Cn(12, main); Shadow(main, 2); Reg(main, "BackgroundColor3", "BG")
    win.Main = main; win._fullSize = UDim2.new(0, W, 0, H)

    -- Intro animation
    task.defer(function()
        Tw(main, {Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 0}, .55, Enum.EasingStyle.Back)
    end)

    -- ══ Top Bar ══
    local topbar = I("Frame", {
        Name = "TB", Size = UDim2.new(1, 0, 0, TB),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 10,
    }, main)
    Cn(12, topbar); Reg(topbar, "BackgroundColor3", "Panel")
    -- Bottom fill (flatten corners)
    local tbFill = I("Frame", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 10,
    }, topbar)
    Reg(tbFill, "BackgroundColor3", "Panel")

    -- Accent line (inside topbar)
    local acLine = I("Frame", {
        Size = UDim2.new(1, -28, 0, 2), Position = UDim2.new(0, 14, 0, 0),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 15,
    }, topbar)
    Cn(1, acLine); Reg(acLine, "BackgroundColor3", "Accent")
    I("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, .8),
            NumberSequenceKeypoint.new(.5, .05),
            NumberSequenceKeypoint.new(1, .8),
        },
    }, acLine)

    -- Bottom divider
    local tbDiv = I("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 11,
    }, topbar)
    Reg(tbDiv, "BackgroundColor3", "Border")

    -- Title
    local titleLbl = I("TextLabel", {
        Text = win.Title, Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, IW + 14, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    }, topbar)
    Reg(titleLbl, "TextColor3", "Text")

    -- Search
    local searchFrame = I("Frame", {
        Size = UDim2.new(0, 185, 0, 26),
        Position = UDim2.new(.5, -92, .5, -13),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 14,
    }, topbar)
    Cn(7, searchFrame); Reg(searchFrame, "BackgroundColor3", "Elevated")
    local searchStroke = St(T.Border, 1, searchFrame)
    Reg(searchStroke, "Color", "Border")

    local searchIcon = I("TextLabel", {
        Text = "🔍", Size = UDim2.new(0, 22, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 11,
        Font = Enum.Font.Gotham, ZIndex = 15,
    }, searchFrame)
    Reg(searchIcon, "TextColor3", "TextMut")

    local searchBox = I("TextBox", {
        Text = "", PlaceholderText = "Search...",
        Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text,
        PlaceholderColor3 = T.TextDis, TextSize = 11, Font = Enum.Font.Gotham,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
    }, searchFrame)
    Reg(searchBox, "TextColor3", "Text")
    Reg(searchBox, "PlaceholderColor3", "TextDis")

    -- Avatar
    local avatar = I("Frame", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, .5, -15),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 12,
    }, topbar)
    Cn(15, avatar); Reg(avatar, "BackgroundColor3", "Accent")
    local avatarLetter = I("TextLabel", {
        Text = string.upper(string.sub(LP.Name, 1, 1)),
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        TextColor3 = Color3.new(1, 1, 1), TextSize = 12,
        Font = Enum.Font.GothamBold, ZIndex = 13,
    }, avatar)

    local userNameLbl = I("TextLabel", {
        Text = LP.DisplayName, Size = UDim2.new(0, 95, 0, 13),
        Position = UDim2.new(1, -148, 0, 9),
        BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 10,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    }, topbar)
    Reg(userNameLbl, "TextColor3", "Text")

    local dateLbl = I("TextLabel", {
        Text = os.date("%d/%m/%Y"), Size = UDim2.new(0, 95, 0, 11),
        Position = UDim2.new(1, -148, 0, 24),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 9,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    }, topbar)
    Reg(dateLbl, "TextColor3", "TextMut")

    -- ══ SMOOTH LERP DRAG ══
    do
        local dragging, dragInput, mStart, fStart = false, nil, nil, nil
        local targetPos = main.Position

        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; mStart = inp.Position; fStart = main.Position; targetPos = fStart
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        topbar.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
        end)
        UIS.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging and mStart then
                local d = inp.Position - mStart
                targetPos = UDim2.new(fStart.X.Scale, fStart.X.Offset + d.X, fStart.Y.Scale, fStart.Y.Offset + d.Y)
            end
        end)
        RS.RenderStepped:Connect(function()
            if dragging then
                local cX, cY = main.Position.X.Offset, main.Position.Y.Offset
                local tX, tY = targetPos.X.Offset, targetPos.Y.Offset
                local f = .22 -- lerp factor (lower = heavier feel)
                main.Position = UDim2.new(targetPos.X.Scale, cX + (tX - cX) * f, targetPos.Y.Scale, cY + (tY - cY) * f)
            end
        end)
    end

    -- ══ Icon Sidebar ══
    local iconBar = I("Frame", {
        Size = UDim2.new(0, IW, 1, -TB), Position = UDim2.new(0, 0, 0, TB),
        BackgroundColor3 = T.IconBar, BorderSizePixel = 0, ZIndex = 8,
    }, main)
    Reg(iconBar, "BackgroundColor3", "IconBar")
    local iconDiv = I("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 9,
    }, iconBar)
    Reg(iconDiv, "BackgroundColor3", "Border")

    local iconScroll = I("ScrollingFrame", {
        Size = UDim2.new(1, -1, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 9,
    }, iconBar)
    local iLay = Ls(iconScroll, 4); Pd(10, 10, 0, 0, iconScroll)
    iLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        iconScroll.CanvasSize = UDim2.new(0, 0, 0, iLay.AbsoluteContentSize.Y + 20)
    end)
    win.IconScroll = iconScroll

    -- ══ Sub Sidebar ══
    local subSide = I("Frame", {
        Size = UDim2.new(0, SW, 1, -TB), Position = UDim2.new(0, IW, 0, TB),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 6,
    }, main)
    Reg(subSide, "BackgroundColor3", "Panel")
    local subDiv = I("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 7,
    }, subSide)
    Reg(subDiv, "BackgroundColor3", "Border")

    local subScroll = I("ScrollingFrame", {
        Size = UDim2.new(1, -1, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 7,
    }, subSide)
    local sLay = Ls(subScroll, 2); Pd(10, 10, 8, 8, subScroll)
    sLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        subScroll.CanvasSize = UDim2.new(0, 0, 0, sLay.AbsoluteContentSize.Y + 20)
    end)
    win.SubScroll = subScroll

    -- ══ Content ══
    local content = I("Frame", {
        Size = UDim2.new(1, -(IW + SW), 1, -TB),
        Position = UDim2.new(0, IW + SW, 0, TB),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
        ClipsDescendants = true,
    }, main)
    win.Content = content

    -- ══ Search Logic ══
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for _, tab in ipairs(win.Tabs) do
            for _, sec in ipairs(tab.Sections) do
                local any = false
                for _, el in ipairs(sec.Elements) do
                    if el._row then
                        local m = q == "" or string.find(string.lower(el.Name), q, 1, true)
                        el._row.Visible = m ~= nil
                        if m then any = true end
                    end
                end
                if sec.Frame then sec.Frame.Visible = any or q == "" end
                if sec._subEntry then sec._subEntry.Visible = any or q == "" end
            end
        end
    end)

    -- ══ Global Keybinds ══
    win._globalConns:Add(UIS.InputBegan:Connect(function(inp, gpe)
        if inp.KeyCode == win.ToggleKey and not gpe then
            win:SetOpen(not win.Open); return
        end
        if gpe or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode == elem._keybind then
                if elem._keybindMode == "Toggle" and elem.Type == "Toggle" and elem._setValue then
                    local cur = Library.Flags[flag] and Library.Flags[flag].Toggle or false
                    elem._setValue(not cur)
                elseif elem._keybindMode == "Hold" and elem.Type == "Toggle" and elem._setValue then
                    elem._setValue(true)
                end
            end
        end
    end))
    win._globalConns:Add(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode == elem._keybind and elem._keybindMode == "Hold" then
                if elem.Type == "Toggle" and elem._setValue then elem._setValue(false) end
            end
        end
    end))

    table.insert(Library.Windows, win)
    return win
end

-- ═══════════════════════════════════════════════════
--  WATERMARK (optional)
-- ═══════════════════════════════════════════════════
function Library:Watermark(enabled, customText)
    if not enabled then
        if self._watermark then self._watermark.Visible = false end; return
    end
    if not self._watermark then
        local wm = I("Frame", {
            Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(.5, 0, 0, 8), AnchorPoint = Vector2.new(.5, 0),
            BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 100,
            BackgroundTransparency = .15,
        }, self.Gui)
        Cn(6, wm); St(T.Border, 1, wm); Pd(0, 0, 10, 10, wm)
        Reg(wm, "BackgroundColor3", "Panel")

        local wmLbl = I("TextLabel", {
            Text = "", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 10,
            Font = Enum.Font.Gotham, ZIndex = 101,
        }, wm)
        Reg(wmLbl, "TextColor3", "TextSub")
        self._watermark = wm; self._wmLabel = wmLbl

        local label = customText or self.Title
        RS.RenderStepped:Connect(function()
            if not wm or not wm.Parent or not wm.Visible then return end
            local fps = math.floor(1 / math.max(RS.RenderStepped:Wait(), 0.001))
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            wmLbl.Text = label .. "  |  " .. fps .. " FPS  |  " .. ping .. "ms"
        end)
    end
    self._watermark.Visible = true
end

-- ═══════════════════════════════════════════════════
--  KEYBIND LIST (optional)
-- ═══════════════════════════════════════════════════
function Library:KeybindList(enabled)
    if not enabled then
        if self._kbList then self._kbList.Visible = false end; return
    end
    if not self._kbList then
        local kbl = I("Frame", {
            Size = UDim2.new(0, 180, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 10, .5, -100),
            BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 90,
            BackgroundTransparency = .1,
        }, self.Gui)
        Cn(8, kbl); St(T.Border, 1, kbl); Pd(6, 6, 8, 8, kbl)
        Reg(kbl, "BackgroundColor3", "Panel")

        local headerLbl = I("TextLabel", {
            Text = "KEYBINDS", Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 9,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 91, LayoutOrder = 0,
        }, kbl)
        Reg(headerLbl, "TextColor3", "TextSub")
        Ls(kbl, 3)
        self._kbList = kbl; self._kbItems = {}

        -- Update every .5s (not every frame)
        task.spawn(function()
            while kbl and kbl.Parent do
                task.wait(.5)
                if not kbl.Visible then continue end
                for _, item in ipairs(self._kbItems) do
                    if item and item.Parent then item:Destroy() end
                end
                table.clear(self._kbItems)
                local order = 1
                for flag, elem in pairs(Library.Elements) do
                    if elem._keybind and elem.Type == "Toggle" and Library.Flags[flag] and Library.Flags[flag].Toggle then
                        local row = I("Frame", {
                            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
                            ZIndex = 91, LayoutOrder = order,
                        }, kbl)
                        I("TextLabel", {
                            Text = elem.Name, Size = UDim2.new(1, -35, 1, 0),
                            BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 10,
                            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 92,
                        }, row)
                        I("TextLabel", {
                            Text = "[" .. KeyName(elem._keybind) .. "]",
                            Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0),
                            BackgroundTransparency = 1, TextColor3 = T.Accent, TextSize = 9,
                            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 92,
                        }, row)
                        table.insert(self._kbItems, row)
                        order = order + 1
                    end
                end
            end
        end)
    end
    self._kbList.Visible = true
end

-- ═══════════════════════════════════════════════════
--  DIALOG
-- ═══════════════════════════════════════════════════
function Library:Dialog(title, message, onConfirm, onCancel)
    local dim = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 800,
    }, self.Overlay)
    Tw(dim, {BackgroundTransparency = .5}, .3)

    local dialog = I("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(.5, 0, .5, 0), AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 801,
        ClipsDescendants = true,
    }, self.Overlay)
    Cn(12, dialog); St(T.BorderLight, 1, dialog); Shadow(dialog, 801)
    Reg(dialog, "BackgroundColor3", "Elevated")

    local openTw = TwWait(dialog, {Size = UDim2.new(0, 320, 0, 160)}, .35, Enum.EasingStyle.Back)
    if openTw then openTw.Completed:Wait() end

    -- Content
    I("TextLabel", {
        Text = title or "Confirm", Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 12, 0, 14), BackgroundTransparency = 1,
        TextColor3 = T.Text, TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 802,
    }, dialog)
    I("TextLabel", {
        Text = message or "", Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 12, 0, 40),
        BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 802,
    }, dialog)

    local function Close()
        local tw = TwWait(dialog, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = .5}, .2)
        Tw(dim, {BackgroundTransparency = 1}, .2)
        if tw then tw.Completed:Wait() end
        pcall(function() dialog:Destroy(); dim:Destroy() end)
    end

    local cfm = I("TextButton", {
        Text = "Confirm", Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -218, 1, -44),
        BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11, Font = Enum.Font.GothamBold,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 802,
    }, dialog)
    Cn(6, cfm); Reg(cfm, "BackgroundColor3", "Accent")
    cfm.MouseButton1Click:Connect(function() Close(); if onConfirm then task.spawn(onConfirm) end end)
    cfm.MouseEnter:Connect(function() Tw(cfm, {BackgroundColor3 = T.AccentGlow}, .1) end)
    cfm.MouseLeave:Connect(function() Tw(cfm, {BackgroundColor3 = T.Accent}, .1) end)

    local ccl = I("TextButton", {
        Text = "Cancel", Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -112, 1, -44),
        BackgroundColor3 = T.Hover, TextColor3 = T.TextSub,
        TextSize = 11, Font = Enum.Font.GothamBold,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 802,
    }, dialog)
    Cn(6, ccl); St(T.BorderLight, 1, ccl); Reg(ccl, "BackgroundColor3", "Hover")
    ccl.MouseButton1Click:Connect(function() Close(); if onCancel then task.spawn(onCancel) end end)
    ccl.MouseEnter:Connect(function() Tw(ccl, {BackgroundColor3 = T.Active}, .1) end)
    ccl.MouseLeave:Connect(function() Tw(ccl, {BackgroundColor3 = T.Hover}, .1) end)
end

-- ═══════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════
function Library:new_tab(name, icon)
    local win = self
    icon = icon or string.upper(string.sub(name, 1, 1))
    local tab = {Name = name, Icon = icon, Sections = {}, Active = false}
    local GAP = 10

    -- Icon button
    local ib = I("TextButton", {
        Name = name, Text = "", Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.IconBar, BackgroundTransparency = .5,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 10,
    }, win.IconScroll)
    Cn(8, ib); Reg(ib, "BackgroundColor3", "IconBar")
    tab.IconBtn = ib

    -- FIX: Indicator properly centered
    local ind = I("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 3, .5, 0),
        AnchorPoint = Vector2.new(0, .5),
        BackgroundColor3 = T.TextMut, BorderSizePixel = 0, ZIndex = 11,
    }, ib)
    Cn(2, ind); Reg(ind, "BackgroundColor3", "TextMut")
    tab.Indicator = ind

    local il = I("TextLabel", {
        Text = icon, Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, TextColor3 = T.TextMut,
        TextSize = 15, Font = Enum.Font.GothamBold, ZIndex = 11,
    }, ib)
    Reg(il, "TextColor3", "TextMut")
    tab.IconLabel = il

    -- Tooltip
    local tt = I("TextLabel", {
        Text = " " .. name .. " ", Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(1, 8, .5, -11),
        BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
        TextSize = 11, Font = Enum.Font.Gotham, BorderSizePixel = 0,
        Visible = false, ZIndex = 900,
    }, ib)
    Cn(5, tt); St(T.BorderLight, 1, tt)
    Reg(tt, "BackgroundColor3", "Elevated"); Reg(tt, "TextColor3", "Text")

    ib.MouseEnter:Connect(function()
        tt.Visible = true
        if not tab.Active then
            Tw(ib, {BackgroundTransparency = 0, BackgroundColor3 = T.Hover}, .15)
            Tw(il, {TextColor3 = T.TextSub}, .15)
        end
    end)
    ib.MouseLeave:Connect(function()
        tt.Visible = false
        if not tab.Active then
            Tw(ib, {BackgroundTransparency = .5, BackgroundColor3 = T.IconBar}, .15)
            Tw(il, {TextColor3 = T.TextMut}, .15)
        end
    end)
    ib.MouseButton1Click:Connect(function() win:SelectTab(tab) end)

    -- Sub container
    local subC = I("Frame", {
        Name = name .. "_sub", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, ZIndex = 7,
    }, win.SubScroll)
    Ls(subC, 2); tab.SubContainer = subC

    local subHeader = I("TextLabel", {
        Text = string.upper(name), Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1, TextColor3 = T.TextMut,
        TextSize = 9, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, subC)
    Reg(subHeader, "TextColor3", "TextMut")

    -- Page with two columns
    local page = I("ScrollingFrame", {
        Name = name .. "_pg", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, ZIndex = 5,
    }, win.Content)
    tab.Page = page

    local colFrame = I("Frame", {
        Name = "Cols", Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, page)

    local leftCol = I("Frame", {
        Name = "L", Size = UDim2.new(.5, -GAP / 2, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, colFrame)
    local lLay = Ls(leftCol, GAP)

    local rightCol = I("Frame", {
        Name = "R", Size = UDim2.new(.5, -GAP / 2, 0, 0),
        Position = UDim2.new(.5, GAP / 2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, colFrame)
    local rLay = Ls(rightCol, GAP)

    tab.LeftCol = leftCol; tab.RightCol = rightCol; tab.ColFrame = colFrame

    local function UpdCanvas()
        if not lLay or not rLay then return end
        local lH = lLay.AbsoluteContentSize.Y
        local rH = rLay.AbsoluteContentSize.Y
        local maxH = math.max(lH, rH, 10)
        colFrame.Size = UDim2.new(1, -20, 0, maxH)
        page.CanvasSize = UDim2.new(0, 0, 0, maxH + 30)
    end
    lLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas)
    rLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas)
    task.defer(UpdCanvas)

    table.insert(win.Tabs, tab)
    if #win.Tabs == 1 then win:SelectTab(tab) end

    -- ═══════════════════════════════════════
    --  SECTION
    -- ═══════════════════════════════════════
    function tab:new_section(sectionName, side)
        side = side or "Left"
        local targetCol = side == "Right" and rightCol or leftCol
        local section = {Name = sectionName, Elements = {}, Side = side}

        -- Sub entry
        local subE = I("TextButton", {
            Name = sectionName, Text = "", Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = T.Panel, BackgroundTransparency = .5,
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8,
        }, subC)
        Cn(5, subE); section._subEntry = subE

        local dm = I("TextLabel", {
            Text = "◆", Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, 4, 0, 0),
            BackgroundTransparency = 1, TextColor3 = T.TextMut,
            TextSize = 6, Font = Enum.Font.GothamBold, ZIndex = 9,
        }, subE)
        Reg(dm, "TextColor3", "TextMut")

        local sl = I("TextLabel", {
            Text = sectionName, Size = UDim2.new(1, -22, 1, 0),
            Position = UDim2.new(0, 18, 0, 0),
            BackgroundTransparency = 1, TextColor3 = T.TextSub,
            TextSize = 11, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
        }, subE)
        Reg(sl, "TextColor3", "TextSub")

        subE.MouseEnter:Connect(function() Tw(subE, {BackgroundTransparency = 0, BackgroundColor3 = T.Hover}, .12) end)
        subE.MouseLeave:Connect(function() Tw(subE, {BackgroundTransparency = .5, BackgroundColor3 = T.Panel}, .12) end)
        subE.MouseButton1Click:Connect(function()
            task.defer(function()
                if section.Frame then
                    local tY = section.Frame.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
                    TS:Create(page, TweenInfo.new(.4, Enum.EasingStyle.Quint), {
                        CanvasPosition = Vector2.new(0, math.max(0, tY - 8))
                    }):Play()
                end
            end)
            Tw(dm, {TextColor3 = T.Accent}, .15); Tw(sl, {TextColor3 = T.Text}, .15)
            task.delay(.8, function() Tw(dm, {TextColor3 = T.TextMut}, .3); Tw(sl, {TextColor3 = T.TextSub}, .3) end)
        end)

        -- Card
        local card = I("Frame", {
            Name = sectionName, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Card, BorderSizePixel = 0, ZIndex = 6,
        }, targetCol)
        Cn(10, card); St(T.Border, 1, card); Ls(card, 0)
        Reg(card, "BackgroundColor3", "Card")
        section.Frame = card

        -- Stagger entrance
        card.BackgroundTransparency = .6
        task.delay(#tab.Sections * .07, function()
            Tw(card, {BackgroundTransparency = 0}, .45)
        end)

        -- Header
        local hd = I("Frame", {
            Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.CardHead,
            BorderSizePixel = 0, ZIndex = 7, LayoutOrder = 1,
        }, card)
        Cn(10, hd); Reg(hd, "BackgroundColor3", "CardHead")
        I("Frame", {
            Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = T.CardHead, BorderSizePixel = 0, ZIndex = 7,
        }, hd)
        local hdLine = I("Frame", {
            Size = UDim2.new(1, -18, 0, 1), Position = UDim2.new(0, 9, 1, -1),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 8,
        }, hd)
        Reg(hdLine, "BackgroundColor3", "Border")

        local pill = I("Frame", {
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 8, .5, -6),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 8,
        }, hd)
        Cn(2, pill); Reg(pill, "BackgroundColor3", "Accent")

        local hdLbl = I("TextLabel", {
            Text = string.upper(sectionName),
            Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1, TextColor3 = T.TextSub,
            TextSize = 9, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
        }, hd)
        Reg(hdLbl, "TextColor3", "TextSub")

        -- Elements container
        local ec = I("Frame", {
            Name = "El", Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, LayoutOrder = 2,
        }, card)
        Ls(ec, 1); Pd(5, 7, 7, 7, ec)
        section.Container = ec

        -- ═════════════════════════════
        --  SUB-FOLDER
        -- ═════════════════════════════
        function section:sub_folder(folderName)
            local fRow = I("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
                ClipsDescendants = true,
            }, ec)

            local fBtn = I("TextButton", {
                Text = "", Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = T.Elevated, BackgroundTransparency = .5,
                BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8,
            }, fRow)
            Cn(5, fBtn); Reg(fBtn, "BackgroundColor3", "Elevated")

            local fArrow = I("TextLabel", {
                Text = "▸", Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1, TextColor3 = T.TextMut,
                TextSize = 10, Font = Enum.Font.GothamBold, ZIndex = 9,
            }, fBtn)
            Reg(fArrow, "TextColor3", "TextMut")

            local fLabel = I("TextLabel", {
                Text = folderName, Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1, TextColor3 = T.TextSub,
                TextSize = 10, Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
            }, fBtn)
            Reg(fLabel, "TextColor3", "TextSub")

            local fContent = I("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, Visible = false,
            }, fRow)
            Ls(fContent, 1); Pd(2, 4, 8, 0, fContent)

            local fOpen = false
            fBtn.MouseButton1Click:Connect(function()
                fOpen = not fOpen; fContent.Visible = fOpen
                Tw(fArrow, {Rotation = fOpen and 90 or 0}, .2, Enum.EasingStyle.Back)
                Tw(fBtn, {BackgroundTransparency = fOpen and 0 or .5}, .15)
            end)
            fBtn.MouseEnter:Connect(function() Tw(fBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.Hover}, .1) end)
            fBtn.MouseLeave:Connect(function()
                if not fOpen then Tw(fBtn, {BackgroundTransparency = .5, BackgroundColor3 = T.Elevated}, .1) end
            end)

            local folder = {Elements = {}}
            function folder:element(eType, eName, options, callback)
                return section:element(eType, eName, options, callback, fContent)
            end
            return folder
        end

        -- ═════════════════════════════
        --  ELEMENT FACTORY
        -- ═════════════════════════════
        function section:element(eType, eName, options, callback, targetContainer)
            options = options or {}
            callback = callback or function() end
            local container = targetContainer or ec
            local flag = sectionName .. "_" .. eName
            local tooltipText = options.tooltip
            local elem = {
                Type = eType, Name = eName, Flag = flag,
                _keybind = nil, _keybindMode = "Toggle", _hasKeybind = false,
                _setValue = nil, _getValue = nil, _callback = callback,
            }

            local function Row(h)
                local f = I("Frame", {
                    Size = UDim2.new(1, 0, 0, h or 34),
                    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
                }, container)
                Cn(6, f)
                if tooltipText and tooltipText ~= "" then
                    local tooltipTimer
                    local hBtn = I("TextButton", {
                        Text = "", Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1, ZIndex = 15,
                    }, f)
                    hBtn.MouseEnter:Connect(function()
                        tooltipTimer = task.delay(.8, function() win:_showTooltip(tooltipText) end)
                    end)
                    hBtn.MouseLeave:Connect(function()
                        if tooltipTimer then pcall(task.cancel, tooltipTimer) end
                        win:_hideTooltip()
                    end)
                end
                return f
            end

            -- ═══ TOGGLE ═══
            if eType == "Toggle" then
                Library.Flags[flag] = {Toggle = false, Active = false}
                local row = Row(34)

                local hov = I("Frame", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.Hover,
                    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
                }, row)
                Cn(6, hov)

                local lbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -75, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(lbl, "TextColor3", "Text")

                local sw = I("Frame", {
                    Size = UDim2.new(0, 34, 0, 17), Position = UDim2.new(1, -42, .5, -8),
                    BackgroundColor3 = T.ToggleBg, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(9, sw); St(T.BorderLight, 1, sw)
                Reg(sw, "BackgroundColor3", "ToggleBg")

                local gl = I("Frame", {
                    Size = UDim2.new(0, 42, 0, 25), Position = UDim2.new(1, -46, .5, -12),
                    BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 1,
                    BorderSizePixel = 0, ZIndex = 8,
                }, row)
                Cn(12, gl)

                local kn = I("Frame", {
                    Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 3, .5, -5),
                    BackgroundColor3 = T.ToggleKnob, BorderSizePixel = 0, ZIndex = 10,
                }, sw)
                Cn(6, kn); Reg(kn, "BackgroundColor3", "ToggleKnob")

                local gear = I("TextButton", {
                    Text = "⚙", Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -66, .5, -9),
                    BackgroundTransparency = 1, TextColor3 = T.TextMut,
                    TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 13, Visible = false,
                }, row)
                Reg(gear, "TextColor3", "TextMut")

                local toggled = false
                local function Set(val, silent)
                    toggled = val
                    Library.Flags[flag].Toggle = val
                    Library.Flags[flag].Active = val
                    if val then
                        Tw(sw, {BackgroundColor3 = T.Accent}, .22)
                        Tw(kn, {Position = UDim2.new(0, 20, .5, -5), BackgroundColor3 = Color3.new(1, 1, 1)}, .22, Enum.EasingStyle.Back)
                        Tw(gl, {BackgroundTransparency = .78}, .35)
                    else
                        Tw(sw, {BackgroundColor3 = T.ToggleBg}, .22)
                        Tw(kn, {Position = UDim2.new(0, 3, .5, -5), BackgroundColor3 = T.ToggleKnob}, .22, Enum.EasingStyle.Back)
                        Tw(gl, {BackgroundTransparency = 1}, .22)
                    end
                    if not silent then pcall(callback, {Toggle = val}) end
                end
                elem._setValue = Set
                elem._getValue = function() return toggled end

                local click = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, ZIndex = 11,
                }, row)
                click.MouseButton1Click:Connect(function() Set(not toggled) end)
                click.MouseEnter:Connect(function() Tw(hov, {BackgroundTransparency = .88}, .12) end)
                click.MouseLeave:Connect(function() Tw(hov, {BackgroundTransparency = 1}, .12) end)
                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem, gear) end)

                elem._gear = gear; elem._row = row
                function elem:add_keybind()
                    self._hasKeybind = true; gear.Visible = true; return self
                end
                function elem:set_value(v) Set(v, false) end

            -- ═══ SLIDER (with pop handle + floating tooltip + glow) ═══
            elseif eType == "Slider" then
                local c = options.default or {}
                local mn = c.min or 0
                local mx = c.max or 100
                local df = c.default or mn
                local dc = c.decimals or 0

                -- Strict clamp to avoid NaN
                if mx <= mn then mx = mn + 1 end
                df = math.clamp(df, mn, mx)

                Library.Flags[flag] = {Slider = df}
                local row = Row(46)

                local nameLbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(.55, 0, 0, 18),
                    Position = UDim2.new(0, 8, 0, 3),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(nameLbl, "TextColor3", "Text")

                local valLbl = I("TextLabel", {
                    Text = dc > 0 and string.format("%." .. dc .. "f", df) or tostring(df),
                    Size = UDim2.new(.45, -8, 0, 18), Position = UDim2.new(.55, 0, 0, 3),
                    BackgroundTransparency = 1, TextColor3 = T.Accent, TextSize = 11,
                    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
                }, row)
                Reg(valLbl, "TextColor3", "Accent")

                local track = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 5), Position = UDim2.new(0, 8, 0, 30),
                    BackgroundColor3 = T.SliderTrack, BorderSizePixel = 0, ZIndex = 9,
                    ClipsDescendants = true,
                }, row)
                Cn(3, track); Reg(track, "BackgroundColor3", "SliderTrack")

                local initPct = math.clamp((df - mn) / (mx - mn), 0, 1)
                local fill = I("Frame", {
                    Size = UDim2.new(initPct, 0, 1, 0),
                    BackgroundColor3 = T.SliderFill, BorderSizePixel = 0, ZIndex = 10,
                }, track)
                Cn(3, fill); Reg(fill, "BackgroundColor3", "SliderFill")
                I("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, T.AccentDim),
                        ColorSequenceKeypoint.new(1, T.Accent),
                    },
                }, fill)

                -- Fill glow stroke
                local fillGlow = St(T.AccentGlow, 1, fill)
                fillGlow.Transparency = 1

                local handle = I("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundColor3 = T.SliderKnob, BorderSizePixel = 0, ZIndex = 11,
                }, row)
                Cn(6, handle); Reg(handle, "BackgroundColor3", "SliderKnob")
                local handleStroke = St(T.Accent, 2, handle)
                Reg(handleStroke, "Color", "Accent")

                -- Floating tooltip
                local ftip = I("TextLabel", {
                    Text = "", Size = UDim2.new(0, 0, 0, 18),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 10, Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0, Visible = false, ZIndex = 20,
                }, row)
                Cn(4, ftip); St(T.BorderLight, 1, ftip); Pd(0, 0, 6, 6, ftip)
                Reg(ftip, "BackgroundColor3", "Elevated"); Reg(ftip, "TextColor3", "Text")

                local function Fmt(v)
                    if dc > 0 then return string.format("%." .. dc .. "f", v)
                    else return tostring(math.floor(v + .5)) end
                end

                local function PosHandle()
                    if not track or not track.Parent or not row or not row.Parent then return end
                    local range = mx - mn
                    if range <= 0 then range = 1 end
                    local pct = math.clamp((Library.Flags[flag].Slider - mn) / range, 0, 1)
                    local tx = track.AbsolutePosition.X
                    local tw = math.max(track.AbsoluteSize.X, 1)
                    local rx = row.AbsolutePosition.X
                    handle.Position = UDim2.new(0, tx - rx + pct * tw - 6, 0, 25)
                    ftip.Position = UDim2.new(0, tx - rx + pct * tw - 15, 0, 10)
                end

                local function SetSlider(v, silent)
                    local range = mx - mn
                    if range <= 0 then range = 1 end
                    local factor = 10 ^ dc
                    local r = math.clamp(math.floor(v * factor + .5) / factor, mn, mx)
                    Library.Flags[flag].Slider = r
                    local pct = math.clamp((r - mn) / range, 0, 1)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valLbl.Text = Fmt(r); ftip.Text = Fmt(r)
                    PosHandle()
                    if not silent then pcall(callback, {Slider = r}) end
                end
                elem._setValue = SetSlider
                elem._getValue = function() return Library.Flags[flag].Slider end
                task.defer(PosHandle)

                local dragging = false
                local trackBtn = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundTransparency = 1, ZIndex = 12,
                }, row)

                trackBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; ftip.Visible = true
                        Tw(handle, {Size = UDim2.new(0, 16, 0, 16)}, .12, Enum.EasingStyle.Back)
                        Tw(fillGlow, {Transparency = .3}, .15)
                        -- First click: tween to position
                        local tw = math.max(track.AbsoluteSize.X, 1)
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw, 0, 1)
                        SetSlider(mn + pct * (mx - mn))
                    end
                end)
                UIS.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local tw = math.max(track.AbsoluteSize.X, 1)
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw, 0, 1)
                        SetSlider(mn + pct * (mx - mn))
                    end
                end)
                UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false; ftip.Visible = false
                        Tw(handle, {Size = UDim2.new(0, 12, 0, 12)}, .15, Enum.EasingStyle.Back)
                        Tw(fillGlow, {Transparency = 1}, .2)
                    end
                end)

                elem._row = row
                function elem:set_value(v) SetSlider(v) end

            -- ═══ DROPDOWN ═══
            elseif eType == "Dropdown" then
                local opts = options.options or {"Option"}
                local defOpt = options.default or opts[1]
                Library.Flags[flag] = {Dropdown = defOpt}
                local row = Row(52)

                I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 8, 0, 2),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 10,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)

                local df = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 20),
                    BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(6, df); St(T.BorderLight, 1, df); Reg(df, "BackgroundColor3", "Elevated")

                local sel = I("TextLabel", {
                    Text = defOpt, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
                }, df)
                Reg(sel, "TextColor3", "Text")

                local ch = I("TextLabel", {
                    Text = "▾", Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub,
                    TextSize = 11, Font = Enum.Font.Gotham, ZIndex = 10,
                }, df)

                local function SetDD(v, s)
                    Library.Flags[flag].Dropdown = v; sel.Text = v
                    if not s then pcall(callback, {Dropdown = v}) end
                end
                elem._setValue = SetDD
                elem._getValue = function() return Library.Flags[flag].Dropdown end

                local ca = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, ZIndex = 11,
                }, df)
                ca.MouseButton1Click:Connect(function()
                    Tw(ch, {Rotation = 180}, .2)
                    win:_openDropdown(opts, df, function(v, s)
                        SetDD(v, s); Tw(ch, {Rotation = 0}, .2)
                    end, function()
                        Tw(ch, {Rotation = 0}, .2)
                    end)
                end)
                ca.MouseEnter:Connect(function() Tw(df, {BackgroundColor3 = T.Hover}, .12) end)
                ca.MouseLeave:Connect(function() Tw(df, {BackgroundColor3 = T.Elevated}, .12) end)

                elem._row = row
                function elem:set_value(v) SetDD(v) end

            -- ═══ BUTTON ═══
            elseif eType == "Button" then
                local row = Row(36)
                local btn = I("TextButton", {
                    Text = eName, Size = UDim2.new(1, -16, 0, 26),
                    Position = UDim2.new(0, 8, .5, -13),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 11, Font = Enum.Font.Gotham,
                    BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 9,
                    ClipsDescendants = true,
                }, row)
                Cn(6, btn); St(T.BorderLight, 1, btn)
                Reg(btn, "BackgroundColor3", "Elevated"); Reg(btn, "TextColor3", "Text")

                btn.MouseButton1Click:Connect(function()
                    Tw(btn, {BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1, 1, 1)}, .06)
                    task.delay(.15, function()
                        Tw(btn, {BackgroundColor3 = T.Elevated, TextColor3 = T.Text}, .2)
                    end)
                    pcall(callback, {})
                end)
                btn.MouseEnter:Connect(function() Tw(btn, {BackgroundColor3 = T.Hover}, .12) end)
                btn.MouseLeave:Connect(function() Tw(btn, {BackgroundColor3 = T.Elevated}, .12) end)
                elem._row = row

            -- ═══ TEXTBOX ═══
            elseif eType == "TextBox" then
                Library.Flags[flag] = {Text = options.default or ""}
                local row = Row(52)

                I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 8, 0, 2),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub,
                    TextSize = 10, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)

                local tb = I("TextBox", {
                    Text = options.default or "", PlaceholderText = options.placeholder or "Enter...",
                    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 20),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    PlaceholderColor3 = T.TextDis, TextSize = 11, Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false, BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Cn(6, tb); Reg(tb, "BackgroundColor3", "Elevated"); Reg(tb, "TextColor3", "Text")
                local st = St(T.BorderLight, 1, tb)
                Pd(0, 0, 8, 8, tb)

                tb.Focused:Connect(function()
                    Tw(st, {Color = T.Accent}, .15)
                    Tw(tb, {BackgroundColor3 = T.Hover}, .15)
                end)
                tb.FocusLost:Connect(function(enter)
                    Tw(st, {Color = T.BorderLight}, .15)
                    Tw(tb, {BackgroundColor3 = T.Elevated}, .15)
                    Library.Flags[flag].Text = tb.Text
                    pcall(callback, {Text = tb.Text, Enter = enter})
                end)
                tb:GetPropertyChangedSignal("Text"):Connect(function()
                    Library.Flags[flag].Text = tb.Text
                end)

                elem._row = row; elem._tb = tb
                function elem:set_value(v)
                    tb.Text = tostring(v); Library.Flags[flag].Text = tostring(v)
                end

            -- ═══ LABEL ═══
            elseif eType == "Label" then
                local row = Row(0); row.AutomaticSize = Enum.AutomaticSize.Y
                local lbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -16, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0, 8, 0, 5),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub,
                    TextSize = 10, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 9,
                }, row)
                Reg(lbl, "TextColor3", "TextSub")
                I("Frame", {Size = UDim2.new(1, 0, 0, 5), BackgroundTransparency = 1}, row)
                elem._row = row
                function elem:set_text(t) lbl.Text = t end

            -- ═══ SEPARATOR ═══
            elseif eType == "Separator" then
                local row = Row(16)
                local line = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, .5, 0),
                    BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Reg(line, "BackgroundColor3", "Border")
                if eName and eName ~= "" then
                    local sepLbl = I("TextLabel", {
                        Text = " " .. eName .. " ",
                        Size = UDim2.new(0, 0, 0, 12), AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(.5, 0, .5, -6),
                        BackgroundColor3 = T.Card, TextColor3 = T.TextMut,
                        TextSize = 9, Font = Enum.Font.Gotham, BorderSizePixel = 0, ZIndex = 10,
                    }, row)
                    Reg(sepLbl, "BackgroundColor3", "Card")
                    Reg(sepLbl, "TextColor3", "TextMut")
                end
                elem._row = row
            end

            Library.Elements[flag] = elem
            table.insert(section.Elements, elem)
            return elem
        end

        table.insert(tab.Sections, section)
        return section
    end

    return tab
end

-- ═══════════════════════════════════════════════════
--  TAB SWITCHING (slide + fade + cascade)
-- ═══════════════════════════════════════════════════
function Library:SelectTab(target)
    if self.ActiveTab and self.ActiveTab ~= target and self.ActiveTab.ColFrame then
        local old = self.ActiveTab
        Tw(old.ColFrame, {Position = UDim2.new(-.05, 0, 0, 10)}, .2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        task.delay(.18, function()
            old.Page.Visible = false
            if old.ColFrame then old.ColFrame.Position = UDim2.new(0, 10, 0, 10) end
        end)
    end

    for _, t in ipairs(self.Tabs) do
        t.Active = false; t.SubContainer.Visible = false
        Tw(t.IconBtn, {BackgroundTransparency = .5, BackgroundColor3 = T.IconBar}, .18)
        Tw(t.IconLabel, {TextColor3 = T.TextMut}, .18)
        Tw(t.Indicator, {BackgroundColor3 = T.TextMut, Size = UDim2.new(0, 3, 0, 0)}, .18)
    end

    target.Active = true; target.SubContainer.Visible = true
    Tw(target.IconBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.Active}, .18)
    Tw(target.IconLabel, {TextColor3 = T.Accent}, .18)
    Tw(target.Indicator, {BackgroundColor3 = T.Accent, Size = UDim2.new(0, 3, 0, 20)}, .28, Enum.EasingStyle.Back)

    task.delay(.12, function()
        target.Page.Visible = true
        if target.ColFrame then
            target.ColFrame.Position = UDim2.new(.04, 0, 0, 8)
            Tw(target.ColFrame, {Position = UDim2.new(0, 10, 0, 10)}, .4, Enum.EasingStyle.Exponential)
        end
        for i, sec in ipairs(target.Sections) do
            if sec.Frame then
                sec.Frame.BackgroundTransparency = .5
                task.delay(i * .06, function()
                    Tw(sec.Frame, {BackgroundTransparency = 0}, .35)
                end)
            end
        end
    end)

    self.ActiveTab = target; self:_closePopups()
end

-- ═══════════════════════════════════════════════════
--  POPUP SYSTEM (with connection cleanup)
-- ═══════════════════════════════════════════════════
function Library:_closePopups()
    self._popupConns:DisconnectAll()
    if self._popup then
        pcall(function() self._popup:Destroy() end)
        self._popup = nil; self._popupElem = nil
    end
    self._dropConns:DisconnectAll()
    if self._dropdown then
        pcall(function() self._dropdown:Destroy() end)
        self._dropdown = nil
    end
end

function Library:_openKeybindPopup(elem, anchor)
    if self._popup then
        local was = self._popupElem == elem
        self:_closePopups()
        if was then return end
    end
    self._popupElem = elem
    local conns = self._popupConns

    local pop = I("Frame", {
        Size = UDim2.new(0, 190, 0, 145),
        BackgroundColor3 = T.Elevated, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 600,
    }, self.Overlay)
    Cn(9, pop); St(T.BorderLight, 1, pop); Shadow(pop, 600)
    Reg(pop, "BackgroundColor3", "Elevated")
    self._popup = pop

    task.defer(function()
        if not anchor or not anchor.Parent then return end
        local ap = anchor.AbsolutePosition; local as = anchor.AbsoluteSize
        pop.Position = UDim2.new(0, math.clamp(ap.X - 190 + as.X + 4, 0, 1000), 0, ap.Y + as.Y + 8)
        Tw(pop, {BackgroundTransparency = 0}, .22, Enum.EasingStyle.Back)
    end)

    I("TextLabel", {
        Text = "KEYBIND  ·  " .. elem.Name,
        Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1, TextColor3 = T.TextSub,
        TextSize = 8, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local keyStr = elem._keybind and KeyName(elem._keybind) or "None"
    local keyBtn = I("TextButton", {
        Text = keyStr, Size = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 8, 0, 27),
        BackgroundColor3 = T.Panel, TextColor3 = T.Text,
        TextSize = 11, Font = Enum.Font.Gotham,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 601,
    }, pop)
    Cn(6, keyBtn); St(T.Border, 1, keyBtn)
    Reg(keyBtn, "BackgroundColor3", "Panel"); Reg(keyBtn, "TextColor3", "Text")

    local listening = false
    local listenConn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "Press key..."; keyBtn.TextColor3 = T.Accent
        Tw(keyBtn, {BackgroundColor3 = T.Hover}, .1)
        if listenConn then listenConn:Disconnect() end
        listenConn = UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                elem._keybind = inp.KeyCode
                keyBtn.Text = KeyName(inp.KeyCode); keyBtn.TextColor3 = T.Text
                Tw(keyBtn, {BackgroundColor3 = T.Panel}, .1)
                listening = false
                if listenConn then listenConn:Disconnect(); listenConn = nil end
            end
        end)
        conns:Add(listenConn)
    end)
    keyBtn.MouseEnter:Connect(function() Tw(keyBtn, {BackgroundColor3 = T.Hover}, .1) end)
    keyBtn.MouseLeave:Connect(function()
        if not listening then Tw(keyBtn, {BackgroundColor3 = T.Panel}, .1) end
    end)

    -- Clear button
    I("TextButton", {
        Text = "Clear", Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -48, 0, 32),
        BackgroundTransparency = 1, TextColor3 = T.Danger,
        TextSize = 9, Font = Enum.Font.GothamBold, ZIndex = 602,
    }, pop).MouseButton1Click:Connect(function()
        elem._keybind = nil; keyBtn.Text = "None"; keyBtn.TextColor3 = T.TextSub
    end)

    -- Mode
    I("TextLabel", {
        Text = "MODE", Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 0, 62),
        BackgroundTransparency = 1, TextColor3 = T.TextMut,
        TextSize = 8, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local mTrack = I("Frame", {
        Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 78),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 601,
    }, pop)
    Cn(7, mTrack); Reg(mTrack, "BackgroundColor3", "Panel")

    local function MBtn(label, xOff, active)
        local mb = I("TextButton", {
            Text = label, Size = UDim2.new(.5, -3, 1, -4),
            Position = UDim2.new(xOff, xOff == 0 and 2 or 1, 0, 2),
            BackgroundColor3 = active and T.Accent or T.Panel,
            TextColor3 = active and Color3.new(1, 1, 1) or T.TextSub,
            TextSize = 10, Font = Enum.Font.Gotham,
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 602,
        }, mTrack)
        Cn(5, mb); return mb
    end

    local tBtn = MBtn("Toggle", 0, elem._keybindMode == "Toggle")
    local hBtn = MBtn("Hold", .5, elem._keybindMode == "Hold")

    local function SetMode(m)
        elem._keybindMode = m
        Tw(tBtn, {BackgroundColor3 = m == "Toggle" and T.Accent or T.Panel}, .12)
        tBtn.TextColor3 = m == "Toggle" and Color3.new(1, 1, 1) or T.TextSub
        Tw(hBtn, {BackgroundColor3 = m == "Hold" and T.Accent or T.Panel}, .12)
        hBtn.TextColor3 = m == "Hold" and Color3.new(1, 1, 1) or T.TextSub
    end
    tBtn.MouseButton1Click:Connect(function() SetMode("Toggle") end)
    hBtn.MouseButton1Click:Connect(function() SetMode("Hold") end)

    -- Outside click
    local ready = false
    task.delay(.25, function() ready = true end)
    conns:Add(UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if pop and pop.Parent and IsOut(inp.Position, pop) then
                    self:_closePopups()
                end
            end)
        end
    end))
end

function Library:_openDropdown(opts, anchor, setFn, onClose)
    if self._dropdown then
        self._dropdown:Destroy(); self._dropdown = nil
        self._dropConns:DisconnectAll()
        if onClose then onClose() end; return
    end

    local conns = self._dropConns
    local IH, MX = 26, 7
    local shown = math.min(#opts, MX)
    local totalH = shown * IH + 10

    local dd = I("Frame", {
        Size = UDim2.new(0, anchor.AbsoluteSize.X, 0, 0),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0,
        ZIndex = 600, ClipsDescendants = true,
    }, self.Overlay)
    Cn(7, dd); St(T.BorderLight, 1, dd); Shadow(dd, 600)
    Reg(dd, "BackgroundColor3", "Elevated")
    self._dropdown = dd

    task.defer(function()
        if not anchor or not anchor.Parent then return end
        local ap = anchor.AbsolutePosition; local as = anchor.AbsoluteSize
        dd.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 3)
        Tw(dd, {Size = UDim2.new(0, as.X, 0, totalH)}, .25, Enum.EasingStyle.Back)
    end)

    local scr = I("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #opts * IH + 10), ZIndex = 601,
    }, dd)
    Ls(scr, 1); Pd(4, 4, 4, 4, scr)

    for idx, opt in ipairs(opts) do
        local item = I("TextButton", {
            Text = opt, Size = UDim2.new(1, 0, 0, IH),
            BackgroundColor3 = T.Hover, BackgroundTransparency = 1,
            TextColor3 = T.Text, TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 602,
        }, scr)
        Cn(4, item); Pd(0, 0, 8, 6, item)

        -- Stagger entrance
        item.TextTransparency = 1
        task.delay(idx * .02, function() Tw(item, {TextTransparency = 0}, .18) end)

        item.MouseEnter:Connect(function() Tw(item, {BackgroundTransparency = .65}, .08) end)
        item.MouseLeave:Connect(function() Tw(item, {BackgroundTransparency = 1}, .08) end)
        item.MouseButton1Click:Connect(function()
            setFn(opt, false)
            Tw(dd, {Size = UDim2.new(0, dd.AbsoluteSize.X, 0, 0)}, .15)
            task.delay(.16, function()
                if dd and dd.Parent then dd:Destroy() end
                self._dropdown = nil
                conns:DisconnectAll()
            end)
        end)
    end

    local ready = false
    task.delay(.15, function() ready = true end)
    conns:Add(UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not dd or not dd.Parent then return end
                if IsOut(inp.Position, dd) then
                    Tw(dd, {Size = UDim2.new(0, dd.AbsoluteSize.X, 0, 0)}, .12)
                    task.delay(.13, function()
                        if dd and dd.Parent then dd:Destroy() end
                        self._dropdown = nil
                        conns:DisconnectAll()
                        if onClose then onClose() end
                    end)
                end
            end)
        end
    end))
end

-- ═══════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════
function Library:Toggle() self:SetOpen(not self.Open) end

function Library:SetOpen(state)
    self.Open = state
    if state then
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, self._fullSize.X.Offset * .88, 0, self._fullSize.Y.Offset * .88)
        self.Main.BackgroundTransparency = .3
        Tw(self.Main, {Size = self._fullSize, BackgroundTransparency = 0}, .4, Enum.EasingStyle.Back)
        Tw(self._blur, {Size = 8}, .5)
    else
        Tw(self.Main, {
            Size = UDim2.new(0, self._fullSize.X.Offset * .9, 0, self._fullSize.Y.Offset * .9),
            BackgroundTransparency = .25,
        }, .22, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        Tw(self._blur, {Size = 0}, .3)
        task.delay(.23, function()
            if not self.Open then self.Main.Visible = false end
        end)
    end
end

function Library:Destroy()
    self._globalConns:DisconnectAll()
    self:_closePopups()
    pcall(function() self._blur:Destroy() end)
    pcall(function() self.Gui:Destroy() end)
end

function Library:SaveConfig(name)
    pcall(function()
        local d = {}
        for f, v in pairs(Library.Flags) do
            local c = {}
            for k, x in pairs(v) do
                if typeof(x) == "Color3" then
                    c[k] = {R = x.R, G = x.G, B = x.B, _c3 = true}
                else c[k] = x end
            end
            d[f] = c
        end
        pcall(makefolder, "NexUI_configs")
        writefile("NexUI_configs/" .. name .. ".json", Http:JSONEncode(d))
    end)
end

function Library:LoadConfig(name)
    pcall(function()
        local d = Http:JSONDecode(readfile("NexUI_configs/" .. name .. ".json"))
        for f, v in pairs(d) do
            for k, x in pairs(v) do
                if type(x) == "table" and x._c3 then v[k] = Color3.new(x.R, x.G, x.B) end
            end
            Library.Flags[f] = v
            local e = Library.Elements[f]
            if e and e._setValue then
                if e.Type == "Toggle" then pcall(e._setValue, v.Toggle, true) end
                if e.Type == "Slider" then pcall(e._setValue, v.Slider, true) end
                if e.Type == "Dropdown" then pcall(e._setValue, v.Dropdown, true) end
            end
        end
    end)
end

function Library:ListConfigs()
    local o = {}
    pcall(function()
        pcall(makefolder, "NexUI_configs")
        for _, f in next, listfiles("NexUI_configs") do
            table.insert(o, f:gsub("NexUI_configs/", ""):gsub("NexUI_configs\\", ""):gsub("%.json$", ""))
        end
    end)
    return o
end

-- ═══════════════════════════════════════════════════
--  NOTIFICATION QUEUE SYSTEM
-- ═══════════════════════════════════════════════════
Library._notifHolder = nil
Library._notifQueue = {}
Library._notifProcessing = false

local function ProcessNotifQueue()
    if Library._notifProcessing then return end
    Library._notifProcessing = true

    task.spawn(function()
        while #Library._notifQueue > 0 do
            local data = table.remove(Library._notifQueue, 1)
            Library:_showNotification(data.title, data.desc, data.duration, data.nType)
            task.wait(.3) -- stagger between notifications
        end
        Library._notifProcessing = false
    end)
end

function Library:Notify(title, desc, duration, nType)
    table.insert(Library._notifQueue, {
        title = title, desc = desc, duration = duration or 4, nType = nType or "info",
    })
    ProcessNotifQueue()
end

function Library:_showNotification(title, desc, duration, nType)
    -- Ensure holder exists
    if not Library._notifHolder or not Library._notifHolder.Parent then
        local ng = I("ScreenGui", {
            Name = "__NexUI_N", ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2000,
        })
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(ng); ng.Parent = game.CoreGui
            elseif gethui then ng.Parent = gethui()
            else ng.Parent = LP:WaitForChild("PlayerGui") end
        end)
        Library._notifHolder = I("Frame", {
            Size = UDim2.new(0, 290, 1, 0),
            Position = UDim2.new(1, -305, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
        }, ng)
        local hl = Ls(Library._notifHolder, 8)
        hl.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Pd(12, 12, 0, 0, Library._notifHolder)
    end

    local ac = ({
        info = T.Accent, success = T.Success,
        warning = T.Warning, error = T.Danger,
    })[nType] or T.Accent

    -- Wrapper (for AutomaticSize)
    local wr = I("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    }, Library._notifHolder)

    -- Card
    local nf = I("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(1.2, 0, 0, 0),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0,
        BackgroundTransparency = .3, ZIndex = 10, ClipsDescendants = true,
    }, wr)
    Cn(10, nf)
    local nfStroke = St(T.Border, 1, nf)

    -- Accent bar
    I("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = ac, BorderSizePixel = 0, ZIndex = 11,
    }, nf)

    -- Content
    local inner = I("Frame", {
        Size = UDim2.new(1, -3, 0, 0), Position = UDim2.new(0, 3, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 11,
    }, nf)
    Ls(inner, 3); Pd(10, 12, 10, 10, inner)

    -- Title row
    local titleRow = I("Frame", {
        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 12, LayoutOrder = 1,
    }, inner)

    local dot = I("Frame", {
        Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 0, .5, -3),
        BackgroundColor3 = ac, BorderSizePixel = 0, ZIndex = 13,
    }, titleRow)
    Cn(3, dot)

    local tLbl = I("TextLabel", {
        Text = title or "Notification",
        Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text,
        TextSize = 11, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 13,
    }, titleRow)

    local dLbl
    if desc and desc ~= "" then
        dLbl = I("TextLabel", {
            Text = desc, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, TextColor3 = T.TextSub,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            TextTransparency = 1, ZIndex = 12, LayoutOrder = 2,
        }, inner)
    end

    I("Frame", {Size = UDim2.new(1, 0, 0, 5), BackgroundTransparency = 1, LayoutOrder = 3}, inner)

    local pC = I("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0,
        ZIndex = 12, LayoutOrder = 4,
    }, inner)
    Cn(1, pC)

    local pF = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ac, BorderSizePixel = 0, ZIndex = 13,
    }, pC)
    Cn(1, pF)

    local dismissed = false

    local function Dismiss()
        if dismissed then return end
        dismissed = true
        Tw(nf, {Position = UDim2.new(1.3, 0, 0, 0)}, .35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(.4, function()
            if wr and wr.Parent then pcall(function() wr:Destroy() end) end
        end)
    end

    -- ═══ ENTRY ANIMATION ═══
    task.defer(function()
        if not nf or not nf.Parent then return end
        Tw(nf, {Position = UDim2.new(0, 0, 0, 0)}, .5)
    end)
    task.delay(.08, function()
        if not nf or not nf.Parent then return end
        Tw(nf, {BackgroundTransparency = 0}, .35)
    end)
    task.delay(.12, function()
        if not dot or not dot.Parent then return end
        Tw(dot, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, -1, .5, -4)}, .12)
        task.delay(.12, function()
            if not dot or not dot.Parent then return end
            Tw(dot, {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 0, .5, -3)}, .12)
        end)
    end)
    task.delay(.18, function()
        if not tLbl or not tLbl.Parent then return end
        Tw(tLbl, {TextTransparency = 0}, .3)
    end)
    task.delay(.26, function()
        if dLbl and dLbl.Parent then Tw(dLbl, {TextTransparency = .1}, .3) end
    end)
    task.delay(.35, function()
        if pF and pF.Parent then
            Tw(pF, {Size = UDim2.new(0, 0, 1, 0)}, duration - .5, Enum.EasingStyle.Linear)
        end
    end)

    -- ═══ EXIT ANIMATION ═══
    task.delay(duration, function()
        if dismissed then return end
        if tLbl and tLbl.Parent then Tw(tLbl, {TextTransparency = .5}, .2) end
        if dLbl and dLbl.Parent then Tw(dLbl, {TextTransparency = .6}, .2) end
        if dot and dot.Parent then Tw(dot, {BackgroundTransparency = .5}, .2) end
        task.delay(.1, function()
            if nf and nf.Parent then Tw(nf, {BackgroundTransparency = .4}, .25) end
        end)
        task.delay(.15, function()
            if nf and nf.Parent then
                Tw(nf, {Position = UDim2.new(1.3, 0, 0, 0)}, .5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            end
        end)
        task.delay(.7, function()
            if wr and wr.Parent then pcall(function() wr:Destroy() end) end
        end)
    end)

    -- Click dismiss + hover
    local disBtn = I("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 14,
    }, nf)
    disBtn.MouseButton1Click:Connect(Dismiss)
    disBtn.MouseEnter:Connect(function()
        if not dismissed and nf and nf.Parent then Tw(nf, {BackgroundTransparency = .05}, .1) end
    end)
    disBtn.MouseLeave:Connect(function()
        if not dismissed and nf and nf.Parent then Tw(nf, {BackgroundTransparency = 0}, .1) end
    end)
end

-- ═══════════════════════════════════════════════════
return Library
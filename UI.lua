--[[
    ███╗░░██╗███████╗██╗░░██╗██╗░░░██╗██╗
    ████╗░██║██╔════╝╚██╗██╔╝██║░░░██║██║
    ██╔██╗██║█████╗░░░╚███╔╝░██║░░░██║██║
    ██║╚████║██╔══╝░░░██╔██╗░██║░░░██║██║
    ██║░╚███║███████╗██╔╝╚██╗╚██████╔╝██║
    ╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝░╚═════╝░╚═╝
    
    NexUI Library — v5.0  (Full Rewrite)
    
    • Two-column section layout (Left / Right)
    • Background blur when open
    • 6 theme presets + custom theme support
    • Enhanced micro-animations (bounce, stagger, spring)
    • No min/close buttons (RightShift to toggle)
    • Redesigned notifications with sequential animations
    • All v4 bugfixes preserved
    
    USAGE:
        local Library = loadstring(...)()
        Library:SetTheme("Midnight")   -- optional
        local Window = Library.new("Hub Name")
        local Tab = Window:new_tab("Combat", "⚔")
        local Left  = Tab:new_section("Aimbot", "Left")
        local Right = Tab:new_section("Settings", "Right")
        Left:element("Toggle", "Enabled", {}, function(s) end):add_keybind()
        Right:element("Slider", "FOV", {default={min=1,max=360,default=90}}, function(s) end)
]]

local Library    = {}
Library.__index  = Library
Library.Flags    = {}
Library.Elements = {}
Library.Windows  = {}
Library._themed  = {}  -- {obj, property, themeKey}

-- ═══════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local TS          = game:GetService("TweenService")
local Http        = game:GetService("HttpService")
local Lighting    = game:GetService("Lighting")
local LP          = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  THEME SYSTEM
-- ═══════════════════════════════════════════════════════════
Library.Themes = {
    Default = {
        BG=Color3.fromRGB(8,8,12),         IconBar=Color3.fromRGB(10,10,15),
        Panel=Color3.fromRGB(14,14,20),     Elevated=Color3.fromRGB(20,20,28),
        Hover=Color3.fromRGB(28,28,38),     Active=Color3.fromRGB(35,35,48),
        Card=Color3.fromRGB(16,16,23),      CardHead=Color3.fromRGB(20,20,28),
        Accent=Color3.fromRGB(45,125,255),  AccentDim=Color3.fromRGB(20,65,150),
        AccentGlow=Color3.fromRGB(35,100,230),
        Text=Color3.fromRGB(230,230,242),   TextSub=Color3.fromRGB(135,135,158),
        TextMut=Color3.fromRGB(70,70,90),   TextDis=Color3.fromRGB(45,45,60),
        Border=Color3.fromRGB(26,26,36),    BorderLight=Color3.fromRGB(40,40,54),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(22,22,30),  ToggleKnob=Color3.fromRGB(85,85,105),
        SliderTrack=Color3.fromRGB(20,20,28),SliderFill=Color3.fromRGB(45,125,255),
        SliderKnob=Color3.fromRGB(210,220,255),
    },
    Midnight = {
        BG=Color3.fromRGB(10,8,18),        IconBar=Color3.fromRGB(12,10,22),
        Panel=Color3.fromRGB(16,13,28),     Elevated=Color3.fromRGB(24,20,40),
        Hover=Color3.fromRGB(32,28,52),     Active=Color3.fromRGB(40,35,60),
        Card=Color3.fromRGB(18,15,30),      CardHead=Color3.fromRGB(22,18,36),
        Accent=Color3.fromRGB(130,80,255),  AccentDim=Color3.fromRGB(70,40,150),
        AccentGlow=Color3.fromRGB(100,60,220),
        Text=Color3.fromRGB(230,225,245),   TextSub=Color3.fromRGB(140,130,165),
        TextMut=Color3.fromRGB(75,65,100),  TextDis=Color3.fromRGB(50,42,70),
        Border=Color3.fromRGB(30,25,45),    BorderLight=Color3.fromRGB(45,38,65),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(24,20,36),  ToggleKnob=Color3.fromRGB(90,80,115),
        SliderTrack=Color3.fromRGB(22,18,34),SliderFill=Color3.fromRGB(130,80,255),
        SliderKnob=Color3.fromRGB(215,200,255),
    },
    Ocean = {
        BG=Color3.fromRGB(6,12,14),        IconBar=Color3.fromRGB(8,14,18),
        Panel=Color3.fromRGB(10,18,24),     Elevated=Color3.fromRGB(16,26,34),
        Hover=Color3.fromRGB(22,34,44),     Active=Color3.fromRGB(28,42,54),
        Card=Color3.fromRGB(12,20,26),      CardHead=Color3.fromRGB(16,24,32),
        Accent=Color3.fromRGB(30,190,180),  AccentDim=Color3.fromRGB(15,100,95),
        AccentGlow=Color3.fromRGB(25,150,140),
        Text=Color3.fromRGB(220,240,238),   TextSub=Color3.fromRGB(120,155,150),
        TextMut=Color3.fromRGB(55,80,78),   TextDis=Color3.fromRGB(35,55,52),
        Border=Color3.fromRGB(20,32,38),    BorderLight=Color3.fromRGB(32,48,56),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(14,24,30),  ToggleKnob=Color3.fromRGB(60,95,100),
        SliderTrack=Color3.fromRGB(12,22,28),SliderFill=Color3.fromRGB(30,190,180),
        SliderKnob=Color3.fromRGB(180,245,240),
    },
    Rose = {
        BG=Color3.fromRGB(14,8,10),        IconBar=Color3.fromRGB(18,10,13),
        Panel=Color3.fromRGB(24,14,18),     Elevated=Color3.fromRGB(34,20,26),
        Hover=Color3.fromRGB(44,28,34),     Active=Color3.fromRGB(54,35,42),
        Card=Color3.fromRGB(26,16,20),      CardHead=Color3.fromRGB(30,18,24),
        Accent=Color3.fromRGB(235,65,100),  AccentDim=Color3.fromRGB(140,30,55),
        AccentGlow=Color3.fromRGB(200,50,80),
        Text=Color3.fromRGB(242,228,232),   TextSub=Color3.fromRGB(160,130,140),
        TextMut=Color3.fromRGB(95,65,75),   TextDis=Color3.fromRGB(65,42,50),
        Border=Color3.fromRGB(38,24,30),    BorderLight=Color3.fromRGB(55,36,44),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(30,18,22),  ToggleKnob=Color3.fromRGB(110,75,85),
        SliderTrack=Color3.fromRGB(28,16,20),SliderFill=Color3.fromRGB(235,65,100),
        SliderKnob=Color3.fromRGB(255,200,215),
    },
    Sunset = {
        BG=Color3.fromRGB(14,10,8),        IconBar=Color3.fromRGB(18,12,10),
        Panel=Color3.fromRGB(24,18,14),     Elevated=Color3.fromRGB(34,26,20),
        Hover=Color3.fromRGB(44,34,28),     Active=Color3.fromRGB(55,42,34),
        Card=Color3.fromRGB(26,20,16),      CardHead=Color3.fromRGB(30,24,18),
        Accent=Color3.fromRGB(255,140,40),  AccentDim=Color3.fromRGB(160,80,20),
        AccentGlow=Color3.fromRGB(220,110,30),
        Text=Color3.fromRGB(245,238,228),   TextSub=Color3.fromRGB(165,148,130),
        TextMut=Color3.fromRGB(100,82,65),  TextDis=Color3.fromRGB(68,55,42),
        Border=Color3.fromRGB(40,32,24),    BorderLight=Color3.fromRGB(58,46,36),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(30,22,16),  ToggleKnob=Color3.fromRGB(115,90,70),
        SliderTrack=Color3.fromRGB(28,20,14),SliderFill=Color3.fromRGB(255,140,40),
        SliderKnob=Color3.fromRGB(255,220,180),
    },
    Mono = {
        BG=Color3.fromRGB(10,10,10),       IconBar=Color3.fromRGB(13,13,13),
        Panel=Color3.fromRGB(18,18,18),     Elevated=Color3.fromRGB(26,26,26),
        Hover=Color3.fromRGB(34,34,34),     Active=Color3.fromRGB(42,42,42),
        Card=Color3.fromRGB(20,20,20),      CardHead=Color3.fromRGB(24,24,24),
        Accent=Color3.fromRGB(200,200,200), AccentDim=Color3.fromRGB(100,100,100),
        AccentGlow=Color3.fromRGB(150,150,150),
        Text=Color3.fromRGB(235,235,235),   TextSub=Color3.fromRGB(150,150,150),
        TextMut=Color3.fromRGB(80,80,80),   TextDis=Color3.fromRGB(50,50,50),
        Border=Color3.fromRGB(30,30,30),    BorderLight=Color3.fromRGB(45,45,45),
        Success=Color3.fromRGB(45,215,115), Warning=Color3.fromRGB(255,185,35),
        Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(22,22,22),  ToggleKnob=Color3.fromRGB(90,90,90),
        SliderTrack=Color3.fromRGB(20,20,20),SliderFill=Color3.fromRGB(200,200,200),
        SliderKnob=Color3.fromRGB(235,235,235),
    },
}

Library.CurrentTheme = "Default"
local T = {} -- active theme reference
for k,v in pairs(Library.Themes.Default) do T[k] = v end

function Library:SetTheme(name)
    local theme = Library.Themes[name]
    if not theme then return end
    Library.CurrentTheme = name
    for k,v in pairs(theme) do T[k] = v end
    -- Re-apply to all registered themed objects
    for _,entry in ipairs(Library._themed) do
        local obj, prop, key = entry[1], entry[2], entry[3]
        if obj and obj.Parent then
            pcall(function() TS:Create(obj, TweenInfo.new(.3, Enum.EasingStyle.Quart), {[prop]=T[key]}):Play() end)
        end
    end
end

local function Reg(obj, prop, key)
    table.insert(Library._themed, {obj, prop, key})
    pcall(function() obj[prop] = T[key] end)
    return obj
end

-- ═══════════════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════════════
local function Tw(o,p,t,s,d)
    pcall(function() TS:Create(o,TweenInfo.new(t or .15,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play() end)
end

local function N(c,p,par)
    local ok,i=pcall(Instance.new,c)
    if not ok then return nil end
    for k,v in pairs(p or {}) do pcall(function() i[k]=v end) end
    if par then i.Parent=par end; return i
end

local function Cn(r,p) return N("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function St(c,t,p) return N("UIStroke",{Color=c or T.Border,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function Pd(t,b,l,r,p) return N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},p) end
local function Ls(par,gap) return N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap or 0)},par) end

local function Shadow(p,z)
    N("ImageLabel",{Name="_Sh",Size=UDim2.new(1,44,1,44),Position=UDim2.new(0,-22,0,-22),BackgroundTransparency=1,Image="rbxassetid://5554236805",ImageColor3=Color3.new(0,0,0),ImageTransparency=.45,ZIndex=(z or 1)-1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(23,23,277,277)},p)
end

local function KeyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.","") end

local function IsOutside(pos, frame)
    local pp,ps = frame.AbsolutePosition, frame.AbsoluteSize
    return pos.X<pp.X or pos.X>pp.X+ps.X or pos.Y<pp.Y or pos.Y>pp.Y+ps.Y
end

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════
function Library.new(title, toggleKey)
    local win = setmetatable({}, Library)
    win.Title     = title or "NexUI"
    win.Tabs      = {}
    win.ActiveTab = nil
    win.Open      = true
    win._popup    = nil
    win._popupElem= nil
    win._dropdown = nil
    win.ToggleKey = toggleKey or Enum.KeyCode.RightShift

    local W,H    = 780,490
    local TOPBAR = 46
    local ICONW  = 46
    local SUBW   = 150

    -- ScreenGui
    local gui = N("ScreenGui",{
        Name="__NexUI_"..math.random(1e4,9e4),
        ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=1000,
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent=game.CoreGui
        elseif gethui then gui.Parent=gethui()
        else gui.Parent=LP:WaitForChild("PlayerGui") end
    end)
    if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end
    win.Gui = gui

    -- Background blur
    local blur = N("BlurEffect",{Name="__NexBlur",Size=0},Lighting)
    win._blur = blur

    -- Overlay
    win.Overlay = N("Frame",{Name="Ov",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=500},gui)

    -- Main
    local main = N("Frame",{
        Name="W", Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=T.BG, BorderSizePixel=0, ClipsDescendants=true,
        AnchorPoint=Vector2.new(0.5,0.5),
    },gui)
    Cn(12,main); Shadow(main,2)
    Reg(main,"BackgroundColor3","BG")
    win.Main = main
    win._fullSize = UDim2.new(0,W,0,H)

    -- Intro animation
    main.Size = UDim2.new(0,W*.85,0,H*.85)
    main.BackgroundTransparency = .3
    Tw(main,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},.45,Enum.EasingStyle.Back)
    Tw(blur,{Size=6},.5)

    -- ── Top Bar ──────────────────────────────────────
    local topbar = N("Frame",{
        Name="TB", Size=UDim2.new(1,0,0,TOPBAR),
        BackgroundColor3=T.Panel, BorderSizePixel=0, ZIndex=10,
    },main)
    Cn(12,topbar); Reg(topbar,"BackgroundColor3","Panel")
    N("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10},topbar)

    -- Accent glow line
    local acLine = N("Frame",{
        Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,0,0),
        BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=15,
    },topbar)
    Cn(1,acLine); Reg(acLine,"BackgroundColor3","Accent")
    N("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,.75),NumberSequenceKeypoint.new(.5,.1),NumberSequenceKeypoint.new(1,.75)}},acLine)

    -- Bottom divider
    local tbDiv = N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=11},topbar)
    Reg(tbDiv,"BackgroundColor3","Border")

    -- Title
    local titleLbl = N("TextLabel",{
        Text=win.Title, Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,ICONW+14,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=14,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    },topbar)
    Reg(titleLbl,"TextColor3","Text")

    -- Search
    local searchFrame = N("Frame",{
        Size=UDim2.new(0,190,0,26),Position=UDim2.new(0.5,-95,0.5,-13),
        BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=14,
    },topbar)
    Cn(7,searchFrame); St(T.Border,1,searchFrame); Reg(searchFrame,"BackgroundColor3","Elevated")
    N("TextLabel",{Text="🔍",Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=11,Font=Enum.Font.Gotham,ZIndex=15},searchFrame)
    local searchBox = N("TextBox",{
        Text="",PlaceholderText="Search...",
        Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,26,0,0),
        BackgroundTransparency=1,TextColor3=T.Text,PlaceholderColor3=T.TextDis,
        TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15,
    },searchFrame)

    -- Avatar
    local avatar = N("Frame",{
        Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0.5,-15),
        BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=12,
    },topbar)
    Cn(15,avatar); Reg(avatar,"BackgroundColor3","Accent")
    N("TextLabel",{
        Text=string.upper(string.sub(LP.Name,1,1)),
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        TextColor3=Color3.new(1,1,1),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=13,
    },avatar)

    -- User info
    N("TextLabel",{
        Text=LP.DisplayName,Size=UDim2.new(0,95,0,13),Position=UDim2.new(1,-148,0,9),
        BackgroundTransparency=1,TextColor3=T.Text,TextSize=10,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=12,
    },topbar)
    N("TextLabel",{
        Text=os.date("%d/%m/%Y"),Size=UDim2.new(0,95,0,11),Position=UDim2.new(1,-148,0,24),
        BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=9,
        Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=12,
    },topbar)

    -- ── Drag ─────────────────────────────────────────
    do
        local dragging,dragInput,mouseStart,frameStart = false,nil,nil,nil
        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; mouseStart=inp.Position; frameStart=main.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        topbar.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement then dragInput=inp end
        end)
        UIS.InputChanged:Connect(function(inp)
            if inp==dragInput and dragging and mouseStart then
                local d=inp.Position-mouseStart
                main.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+d.X,frameStart.Y.Scale,frameStart.Y.Offset+d.Y)
            end
        end)
    end

    -- ── Icon Sidebar ─────────────────────────────────
    local iconBar = N("Frame",{
        Size=UDim2.new(0,ICONW,1,-TOPBAR),Position=UDim2.new(0,0,0,TOPBAR),
        BackgroundColor3=T.IconBar,BorderSizePixel=0,ZIndex=8,
    },main)
    Reg(iconBar,"BackgroundColor3","IconBar")
    N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},iconBar)

    local iconScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=9,
    },iconBar)
    local iconLay = Ls(iconScroll,4); Pd(10,10,0,0,iconScroll)
    iconLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        iconScroll.CanvasSize=UDim2.new(0,0,0,iconLay.AbsoluteContentSize.Y+20)
    end)
    win.IconScroll = iconScroll

    -- ── Sub Sidebar ──────────────────────────────────
    local subSide = N("Frame",{
        Size=UDim2.new(0,SUBW,1,-TOPBAR),Position=UDim2.new(0,ICONW,0,TOPBAR),
        BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=6,
    },main)
    Reg(subSide,"BackgroundColor3","Panel")
    N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=7},subSide)

    local subScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=7,
    },subSide)
    local subLay = Ls(subScroll,2); Pd(10,10,8,8,subScroll)
    subLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        subScroll.CanvasSize=UDim2.new(0,0,0,subLay.AbsoluteContentSize.Y+20)
    end)
    win.SubScroll = subScroll

    -- ── Content ──────────────────────────────────────
    local content = N("Frame",{
        Size=UDim2.new(1,-(ICONW+SUBW),1,-TOPBAR),
        Position=UDim2.new(0,ICONW+SUBW,0,TOPBAR),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,
    },main)
    win.Content = content

    -- ── Search Logic ─────────────────────────────────
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=string.lower(searchBox.Text)
        for _,tab in ipairs(win.Tabs) do
            for _,sec in ipairs(tab.Sections) do
                local anyVis=false
                for _,el in ipairs(sec.Elements) do
                    if el._row then
                        local m=q=="" or string.find(string.lower(el.Name),q,1,true)
                        el._row.Visible=m~=nil; if m then anyVis=true end
                    end
                end
                if sec.Frame then sec.Frame.Visible=anyVis or q=="" end
                if sec._subEntry then sec._subEntry.Visible=anyVis or q=="" end
            end
        end
    end)

    -- ── Global keybinds ──────────────────────────────
    UIS.InputBegan:Connect(function(inp,gpe)
        if inp.KeyCode==win.ToggleKey and not gpe then win:SetOpen(not win.Open); return end
        if gpe or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for flag,elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode==elem._keybind then
                if elem._keybindMode=="Toggle" and elem.Type=="Toggle" and elem._setValue then
                    elem._setValue(not(Library.Flags[flag] and Library.Flags[flag].Toggle or false))
                elseif elem._keybindMode=="Hold" and elem.Type=="Toggle" and elem._setValue then
                    elem._setValue(true)
                end
            end
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for flag,elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode==elem._keybind and elem._keybindMode=="Hold" then
                if elem.Type=="Toggle" and elem._setValue then elem._setValue(false) end
            end
        end
    end)

    table.insert(Library.Windows,win)
    return win
end

-- ═══════════════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════════════
function Library:new_tab(name, icon)
    local win=self
    icon=icon or string.upper(string.sub(name,1,1))
    local tab={Name=name,Icon=icon,Sections={},Active=false}

    local ICONW=46

    -- Icon button
    local iconBtn=N("TextButton",{
        Name=name,Text="",Size=UDim2.new(1,0,0,40),
        BackgroundColor3=T.IconBar,BackgroundTransparency=.5,
        BorderSizePixel=0,AutoButtonColor=false,ZIndex=10,
    },win.IconScroll)
    Cn(8,iconBtn); tab.IconBtn=iconBtn

    local indicator=N("Frame",{
        Size=UDim2.new(0,3,0,0),Position=UDim2.new(0,2,.5,0),
        BackgroundColor3=T.TextMut,BorderSizePixel=0,ZIndex=11,
    },iconBtn)
    Cn(2,indicator); tab.Indicator=indicator

    local iconLbl=N("TextLabel",{
        Text=icon,Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,TextColor3=T.TextMut,
        TextSize=15,Font=Enum.Font.GothamBold,ZIndex=11,
    },iconBtn); tab.IconLabel=iconLbl

    -- Tooltip
    local tooltip=N("TextLabel",{
        Text=" "..name.." ",Size=UDim2.new(0,0,0,22),
        AutomaticSize=Enum.AutomaticSize.X,
        Position=UDim2.new(1,8,.5,-11),
        BackgroundColor3=T.Elevated,TextColor3=T.Text,
        TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,
        Visible=false,ZIndex=900,
    },iconBtn)
    Cn(5,tooltip); St(T.BorderLight,1,tooltip)

    iconBtn.MouseEnter:Connect(function()
        tooltip.Visible=true
        if not tab.Active then
            Tw(iconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.12)
            Tw(iconLbl,{TextColor3=T.TextSub},.12)
        end
    end)
    iconBtn.MouseLeave:Connect(function()
        tooltip.Visible=false
        if not tab.Active then
            Tw(iconBtn,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.12)
            Tw(iconLbl,{TextColor3=T.TextMut},.12)
        end
    end)
    iconBtn.MouseButton1Click:Connect(function() win:SelectTab(tab) end)

    -- Sub sidebar container
    local subContainer=N("Frame",{
        Name=name.."_sub",Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=7,
    },win.SubScroll)
    Ls(subContainer,2); tab.SubContainer=subContainer

    N("TextLabel",{
        Text=string.upper(name),Size=UDim2.new(1,0,0,26),
        BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=9,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8,
    },subContainer)

    -- ── Content page with TWO COLUMNS ────────────────
    local page=N("ScrollingFrame",{
        Name=name.."_pg",Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=5,
    },win.Content)
    Pd(10,14,10,10,page)
    tab.Page=page

    -- Columns container
    local colContainer=N("Frame",{
        Size=UDim2.new(1,0,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },page)

    local leftCol=N("Frame",{
        Size=UDim2.new(0.5,-5,0,0),Position=UDim2.new(0,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },colContainer)
    Ls(leftCol,10)

    local rightCol=N("Frame",{
        Size=UDim2.new(0.5,-5,0,0),Position=UDim2.new(0.5,5,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },colContainer)
    Ls(rightCol,10)

    tab.LeftCol=leftCol; tab.RightCol=rightCol; tab.ColContainer=colContainer

    -- Update canvas based on tallest column
    local function UpdateCanvas()
        local lH = leftCol:FindFirstChildOfClass("UIListLayout") and leftCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y or 0
        local rH = rightCol:FindFirstChildOfClass("UIListLayout") and rightCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y or 0
        local maxH = math.max(lH, rH)
        colContainer.Size = UDim2.new(1,0,0,maxH)
        page.CanvasSize = UDim2.new(0,0,0,maxH+30)
    end

    leftCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
    rightCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
    task.defer(UpdateCanvas)

    table.insert(win.Tabs,tab)
    if #win.Tabs==1 then win:SelectTab(tab) end

    -- ═══════════════════════════════════════════════════
    --  SECTION (with side parameter)
    -- ═══════════════════════════════════════════════════
    function tab:new_section(sectionName, side)
        side = side or "Left"
        local targetCol = side=="Right" and rightCol or leftCol
        local section = {Name=sectionName, Elements={}, Side=side}

        -- Sub entry
        local subEntry=N("TextButton",{
            Name=sectionName,Text="",Size=UDim2.new(1,0,0,26),
            BackgroundColor3=T.Panel,BackgroundTransparency=.5,
            BorderSizePixel=0,AutoButtonColor=false,ZIndex=8,
        },subContainer)
        Cn(5,subEntry); section._subEntry=subEntry

        local diamond=N("TextLabel",{
            Text="◆",Size=UDim2.new(0,14,1,0),Position=UDim2.new(0,4,0,0),
            BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=6,
            Font=Enum.Font.GothamBold,ZIndex=9,
        },subEntry)
        local subLbl=N("TextLabel",{
            Text=sectionName,Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,18,0,0),
            BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,
            Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9,
        },subEntry)

        subEntry.MouseEnter:Connect(function() Tw(subEntry,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.1) end)
        subEntry.MouseLeave:Connect(function() Tw(subEntry,{BackgroundTransparency=.5,BackgroundColor3=T.Panel},.1) end)
        subEntry.MouseButton1Click:Connect(function()
            task.defer(function()
                if section.Frame then
                    local targetY=section.Frame.AbsolutePosition.Y-page.AbsolutePosition.Y+page.CanvasPosition.Y
                    TS:Create(page,TweenInfo.new(.4,Enum.EasingStyle.Quint),{CanvasPosition=Vector2.new(0,math.max(0,targetY-8))}):Play()
                end
            end)
            Tw(diamond,{TextColor3=T.Accent},.15); Tw(subLbl,{TextColor3=T.Text},.15)
            task.delay(.8,function() Tw(diamond,{TextColor3=T.TextMut},.3); Tw(subLbl,{TextColor3=T.TextSub},.3) end)
        end)

        -- Card
        local card=N("Frame",{
            Name=sectionName,Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=6,
        },targetCol)
        Cn(10,card); St(T.Border,1,card); Ls(card,0)
        Reg(card,"BackgroundColor3","Card")
        section.Frame=card

        -- Card entrance animation (staggered)
        card.BackgroundTransparency=1
        local delay = #tab.Sections * .06
        task.delay(delay,function()
            Tw(card,{BackgroundTransparency=0},.35,Enum.EasingStyle.Quint)
        end)

        -- Header
        local header=N("Frame",{
            Size=UDim2.new(1,0,0,36),BackgroundColor3=T.CardHead,
            BorderSizePixel=0,ZIndex=7,LayoutOrder=1,
        },card)
        Cn(10,header); Reg(header,"BackgroundColor3","CardHead")
        N("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.CardHead,BorderSizePixel=0,ZIndex=7},header)
        N("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=8},header)

        local pill=N("Frame",{Size=UDim2.new(0,3,0,12),Position=UDim2.new(0,9,.5,-6),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=8},header)
        Cn(2,pill); Reg(pill,"BackgroundColor3","Accent")

        N("TextLabel",{
            Text=string.upper(sectionName),Size=UDim2.new(1,-26,1,0),
            Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,
            TextColor3=T.TextSub,TextSize=9,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8,
        },header)

        -- Elements container
        local ec=N("Frame",{
            Name="El",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7,LayoutOrder=2,
        },card)
        Ls(ec,1); Pd(5,7,7,7,ec)
        section.Container=ec

        -- ═══════════════════════════════════════════
        --  ELEMENT FACTORY
        -- ═══════════════════════════════════════════
        function section:element(eType,eName,options,callback)
            options=options or {}; callback=callback or function() end
            local flag=sectionName.."_"..eName
            local elem={
                Type=eType,Name=eName,Flag=flag,
                _keybind=nil,_keybindMode="Toggle",_hasKeybind=false,
                _setValue=nil,_getValue=nil,_callback=callback,
            }

            local function Row(h)
                local f=N("Frame",{Size=UDim2.new(1,0,0,h or 34),BackgroundColor3=T.Card,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7},ec)
                Cn(6,f); return f
            end

            -- ═════════════════════════════════
            --  TOGGLE
            -- ═════════════════════════════════
            if eType=="Toggle" then
                Library.Flags[flag]={Toggle=false,Active=false}
                local row=Row(36)

                local hov=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Hover,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7},row)
                Cn(6,hov)

                N("TextLabel",{
                    Text=eName,Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,
                    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9,
                },row)

                local sw=N("Frame",{Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-44,.5,-9),BackgroundColor3=T.ToggleBg,BorderSizePixel=0,ZIndex=9},row)
                Cn(9,sw); St(T.BorderLight,1,sw)

                local glow=N("Frame",{Size=UDim2.new(0,44,0,26),Position=UDim2.new(1,-48,.5,-13),BackgroundColor3=T.AccentGlow,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=8},row)
                Cn(13,glow)

                local knob=N("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,3,.5,-6),BackgroundColor3=T.ToggleKnob,BorderSizePixel=0,ZIndex=10},sw)
                Cn(6,knob)

                local gear=N("TextButton",{
                    Text="⚙",Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-70,.5,-10),
                    BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=13,
                    Font=Enum.Font.GothamBold,ZIndex=13,Visible=false,
                },row)

                local toggled=false
                local function Set(val,silent)
                    toggled=val; Library.Flags[flag].Toggle=val; Library.Flags[flag].Active=val
                    if val then
                        Tw(sw,{BackgroundColor3=T.Accent},.2)
                        Tw(knob,{Position=UDim2.new(0,21,.5,-6),BackgroundColor3=Color3.new(1,1,1)},.2,Enum.EasingStyle.Back)
                        Tw(glow,{BackgroundTransparency=.8},.3)
                    else
                        Tw(sw,{BackgroundColor3=T.ToggleBg},.2)
                        Tw(knob,{Position=UDim2.new(0,3,.5,-6),BackgroundColor3=T.ToggleKnob},.2,Enum.EasingStyle.Back)
                        Tw(glow,{BackgroundTransparency=1},.2)
                    end
                    if not silent then pcall(callback,{Toggle=val}) end
                end
                elem._setValue=Set; elem._getValue=function() return toggled end

                local click=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},row)
                click.MouseButton1Click:Connect(function() Set(not toggled) end)
                click.MouseEnter:Connect(function() Tw(hov,{BackgroundTransparency=.9},.1) end)
                click.MouseLeave:Connect(function() Tw(hov,{BackgroundTransparency=1},.1) end)
                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem,gear) end)

                elem._gear=gear; elem._row=row
                function elem:add_keybind() self._hasKeybind=true; gear.Visible=true; return self end
                function elem:set_value(v) Set(v,false) end

            -- ═════════════════════════════════
            --  SLIDER
            -- ═════════════════════════════════
            elseif eType=="Slider" then
                local cfg=options.default or {}
                local vMin,vMax,vDef,vDec=cfg.min or 0,cfg.max or 100,cfg.default or(cfg.min or 0),cfg.decimals or 0
                Library.Flags[flag]={Slider=vDef}
                local row=Row(48)

                N("TextLabel",{Text=eName,Size=UDim2.new(.55,0,0,20),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local valLbl=N("TextLabel",{
                    Text=vDec>0 and string.format("%."..vDec.."f",vDef) or tostring(vDef),
                    Size=UDim2.new(.45,-10,0,20),Position=UDim2.new(.55,0,0,3),
                    BackgroundTransparency=1,TextColor3=T.Accent,TextSize=11,
                    Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=9,
                },row)

                local track=N("Frame",{Size=UDim2.new(1,-20,0,5),Position=UDim2.new(0,10,0,32),BackgroundColor3=T.SliderTrack,BorderSizePixel=0,ZIndex=9,ClipsDescendants=true},row)
                Cn(3,track)
                local fill=N("Frame",{Size=UDim2.new((vDef-vMin)/(vMax-vMin),0,1,0),BackgroundColor3=T.SliderFill,BorderSizePixel=0,ZIndex=10},track)
                Cn(3,fill)
                N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.AccentDim),ColorSequenceKeypoint.new(1,T.Accent)}},fill)

                local handle=N("Frame",{Size=UDim2.new(0,13,0,13),BackgroundColor3=T.SliderKnob,BorderSizePixel=0,ZIndex=11},row)
                Cn(7,handle); St(T.Accent,2,handle)

                local function Fmt(v) return vDec>0 and string.format("%."..vDec.."f",v) or tostring(math.floor(v+.5)) end
                local function PosH()
                    local pct=(Library.Flags[flag].Slider-vMin)/(vMax-vMin)
                    local tx,tw=track.AbsolutePosition.X,track.AbsoluteSize.X
                    handle.Position=UDim2.new(0,tx-row.AbsolutePosition.X+pct*tw-6,0,26)
                end
                local function SetS(v,silent)
                    local f=10^vDec; local r=math.clamp(math.floor(v*f+.5)/f,vMin,vMax)
                    Library.Flags[flag].Slider=r; fill.Size=UDim2.new((r-vMin)/(vMax-vMin),0,1,0)
                    valLbl.Text=Fmt(r); PosH()
                    if not silent then pcall(callback,{Slider=r}) end
                end
                elem._setValue=SetS; elem._getValue=function() return Library.Flags[flag].Slider end
                task.defer(PosH)

                local dr=false
                local function Upd(i) SetS(vMin+math.clamp((i.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)*(vMax-vMin)) end
                local tc=N("TextButton",{Text="",Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,24),BackgroundTransparency=1,ZIndex=12},row)
                tc.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;Upd(i) end end)
                UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then Upd(i) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
                elem._row=row; function elem:set_value(v) SetS(v) end

            -- ═════════════════════════════════
            --  DROPDOWN
            -- ═════════════════════════════════
            elseif eType=="Dropdown" then
                local opts=options.options or {"Option"}; local defOpt=options.default or opts[1]
                Library.Flags[flag]={Dropdown=defOpt}
                local row=Row(54)

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,16),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local df=N("Frame",{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,20),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=9},row)
                Cn(6,df); St(T.BorderLight,1,df)
                local sel=N("TextLabel",{Text=defOpt,Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},df)
                local chev=N("TextLabel",{Text="▾",Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,ZIndex=10},df)

                local function SetD(v,s) Library.Flags[flag].Dropdown=v; sel.Text=v; if not s then pcall(callback,{Dropdown=v}) end end
                elem._setValue=SetD; elem._getValue=function() return Library.Flags[flag].Dropdown end

                local ca=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},df)
                ca.MouseButton1Click:Connect(function()
                    Tw(chev,{Rotation=180},.2)
                    win:_openDropdown(opts,df,function(v,s) SetD(v,s);Tw(chev,{Rotation=0},.2) end,function() Tw(chev,{Rotation=0},.2) end)
                end)
                ca.MouseEnter:Connect(function() Tw(df,{BackgroundColor3=T.Hover},.1) end)
                ca.MouseLeave:Connect(function() Tw(df,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row; function elem:set_value(v) SetD(v) end

            -- ═════════════════════════════════
            --  COMBO
            -- ═════════════════════════════════
            elseif eType=="Combo" then
                local opts=options.options or {}; local defSel=options.default or {}
                Library.Flags[flag]={Combo={table.unpack(defSel)}}
                local row=Row(0); row.AutomaticSize=Enum.AutomaticSize.Y

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,22),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local checks=N("Frame",{Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,10,0,25),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},row)
                Ls(checks,3); N("Frame",{Size=UDim2.new(1,0,0,5),BackgroundTransparency=1,LayoutOrder=999},checks)

                for _,opt in ipairs(opts) do
                    local isSel=table.find(defSel,opt)~=nil
                    local cr=N("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},checks)
                    local cb=N("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,1,.5,-7),BackgroundColor3=isSel and T.Accent or T.ToggleBg,BorderSizePixel=0,ZIndex=10},cr)
                    Cn(4,cb); St(T.BorderLight,1,cb)
                    local ck=N("TextLabel",{Text="✓",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=8,Font=Enum.Font.GothamBold,Visible=isSel,ZIndex=11},cb)
                    N("TextLabel",{Text=opt,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},cr)
                    local cp=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=12},cr)
                    cp.MouseButton1Click:Connect(function()
                        local cur=Library.Flags[flag].Combo; local idx=table.find(cur,opt)
                        if idx then table.remove(cur,idx);ck.Visible=false;Tw(cb,{BackgroundColor3=T.ToggleBg},.12)
                        else table.insert(cur,opt);ck.Visible=true;Tw(cb,{BackgroundColor3=T.Accent},.12) end
                        pcall(callback,{Combo=cur})
                    end)
                end
                elem._row=row

            -- ═════════════════════════════════
            --  BUTTON
            -- ═════════════════════════════════
            elseif eType=="Button" then
                local row=Row(38)
                local btn=N("TextButton",{
                    Text=eName,Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,.5,-14),
                    BackgroundColor3=T.Elevated,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,
                    BorderSizePixel=0,AutoButtonColor=false,ZIndex=9,ClipsDescendants=true,
                },row); Cn(6,btn); St(T.BorderLight,1,btn)
                btn.MouseButton1Click:Connect(function()
                    Tw(btn,{BackgroundColor3=T.Accent,TextColor3=Color3.new(1,1,1)},.06)
                    task.delay(.15,function() Tw(btn,{BackgroundColor3=T.Elevated,TextColor3=T.Text},.2) end)
                    pcall(callback,{})
                end)
                btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=T.Hover},.1) end)
                btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row

            -- ═════════════════════════════════
            --  TEXTBOX
            -- ═════════════════════════════════
            elseif eType=="TextBox" then
                Library.Flags[flag]={Text=options.default or ""}
                local row=Row(54)
                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,16),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local tb=N("TextBox",{
                    Text=options.default or "",PlaceholderText=options.placeholder or "Enter value...",
                    Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,20),
                    BackgroundColor3=T.Elevated,TextColor3=T.Text,PlaceholderColor3=T.TextDis,
                    TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false,BorderSizePixel=0,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9,
                },row); Cn(6,tb); local st=St(T.BorderLight,1,tb); Pd(0,0,8,8,tb)

                tb.Focused:Connect(function() Tw(st,{Color=T.Accent},.15);Tw(tb,{BackgroundColor3=T.Hover},.15) end)
                tb.FocusLost:Connect(function(enter)
                    Tw(st,{Color=T.BorderLight},.15);Tw(tb,{BackgroundColor3=T.Elevated},.15)
                    Library.Flags[flag].Text=tb.Text;pcall(callback,{Text=tb.Text,Enter=enter})
                end)
                tb:GetPropertyChangedSignal("Text"):Connect(function() Library.Flags[flag].Text=tb.Text end)
                elem._row=row; elem._tb=tb
                function elem:set_value(v) tb.Text=tostring(v);Library.Flags[flag].Text=tostring(v) end

            -- ═════════════════════════════════
            --  COLOR PICKER
            -- ═════════════════════════════════
            elseif eType=="ColorPicker" then
                local defColor=options.default or Color3.fromRGB(255,0,0)
                Library.Flags[flag]={Color=defColor}
                local h,s,v=Color3.toHSV(defColor)
                local row=Row(36)

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local preview=N("TextButton",{
                    Text="",Size=UDim2.new(0,26,0,20),Position=UDim2.new(1,-38,.5,-10),
                    BackgroundColor3=defColor,BorderSizePixel=0,AutoButtonColor=false,ZIndex=9,
                },row); Cn(5,preview); St(T.BorderLight,1,preview)

                local pickerOpen,pickerFrame,outsideConn=false,nil,nil
                local function UpdC(silent) local c=Color3.fromHSV(h,s,v);Library.Flags[flag].Color=c;preview.BackgroundColor3=c;if not silent then pcall(callback,{Color=c}) end end

                local function ClosePicker()
                    if not pickerFrame then return end
                    Tw(pickerFrame,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.15)
                    local pf=pickerFrame; task.delay(.16,function() pcall(function() pf:Destroy() end) end)
                    pickerFrame=nil;pickerOpen=false
                    if outsideConn then outsideConn:Disconnect();outsideConn=nil end
                end

                preview.MouseButton1Click:Connect(function()
                    if pickerOpen then ClosePicker();return end
                    pickerOpen=true
                    local PW,PH=210,185
                    local pf=N("Frame",{Size=UDim2.new(0,0,0,0),BackgroundColor3=T.Elevated,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=600,ClipsDescendants=true},win.Overlay)
                    Cn(9,pf);St(T.BorderLight,1,pf);Shadow(pf,600);pickerFrame=pf

                    task.defer(function()
                        local rp=row.AbsolutePosition;local rs=row.AbsoluteSize
                        pf.Position=UDim2.new(0,rp.X+rs.X-PW-4,0,rp.Y+rs.Y+6)
                        Tw(pf,{Size=UDim2.new(0,PW,0,PH),BackgroundTransparency=0},.25,Enum.EasingStyle.Back)
                    end)

                    N("TextLabel",{Text="COLOR  ·  "..eName,Size=UDim2.new(1,-14,0,22),Position=UDim2.new(0,8,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},pf)

                    local svS=140
                    local svF=N("Frame",{Size=UDim2.new(0,svS,0,svS),Position=UDim2.new(0,8,0,28),BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=601,ClipsDescendants=true},pf);Cn(5,svF)
                    N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},svF)
                    N("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},svF:FindFirstChild("Frame"))
                    local blk=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=603},svF)
                    N("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90},blk)
                    local svCur=N("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(s,-5,1-v,-5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=605},svF)
                    Cn(5,svCur);St(Color3.new(1,1,1),2,svCur)

                    local hB=N("Frame",{Size=UDim2.new(0,18,0,svS),Position=UDim2.new(0,svS+14,0,28),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=601},pf);Cn(4,hB)
                    N("UIGradient",{Color=ColorSequence.new{
                        ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(.167,Color3.fromHSV(.167,1,1)),
                        ColorSequenceKeypoint.new(.333,Color3.fromHSV(.333,1,1)),ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),
                        ColorSequenceKeypoint.new(.667,Color3.fromHSV(.667,1,1)),ColorSequenceKeypoint.new(.833,Color3.fromHSV(.833,1,1)),
                        ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
                    },Rotation=90},hB)
                    local hCur=N("Frame",{Size=UDim2.new(1,4,0,4),Position=UDim2.new(0,-2,h,-2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},hB);Cn(2,hCur)

                    local svDrag,hueDrag=false,false
                    N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=606},svF).InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
                    N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=602},hB).InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)

                    UIS.InputChanged:Connect(function(i)
                        if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                        if svDrag then
                            s=math.clamp((i.Position.X-svF.AbsolutePosition.X)/svS,0,1)
                            v=1-math.clamp((i.Position.Y-svF.AbsolutePosition.Y)/svS,0,1)
                            svCur.Position=UDim2.new(s,-5,1-v,-5);UpdC()
                        elseif hueDrag then
                            h=math.clamp((i.Position.Y-hB.AbsolutePosition.Y)/svS,0,1)
                            hCur.Position=UDim2.new(0,-2,h,-2)
                            svF.BackgroundColor3=Color3.fromHSV(h,1,1);UpdC()
                        end
                    end)
                    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false;hueDrag=false end end)

                    local ready=false;task.delay(.3,function() ready=true end)
                    outsideConn=UIS.InputBegan:Connect(function(inp)
                        if not ready or svDrag or hueDrag then return end
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                            task.defer(function() if pf and pf.Parent and IsOutside(inp.Position,pf) then ClosePicker() end end)
                        end
                    end)
                end)

                elem._row=row
                function elem:set_value(c) h,s,v=Color3.toHSV(c);Library.Flags[flag].Color=c;preview.BackgroundColor3=c end

            -- ═════════════════════════════════
            --  LABEL
            -- ═════════════════════════════════
            elseif eType=="Label" then
                local row=Row(0);row.AutomaticSize=Enum.AutomaticSize.Y
                local lbl=N("TextLabel",{Text=eName,Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=9},row)
                N("Frame",{Size=UDim2.new(1,0,0,6),BackgroundTransparency=1},row)
                elem._row=row; function elem:set_text(t) lbl.Text=t end

            -- ═════════════════════════════════
            --  SEPARATOR
            -- ═════════════════════════════════
            elseif eType=="Separator" then
                local row=Row(18)
                N("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,.5,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},row)
                if eName and eName~="" then
                    N("TextLabel",{Text=" "..eName.." ",Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.new(.5,0,.5,-6),BackgroundColor3=T.Card,TextColor3=T.TextMut,TextSize=9,Font=Enum.Font.Gotham,BorderSizePixel=0,ZIndex=10},row)
                end
                elem._row=row
            end

            Library.Elements[flag]=elem; table.insert(section.Elements,elem)
            return elem
        end

        table.insert(tab.Sections,section); return section
    end

    return tab
end

-- ═══════════════════════════════════════════════════════════
--  TAB SWITCHING (with animation)
-- ═══════════════════════════════════════════════════════════
function Library:SelectTab(target)
    for _,t in ipairs(self.Tabs) do
        t.Active=false; t.Page.Visible=false; t.SubContainer.Visible=false
        Tw(t.IconBtn,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.15)
        Tw(t.IconLabel,{TextColor3=T.TextMut},.15)
        Tw(t.Indicator,{BackgroundColor3=T.TextMut,Size=UDim2.new(0,3,0,0)},.15)
    end
    target.Active=true; target.Page.Visible=true; target.SubContainer.Visible=true
    Tw(target.IconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Active},.15)
    Tw(target.IconLabel,{TextColor3=T.Accent},.15)
    Tw(target.Indicator,{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,0,20)},.2,Enum.EasingStyle.Back)

    -- Stagger animate section cards
    for i,sec in ipairs(target.Sections) do
        if sec.Frame then
            sec.Frame.Position=UDim2.new(0,0,0,8)
            sec.Frame.BackgroundTransparency=.5
            task.delay(i*.04,function()
                Tw(sec.Frame,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0},.3,Enum.EasingStyle.Quint)
            end)
        end
    end

    self.ActiveTab=target; self:_closePopups()
end

-- ═══════════════════════════════════════════════════════════
--  POPUPS
-- ═══════════════════════════════════════════════════════════
function Library:_closePopups()
    if self._popup then pcall(function() self._popup:Destroy() end);self._popup=nil;self._popupElem=nil end
    if self._dropdown then pcall(function() self._dropdown:Destroy() end);self._dropdown=nil end
end

function Library:_openKeybindPopup(elem,anchor)
    if self._popup then
        local was=self._popupElem==elem; self:_closePopups()
        if was then return end
    end
    self._popupElem=elem

    local popup=N("Frame",{Size=UDim2.new(0,195,0,148),BackgroundColor3=T.Elevated,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=600},self.Overlay)
    Cn(9,popup);St(T.BorderLight,1,popup);Shadow(popup,600);self._popup=popup

    task.defer(function()
        local ap=anchor.AbsolutePosition;local as=anchor.AbsoluteSize
        popup.Position=UDim2.new(0,math.clamp(ap.X-195+as.X+4,0,1000),0,ap.Y+as.Y+8)
        Tw(popup,{BackgroundTransparency=0},.2,Enum.EasingStyle.Back)
    end)

    N("TextLabel",{Text="KEYBIND  ·  "..elem.Name,Size=UDim2.new(1,-18,0,22),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},popup)

    local keyStr=elem._keybind and KeyName(elem._keybind) or "None"
    local keyBtn=N("TextButton",{Text=keyStr,Size=UDim2.new(1,-18,0,28),Position=UDim2.new(0,9,0,28),BackgroundColor3=T.Panel,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=601},popup)
    Cn(6,keyBtn);St(T.Border,1,keyBtn)

    local listening=false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end;listening=true;keyBtn.Text="Press a key...";keyBtn.TextColor3=T.Accent;Tw(keyBtn,{BackgroundColor3=T.Hover},.1)
        local conn;conn=UIS.InputBegan:Connect(function(inp,gpe) if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                elem._keybind=inp.KeyCode;keyBtn.Text=KeyName(inp.KeyCode);keyBtn.TextColor3=T.Text
                Tw(keyBtn,{BackgroundColor3=T.Panel},.1);listening=false;conn:Disconnect()
            end
        end)
    end)
    keyBtn.MouseEnter:Connect(function() Tw(keyBtn,{BackgroundColor3=T.Hover},.1) end)
    keyBtn.MouseLeave:Connect(function() if not listening then Tw(keyBtn,{BackgroundColor3=T.Panel},.1) end end)

    N("TextButton",{Text="Clear",Size=UDim2.new(0,45,0,18),Position=UDim2.new(1,-54,0,33),BackgroundTransparency=1,TextColor3=T.Danger,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=602},popup).MouseButton1Click:Connect(function()
        elem._keybind=nil;keyBtn.Text="None";keyBtn.TextColor3=T.TextSub
    end)

    N("TextLabel",{Text="MODE",Size=UDim2.new(1,-18,0,14),Position=UDim2.new(0,10,0,66),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},popup)

    local mT=N("Frame",{Size=UDim2.new(1,-18,0,30),Position=UDim2.new(0,9,0,82),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=601},popup);Cn(7,mT)

    local function MB(label,xOff,active)
        local mb=N("TextButton",{Text=label,Size=UDim2.new(.5,-3,1,-4),Position=UDim2.new(xOff,xOff==0 and 2 or 1,0,2),BackgroundColor3=active and T.Accent or T.Panel,TextColor3=active and Color3.new(1,1,1) or T.TextSub,TextSize=10,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=602},mT);Cn(5,mb);return mb
    end
    local tB=MB("Toggle",0,elem._keybindMode=="Toggle")
    local hB=MB("Hold",.5,elem._keybindMode=="Hold")

    local function SM(m) elem._keybindMode=m
        Tw(tB,{BackgroundColor3=m=="Toggle" and T.Accent or T.Panel},.12);tB.TextColor3=m=="Toggle" and Color3.new(1,1,1) or T.TextSub
        Tw(hB,{BackgroundColor3=m=="Hold" and T.Accent or T.Panel},.12);hB.TextColor3=m=="Hold" and Color3.new(1,1,1) or T.TextSub
    end
    tB.MouseButton1Click:Connect(function() SM("Toggle") end)
    hB.MouseButton1Click:Connect(function() SM("Hold") end)

    local ready=false;task.delay(.25,function() ready=true end)
    local oc;oc=UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function() if popup and popup.Parent and IsOutside(inp.Position,popup) then self:_closePopups();oc:Disconnect() end end)
        end
    end)
end

function Library:_openDropdown(options,anchor,setFn,onClose)
    if self._dropdown then self._dropdown:Destroy();self._dropdown=nil;if onClose then onClose() end;return end

    local IH,MAX=28,7;local shown=math.min(#options,MAX);local totalH=shown*IH+10
    local dd=N("Frame",{Size=UDim2.new(0,anchor.AbsoluteSize.X,0,0),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=600,ClipsDescendants=true},self.Overlay)
    Cn(7,dd);St(T.BorderLight,1,dd);Shadow(dd,600);self._dropdown=dd

    task.defer(function()
        local ap=anchor.AbsolutePosition;local as=anchor.AbsoluteSize
        dd.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+3)
        Tw(dd,{Size=UDim2.new(0,as.X,0,totalH)},.2,Enum.EasingStyle.Back)
    end)

    local scroll=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,#options*IH+10),ZIndex=601},dd)
    Ls(scroll,1);Pd(4,4,4,4,scroll)

    for idx,opt in ipairs(options) do
        local item=N("TextButton",{Text=opt,Size=UDim2.new(1,0,0,IH),BackgroundColor3=T.Hover,BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,BorderSizePixel=0,ZIndex=602},scroll)
        Cn(5,item);Pd(0,0,8,6,item)

        -- stagger entrance
        item.TextTransparency=1
        task.delay(idx*.02,function() Tw(item,{TextTransparency=0},.15) end)

        item.MouseEnter:Connect(function() Tw(item,{BackgroundTransparency=.7},.08) end)
        item.MouseLeave:Connect(function() Tw(item,{BackgroundTransparency=1},.08) end)
        item.MouseButton1Click:Connect(function()
            setFn(opt,false)
            Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.15)
            task.delay(.16,function() if dd and dd.Parent then dd:Destroy() end;self._dropdown=nil end)
        end)
    end

    local ready=false;task.delay(.15,function() ready=true end)
    local oc;oc=UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not dd or not dd.Parent then oc:Disconnect();return end
                if IsOutside(inp.Position,dd) then
                    Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.12)
                    task.delay(.13,function() if dd and dd.Parent then dd:Destroy() end;self._dropdown=nil;if onClose then onClose() end end)
                    oc:Disconnect()
                end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════════════
function Library:Toggle() self:SetOpen(not self.Open) end

function Library:SetOpen(state)
    self.Open=state
    if state then
        self.Main.Visible=true
        self.Main.Size=UDim2.new(0,self._fullSize.X.Offset*.9,0,self._fullSize.Y.Offset*.9)
        self.Main.BackgroundTransparency=.2
        Tw(self.Main,{Size=self._fullSize,BackgroundTransparency=0},.35,Enum.EasingStyle.Back)
        Tw(self._blur,{Size=6},.4)
    else
        Tw(self.Main,{Size=UDim2.new(0,self._fullSize.X.Offset*.9,0,self._fullSize.Y.Offset*.9),BackgroundTransparency=.3},.2)
        Tw(self._blur,{Size=0},.25)
        task.delay(.21,function() if not self.Open then self.Main.Visible=false end end)
    end
end

function Library:Destroy()
    pcall(function() self._blur:Destroy() end)
    pcall(function() self.Gui:Destroy() end)
end

function Library:SaveConfig(name)
    pcall(function()
        local data={}
        for flag,val in pairs(Library.Flags) do
            local copy={}
            for k,v in pairs(val) do
                if typeof(v)=="Color3" then copy[k]={R=v.R,G=v.G,B=v.B,_c3=true} else copy[k]=v end
            end; data[flag]=copy
        end
        pcall(makefolder,"NexUI_configs")
        writefile("NexUI_configs/"..name..".json",Http:JSONEncode(data))
    end)
end

function Library:LoadConfig(name)
    pcall(function()
        local raw=readfile("NexUI_configs/"..name..".json")
        local data=Http:JSONDecode(raw)
        for flag,val in pairs(data) do
            for k,v in pairs(val) do if type(v)=="table" and v._c3 then val[k]=Color3.new(v.R,v.G,v.B) end end
            Library.Flags[flag]=val
            local elem=Library.Elements[flag]
            if elem and elem._setValue then
                if elem.Type=="Toggle" then pcall(elem._setValue,val.Toggle,true) end
                if elem.Type=="Slider" then pcall(elem._setValue,val.Slider,true) end
                if elem.Type=="Dropdown" then pcall(elem._setValue,val.Dropdown,true) end
                if elem.Type=="ColorPicker" then pcall(elem.set_value,elem,val.Color) end
            end
        end
    end)
end

function Library:ListConfigs()
    local out={}
    pcall(function() pcall(makefolder,"NexUI_configs")
        for _,f in next,listfiles("NexUI_configs") do
            table.insert(out,f:gsub("NexUI_configs/",""):gsub("NexUI_configs\\",""):gsub("%.json$",""))
        end
    end); return out
end

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION (sequential animated)
-- ═══════════════════════════════════════════════════════════
Library._notifHolder=nil

function Library:Notify(title,desc,duration,nType)
    if not Library._notifHolder or not Library._notifHolder.Parent then
        local ng=N("ScreenGui",{Name="__NexUI_N",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=2000})
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(ng);ng.Parent=game.CoreGui
            elseif gethui then ng.Parent=gethui()
            else ng.Parent=LP:WaitForChild("PlayerGui") end
        end)
        Library._notifHolder=N("Frame",{Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-315,0,0),BackgroundTransparency=1,BorderSizePixel=0},ng)
        local hl=Ls(Library._notifHolder,8);hl.VerticalAlignment=Enum.VerticalAlignment.Bottom
        Pd(12,12,0,0,Library._notifHolder)
    end

    duration=duration or 4; nType=nType or "info"
    local accent=({info=T.Accent,success=T.Success,warning=T.Warning,error=T.Danger})[nType] or T.Accent

    local wrapper=N("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true},Library._notifHolder)

    local nf=N("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.new(1.2,0,0,0),
        BackgroundColor3=T.Panel,BorderSizePixel=0,BackgroundTransparency=.3,
        ZIndex=10,ClipsDescendants=true,
    },wrapper)
    Cn(10,nf);St(T.Border,1,nf)

    -- Accent bar
    N("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=11},nf)

    local inner=N("Frame",{Size=UDim2.new(1,-3,0,0),Position=UDim2.new(0,3,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},nf)
    Ls(inner,3);Pd(10,12,10,10,inner)

    -- Title row
    local titleRow=N("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=12,LayoutOrder=1},inner)
    local dot=N("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,0,0.5,-3),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=13},titleRow);Cn(3,dot)
    local tLbl=N("TextLabel",{Text=title or "Notification",Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,ZIndex=13},titleRow)

    local dLbl
    if desc and desc~="" then
        dLbl=N("TextLabel",{Text=desc,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTransparency=1,ZIndex=12,LayoutOrder=2},inner)
    end

    N("Frame",{Size=UDim2.new(1,0,0,5),BackgroundTransparency=1,LayoutOrder=3},inner)
    local pC=N("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=12,LayoutOrder=4},inner);Cn(1,pC)
    local pF=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=13},pC);Cn(1,pF)

    -- ═ ENTRY ANIMATION ═
    task.defer(function() Tw(nf,{Position=UDim2.new(0,0,0,0)},.5,Enum.EasingStyle.Quint) end)
    task.delay(.08,function() Tw(nf,{BackgroundTransparency=0},.35) end)
    task.delay(.12,function()
        Tw(dot,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,-1,0.5,-4)},.12)
        task.delay(.12,function() Tw(dot,{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,0,0.5,-3)},.12) end)
    end)
    task.delay(.18,function() Tw(tLbl,{TextTransparency=0},.3,Enum.EasingStyle.Quint) end)
    task.delay(.26,function() if dLbl then Tw(dLbl,{TextTransparency=.1},.3,Enum.EasingStyle.Quint) end end)
    task.delay(.35,function() Tw(pF,{Size=UDim2.new(0,0,1,0)},duration-.5,Enum.EasingStyle.Linear) end)

    -- ═ EXIT ANIMATION ═
    task.delay(duration,function()
        Tw(tLbl,{TextTransparency=.5},.2)
        if dLbl then Tw(dLbl,{TextTransparency=.6},.2) end
        Tw(dot,{BackgroundTransparency=.5},.2)
        task.delay(.1,function() Tw(nf,{BackgroundTransparency=.4},.25) end)
        task.delay(.15,function() Tw(nf,{Position=UDim2.new(1.3,0,0,0)},.5,Enum.EasingStyle.Quint,Enum.EasingDirection.In) end)
        task.delay(.7,function() pcall(function() wrapper:Destroy() end) end)
    end)

    -- Click dismiss
    local dismiss=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=14},nf)
    local dismissed=false
    dismiss.MouseButton1Click:Connect(function()
        if dismissed then return end;dismissed=true
        Tw(nf,{Position=UDim2.new(1.3,0,0,0)},.35,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        task.delay(.4,function() pcall(function() wrapper:Destroy() end) end)
    end)
    dismiss.MouseEnter:Connect(function() if not dismissed then Tw(nf,{BackgroundTransparency=.05},.1) end end)
    dismiss.MouseLeave:Connect(function() if not dismissed then Tw(nf,{BackgroundTransparency=0},.1) end end)
end

-- ═══════════════════════════════════════════════════════════
return Library
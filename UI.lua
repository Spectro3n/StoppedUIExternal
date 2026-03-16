--[[
    ███╗░░██╗███████╗██╗░░██╗██╗░░░██╗██╗
    ████╗░██║██╔════╝╚██╗██╔╝██║░░░██║██║
    ██╔██╗██║█████╗░░░╚███╔╝░██║░░░██║██║
    ██║╚████║██╔══╝░░░██╔██╗░██║░░░██║██║
    ██║░╚███║███████╗██╔╝╚██╗╚██████╔╝██║
    ╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝░╚═════╝░╚═╝
    
    NexUI Library — v4.0  (Full Rewrite)
    
    FIXES v3 → v4:
      1. DRAG: Usa delta puro (estilo Orion). Sem pulo ao arrastar.
      2. POPUPS: Detecção de clique externo usa inp.Position (não GetMouseLocation).
         Popup de keybind NÃO fecha ao clicar Hold/Toggle.
         Color picker NÃO fecha ao interagir com o quadrado SV/hue.
      3. COLOR PICKER: Posicionado ABAIXO da opção. Animação de abrir/fechar.
      4. SECTION: UIListLayout no card evita header sobrepor elementos.
      5. TOPBAR: Sem linhas estranhas saindo do frame. Layout limpo.
      6. NOTIFY: Redesenhado com animações sequenciais, barra de progresso
         interna, ClipsDescendants para accent bar não vazar.
      7. GERAL: Mais animações, melhor organização de ZIndex.
]]

local Library    = {}
Library.__index  = Library
Library.Flags    = {}
Library.Elements = {}
Library.Windows  = {}

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════
local T = {
    BG=Color3.fromRGB(8,8,12),       IconBar=Color3.fromRGB(10,10,15),
    Panel=Color3.fromRGB(14,14,20),   Elevated=Color3.fromRGB(20,20,28),
    Hover=Color3.fromRGB(28,28,38),   Active=Color3.fromRGB(35,35,48),
    Card=Color3.fromRGB(16,16,23),    CardHead=Color3.fromRGB(20,20,28),
    Accent=Color3.fromRGB(45,125,255),AccentHov=Color3.fromRGB(75,150,255),
    AccentDim=Color3.fromRGB(20,65,150),AccentGlow=Color3.fromRGB(35,100,230),
    Text=Color3.fromRGB(230,230,242), TextSub=Color3.fromRGB(135,135,158),
    TextMut=Color3.fromRGB(70,70,90), TextDis=Color3.fromRGB(45,45,60),
    Border=Color3.fromRGB(26,26,36),  BorderLight=Color3.fromRGB(40,40,54),
    Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),
    Danger=Color3.fromRGB(225,55,55),
    ToggleBg=Color3.fromRGB(22,22,30),ToggleKnob=Color3.fromRGB(85,85,105),
    SliderTrack=Color3.fromRGB(20,20,28),SliderFill=Color3.fromRGB(45,125,255),
    SliderKnob=Color3.fromRGB(210,220,255),
}

-- ══════════════════════════════════════════════════════════════
--  UTILITIES
-- ══════════════════════════════════════════════════════════════
local function Tw(o,p,t,s,d)
    pcall(function()
        TweenService:Create(o,TweenInfo.new(t or .15,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play()
    end)
end

local function N(c,p,par)
    local ok,i=pcall(Instance.new,c)
    if not ok then return nil end
    for k,v in pairs(p or {}) do pcall(function() i[k]=v end) end
    if par then i.Parent=par end
    return i
end

local function Cn(r,p) return N("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function St(c,t,p) return N("UIStroke",{Color=c or T.Border,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function Pd(t,b,l,r,p) return N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},p) end
local function Ls(par,gap) return N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap or 0)},par) end

local function AutoCanvas(s)
    local l=s:FindFirstChildOfClass("UIListLayout")
    if not l then return end
    local function u() s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+20) end
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u); task.defer(u)
end

local function Shadow(p,z)
    N("ImageLabel",{Name="_Sh",Size=UDim2.new(1,40,1,40),Position=UDim2.new(0,-20,0,-20),BackgroundTransparency=1,Image="rbxassetid://5554236805",ImageColor3=Color3.new(0,0,0),ImageTransparency=.5,ZIndex=(z or 1)-1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(23,23,277,277)},p)
end

local function KeyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.","") end

-- Detecção de clique fora de um frame (usa inp.Position, NÃO GetMouseLocation)
local function IsOutside(clickPos, frame)
    local pp = frame.AbsolutePosition
    local ps = frame.AbsoluteSize
    return clickPos.X < pp.X or clickPos.X > pp.X+ps.X
        or clickPos.Y < pp.Y or clickPos.Y > pp.Y+ps.Y
end

-- ══════════════════════════════════════════════════════════════
--  WINDOW CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════
function Library.new(title, toggleKey)
    local win = setmetatable({}, Library)
    win.Title      = title or "NexUI"
    win.Tabs       = {}
    win.ActiveTab  = nil
    win.Open       = true
    win.Minimized  = false
    win._popup     = nil
    win._popupElem = nil
    win._dropdown  = nil
    win.ToggleKey  = toggleKey or Enum.KeyCode.RightShift

    local W,H      = 780,490
    local TOPBAR   = 50
    local ICONW    = 48
    local SUBW     = 155

    -- ScreenGui (IgnoreGuiInset=false, padrão)
    local gui = N("ScreenGui",{
        Name="__NexUI_"..math.random(1e4,9e4),
        ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=1000,
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent=game.CoreGui
        elseif gethui then gui.Parent=gethui()
        else gui.Parent=LP:WaitForChild("PlayerGui") end
    end)
    if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end
    win.Gui = gui

    -- Overlay para popups
    win.Overlay = N("Frame",{Name="Ov",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=500},gui)

    -- Main Frame
    local main = N("Frame",{
        Name="W", Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=T.BG, BorderSizePixel=0, ClipsDescendants=true,
    },gui)
    Cn(10,main); Shadow(main,2)
    win.Main = main
    win._fullSize = UDim2.new(0,W,0,H)

    -- ── Top Bar ────────────────────────────────────────────
    local topbar = N("Frame",{
        Name="TB", Size=UDim2.new(1,0,0,TOPBAR),
        BackgroundColor3=T.Panel, BorderSizePixel=0, ZIndex=10,
    },main)
    Cn(10,topbar)
    N("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10},topbar)

    -- Accent line sutil (dentro do topbar, não no main)
    local acLine = N("Frame",{
        Size=UDim2.new(1,-20,0,2), Position=UDim2.new(0,10,0,0),
        BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=15,
    },topbar)
    Cn(1,acLine)
    N("UIGradient",{
        Transparency=NumberSequence.new{
            NumberSequenceKeypoint.new(0,.7),
            NumberSequenceKeypoint.new(.5,0),
            NumberSequenceKeypoint.new(1,.7),
        },
    },acLine)

    -- Divider inferior do topbar
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=11},topbar)

    -- Title
    N("TextLabel",{
        Text=win.Title, Size=UDim2.new(0,180,1,0),
        Position=UDim2.new(0,ICONW+12,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=14,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    },topbar)

    -- Search bar
    local searchFrame = N("Frame",{
        Size=UDim2.new(0,200,0,28), Position=UDim2.new(0.5,-100,0.5,-14),
        BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=14,
    },topbar)
    Cn(7,searchFrame); St(T.Border,1,searchFrame)
    N("TextLabel",{
        Text="🔍", Size=UDim2.new(0,24,1,0), Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=12,
        Font=Enum.Font.Gotham, ZIndex=15,
    },searchFrame)
    local searchBox = N("TextBox",{
        Text="", PlaceholderText="Search...",
        Size=UDim2.new(1,-32,1,0), Position=UDim2.new(0,28,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, PlaceholderColor3=T.TextDis,
        TextSize=11, Font=Enum.Font.Gotham, ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
    },searchFrame)

    -- Avatar (far right)
    local avatar = N("Frame",{
        Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-42,0.5,-16),
        BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=12,
    },topbar)
    Cn(16,avatar); St(T.AccentDim,2,avatar)
    N("TextLabel",{
        Text=string.upper(string.sub(LP.Name,1,1)),
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        TextColor3=Color3.new(1,1,1), TextSize=13,
        Font=Enum.Font.GothamBold, ZIndex=13,
    },avatar)

    -- User info
    N("TextLabel",{
        Text=LP.DisplayName, Size=UDim2.new(0,100,0,14),
        Position=UDim2.new(1,-155,0,10),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=11,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12,
    },topbar)
    N("TextLabel",{
        Text=os.date("%d/%m/%Y"), Size=UDim2.new(0,100,0,12),
        Position=UDim2.new(1,-155,0,26),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=9,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12,
    },topbar)

    -- Close button
    local closeBtn = N("TextButton",{
        Text="✕", Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-191,0.5,-14),
        BackgroundColor3=T.Elevated, TextColor3=T.TextSub, TextSize=12,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false, ZIndex=14,
    },topbar)
    Cn(6,closeBtn)
    closeBtn.MouseEnter:Connect(function() Tw(closeBtn,{BackgroundColor3=T.Danger,TextColor3=Color3.new(1,1,1)},.1) end)
    closeBtn.MouseLeave:Connect(function() Tw(closeBtn,{BackgroundColor3=T.Elevated,TextColor3=T.TextSub},.1) end)
    closeBtn.MouseButton1Click:Connect(function() win:SetOpen(false) end)

    -- Minimize button
    local minBtn = N("TextButton",{
        Text="─", Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-223,0.5,-14),
        BackgroundColor3=T.Elevated, TextColor3=T.TextSub, TextSize=14,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false, ZIndex=14,
    },topbar)
    Cn(6,minBtn)
    minBtn.MouseEnter:Connect(function() Tw(minBtn,{BackgroundColor3=T.Warning,TextColor3=T.BG},.1) end)
    minBtn.MouseLeave:Connect(function() Tw(minBtn,{BackgroundColor3=T.Elevated,TextColor3=T.TextSub},.1) end)
    minBtn.MouseButton1Click:Connect(function()
        win.Minimized = not win.Minimized
        Tw(main, {Size = win.Minimized and UDim2.new(0,W,0,TOPBAR+2) or win._fullSize}, .25)
    end)

    -- ── Drag (Delta approach — sem pulo) ───────────────────
    do
        local dragging, dragInput, mouseStart, frameStart = false, nil, nil, nil
        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mouseStart = inp.Position
                frameStart = main.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        topbar.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = inp
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging and mouseStart then
                local d = inp.Position - mouseStart
                main.Position = UDim2.new(
                    frameStart.X.Scale, frameStart.X.Offset + d.X,
                    frameStart.Y.Scale, frameStart.Y.Offset + d.Y
                )
            end
        end)
    end

    -- ── Icon Sidebar ───────────────────────────────────────
    local iconBar = N("Frame",{
        Size=UDim2.new(0,ICONW,1,-TOPBAR), Position=UDim2.new(0,0,0,TOPBAR),
        BackgroundColor3=T.IconBar, BorderSizePixel=0, ZIndex=8,
    },main)
    N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},iconBar)
    local iconScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), ZIndex=9,
    },iconBar)
    Ls(iconScroll,4); Pd(10,10,0,0,iconScroll); AutoCanvas(iconScroll)
    win.IconScroll = iconScroll

    -- ── Sub Sidebar ────────────────────────────────────────
    local subSide = N("Frame",{
        Size=UDim2.new(0,SUBW,1,-TOPBAR), Position=UDim2.new(0,ICONW,0,TOPBAR),
        BackgroundColor3=T.Panel, BorderSizePixel=0, ZIndex=6,
    },main)
    N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=7},subSide)
    local subScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), ZIndex=7,
    },subSide)
    Ls(subScroll,2); Pd(10,10,8,8,subScroll); AutoCanvas(subScroll)
    win.SubScroll = subScroll

    -- ── Content ────────────────────────────────────────────
    local content = N("Frame",{
        Size=UDim2.new(1,-(ICONW+SUBW),1,-TOPBAR),
        Position=UDim2.new(0,ICONW+SUBW,0,TOPBAR),
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=4,
    },main)
    win.Content = content

    -- ── Search Logic ───────────────────────────────────────
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for _,tab in ipairs(win.Tabs) do
            for _,sec in ipairs(tab.Sections) do
                local anyVis = false
                for _,el in ipairs(sec.Elements) do
                    if el._row then
                        local m = q=="" or string.find(string.lower(el.Name),q,1,true)
                        el._row.Visible = m~=nil
                        if m then anyVis=true end
                    end
                end
                if sec.Frame then sec.Frame.Visible = anyVis or q=="" end
                if sec._subEntry then sec._subEntry.Visible = anyVis or q=="" end
            end
        end
    end)

    -- ── Global keybind ─────────────────────────────────────
    UIS.InputBegan:Connect(function(inp, gpe)
        if inp.KeyCode == win.ToggleKey and not gpe then
            win:SetOpen(not win.Open); return
        end
        if gpe or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode == elem._keybind then
                if elem._keybindMode=="Toggle" and elem.Type=="Toggle" and elem._setValue then
                    elem._setValue(not (Library.Flags[flag] and Library.Flags[flag].Toggle or false))
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

    table.insert(Library.Windows, win)
    return win
end

-- ══════════════════════════════════════════════════════════════
--  TAB
-- ══════════════════════════════════════════════════════════════
function Library:new_tab(name, icon)
    local win = self
    icon = icon or string.upper(string.sub(name,1,1))
    local tab = {Name=name, Icon=icon, Sections={}, Active=false}

    local iconBtn = N("TextButton",{
        Name=name, Text="", Size=UDim2.new(1,0,0,42),
        BackgroundColor3=T.IconBar, BackgroundTransparency=.5,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=10,
    },win.IconScroll)
    Cn(8,iconBtn)
    tab.IconBtn = iconBtn

    local indicator = N("Frame",{
        Size=UDim2.new(0,3,0,18), Position=UDim2.new(0,2,.5,-9),
        BackgroundColor3=T.TextMut, BorderSizePixel=0, ZIndex=11,
    },iconBtn)
    Cn(2,indicator); tab.Indicator = indicator

    local iconLbl = N("TextLabel",{
        Text=icon, Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, TextColor3=T.TextMut,
        TextSize=16, Font=Enum.Font.GothamBold, ZIndex=11,
    },iconBtn)
    tab.IconLabel = iconLbl

    -- Tooltip
    local tooltip = N("TextLabel",{
        Text=" "..name.." ", Size=UDim2.new(0,0,0,22),
        AutomaticSize=Enum.AutomaticSize.X,
        Position=UDim2.new(1,8,.5,-11),
        BackgroundColor3=T.Elevated, TextColor3=T.Text,
        TextSize=11, Font=Enum.Font.Gotham, BorderSizePixel=0,
        Visible=false, ZIndex=900,
    },iconBtn)
    Cn(5,tooltip); St(T.BorderLight,1,tooltip)

    iconBtn.MouseEnter:Connect(function()
        tooltip.Visible=true
        if not tab.Active then
            Tw(iconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.1)
            Tw(iconLbl,{TextColor3=T.TextSub},.1)
        end
    end)
    iconBtn.MouseLeave:Connect(function()
        tooltip.Visible=false
        if not tab.Active then
            Tw(iconBtn,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.1)
            Tw(iconLbl,{TextColor3=T.TextMut},.1)
        end
    end)
    iconBtn.MouseButton1Click:Connect(function() win:SelectTab(tab) end)

    -- Sub sidebar container
    local subContainer = N("Frame",{
        Name=name.."_sub", Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=7,
    },win.SubScroll)
    Ls(subContainer,2); tab.SubContainer = subContainer

    N("TextLabel",{
        Text=string.upper(name), Size=UDim2.new(1,0,0,28),
        BackgroundTransparency=1, TextColor3=T.TextMut,
        TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
    },subContainer)

    -- Content page
    local page = N("ScrollingFrame",{
        Name=name.."_pg", Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0), Visible=false, ZIndex=5,
    },win.Content)
    Ls(page,10); Pd(12,14,12,14,page); AutoCanvas(page)
    tab.Page = page

    table.insert(win.Tabs, tab)
    if #win.Tabs==1 then win:SelectTab(tab) end

    -- ════════════════════════════════════════════════════════
    --  SECTION
    -- ════════════════════════════════════════════════════════
    function tab:new_section(sectionName)
        local section = {Name=sectionName, Elements={}}

        -- Sub entry
        local subEntry = N("TextButton",{
            Name=sectionName, Text="", Size=UDim2.new(1,0,0,28),
            BackgroundColor3=T.Panel, BackgroundTransparency=.5,
            BorderSizePixel=0, AutoButtonColor=false, ZIndex=8,
        },subContainer)
        Cn(6,subEntry); section._subEntry = subEntry

        local diamond = N("TextLabel",{
            Text="◆", Size=UDim2.new(0,16,1,0), Position=UDim2.new(0,4,0,0),
            BackgroundTransparency=1, TextColor3=T.TextMut,
            TextSize=7, Font=Enum.Font.GothamBold, ZIndex=9,
        },subEntry)
        local subLbl = N("TextLabel",{
            Text=sectionName, Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,20,0,0),
            BackgroundTransparency=1, TextColor3=T.TextSub,
            TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
        },subEntry)

        subEntry.MouseEnter:Connect(function() Tw(subEntry,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.1) end)
        subEntry.MouseLeave:Connect(function() Tw(subEntry,{BackgroundTransparency=.5,BackgroundColor3=T.Panel},.1) end)
        subEntry.MouseButton1Click:Connect(function()
            task.defer(function()
                if section.Frame then
                    local targetY = section.Frame.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
                    TweenService:Create(page,TweenInfo.new(.35,Enum.EasingStyle.Quart),{CanvasPosition=Vector2.new(0,math.max(0,targetY-6))}):Play()
                end
            end)
            Tw(diamond,{TextColor3=T.Accent},.15); Tw(subLbl,{TextColor3=T.Text},.15)
            task.delay(.8,function() Tw(diamond,{TextColor3=T.TextMut},.3); Tw(subLbl,{TextColor3=T.TextSub},.3) end)
        end)

        -- Card com UIListLayout (header + elements sem sobreposição)
        local card = N("Frame",{
            Name=sectionName, Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=T.Card, BorderSizePixel=0, ZIndex=6,
        },page)
        Cn(9,card); St(T.Border,1,card); Ls(card,0)
        section.Frame = card

        -- Header
        local header = N("Frame",{
            Size=UDim2.new(1,0,0,38), BackgroundColor3=T.CardHead,
            BorderSizePixel=0, ZIndex=7, LayoutOrder=1,
        },card)
        Cn(9,header)
        N("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.CardHead,BorderSizePixel=0,ZIndex=7},header)
        N("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=8},header)

        local pill = N("Frame",{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,10,.5,-7),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=8},header)
        Cn(2,pill)
        N("TextLabel",{
            Text=string.upper(sectionName), Size=UDim2.new(1,-28,1,0),
            Position=UDim2.new(0,20,0,0), BackgroundTransparency=1,
            TextColor3=T.TextSub, TextSize=10, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
        },header)

        -- Elements container
        local ec = N("Frame",{
            Name="El", Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, BorderSizePixel=0, ZIndex=7, LayoutOrder=2,
        },card)
        Ls(ec,1); Pd(6,8,8,8,ec)
        section.Container = ec

        -- ════════════════════════════════════════════════════
        --  ELEMENTS
        -- ════════════════════════════════════════════════════
        function section:element(eType, eName, options, callback)
            options  = options  or {}
            callback = callback or function() end
            local flag = sectionName.."_"..eName
            local elem = {
                Type=eType, Name=eName, Flag=flag,
                _keybind=nil, _keybindMode="Toggle", _hasKeybind=false,
                _setValue=nil, _getValue=nil, _callback=callback,
            }

            local function Row(h)
                local f = N("Frame",{
                    Size=UDim2.new(1,0,0,h or 36),
                    BackgroundColor3=T.BG, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=7,
                },ec); Cn(6,f); return f
            end

            -- ══════════════════════════════════════════
            --  TOGGLE
            -- ══════════════════════════════════════════
            if eType=="Toggle" then
                Library.Flags[flag] = {Toggle=false, Active=false}
                local row = Row(38)

                local hoverBg = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Hover,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7},row)
                Cn(6,hoverBg)

                N("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-85,1,0), Position=UDim2.new(0,12,0,0),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local sw = N("Frame",{
                    Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-48,.5,-10),
                    BackgroundColor3=T.ToggleBg, BorderSizePixel=0, ZIndex=9,
                },row)
                Cn(10,sw); St(T.BorderLight,1,sw)

                local glow = N("Frame",{
                    Size=UDim2.new(0,46,0,28), Position=UDim2.new(1,-52,.5,-14),
                    BackgroundColor3=T.AccentGlow, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=8,
                },row); Cn(14,glow)

                local knob = N("Frame",{
                    Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,3,.5,-7),
                    BackgroundColor3=T.ToggleKnob, BorderSizePixel=0, ZIndex=10,
                },sw); Cn(7,knob)

                -- Gear (ZIndex=13, ACIMA do click overlay ZIndex=11)
                local gear = N("TextButton",{
                    Text="⚙", Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-76,.5,-11),
                    BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=14,
                    Font=Enum.Font.GothamBold, ZIndex=13, Visible=false,
                },row)

                local toggled = false
                local function SetToggle(val, silent)
                    toggled = val
                    Library.Flags[flag].Toggle = val; Library.Flags[flag].Active = val
                    if val then
                        Tw(sw,{BackgroundColor3=T.Accent},.2)
                        Tw(knob,{Position=UDim2.new(0,21,.5,-7),BackgroundColor3=Color3.new(1,1,1)},.2)
                        Tw(glow,{BackgroundTransparency=.82},.3)
                    else
                        Tw(sw,{BackgroundColor3=T.ToggleBg},.2)
                        Tw(knob,{Position=UDim2.new(0,3,.5,-7),BackgroundColor3=T.ToggleKnob},.2)
                        Tw(glow,{BackgroundTransparency=1},.2)
                    end
                    if not silent then pcall(callback,{Toggle=val}) end
                end
                elem._setValue = SetToggle
                elem._getValue = function() return toggled end

                local click = N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},row)
                click.MouseButton1Click:Connect(function() SetToggle(not toggled) end)
                click.MouseEnter:Connect(function() Tw(hoverBg,{BackgroundTransparency=.92},.1) end)
                click.MouseLeave:Connect(function() Tw(hoverBg,{BackgroundTransparency=1},.1) end)
                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem, gear) end)

                elem._gear=gear; elem._row=row
                function elem:add_keybind() self._hasKeybind=true; gear.Visible=true; return self end
                function elem:set_value(v) SetToggle(v,false) end

            -- ══════════════════════════════════════════
            --  SLIDER
            -- ══════════════════════════════════════════
            elseif eType=="Slider" then
                local cfg=options.default or {}
                local vMin,vMax,vDef,vDec = cfg.min or 0, cfg.max or 100, cfg.default or (cfg.min or 0), cfg.decimals or 0
                Library.Flags[flag] = {Slider=vDef}
                local row = Row(52)

                N("TextLabel",{
                    Text=eName, Size=UDim2.new(.6,0,0,22), Position=UDim2.new(0,12,0,4),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)
                local valLbl = N("TextLabel",{
                    Text=(vDec>0 and string.format("%."..vDec.."f",vDef) or tostring(vDef)),
                    Size=UDim2.new(.4,-12,0,22), Position=UDim2.new(.6,0,0,4),
                    BackgroundTransparency=1, TextColor3=T.Accent, TextSize=12,
                    Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=9,
                },row)

                local track = N("Frame",{
                    Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,0,36),
                    BackgroundColor3=T.SliderTrack, BorderSizePixel=0, ZIndex=9, ClipsDescendants=true,
                },row); Cn(3,track)

                local fill = N("Frame",{
                    Size=UDim2.new((vDef-vMin)/(vMax-vMin),0,1,0),
                    BackgroundColor3=T.SliderFill, BorderSizePixel=0, ZIndex=10,
                },track); Cn(3,fill)
                N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.AccentDim),ColorSequenceKeypoint.new(1,T.Accent)}},fill)

                local handle = N("Frame",{Size=UDim2.new(0,14,0,14),BackgroundColor3=T.SliderKnob,BorderSizePixel=0,ZIndex=11},row)
                Cn(7,handle); St(T.Accent,2,handle)

                local function Fmt(v) return vDec>0 and string.format("%."..vDec.."f",v) or tostring(math.floor(v+.5)) end
                local function PosHandle()
                    local pct=(Library.Flags[flag].Slider-vMin)/(vMax-vMin)
                    local tx,tw=track.AbsolutePosition.X,track.AbsoluteSize.X
                    handle.Position=UDim2.new(0,tx-row.AbsolutePosition.X+pct*tw-7,0,30)
                end
                local function SetSlider(v,silent)
                    local f=10^vDec; local r=math.clamp(math.floor(v*f+.5)/f,vMin,vMax)
                    Library.Flags[flag].Slider=r
                    fill.Size=UDim2.new((r-vMin)/(vMax-vMin),0,1,0)
                    valLbl.Text=Fmt(r); PosHandle()
                    if not silent then pcall(callback,{Slider=r}) end
                end
                elem._setValue=SetSlider; elem._getValue=function() return Library.Flags[flag].Slider end
                task.defer(PosHandle)

                local draggingS=false
                local function Upd(inp) local rel=inp.Position.X-track.AbsolutePosition.X; SetSlider(vMin+math.clamp(rel/math.max(track.AbsoluteSize.X,1),0,1)*(vMax-vMin)) end
                local tc=N("TextButton",{Text="",Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,ZIndex=12},row)
                tc.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingS=true;Upd(i) end end)
                UIS.InputChanged:Connect(function(i) if draggingS and i.UserInputType==Enum.UserInputType.MouseMovement then Upd(i) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingS=false end end)
                elem._row=row
                function elem:set_value(v) SetSlider(v) end

            -- ══════════════════════════════════════════
            --  DROPDOWN
            -- ══════════════════════════════════════════
            elseif eType=="Dropdown" then
                local opts=options.options or {"Option"}
                local defOpt=options.default or opts[1]
                Library.Flags[flag]={Dropdown=defOpt}
                local row=Row(58)

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,18),Position=UDim2.new(0,12,0,4),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local dropFrame=N("Frame",{Size=UDim2.new(1,-24,0,30),Position=UDim2.new(0,12,0,22),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=9},row)
                Cn(7,dropFrame); St(T.BorderLight,1,dropFrame)
                local selLbl=N("TextLabel",{Text=defOpt,Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},dropFrame)
                local chevron=N("TextLabel",{Text="▾",Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-24,0,0),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=12,Font=Enum.Font.Gotham,ZIndex=10},dropFrame)

                local function SetDD(v,s) Library.Flags[flag].Dropdown=v; selLbl.Text=v; if not s then pcall(callback,{Dropdown=v}) end end
                elem._setValue=SetDD; elem._getValue=function() return Library.Flags[flag].Dropdown end

                local ca=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},dropFrame)
                ca.MouseButton1Click:Connect(function()
                    Tw(chevron,{Rotation=180},.2)
                    win:_openDropdown(opts,dropFrame,function(v,s) SetDD(v,s); Tw(chevron,{Rotation=0},.2) end,function() Tw(chevron,{Rotation=0},.2) end)
                end)
                ca.MouseEnter:Connect(function() Tw(dropFrame,{BackgroundColor3=T.Hover},.1) end)
                ca.MouseLeave:Connect(function() Tw(dropFrame,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row
                function elem:set_value(v) SetDD(v) end

            -- ══════════════════════════════════════════
            --  COMBO
            -- ══════════════════════════════════════════
            elseif eType=="Combo" then
                local opts=options.options or {}
                local defSel=options.default or {}
                Library.Flags[flag]={Combo={table.unpack(defSel)}}
                local row=Row(0); row.AutomaticSize=Enum.AutomaticSize.Y

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,24),Position=UDim2.new(0,12,0,4),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local checks=N("Frame",{Size=UDim2.new(1,-24,0,0),Position=UDim2.new(0,12,0,28),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},row)
                Ls(checks,4); N("Frame",{Size=UDim2.new(1,0,0,6),BackgroundTransparency=1,LayoutOrder=999},checks)

                for _,opt in ipairs(opts) do
                    local isSel=table.find(defSel,opt)~=nil
                    local cr=N("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},checks)
                    local cb=N("Frame",{Size=UDim2.new(0,15,0,15),Position=UDim2.new(0,2,.5,-7),BackgroundColor3=isSel and T.Accent or T.ToggleBg,BorderSizePixel=0,ZIndex=10},cr)
                    Cn(4,cb); St(T.BorderLight,1,cb)
                    local ck=N("TextLabel",{Text="✓",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=9,Font=Enum.Font.GothamBold,Visible=isSel,ZIndex=11},cb)
                    N("TextLabel",{Text=opt,Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,22,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},cr)
                    local cp=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=12},cr)
                    cp.MouseButton1Click:Connect(function()
                        local cur=Library.Flags[flag].Combo; local idx=table.find(cur,opt)
                        if idx then table.remove(cur,idx); ck.Visible=false; Tw(cb,{BackgroundColor3=T.ToggleBg},.12)
                        else table.insert(cur,opt); ck.Visible=true; Tw(cb,{BackgroundColor3=T.Accent},.12) end
                        pcall(callback,{Combo=cur})
                    end)
                end
                elem._row=row

            -- ══════════════════════════════════════════
            --  BUTTON
            -- ══════════════════════════════════════════
            elseif eType=="Button" then
                local row=Row(40)
                local btn=N("TextButton",{
                    Text=eName, Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,.5,-15),
                    BackgroundColor3=T.Elevated, TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
                    BorderSizePixel=0, AutoButtonColor=false, ZIndex=9, ClipsDescendants=true,
                },row); Cn(7,btn); St(T.BorderLight,1,btn)
                btn.MouseButton1Click:Connect(function()
                    Tw(btn,{BackgroundColor3=T.Accent,TextColor3=Color3.new(1,1,1)},.08)
                    task.delay(.2,function() Tw(btn,{BackgroundColor3=T.Elevated,TextColor3=T.Text},.2) end)
                    pcall(callback,{})
                end)
                btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=T.Hover},.1) end)
                btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row

            -- ══════════════════════════════════════════
            --  TEXTBOX
            -- ══════════════════════════════════════════
            elseif eType=="TextBox" then
                Library.Flags[flag]={Text=options.default or ""}
                local row=Row(58)
                N("TextLabel",{Text=eName,Size=UDim2.new(1,-10,0,18),Position=UDim2.new(0,12,0,4),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local tb=N("TextBox",{
                    Text=options.default or "", PlaceholderText=options.placeholder or "Enter value...",
                    Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,22),
                    BackgroundColor3=T.Elevated, TextColor3=T.Text, PlaceholderColor3=T.TextDis,
                    TextSize=12, Font=Enum.Font.Gotham, ClearTextOnFocus=false, BorderSizePixel=0,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row); Cn(7,tb); local st=St(T.BorderLight,1,tb); Pd(0,0,10,10,tb)

                tb.Focused:Connect(function() Tw(st,{Color=T.Accent},.15); Tw(tb,{BackgroundColor3=T.Hover},.15) end)
                tb.FocusLost:Connect(function(enter)
                    Tw(st,{Color=T.BorderLight},.15); Tw(tb,{BackgroundColor3=T.Elevated},.15)
                    Library.Flags[flag].Text=tb.Text; pcall(callback,{Text=tb.Text,Enter=enter})
                end)
                tb:GetPropertyChangedSignal("Text"):Connect(function() Library.Flags[flag].Text=tb.Text end)
                elem._row=row; elem._tb=tb
                function elem:set_value(v) tb.Text=tostring(v); Library.Flags[flag].Text=tostring(v) end

            -- ══════════════════════════════════════════
            --  COLOR PICKER (posicionado ABAIXO, com animação)
            -- ══════════════════════════════════════════
            elseif eType=="ColorPicker" then
                local defColor=options.default or Color3.fromRGB(255,0,0)
                Library.Flags[flag]={Color=defColor}
                local h,s,v = Color3.toHSV(defColor)
                local row=Row(38)

                N("TextLabel",{Text=eName,Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local preview=N("TextButton",{
                    Text="", Size=UDim2.new(0,28,0,22), Position=UDim2.new(1,-42,.5,-11),
                    BackgroundColor3=defColor, BorderSizePixel=0, AutoButtonColor=false, ZIndex=9,
                },row); Cn(6,preview); St(T.BorderLight,1,preview)

                local pickerOpen,pickerFrame,outsideConn = false,nil,nil

                local function UpdateColor(silent)
                    local c=Color3.fromHSV(h,s,v)
                    Library.Flags[flag].Color=c; preview.BackgroundColor3=c
                    if not silent then pcall(callback,{Color=c}) end
                end

                local function ClosePickerAnim()
                    if not pickerFrame then return end
                    Tw(pickerFrame,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.15)
                    local pf=pickerFrame
                    task.delay(.16,function() pcall(function() pf:Destroy() end) end)
                    pickerFrame=nil; pickerOpen=false
                    if outsideConn then outsideConn:Disconnect(); outsideConn=nil end
                end

                preview.MouseButton1Click:Connect(function()
                    if pickerOpen then ClosePickerAnim(); return end
                    pickerOpen=true

                    local PW,PH = 220,195
                    local pf=N("Frame",{
                        Size=UDim2.new(0,0,0,0), BackgroundColor3=T.Elevated,
                        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=600,
                        ClipsDescendants=true,
                    },win.Overlay)
                    Cn(9,pf); St(T.BorderLight,1,pf); Shadow(pf,600)
                    pickerFrame=pf

                    -- Posicionar ABAIXO da row
                    task.defer(function()
                        local rp=row.AbsolutePosition; local rs=row.AbsoluteSize
                        pf.Position=UDim2.new(0, rp.X+rs.X-PW-4, 0, rp.Y+rs.Y+6)
                        -- Animação de abrir
                        Tw(pf,{Size=UDim2.new(0,PW,0,PH),BackgroundTransparency=0},.2,Enum.EasingStyle.Back)
                    end)

                    N("TextLabel",{
                        Text="COLOR  ·  "..eName, Size=UDim2.new(1,-16,0,24),
                        Position=UDim2.new(0,10,0,4), BackgroundTransparency=1,
                        TextColor3=T.TextSub, TextSize=9, Font=Enum.Font.GothamBold,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
                    },pf)

                    local svS=150
                    local svFrame=N("Frame",{
                        Size=UDim2.new(0,svS,0,svS), Position=UDim2.new(0,10,0,32),
                        BackgroundColor3=Color3.fromHSV(h,1,1), BorderSizePixel=0,
                        ZIndex=601, ClipsDescendants=true,
                    },pf); Cn(5,svFrame)

                    local whOv=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},svFrame)
                    N("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},whOv)
                    local blOv=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=603},svFrame)
                    N("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90},blOv)

                    local svCur=N("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(s,-5,1-v,-5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=605},svFrame)
                    Cn(5,svCur); St(Color3.new(1,1,1),2,svCur)

                    local hueBar=N("Frame",{Size=UDim2.new(0,20,0,svS),Position=UDim2.new(0,svS+16,0,32),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=601},pf)
                    Cn(4,hueBar)
                    N("UIGradient",{Color=ColorSequence.new{
                        ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
                        ColorSequenceKeypoint.new(.167,Color3.fromHSV(.167,1,1)),
                        ColorSequenceKeypoint.new(.333,Color3.fromHSV(.333,1,1)),
                        ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),
                        ColorSequenceKeypoint.new(.667,Color3.fromHSV(.667,1,1)),
                        ColorSequenceKeypoint.new(.833,Color3.fromHSV(.833,1,1)),
                        ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
                    },Rotation=90},hueBar)
                    local hueCur=N("Frame",{Size=UDim2.new(1,4,0,4),Position=UDim2.new(0,-2,h,-2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},hueBar)
                    Cn(2,hueCur)

                    -- SV drag
                    local svDrag=false
                    local svBtn=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=606},svFrame)
                    svBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
                    UIS.InputChanged:Connect(function(i)
                        if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
                            local rx=math.clamp((i.Position.X-svFrame.AbsolutePosition.X)/svS,0,1)
                            local ry=math.clamp((i.Position.Y-svFrame.AbsolutePosition.Y)/svS,0,1)
                            s=rx; v=1-ry; svCur.Position=UDim2.new(s,-5,1-v,-5); UpdateColor()
                        end
                    end)
                    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)

                    -- Hue drag
                    local hueDrag=false
                    local hueBtn=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=602},hueBar)
                    hueBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
                    UIS.InputChanged:Connect(function(i)
                        if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
                            local ry=math.clamp((i.Position.Y-hueBar.AbsolutePosition.Y)/svS,0,1)
                            h=ry; hueCur.Position=UDim2.new(0,-2,h,-2)
                            svFrame.BackgroundColor3=Color3.fromHSV(h,1,1); UpdateColor()
                        end
                    end)
                    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)

                    -- Outside click (usa inp.Position, delay para evitar fechar ao interagir)
                    local ready=false
                    task.delay(.25,function() ready=true end)
                    outsideConn = UIS.InputBegan:Connect(function(inp)
                        if not ready then return end
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                            if svDrag or hueDrag then return end
                            task.defer(function()
                                if not pf or not pf.Parent then return end
                                if IsOutside(inp.Position, pf) then ClosePickerAnim() end
                            end)
                        end
                    end)
                end)

                elem._row=row
                function elem:set_value(c)
                    h,s,v=Color3.toHSV(c); Library.Flags[flag].Color=c; preview.BackgroundColor3=c
                end

            -- ══════════════════════════════════════════
            --  LABEL
            -- ══════════════════════════════════════════
            elseif eType=="Label" then
                local row=Row(0); row.AutomaticSize=Enum.AutomaticSize.Y
                local lbl=N("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-24,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    Position=UDim2.new(0,12,0,8), BackgroundTransparency=1, TextColor3=T.TextSub,
                    TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true, ZIndex=9,
                },row)
                N("Frame",{Size=UDim2.new(1,0,0,8),BackgroundTransparency=1},row)
                elem._row=row
                function elem:set_text(t) lbl.Text=t end

            -- ══════════════════════════════════════════
            --  SEPARATOR
            -- ══════════════════════════════════════════
            elseif eType=="Separator" then
                local row=Row(22)
                N("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,.5,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},row)
                if eName and eName~="" then
                    N("TextLabel",{Text=" "..eName.." ",Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.new(.5,0,.5,-7),BackgroundColor3=T.Card,TextColor3=T.TextMut,TextSize=10,Font=Enum.Font.Gotham,BorderSizePixel=0,ZIndex=10},row)
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

-- ══════════════════════════════════════════════════════════════
--  TAB SWITCHING
-- ══════════════════════════════════════════════════════════════
function Library:SelectTab(target)
    for _,t in ipairs(self.Tabs) do
        t.Active=false; t.Page.Visible=false; t.SubContainer.Visible=false
        Tw(t.IconBtn,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.15)
        Tw(t.IconLabel,{TextColor3=T.TextMut},.15)
        Tw(t.Indicator,{BackgroundColor3=T.TextMut,Size=UDim2.new(0,3,0,18)},.15)
    end
    target.Active=true; target.Page.Visible=true; target.SubContainer.Visible=true
    Tw(target.IconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Active},.15)
    Tw(target.IconLabel,{TextColor3=T.Accent},.15)
    Tw(target.Indicator,{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,0,24)},.15)
    self.ActiveTab=target; self:_closePopups()
end

-- ══════════════════════════════════════════════════════════════
--  POPUP HELPERS
-- ══════════════════════════════════════════════════════════════
function Library:_closePopups()
    if self._popup then pcall(function() self._popup:Destroy() end); self._popup=nil; self._popupElem=nil end
    if self._dropdown then pcall(function() self._dropdown:Destroy() end); self._dropdown=nil end
end

-- ══════════════════════════════════════════════════════════════
--  KEYBIND POPUP (fix: não fecha ao clicar Hold/Toggle)
-- ══════════════════════════════════════════════════════════════
function Library:_openKeybindPopup(elem, anchor)
    if self._popup then
        local wasThis=self._popupElem==elem; self:_closePopups()
        if wasThis then return end
    end
    self._popupElem=elem

    local popup=N("Frame",{
        Size=UDim2.new(0,200,0,155), BackgroundColor3=T.Elevated,
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=600,
    },self.Overlay)
    Cn(9,popup); St(T.BorderLight,1,popup); Shadow(popup,600)
    self._popup=popup

    task.defer(function()
        local ap=anchor.AbsolutePosition; local as=anchor.AbsoluteSize
        popup.Position=UDim2.new(0,math.clamp(ap.X-200+as.X+4,0,1000),0,ap.Y+as.Y+8)
        Tw(popup,{BackgroundTransparency=0},.2)
    end)

    N("TextLabel",{
        Text="KEYBIND  ·  "..elem.Name, Size=UDim2.new(1,-20,0,24),
        Position=UDim2.new(0,12,0,6), BackgroundTransparency=1, TextColor3=T.TextSub,
        TextSize=9, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
    },popup)

    local keyStr=elem._keybind and KeyName(elem._keybind) or "None"
    local keyBtn=N("TextButton",{
        Text=keyStr, Size=UDim2.new(1,-20,0,30), Position=UDim2.new(0,10,0,32),
        BackgroundColor3=T.Panel, TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=601,
    },popup); Cn(6,keyBtn); St(T.Border,1,keyBtn)

    local listening=false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end; listening=true
        keyBtn.Text="Press a key..."; keyBtn.TextColor3=T.Accent; Tw(keyBtn,{BackgroundColor3=T.Hover},.1)
        local conn; conn=UIS.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                elem._keybind=inp.KeyCode; keyBtn.Text=KeyName(inp.KeyCode)
                keyBtn.TextColor3=T.Text; Tw(keyBtn,{BackgroundColor3=T.Panel},.1)
                listening=false; conn:Disconnect()
            end
        end)
    end)
    keyBtn.MouseEnter:Connect(function() Tw(keyBtn,{BackgroundColor3=T.Hover},.1) end)
    keyBtn.MouseLeave:Connect(function() if not listening then Tw(keyBtn,{BackgroundColor3=T.Panel},.1) end end)

    local clearBtn=N("TextButton",{
        Text="Clear", Size=UDim2.new(0,50,0,20), Position=UDim2.new(1,-60,0,37),
        BackgroundTransparency=1, TextColor3=T.Danger, TextSize=10,
        Font=Enum.Font.GothamBold, ZIndex=602,
    },popup)
    clearBtn.MouseButton1Click:Connect(function()
        elem._keybind=nil; keyBtn.Text="None"; keyBtn.TextColor3=T.TextSub
    end)

    N("TextLabel",{
        Text="MODE", Size=UDim2.new(1,-20,0,16), Position=UDim2.new(0,12,0,74),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=9,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
    },popup)

    local mTrack=N("Frame",{
        Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,92),
        BackgroundColor3=T.Panel, BorderSizePixel=0, ZIndex=601,
    },popup); Cn(8,mTrack)

    local function MBtn(label,xOff,active)
        local mb=N("TextButton",{
            Text=label, Size=UDim2.new(.5,-3,1,-4),
            Position=UDim2.new(xOff,xOff==0 and 2 or 1,0,2),
            BackgroundColor3=active and T.Accent or T.Panel,
            TextColor3=active and Color3.new(1,1,1) or T.TextSub,
            TextSize=11, Font=Enum.Font.Gotham, BorderSizePixel=0,
            AutoButtonColor=false, ZIndex=602,
        },mTrack); Cn(6,mb); return mb
    end
    local tBtn=MBtn("Toggle",0,elem._keybindMode=="Toggle")
    local hBtn=MBtn("Hold",.5,elem._keybindMode=="Hold")

    local function SetMode(m)
        elem._keybindMode=m
        Tw(tBtn,{BackgroundColor3=m=="Toggle" and T.Accent or T.Panel},.12)
        tBtn.TextColor3=m=="Toggle" and Color3.new(1,1,1) or T.TextSub
        Tw(hBtn,{BackgroundColor3=m=="Hold" and T.Accent or T.Panel},.12)
        hBtn.TextColor3=m=="Hold" and Color3.new(1,1,1) or T.TextSub
    end
    tBtn.MouseButton1Click:Connect(function() SetMode("Toggle") end)
    hBtn.MouseButton1Click:Connect(function() SetMode("Hold") end)

    -- Outside click com delay + inp.Position
    local ready=false
    task.delay(.2,function() ready=true end)
    local oc; oc=UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not popup or not popup.Parent then oc:Disconnect() return end
                if IsOutside(inp.Position, popup) then
                    self:_closePopups(); oc:Disconnect()
                end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  DROPDOWN POPUP
-- ══════════════════════════════════════════════════════════════
function Library:_openDropdown(options, anchor, setFn, onClose)
    if self._dropdown then
        self._dropdown:Destroy(); self._dropdown=nil
        if onClose then onClose() end; return
    end

    local IH,MAX = 30,7
    local shown=math.min(#options,MAX); local totalH=shown*IH+12

    local dd=N("Frame",{
        Size=UDim2.new(0,anchor.AbsoluteSize.X,0,0),
        BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=600, ClipsDescendants=true,
    },self.Overlay)
    Cn(8,dd); St(T.BorderLight,1,dd); Shadow(dd,600)
    self._dropdown=dd

    task.defer(function()
        local ap=anchor.AbsolutePosition; local as=anchor.AbsoluteSize
        dd.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4)
        Tw(dd,{Size=UDim2.new(0,as.X,0,totalH)},.2)
    end)

    local scroll=N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,#options*IH+12), ZIndex=601,
    },dd)
    Ls(scroll,1); Pd(5,5,5,5,scroll)

    for _,opt in ipairs(options) do
        local item=N("TextButton",{
            Text=opt, Size=UDim2.new(1,0,0,IH),
            BackgroundColor3=T.Hover, BackgroundTransparency=1,
            TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=602,
        },scroll); Cn(5,item); Pd(0,0,10,8,item)
        item.MouseEnter:Connect(function() Tw(item,{BackgroundTransparency=.7},.08) end)
        item.MouseLeave:Connect(function() Tw(item,{BackgroundTransparency=1},.08) end)
        item.MouseButton1Click:Connect(function()
            setFn(opt,false)
            Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.15)
            task.delay(.16,function() if dd and dd.Parent then dd:Destroy() end; self._dropdown=nil end)
        end)
    end

    local ready=false; task.delay(.15,function() ready=true end)
    local oc; oc=UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not dd or not dd.Parent then oc:Disconnect() return end
                if IsOutside(inp.Position, dd) then
                    Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.12)
                    task.delay(.13,function()
                        if dd and dd.Parent then dd:Destroy() end
                        self._dropdown=nil; if onClose then onClose() end
                    end)
                    oc:Disconnect()
                end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  PUBLIC API
-- ══════════════════════════════════════════════════════════════
function Library:Toggle() self.Open=not self.Open; self.Main.Visible=self.Open end

function Library:SetOpen(state)
    self.Open=state
    if state then
        self.Main.Visible=true; self.Main.Size=UDim2.new(0,0,0,0)
        Tw(self.Main,{Size=self._fullSize},.25,Enum.EasingStyle.Back)
    else
        Tw(self.Main,{Size=UDim2.new(0,0,0,0)},.2)
        task.delay(.21,function() if not self.Open then self.Main.Visible=false end end)
    end
end

function Library:Destroy() pcall(function() self.Gui:Destroy() end) end

function Library:SaveConfig(name)
    pcall(function()
        local data={}
        for flag,val in pairs(Library.Flags) do
            local copy={}
            for k,v in pairs(val) do
                if typeof(v)=="Color3" then copy[k]={R=v.R,G=v.G,B=v.B,_c3=true}
                else copy[k]=v end
            end
            data[flag]=copy
        end
        pcall(makefolder,"NexUI_configs")
        writefile("NexUI_configs/"..name..".json",HttpService:JSONEncode(data))
    end)
end

function Library:LoadConfig(name)
    pcall(function()
        local raw=readfile("NexUI_configs/"..name..".json")
        local data=HttpService:JSONDecode(raw)
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
    pcall(function()
        pcall(makefolder,"NexUI_configs")
        for _,f in next,listfiles("NexUI_configs") do
            table.insert(out,f:gsub("NexUI_configs/",""):gsub("NexUI_configs\\",""):gsub("%.json$",""))
        end
    end)
    return out
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION (redesenhado com animações sequenciais)
-- ══════════════════════════════════════════════════════════════
Library._notifHolder = nil

function Library:Notify(title, desc, duration, nType)
    if not Library._notifHolder or not Library._notifHolder.Parent then
        local ng=N("ScreenGui",{
            Name="__NexUI_N", ResetOnSpawn=false,
            ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=2000,
        })
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(ng); ng.Parent=game.CoreGui
            elseif gethui then ng.Parent=gethui()
            else ng.Parent=LP:WaitForChild("PlayerGui") end
        end)
        Library._notifHolder=N("Frame",{
            Size=UDim2.new(0,310,1,0), Position=UDim2.new(1,-325,0,0),
            BackgroundTransparency=1, BorderSizePixel=0,
        },ng)
        local hl=Ls(Library._notifHolder,8)
        hl.VerticalAlignment=Enum.VerticalAlignment.Bottom
        Pd(12,12,0,0,Library._notifHolder)
    end

    duration=duration or 4
    nType=nType or "info"
    local accent=({info=T.Accent,success=T.Success,warning=T.Warning,error=T.Danger})[nType] or T.Accent

    -- Container wrapper (para animação de posição)
    local wrapper=N("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0,
        ClipsDescendants=true,
    },Library._notifHolder)

    -- Card
    local nf=N("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.new(1.2,0,0,0), -- começa fora da tela (direita)
        BackgroundColor3=T.Panel, BorderSizePixel=0,
        BackgroundTransparency=.3, ZIndex=10,
        ClipsDescendants=true, -- accent bar não vaza das bordas arredondadas
    },wrapper)
    Cn(10,nf); St(T.Border,1,nf)

    -- Accent bar esquerda (dentro do ClipsDescendants)
    N("Frame",{
        Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=accent, BorderSizePixel=0, ZIndex=11,
    },nf)

    -- Conteúdo com layout
    local inner=N("Frame",{
        Size=UDim2.new(1,-3,0,0), Position=UDim2.new(0,3,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=11,
    },nf)
    Ls(inner,3); Pd(10,14,12,10,inner)

    -- Dot + título
    local titleRow=N("Frame",{
        Size=UDim2.new(1,0,0,18),         BackgroundTransparency=1, BorderSizePixel=0, ZIndex=12, LayoutOrder=1,
    },inner)

    -- Dot de status
    local dot=N("Frame",{
        Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,0,0.5,-3),
        BackgroundColor3=accent, BorderSizePixel=0, ZIndex=13,
    },titleRow)
    Cn(3,dot)

    -- Título
    local titleLbl=N("TextLabel",{
        Text=title or "Notification",
        Size=UDim2.new(1,-14,1,0), Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
        TextTransparency=1, ZIndex=13,
    },titleRow)

    -- Descrição
    local descLbl
    if desc and desc ~= "" then
        descLbl=N("TextLabel",{
            Text=desc,
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=11,
            Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true, TextTransparency=1, ZIndex=12, LayoutOrder=2,
        },inner)
    end

    -- Spacer para a progress bar
    N("Frame",{
        Size=UDim2.new(1,0,0,6), BackgroundTransparency=1,
        LayoutOrder=3,
    },inner)

    -- Progress bar (dentro do inner, abaixo do texto)
    local progContainer=N("Frame",{
        Size=UDim2.new(1,0,0,3),
        BackgroundColor3=T.Elevated, BorderSizePixel=0,
        ZIndex=12, LayoutOrder=4,
    },inner)
    Cn(2,progContainer)

    local progFill=N("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=accent, BorderSizePixel=0, ZIndex=13,
    },progContainer)
    Cn(2,progFill)

    -- ═══════════════════════════════════════════
    --  ANIMAÇÃO SEQUENCIAL DE ENTRADA
    -- ═══════════════════════════════════════════

    -- 1) Slide in (da direita para a posição)
    task.defer(function()
        Tw(nf, {Position=UDim2.new(0,0,0,0)}, .5, Enum.EasingStyle.Quint)
    end)

    -- 2) Fade in do background (já está .3, levar para 0)
    task.delay(.1, function()
        Tw(nf, {BackgroundTransparency=0}, .4)
    end)

    -- 3) Dot pulsa
    task.delay(.15, function()
        Tw(dot, {Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,-1,0.5,-4)}, .15)
        task.delay(.15, function()
            Tw(dot, {Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,0,0.5,-3)}, .15)
        end)
    end)

    -- 4) Título fade in
    task.delay(.2, function()
        Tw(titleLbl, {TextTransparency=0}, .35, Enum.EasingStyle.Quint)
    end)

    -- 5) Descrição fade in
    task.delay(.3, function()
        if descLbl then
            Tw(descLbl, {TextTransparency=0.1}, .35, Enum.EasingStyle.Quint)
        end
    end)

    -- 6) Progress bar countdown
    task.delay(.4, function()
        Tw(progFill, {Size=UDim2.new(0,0,1,0)}, duration - .6, Enum.EasingStyle.Linear)
    end)

    -- ═══════════════════════════════════════════
    --  ANIMAÇÃO SEQUENCIAL DE SAÍDA
    -- ═══════════════════════════════════════════
    task.delay(duration, function()
        -- Fade out textos
        Tw(titleLbl, {TextTransparency=.5}, .25)
        if descLbl then
            Tw(descLbl, {TextTransparency=.6}, .25)
        end

        -- Dot pisca
        task.delay(.1, function()
            Tw(dot, {BackgroundTransparency=.5}, .2)
        end)

        -- Stroke fade
        local stroke = nf:FindFirstChildOfClass("UIStroke")
        if stroke then
            Tw(stroke, {Transparency=.8}, .3)
        end

        -- Background fade
        task.delay(.15, function()
            Tw(nf, {BackgroundTransparency=.5}, .3)
        end)

        -- Slide out (para a direita)
        task.delay(.2, function()
            Tw(nf, {Position=UDim2.new(1.3,0,0,0)}, .6, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        end)

        -- Destroy
        task.delay(.9, function()
            pcall(function() wrapper:Destroy() end)
        end)
    end)

    -- Click para dispensar manualmente
    local dismissBtn=N("TextButton",{
        Text="", Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, ZIndex=14,
    },nf)
    local dismissed=false
    dismissBtn.MouseButton1Click:Connect(function()
        if dismissed then return end
        dismissed=true
        Tw(nf, {Position=UDim2.new(1.3,0,0,0)}, .4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tw(nf, {BackgroundTransparency=.6}, .3)
        task.delay(.45, function()
            pcall(function() wrapper:Destroy() end)
        end)
    end)

    -- Hover effect
    dismissBtn.MouseEnter:Connect(function()
        if not dismissed then
            Tw(nf, {BackgroundTransparency=.05}, .15)
        end
    end)
    dismissBtn.MouseLeave:Connect(function()
        if not dismissed then
            Tw(nf, {BackgroundTransparency=0}, .15)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
return Library
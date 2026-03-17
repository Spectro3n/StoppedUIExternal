--[[
    ███╗░░██╗███████╗██╗░░██╗██╗░░░██╗██╗
    ████╗░██║██╔════╝╚██╗██╔╝██║░░░██║██║
    ██╔██╗██║█████╗░░░╚███╔╝░██║░░░██║██║
    ██║╚████║██╔══╝░░░██╔██╗░██║░░░██║██║
    ██║░╚███║███████╗██╔╝╚██╗╚██████╔╝██║
    ╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝░╚═════╝░╚═╝
    
    NexUI Library — v5.1
    
    • Two-column section layout (side by side)
    • Active background blur
    • 6 theme presets
    • Fluid micro-animations (spring, stagger, cascade)
    • Animated tab transitions (slide + fade)
    • RightShift to toggle (no close/min buttons)
    
    USAGE:
        local Library = loadstring(...)()
        Library:SetTheme("Midnight")
        local Window = Library.new("Hub")
        local Tab    = Window:new_tab("Combat", "⚔")
        local Left   = Tab:new_section("Aimbot")
        local Right  = Tab:new_section("Settings", "Right")
        Left:element("Toggle", "Enabled", {}, function(s) end):add_keybind()
        Right:element("Slider", "FOV", {default={min=1,max=360,default=90}}, cb)
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
local LP      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  THEMES
-- ═══════════════════════════════════════════════════════════
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
for k,v in pairs(Library.Themes.Default) do T[k]=v end

function Library:SetTheme(name)
    local theme=Library.Themes[name]; if not theme then return end
    Library.CurrentTheme=name
    for k,v in pairs(theme) do T[k]=v end
    for _,e in ipairs(Library._themed) do
        if e[1] and e[1].Parent then
            pcall(function() TS:Create(e[1],TweenInfo.new(.4,Enum.EasingStyle.Quint),{[e[2]]=T[e[3]]}):Play() end)
        end
    end
end

local function Reg(o,p,k) table.insert(Library._themed,{o,p,k}); pcall(function() o[p]=T[k] end); return o end

-- ═══════════════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════════════
local function Tw(o,p,t,s,d) pcall(function() TS:Create(o,TweenInfo.new(t or .15,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play() end) end
local function I(c,p,par) local ok,i=pcall(Instance.new,c); if not ok then return nil end; for k,v in pairs(p or{}) do pcall(function() i[k]=v end) end; if par then i.Parent=par end; return i end
local function Cn(r,p) return I("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function St(c,t,p) return I("UIStroke",{Color=c or T.Border,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function Pd(t,b,l,r,p) return I("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},p) end
local function Ls(par,gap) return I("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap or 0)},par) end
local function Shadow(p,z) I("ImageLabel",{Name="_Sh",Size=UDim2.new(1,48,1,48),Position=UDim2.new(0,-24,0,-24),BackgroundTransparency=1,Image="rbxassetid://5554236805",ImageColor3=Color3.new(0,0,0),ImageTransparency=.4,ZIndex=(z or 1)-1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(23,23,277,277)},p) end
local function KeyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.","") end
local function IsOut(pos,f) local p,s=f.AbsolutePosition,f.AbsoluteSize; return pos.X<p.X or pos.X>p.X+s.X or pos.Y<p.Y or pos.Y>p.Y+s.Y end

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════
function Library.new(title, toggleKey)
    local win=setmetatable({},Library)
    win.Title=title or "NexUI"; win.Tabs={}; win.ActiveTab=nil; win.Open=true
    win._popup=nil; win._popupElem=nil; win._dropdown=nil
    win.ToggleKey=toggleKey or Enum.KeyCode.RightShift

    local W,H=780,490; local TB=46; local IW=46; local SW=150

    local gui=I("ScreenGui",{Name="__NexUI_"..math.random(1e4,9e4),ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000})
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui);gui.Parent=game.CoreGui
        elseif gethui then gui.Parent=gethui()
        else gui.Parent=LP:WaitForChild("PlayerGui") end
    end)
    if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end
    win.Gui=gui

    -- ═══ BLUR (active by default) ═══
    -- Remove any old blur first
    for _,v in ipairs(Light:GetChildren()) do
        if v.Name=="__NexBlur" then v:Destroy() end
    end
    local blur=I("BlurEffect",{Name="__NexBlur",Size=0,Enabled=true},Light)
    win._blur=blur
    -- Animate blur in
    task.defer(function() Tw(blur,{Size=8},.6,Enum.EasingStyle.Quint) end)

    win.Overlay=I("Frame",{Name="Ov",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=500},gui)

    -- Main
    local main=I("Frame",{
        Name="W",Size=UDim2.new(0,W*.88,0,H*.88),
        Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=T.BG,BorderSizePixel=0,ClipsDescendants=true,
        BackgroundTransparency=.4,
    },gui)
    Cn(12,main); Shadow(main,2); Reg(main,"BackgroundColor3","BG")
    win.Main=main; win._fullSize=UDim2.new(0,W,0,H)

    -- ═══ INTRO ANIMATION ═══
    task.defer(function()
        Tw(main,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},.55,Enum.EasingStyle.Back)
    end)

    -- ══ Top Bar ══
    local topbar=I("Frame",{Name="TB",Size=UDim2.new(1,0,0,TB),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10},main)
    Cn(12,topbar); Reg(topbar,"BackgroundColor3","Panel")
    I("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10},topbar)

    -- Accent glow
    local acLine=I("Frame",{Size=UDim2.new(1,-28,0,2),Position=UDim2.new(0,14,0,0),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=15},topbar)
    Cn(1,acLine); Reg(acLine,"BackgroundColor3","Accent")
    I("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(.5,.05),NumberSequenceKeypoint.new(1,.8)}},acLine)

    -- Divider
    I("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=11},topbar)

    -- Title
    I("TextLabel",{Text=win.Title,Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,IW+14,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},topbar)

    -- Search
    local sf=I("Frame",{Size=UDim2.new(0,185,0,26),Position=UDim2.new(.5,-92,.5,-13),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=14},topbar)
    Cn(7,sf); St(T.Border,1,sf)
    I("TextLabel",{Text="🔍",Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=11,Font=Enum.Font.Gotham,ZIndex=15},sf)
    local searchBox=I("TextBox",{Text="",PlaceholderText="Search...",Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,26,0,0),BackgroundTransparency=1,TextColor3=T.Text,PlaceholderColor3=T.TextDis,TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},sf)

    -- Avatar
    local av=I("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,.5,-15),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=12},topbar)
    Cn(15,av); Reg(av,"BackgroundColor3","Accent")
    I("TextLabel",{Text=string.upper(string.sub(LP.Name,1,1)),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=13},av)
    I("TextLabel",{Text=LP.DisplayName,Size=UDim2.new(0,95,0,13),Position=UDim2.new(1,-148,0,9),BackgroundTransparency=1,TextColor3=T.Text,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=12},topbar)
    I("TextLabel",{Text=os.date("%d/%m/%Y"),Size=UDim2.new(0,95,0,11),Position=UDim2.new(1,-148,0,24),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=12},topbar)

    -- ══ Drag ══
    do
        local dragging,dragInput,mStart,fStart=false,nil,nil,nil
        topbar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;mStart=inp.Position;fStart=main.Position; inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
        topbar.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement then dragInput=inp end end)
        UIS.InputChanged:Connect(function(inp) if inp==dragInput and dragging and mStart then local d=inp.Position-mStart; main.Position=UDim2.new(fStart.X.Scale,fStart.X.Offset+d.X,fStart.Y.Scale,fStart.Y.Offset+d.Y) end end)
    end

    -- ══ Icon Sidebar ══
    local iconBar=I("Frame",{Size=UDim2.new(0,IW,1,-TB),Position=UDim2.new(0,0,0,TB),BackgroundColor3=T.IconBar,BorderSizePixel=0,ZIndex=8},main)
    Reg(iconBar,"BackgroundColor3","IconBar")
    I("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},iconBar)
    local iconScroll=I("ScrollingFrame",{Size=UDim2.new(1,-1,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=9},iconBar)
    local iLay=Ls(iconScroll,4); Pd(10,10,0,0,iconScroll)
    iLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() iconScroll.CanvasSize=UDim2.new(0,0,0,iLay.AbsoluteContentSize.Y+20) end)
    win.IconScroll=iconScroll

    -- ══ Sub Sidebar ══
    local subSide=I("Frame",{Size=UDim2.new(0,SW,1,-TB),Position=UDim2.new(0,IW,0,TB),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=6},main)
    Reg(subSide,"BackgroundColor3","Panel")
    I("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=7},subSide)
    local subScroll=I("ScrollingFrame",{Size=UDim2.new(1,-1,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=7},subSide)
    local sLay=Ls(subScroll,2); Pd(10,10,8,8,subScroll)
    sLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() subScroll.CanvasSize=UDim2.new(0,0,0,sLay.AbsoluteContentSize.Y+20) end)
    win.SubScroll=subScroll

    -- ══ Content ══
    local content=I("Frame",{Size=UDim2.new(1,-(IW+SW),1,-TB),Position=UDim2.new(0,IW+SW,0,TB),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,ClipsDescendants=true},main)
    win.Content=content

    -- ══ Search ══
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=string.lower(searchBox.Text)
        for _,tab in ipairs(win.Tabs) do for _,sec in ipairs(tab.Sections) do
            local any=false
            for _,el in ipairs(sec.Elements) do if el._row then local m=q=="" or string.find(string.lower(el.Name),q,1,true); el._row.Visible=m~=nil; if m then any=true end end end
            if sec.Frame then sec.Frame.Visible=any or q=="" end
            if sec._subEntry then sec._subEntry.Visible=any or q=="" end
        end end
    end)

    -- ══ Global Keybinds ══
    UIS.InputBegan:Connect(function(inp,gpe)
        if inp.KeyCode==win.ToggleKey and not gpe then win:SetOpen(not win.Open);return end
        if gpe or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for flag,elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode==elem._keybind then
                if elem._keybindMode=="Toggle" and elem.Type=="Toggle" and elem._setValue then
                    elem._setValue(not(Library.Flags[flag] and Library.Flags[flag].Toggle or false))
                elseif elem._keybindMode=="Hold" and elem.Type=="Toggle" and elem._setValue then elem._setValue(true) end
            end
        end
    end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for flag,elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode==elem._keybind and elem._keybindMode=="Hold" and elem.Type=="Toggle" and elem._setValue then elem._setValue(false) end
        end
    end)

    table.insert(Library.Windows,win); return win
end

-- ═══════════════════════════════════════════════════════════
--  TAB (with two-column content)
-- ═══════════════════════════════════════════════════════════
function Library:new_tab(name, icon)
    local win=self; icon=icon or string.upper(string.sub(name,1,1))
    local tab={Name=name,Icon=icon,Sections={},Active=false}

    -- Icon btn
    local ib=I("TextButton",{Name=name,Text="",Size=UDim2.new(1,0,0,40),BackgroundColor3=T.IconBar,BackgroundTransparency=.5,BorderSizePixel=0,AutoButtonColor=false,ZIndex=10},win.IconScroll)
    Cn(8,ib); tab.IconBtn=ib

    local ind=I("Frame",{Size=UDim2.new(0,3,0,0),Position=UDim2.new(0,2,.5,0),BackgroundColor3=T.TextMut,BorderSizePixel=0,ZIndex=11},ib)
    Cn(2,ind); tab.Indicator=ind

    local il=I("TextLabel",{Text=icon,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=15,Font=Enum.Font.GothamBold,ZIndex=11},ib)
    tab.IconLabel=il

    local tt=I("TextLabel",{Text=" "..name.." ",Size=UDim2.new(0,0,0,22),AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.new(1,8,.5,-11),BackgroundColor3=T.Elevated,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,Visible=false,ZIndex=900},ib)
    Cn(5,tt); St(T.BorderLight,1,tt)

    ib.MouseEnter:Connect(function() tt.Visible=true; if not tab.Active then Tw(ib,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.12); Tw(il,{TextColor3=T.TextSub},.12) end end)
    ib.MouseLeave:Connect(function() tt.Visible=false; if not tab.Active then Tw(ib,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.12); Tw(il,{TextColor3=T.TextMut},.12) end end)
    ib.MouseButton1Click:Connect(function() win:SelectTab(tab) end)

    -- Sub container
    local subC=I("Frame",{Name=name.."_sub",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=7},win.SubScroll)
    Ls(subC,2); tab.SubContainer=subC
    I("TextLabel",{Text=string.upper(name),Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=9,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},subC)

    -- ═══ PAGE WITH TWO COLUMNS (side by side) ═══
    local page=I("ScrollingFrame",{
        Name=name.."_pg",Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=5,
    },win.Content)
    tab.Page=page

    -- Container for both columns (NO UIListLayout — columns positioned manually)
    local colFrame=I("Frame",{
        Name="Columns",
        Size=UDim2.new(1,-20,0,0), -- width = page - padding, height updated dynamically
        Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },page)

    local GAP=10 -- gap between columns

    local leftCol=I("Frame",{
        Name="Left",
        Size=UDim2.new(0.5,-GAP/2,0,0),
        Position=UDim2.new(0,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },colFrame)
    local lLayout=Ls(leftCol,10)

    local rightCol=I("Frame",{
        Name="Right",
        Size=UDim2.new(0.5,-GAP/2,0,0),
        Position=UDim2.new(0.5,GAP/2,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    },colFrame)
    local rLayout=Ls(rightCol,10)

    tab.LeftCol=leftCol; tab.RightCol=rightCol; tab.ColFrame=colFrame

    -- Dynamic canvas update (tallest column)
    local function UpdCanvas()
        local lH=lLayout.AbsoluteContentSize.Y
        local rH=rLayout.AbsoluteContentSize.Y
        local maxH=math.max(lH,rH)
        colFrame.Size=UDim2.new(1,-20,0,maxH)
        page.CanvasSize=UDim2.new(0,0,0,maxH+30)
    end
    lLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas)
    rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas)
    task.defer(UpdCanvas)

    table.insert(win.Tabs,tab)
    if #win.Tabs==1 then win:SelectTab(tab) end

    -- ═══════════════════════════════════════════
    --  SECTION
    -- ═══════════════════════════════════════════
    function tab:new_section(sectionName, side)
        side=side or "Left"
        local targetCol = side=="Right" and rightCol or leftCol
        local section={Name=sectionName,Elements={},Side=side}

        -- Sub sidebar entry
        local subE=I("TextButton",{Name=sectionName,Text="",Size=UDim2.new(1,0,0,26),BackgroundColor3=T.Panel,BackgroundTransparency=.5,BorderSizePixel=0,AutoButtonColor=false,ZIndex=8},subC)
        Cn(5,subE); section._subEntry=subE
        local dm=I("TextLabel",{Text="◆",Size=UDim2.new(0,14,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=6,Font=Enum.Font.GothamBold,ZIndex=9},subE)
        local sl=I("TextLabel",{Text=sectionName,Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},subE)

        subE.MouseEnter:Connect(function() Tw(subE,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.1) end)
        subE.MouseLeave:Connect(function() Tw(subE,{BackgroundTransparency=.5,BackgroundColor3=T.Panel},.1) end)
        subE.MouseButton1Click:Connect(function()
            task.defer(function()
                if section.Frame then
                    local tY=section.Frame.AbsolutePosition.Y-page.AbsolutePosition.Y+page.CanvasPosition.Y
                    TS:Create(page,TweenInfo.new(.4,Enum.EasingStyle.Quint),{CanvasPosition=Vector2.new(0,math.max(0,tY-8))}):Play()
                end
            end)
            Tw(dm,{TextColor3=T.Accent},.15); Tw(sl,{TextColor3=T.Text},.15)
            task.delay(.8,function() Tw(dm,{TextColor3=T.TextMut},.3); Tw(sl,{TextColor3=T.TextSub},.3) end)
        end)

        -- Card
        local card=I("Frame",{
            Name=sectionName,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=6,
        },targetCol)
        Cn(10,card); St(T.Border,1,card); Ls(card,0)
        Reg(card,"BackgroundColor3","Card")
        section.Frame=card

        -- ═══ STAGGERED ENTRANCE ═══
        card.BackgroundTransparency=.6
        card.Position=UDim2.new(0,0,0,12)
        local delay=#tab.Sections*.07
        task.delay(delay,function()
            Tw(card,{BackgroundTransparency=0,Position=UDim2.new(0,0,0,0)},.4,Enum.EasingStyle.Quint)
        end)

        -- Header
        local hd=I("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=T.CardHead,BorderSizePixel=0,ZIndex=7,LayoutOrder=1},card)
        Cn(10,hd); Reg(hd,"BackgroundColor3","CardHead")
        I("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.CardHead,BorderSizePixel=0,ZIndex=7},hd)
        I("Frame",{Size=UDim2.new(1,-18,0,1),Position=UDim2.new(0,9,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=8},hd)
        local pill=I("Frame",{Size=UDim2.new(0,3,0,12),Position=UDim2.new(0,8,.5,-6),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=8},hd)
        Cn(2,pill); Reg(pill,"BackgroundColor3","Accent")
        I("TextLabel",{Text=string.upper(sectionName),Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,16,0,0),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=9,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},hd)

        -- Elements
        local ec=I("Frame",{Name="El",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7,LayoutOrder=2},card)
        Ls(ec,1); Pd(5,7,7,7,ec)
        section.Container=ec

        -- ═══════════════════════════════════
        --  ELEMENTS
        -- ═══════════════════════════════════
        function section:element(eType,eName,options,callback)
            options=options or {}; callback=callback or function() end
            local flag=sectionName.."_"..eName
            local elem={Type=eType,Name=eName,Flag=flag,_keybind=nil,_keybindMode="Toggle",_hasKeybind=false,_setValue=nil,_getValue=nil,_callback=callback}

            local function Row(h)
                local f=I("Frame",{Size=UDim2.new(1,0,0,h or 34),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7},ec)
                Cn(6,f); return f
            end

            -- ═══ TOGGLE ═══
            if eType=="Toggle" then
                Library.Flags[flag]={Toggle=false,Active=false}
                local row=Row(34)
                local hov=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Hover,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=7},row); Cn(6,hov)
                I("TextLabel",{Text=eName,Size=UDim2.new(1,-75,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)

                local sw=I("Frame",{Size=UDim2.new(0,34,0,17),Position=UDim2.new(1,-42,.5,-8),BackgroundColor3=T.ToggleBg,BorderSizePixel=0,ZIndex=9},row)
                Cn(9,sw); St(T.BorderLight,1,sw)
                local gl=I("Frame",{Size=UDim2.new(0,42,0,25),Position=UDim2.new(1,-46,.5,-12),BackgroundColor3=T.AccentGlow,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=8},row); Cn(12,gl)
                local kn=I("Frame",{Size=UDim2.new(0,11,0,11),Position=UDim2.new(0,3,.5,-5),BackgroundColor3=T.ToggleKnob,BorderSizePixel=0,ZIndex=10},sw); Cn(6,kn)

                local gear=I("TextButton",{Text="⚙",Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-66,.5,-9),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=13,Visible=false},row)

                local tog=false
                local function Set(v,silent) tog=v; Library.Flags[flag].Toggle=v; Library.Flags[flag].Active=v
                    if v then
                        Tw(sw,{BackgroundColor3=T.Accent},.22)
                        Tw(kn,{Position=UDim2.new(0,20,.5,-5),BackgroundColor3=Color3.new(1,1,1)},.22,Enum.EasingStyle.Back)
                        Tw(gl,{BackgroundTransparency=.78},.35)
                    else
                        Tw(sw,{BackgroundColor3=T.ToggleBg},.22)
                        Tw(kn,{Position=UDim2.new(0,3,.5,-5),BackgroundColor3=T.ToggleKnob},.22,Enum.EasingStyle.Back)
                        Tw(gl,{BackgroundTransparency=1},.22)
                    end
                    if not silent then pcall(callback,{Toggle=v}) end
                end
                elem._setValue=Set; elem._getValue=function() return tog end

                local ck=I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},row)
                ck.MouseButton1Click:Connect(function() Set(not tog) end)
                ck.MouseEnter:Connect(function() Tw(hov,{BackgroundTransparency=.9},.1) end)
                ck.MouseLeave:Connect(function() Tw(hov,{BackgroundTransparency=1},.1) end)
                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem,gear) end)

                elem._gear=gear; elem._row=row
                function elem:add_keybind() self._hasKeybind=true;gear.Visible=true;return self end
                function elem:set_value(v) Set(v,false) end

            -- ═══ SLIDER ═══
            elseif eType=="Slider" then
                local c=options.default or {}
                local mn,mx,df,dc=c.min or 0,c.max or 100,c.default or(c.min or 0),c.decimals or 0
                Library.Flags[flag]={Slider=df}; local row=Row(46)
                I("TextLabel",{Text=eName,Size=UDim2.new(.55,0,0,18),Position=UDim2.new(0,8,0,3),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local vl=I("TextLabel",{Text=dc>0 and string.format("%."..dc.."f",df) or tostring(df),Size=UDim2.new(.45,-8,0,18),Position=UDim2.new(.55,0,0,3),BackgroundTransparency=1,TextColor3=T.Accent,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=9},row)
                local tr=I("Frame",{Size=UDim2.new(1,-16,0,5),Position=UDim2.new(0,8,0,30),BackgroundColor3=T.SliderTrack,BorderSizePixel=0,ZIndex=9,ClipsDescendants=true},row); Cn(3,tr)
                local fl=I("Frame",{Size=UDim2.new((df-mn)/(mx-mn),0,1,0),BackgroundColor3=T.SliderFill,BorderSizePixel=0,ZIndex=10},tr); Cn(3,fl)
                I("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.AccentDim),ColorSequenceKeypoint.new(1,T.Accent)}},fl)
                local hd2=I("Frame",{Size=UDim2.new(0,12,0,12),BackgroundColor3=T.SliderKnob,BorderSizePixel=0,ZIndex=11},row); Cn(6,hd2); St(T.Accent,2,hd2)

                local function Fmt(v) return dc>0 and string.format("%."..dc.."f",v) or tostring(math.floor(v+.5)) end
                local function PH() local p=(Library.Flags[flag].Slider-mn)/(mx-mn); hd2.Position=UDim2.new(0,tr.AbsolutePosition.X-row.AbsolutePosition.X+p*tr.AbsoluteSize.X-6,0,25) end
                local function SS(v,s) local f=10^dc;local r=math.clamp(math.floor(v*f+.5)/f,mn,mx);Library.Flags[flag].Slider=r;fl.Size=UDim2.new((r-mn)/(mx-mn),0,1,0);vl.Text=Fmt(r);PH();if not s then pcall(callback,{Slider=r}) end end
                elem._setValue=SS; elem._getValue=function() return Library.Flags[flag].Slider end; task.defer(PH)
                local dr=false
                local tc=I("TextButton",{Text="",Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,ZIndex=12},row)
                tc.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;SS(mn+math.clamp((i.Position.X-tr.AbsolutePosition.X)/math.max(tr.AbsoluteSize.X,1),0,1)*(mx-mn)) end end)
                UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then SS(mn+math.clamp((i.Position.X-tr.AbsolutePosition.X)/math.max(tr.AbsoluteSize.X,1),0,1)*(mx-mn)) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
                elem._row=row; function elem:set_value(v) SS(v) end

            -- ═══ DROPDOWN ═══
            elseif eType=="Dropdown" then
                local opts=options.options or{"Option"}; local dO=options.default or opts[1]
                Library.Flags[flag]={Dropdown=dO}; local row=Row(52)
                I("TextLabel",{Text=eName,Size=UDim2.new(1,-8,0,16),Position=UDim2.new(0,8,0,2),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local df=I("Frame",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,20),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=9},row); Cn(6,df); St(T.BorderLight,1,df)
                local sel=I("TextLabel",{Text=dO,Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},df)
                local ch=I("TextLabel",{Text="▾",Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-18,0,0),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,ZIndex=10},df)
                local function SD(v,s) Library.Flags[flag].Dropdown=v;sel.Text=v;if not s then pcall(callback,{Dropdown=v}) end end
                elem._setValue=SD; elem._getValue=function() return Library.Flags[flag].Dropdown end
                local ca=I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},df)
                ca.MouseButton1Click:Connect(function() Tw(ch,{Rotation=180},.2);win:_openDropdown(opts,df,function(v,s) SD(v,s);Tw(ch,{Rotation=0},.2) end,function() Tw(ch,{Rotation=0},.2) end) end)
                ca.MouseEnter:Connect(function() Tw(df,{BackgroundColor3=T.Hover},.1) end)
                ca.MouseLeave:Connect(function() Tw(df,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row; function elem:set_value(v) SD(v) end

            -- ═══ COMBO ═══
            elseif eType=="Combo" then
                local opts=options.options or{}; local dS=options.default or {}
                Library.Flags[flag]={Combo={table.unpack(dS)}}; local row=Row(0);row.AutomaticSize=Enum.AutomaticSize.Y
                I("TextLabel",{Text=eName,Size=UDim2.new(1,-8,0,20),Position=UDim2.new(0,8,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local cks=I("Frame",{Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,23),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},row);Ls(cks,3)
                I("Frame",{Size=UDim2.new(1,0,0,5),BackgroundTransparency=1,LayoutOrder=999},cks)
                for _,opt in ipairs(opts) do
                    local is=table.find(dS,opt)~=nil
                    local cr=I("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9},cks)
                    local cb=I("Frame",{Size=UDim2.new(0,13,0,13),Position=UDim2.new(0,1,.5,-6),BackgroundColor3=is and T.Accent or T.ToggleBg,BorderSizePixel=0,ZIndex=10},cr);Cn(3,cb);St(T.BorderLight,1,cb)
                    local ck=I("TextLabel",{Text="✓",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=8,Font=Enum.Font.GothamBold,Visible=is,ZIndex=11},cb)
                    I("TextLabel",{Text=opt,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},cr)
                    I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=12},cr).MouseButton1Click:Connect(function()
                        local cur=Library.Flags[flag].Combo;local idx=table.find(cur,opt)
                        if idx then table.remove(cur,idx);ck.Visible=false;Tw(cb,{BackgroundColor3=T.ToggleBg},.12) else table.insert(cur,opt);ck.Visible=true;Tw(cb,{BackgroundColor3=T.Accent},.12) end
                        pcall(callback,{Combo=cur})
                    end)
                end; elem._row=row

            -- ═══ BUTTON ═══
            elseif eType=="Button" then
                local row=Row(36)
                local btn=I("TextButton",{Text=eName,Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,.5,-13),BackgroundColor3=T.Elevated,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=9,ClipsDescendants=true},row);Cn(6,btn);St(T.BorderLight,1,btn)
                btn.MouseButton1Click:Connect(function() Tw(btn,{BackgroundColor3=T.Accent,TextColor3=Color3.new(1,1,1)},.06);task.delay(.15,function() Tw(btn,{BackgroundColor3=T.Elevated,TextColor3=T.Text},.2) end);pcall(callback,{}) end)
                btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=T.Hover},.1) end)
                btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row

            -- ═══ TEXTBOX ═══
            elseif eType=="TextBox" then
                Library.Flags[flag]={Text=options.default or ""}; local row=Row(52)
                I("TextLabel",{Text=eName,Size=UDim2.new(1,-8,0,16),Position=UDim2.new(0,8,0,2),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local tb=I("TextBox",{Text=options.default or"",PlaceholderText=options.placeholder or"Enter...",Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,20),BackgroundColor3=T.Elevated,TextColor3=T.Text,PlaceholderColor3=T.TextDis,TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row);Cn(6,tb);local st=St(T.BorderLight,1,tb);Pd(0,0,8,8,tb)
                tb.Focused:Connect(function() Tw(st,{Color=T.Accent},.15);Tw(tb,{BackgroundColor3=T.Hover},.15) end)
                tb.FocusLost:Connect(function(e) Tw(st,{Color=T.BorderLight},.15);Tw(tb,{BackgroundColor3=T.Elevated},.15);Library.Flags[flag].Text=tb.Text;pcall(callback,{Text=tb.Text,Enter=e}) end)
                tb:GetPropertyChangedSignal("Text"):Connect(function() Library.Flags[flag].Text=tb.Text end)
                elem._row=row;elem._tb=tb; function elem:set_value(v) tb.Text=tostring(v);Library.Flags[flag].Text=tostring(v) end

            -- ═══ COLOR PICKER ═══
            elseif eType=="ColorPicker" then
                local dC=options.default or Color3.fromRGB(255,0,0);Library.Flags[flag]={Color=dC}
                local h,s,v=Color3.toHSV(dC); local row=Row(34)
                I("TextLabel",{Text=eName,Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
                local pv=I("TextButton",{Text="",Size=UDim2.new(0,24,0,18),Position=UDim2.new(1,-34,.5,-9),BackgroundColor3=dC,BorderSizePixel=0,AutoButtonColor=false,ZIndex=9},row);Cn(5,pv);St(T.BorderLight,1,pv)
                local pO,pF,oC=false,nil,nil
                local function UC(si) local c=Color3.fromHSV(h,s,v);Library.Flags[flag].Color=c;pv.BackgroundColor3=c;if not si then pcall(callback,{Color=c}) end end
                local function CP() if not pF then return end;Tw(pF,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.15);local p=pF;task.delay(.16,function() pcall(function() p:Destroy() end) end);pF=nil;pO=false;if oC then oC:Disconnect();oC=nil end end

                pv.MouseButton1Click:Connect(function()
                    if pO then CP();return end;pO=true
                    local PW,PH=200,178
                    local pf=I("Frame",{Size=UDim2.new(0,0,0,0),BackgroundColor3=T.Elevated,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=600,ClipsDescendants=true},win.Overlay)
                    Cn(9,pf);St(T.BorderLight,1,pf);Shadow(pf,600);pF=pf
                    task.defer(function() local rp=row.AbsolutePosition;local rs=row.AbsoluteSize;pf.Position=UDim2.new(0,rp.X+rs.X-PW-4,0,rp.Y+rs.Y+6);Tw(pf,{Size=UDim2.new(0,PW,0,PH),BackgroundTransparency=0},.25,Enum.EasingStyle.Back) end)
                    I("TextLabel",{Text="COLOR",Size=UDim2.new(1,-12,0,20),Position=UDim2.new(0,8,0,3),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},pf)
                    local SS=135
                    local svF=I("Frame",{Size=UDim2.new(0,SS,0,SS),Position=UDim2.new(0,8,0,25),BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=601,ClipsDescendants=true},pf);Cn(5,svF)
                    local wh=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},svF);I("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},wh)
                    local bl=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=603},svF);I("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90},bl)
                    local sc=I("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(s,-5,1-v,-5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=605},svF);Cn(5,sc);St(Color3.new(1,1,1),2,sc)
                    local hB=I("Frame",{Size=UDim2.new(0,16,0,SS),Position=UDim2.new(0,SS+12,0,25),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=601},pf);Cn(4,hB)
                    I("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(.167,Color3.fromHSV(.167,1,1)),ColorSequenceKeypoint.new(.333,Color3.fromHSV(.333,1,1)),ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),ColorSequenceKeypoint.new(.667,Color3.fromHSV(.667,1,1)),ColorSequenceKeypoint.new(.833,Color3.fromHSV(.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))},Rotation=90},hB)
                    local hC=I("Frame",{Size=UDim2.new(1,4,0,4),Position=UDim2.new(0,-2,h,-2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=602},hB);Cn(2,hC)
                    local sD,hD=false,false
                    I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=606},svF).InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sD=true end end)
                    I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=602},hB).InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hD=true end end)
                    UIS.InputChanged:Connect(function(i) if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                        if sD then s=math.clamp((i.Position.X-svF.AbsolutePosition.X)/SS,0,1);v=1-math.clamp((i.Position.Y-svF.AbsolutePosition.Y)/SS,0,1);sc.Position=UDim2.new(s,-5,1-v,-5);UC()
                        elseif hD then h=math.clamp((i.Position.Y-hB.AbsolutePosition.Y)/SS,0,1);hC.Position=UDim2.new(0,-2,h,-2);svF.BackgroundColor3=Color3.fromHSV(h,1,1);UC() end
                    end)
                    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sD=false;hD=false end end)
                    local rdy=false;task.delay(.3,function() rdy=true end)
                    oC=UIS.InputBegan:Connect(function(inp) if not rdy or sD or hD then return end;if inp.UserInputType==Enum.UserInputType.MouseButton1 then task.defer(function() if pf and pf.Parent and IsOut(inp.Position,pf) then CP() end end) end end)
                end)
                elem._row=row; function elem:set_value(c) h,s,v=Color3.toHSV(c);Library.Flags[flag].Color=c;pv.BackgroundColor3=c end

            -- ═══ LABEL ═══
            elseif eType=="Label" then
                local row=Row(0);row.AutomaticSize=Enum.AutomaticSize.Y
                local lbl=I("TextLabel",{Text=eName,Size=UDim2.new(1,-16,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,8,0,5),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=9},row)
                I("Frame",{Size=UDim2.new(1,0,0,5),BackgroundTransparency=1},row)
                elem._row=row; function elem:set_text(t) lbl.Text=t end

            -- ═══ SEPARATOR ═══
            elseif eType=="Separator" then
                local row=Row(16)
                I("Frame",{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,.5,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},row)
                if eName and eName~="" then I("TextLabel",{Text=" "..eName.." ",Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.new(.5,0,.5,-6),BackgroundColor3=T.Card,TextColor3=T.TextMut,TextSize=9,Font=Enum.Font.Gotham,BorderSizePixel=0,ZIndex=10},row) end
                elem._row=row
            end

            Library.Elements[flag]=elem; table.insert(section.Elements,elem); return elem
        end

        table.insert(tab.Sections,section); return section
    end

    return tab
end

-- ═══════════════════════════════════════════════════════════
--  TAB SWITCHING (animated slide + fade + stagger)
-- ═══════════════════════════════════════════════════════════
function Library:SelectTab(target)
    -- Fade out old
    if self.ActiveTab and self.ActiveTab~=target then
        local old=self.ActiveTab
        -- Slide old content out
        if old.ColFrame then
            Tw(old.ColFrame,{Position=UDim2.new(-0.05,0,0,10)},.2)
        end
        task.delay(.15,function()
            old.Page.Visible=false
            if old.ColFrame then old.ColFrame.Position=UDim2.new(0,10,0,10) end
        end)
    end

    for _,t in ipairs(self.Tabs) do
        t.Active=false; t.SubContainer.Visible=false
        Tw(t.IconBtn,{BackgroundTransparency=.5,BackgroundColor3=T.IconBar},.18)
        Tw(t.IconLabel,{TextColor3=T.TextMut},.18)
        Tw(t.Indicator,{BackgroundColor3=T.TextMut,Size=UDim2.new(0,3,0,0)},.18)
    end

    target.Active=true; target.SubContainer.Visible=true
    Tw(target.IconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Active},.18)
    Tw(target.IconLabel,{TextColor3=T.Accent},.18)
    Tw(target.Indicator,{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,0,20)},.25,Enum.EasingStyle.Back)

    -- Show new page with slide-in
    task.delay(.12,function()
        target.Page.Visible=true
        if target.ColFrame then
            target.ColFrame.Position=UDim2.new(0.03,0,0,8)
            Tw(target.ColFrame,{Position=UDim2.new(0,10,0,10)},.35,Enum.EasingStyle.Quint)
        end

        -- Stagger section cards
        for i,sec in ipairs(target.Sections) do
            if sec.Frame then
                sec.Frame.BackgroundTransparency=.4
                task.delay(i*.05,function()
                    Tw(sec.Frame,{BackgroundTransparency=0},.3,Enum.EasingStyle.Quint)
                end)
            end
        end
    end)

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
    if self._popup then local was=self._popupElem==elem;self:_closePopups();if was then return end end
    self._popupElem=elem
    local pop=I("Frame",{Size=UDim2.new(0,190,0,145),BackgroundColor3=T.Elevated,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=600},self.Overlay)
    Cn(9,pop);St(T.BorderLight,1,pop);Shadow(pop,600);self._popup=pop
    task.defer(function() local ap=anchor.AbsolutePosition;local as=anchor.AbsoluteSize;pop.Position=UDim2.new(0,math.clamp(ap.X-190+as.X+4,0,1000),0,ap.Y+as.Y+8);Tw(pop,{BackgroundTransparency=0},.22,Enum.EasingStyle.Back) end)

    I("TextLabel",{Text="KEYBIND  ·  "..elem.Name,Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},pop)
    local kS=elem._keybind and KeyName(elem._keybind) or "None"
    local kB=I("TextButton",{Text=kS,Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,27),BackgroundColor3=T.Panel,TextColor3=T.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=601},pop);Cn(6,kB);St(T.Border,1,kB)
    local lis=false
    kB.MouseButton1Click:Connect(function() if lis then return end;lis=true;kB.Text="Press key...";kB.TextColor3=T.Accent;Tw(kB,{BackgroundColor3=T.Hover},.1)
        local cn;cn=UIS.InputBegan:Connect(function(inp,gpe) if gpe then return end;if inp.UserInputType==Enum.UserInputType.Keyboard then elem._keybind=inp.KeyCode;kB.Text=KeyName(inp.KeyCode);kB.TextColor3=T.Text;Tw(kB,{BackgroundColor3=T.Panel},.1);lis=false;cn:Disconnect() end end) end)
    kB.MouseEnter:Connect(function() Tw(kB,{BackgroundColor3=T.Hover},.1) end)
    kB.MouseLeave:Connect(function() if not lis then Tw(kB,{BackgroundColor3=T.Panel},.1) end end)
    I("TextButton",{Text="Clear",Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-48,0,32),BackgroundTransparency=1,TextColor3=T.Danger,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=602},pop).MouseButton1Click:Connect(function() elem._keybind=nil;kB.Text="None";kB.TextColor3=T.TextSub end)
    I("TextLabel",{Text="MODE",Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,62),BackgroundTransparency=1,TextColor3=T.TextMut,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=601},pop)
    local mT=I("Frame",{Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,78),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=601},pop);Cn(7,mT)
    local function MB(l,x,a) local m=I("TextButton",{Text=l,Size=UDim2.new(.5,-3,1,-4),Position=UDim2.new(x,x==0 and 2 or 1,0,2),BackgroundColor3=a and T.Accent or T.Panel,TextColor3=a and Color3.new(1,1,1) or T.TextSub,TextSize=10,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=602},mT);Cn(5,m);return m end
    local tB=MB("Toggle",0,elem._keybindMode=="Toggle"); local hB=MB("Hold",.5,elem._keybindMode=="Hold")
    local function SM(m) elem._keybindMode=m;Tw(tB,{BackgroundColor3=m=="Toggle" and T.Accent or T.Panel},.12);tB.TextColor3=m=="Toggle" and Color3.new(1,1,1) or T.TextSub;Tw(hB,{BackgroundColor3=m=="Hold" and T.Accent or T.Panel},.12);hB.TextColor3=m=="Hold" and Color3.new(1,1,1) or T.TextSub end
    tB.MouseButton1Click:Connect(function() SM("Toggle") end); hB.MouseButton1Click:Connect(function() SM("Hold") end)
    local rdy=false;task.delay(.25,function() rdy=true end)
    local oc;oc=UIS.InputBegan:Connect(function(inp) if not rdy then return end;if inp.UserInputType==Enum.UserInputType.MouseButton1 then task.defer(function() if pop and pop.Parent and IsOut(inp.Position,pop) then self:_closePopups();oc:Disconnect() end end) end end)
end

function Library:_openDropdown(opts,anchor,setFn,onClose)
    if self._dropdown then self._dropdown:Destroy();self._dropdown=nil;if onClose then onClose() end;return end
    local IH,MX=26,7;local sh=math.min(#opts,MX);local tH=sh*IH+10
    local dd=I("Frame",{Size=UDim2.new(0,anchor.AbsoluteSize.X,0,0),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=600,ClipsDescendants=true},self.Overlay)
    Cn(7,dd);St(T.BorderLight,1,dd);Shadow(dd,600);self._dropdown=dd
    task.defer(function() local ap=anchor.AbsolutePosition;local as=anchor.AbsoluteSize;dd.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+3);Tw(dd,{Size=UDim2.new(0,as.X,0,tH)},.22,Enum.EasingStyle.Back) end)
    local scr=I("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,#opts*IH+10),ZIndex=601},dd);Ls(scr,1);Pd(4,4,4,4,scr)
    for idx,opt in ipairs(opts) do
        local it=I("TextButton",{Text=opt,Size=UDim2.new(1,0,0,IH),BackgroundColor3=T.Hover,BackgroundTransparency=1,TextColor3=T.Text,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,BorderSizePixel=0,ZIndex=602},scr);Cn(4,it);Pd(0,0,8,6,it)
        it.TextTransparency=1; task.delay(idx*.02,function() Tw(it,{TextTransparency=0},.18) end)
        it.MouseEnter:Connect(function() Tw(it,{BackgroundTransparency=.65},.08) end)
        it.MouseLeave:Connect(function() Tw(it,{BackgroundTransparency=1},.08) end)
        it.MouseButton1Click:Connect(function() setFn(opt,false);Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.15);task.delay(.16,function() if dd and dd.Parent then dd:Destroy() end;self._dropdown=nil end) end)
    end
    local rdy=false;task.delay(.15,function() rdy=true end)
    local oc;oc=UIS.InputBegan:Connect(function(inp) if not rdy then return end;if inp.UserInputType==Enum.UserInputType.MouseButton1 then task.defer(function() if not dd or not dd.Parent then oc:Disconnect();return end;if IsOut(inp.Position,dd) then Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.12);task.delay(.13,function() if dd and dd.Parent then dd:Destroy() end;self._dropdown=nil;if onClose then onClose() end end);oc:Disconnect() end end) end end)
end

-- ═══════════════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════════════
function Library:Toggle() self:SetOpen(not self.Open) end

function Library:SetOpen(state)
    self.Open=state
    if state then
        self.Main.Visible=true
        self.Main.Size=UDim2.new(0,self._fullSize.X.Offset*.88,0,self._fullSize.Y.Offset*.88)
        self.Main.BackgroundTransparency=.3
        Tw(self.Main,{Size=self._fullSize,BackgroundTransparency=0},.4,Enum.EasingStyle.Back)
        Tw(self._blur,{Size=8},.5,Enum.EasingStyle.Quint)
    else
        Tw(self.Main,{Size=UDim2.new(0,self._fullSize.X.Offset*.9,0,self._fullSize.Y.Offset*.9),BackgroundTransparency=.25},.22)
        Tw(self._blur,{Size=0},.3)
        task.delay(.23,function() if not self.Open then self.Main.Visible=false end end)
    end
end

function Library:Destroy() pcall(function() self._blur:Destroy() end); pcall(function() self.Gui:Destroy() end) end

function Library:SaveConfig(name) pcall(function()
    local d={}; for f,v in pairs(Library.Flags) do local c={}; for k,x in pairs(v) do if typeof(x)=="Color3" then c[k]={R=x.R,G=x.G,B=x.B,_c3=true} else c[k]=x end end; d[f]=c end
    pcall(makefolder,"NexUI_configs"); writefile("NexUI_configs/"..name..".json",Http:JSONEncode(d))
end) end

function Library:LoadConfig(name) pcall(function()
    local d=Http:JSONDecode(readfile("NexUI_configs/"..name..".json"))
    for f,v in pairs(d) do for k,x in pairs(v) do if type(x)=="table" and x._c3 then v[k]=Color3.new(x.R,x.G,x.B) end end
        Library.Flags[f]=v; local e=Library.Elements[f]; if e and e._setValue then
            if e.Type=="Toggle" then pcall(e._setValue,v.Toggle,true) end
            if e.Type=="Slider" then pcall(e._setValue,v.Slider,true) end
            if e.Type=="Dropdown" then pcall(e._setValue,v.Dropdown,true) end
            if e.Type=="ColorPicker" then pcall(e.set_value,e,v.Color) end
    end end
end) end

function Library:ListConfigs() local o={}; pcall(function() pcall(makefolder,"NexUI_configs"); for _,f in next,listfiles("NexUI_configs") do table.insert(o,f:gsub("NexUI_configs/",""):gsub("NexUI_configs\\",""):gsub("%.json$","")) end end); return o end

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════
Library._notifHolder=nil

function Library:Notify(title,desc,duration,nType)
    if not Library._notifHolder or not Library._notifHolder.Parent then
        local ng=I("ScreenGui",{Name="__NexUI_N",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=2000})
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(ng);ng.Parent=game.CoreGui elseif gethui then ng.Parent=gethui() else ng.Parent=LP:WaitForChild("PlayerGui") end end)
        Library._notifHolder=I("Frame",{Size=UDim2.new(0,290,1,0),Position=UDim2.new(1,-305,0,0),BackgroundTransparency=1,BorderSizePixel=0},ng)
        local hl=Ls(Library._notifHolder,8);hl.VerticalAlignment=Enum.VerticalAlignment.Bottom;Pd(12,12,0,0,Library._notifHolder)
    end

    duration=duration or 4;nType=nType or "info"
    local ac=({info=T.Accent,success=T.Success,warning=T.Warning,error=T.Danger})[nType] or T.Accent

    local wr=I("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true},Library._notifHolder)
    local nf=I("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(1.2,0,0,0),BackgroundColor3=T.Panel,BorderSizePixel=0,BackgroundTransparency=.3,ZIndex=10,ClipsDescendants=true},wr)
    Cn(10,nf);St(T.Border,1,nf)
    I("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=ac,BorderSizePixel=0,ZIndex=11},nf)

    local inn=I("Frame",{Size=UDim2.new(1,-3,0,0),Position=UDim2.new(0,3,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},nf);Ls(inn,3);Pd(10,12,10,10,inn)
    local tr=I("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=12,LayoutOrder=1},inn)
    local dot=I("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,0,.5,-3),BackgroundColor3=ac,BorderSizePixel=0,ZIndex=13},tr);Cn(3,dot)
    local tL=I("TextLabel",{Text=title or"Notification",Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,TextColor3=T.Text,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,ZIndex=13},tr)
    local dL; if desc and desc~="" then dL=I("TextLabel",{Text=desc,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,TextColor3=T.TextSub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTransparency=1,ZIndex=12,LayoutOrder=2},inn) end
    I("Frame",{Size=UDim2.new(1,0,0,5),BackgroundTransparency=1,LayoutOrder=3},inn)
    local pC=I("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Elevated,BorderSizePixel=0,ZIndex=12,LayoutOrder=4},inn);Cn(1,pC)
    local pF=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=ac,BorderSizePixel=0,ZIndex=13},pC);Cn(1,pF)

    -- Entry
    task.defer(function() Tw(nf,{Position=UDim2.new(0,0,0,0)},.5,Enum.EasingStyle.Quint) end)
    task.delay(.08,function() Tw(nf,{BackgroundTransparency=0},.35) end)
    task.delay(.12,function() Tw(dot,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,-1,.5,-4)},.12);task.delay(.12,function() Tw(dot,{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,0,.5,-3)},.12) end) end)
    task.delay(.18,function() Tw(tL,{TextTransparency=0},.3,Enum.EasingStyle.Quint) end)
    task.delay(.26,function() if dL then Tw(dL,{TextTransparency=.1},.3,Enum.EasingStyle.Quint) end end)
    task.delay(.35,function() Tw(pF,{Size=UDim2.new(0,0,1,0)},duration-.5,Enum.EasingStyle.Linear) end)

    -- Exit
    task.delay(duration,function()
        Tw(tL,{TextTransparency=.5},.2);if dL then Tw(dL,{TextTransparency=.6},.2) end;Tw(dot,{BackgroundTransparency=.5},.2)
        task.delay(.1,function() Tw(nf,{BackgroundTransparency=.4},.25) end)
        task.delay(.15,function() Tw(nf,{Position=UDim2.new(1.3,0,0,0)},.5,Enum.EasingStyle.Quint,Enum.EasingDirection.In) end)
        task.delay(.7,function() pcall(function() wr:Destroy() end) end)
    end)

    -- Click dismiss + hover
    local dis=I("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=14},nf)
    local gone=false
    dis.MouseButton1Click:Connect(function() if gone then return end;gone=true;Tw(nf,{Position=UDim2.new(1.3,0,0,0)},.35,Enum.EasingStyle.Quint,Enum.EasingDirection.In);task.delay(.4,function() pcall(function() wr:Destroy() end) end) end)
    dis.MouseEnter:Connect(function() if not gone then Tw(nf,{BackgroundTransparency=.05},.1) end end)
    dis.MouseLeave:Connect(function() if not gone then Tw(nf,{BackgroundTransparency=0},.1) end end)
end

-- ═══════════════════════════════════════════════════════════
return Library
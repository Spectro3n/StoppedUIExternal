--[[
    ███╗░░██╗███████╗██╗░░██╗██╗░░░██╗██╗
    ████╗░██║██╔════╝╚██╗██╔╝██║░░░██║██║
    ██╔██╗██║█████╗░░░╚███╔╝░██║░░░██║██║
    ██║╚████║██╔══╝░░░██╔██╗░██║░░░██║██║
    ██║░╚███║███████╗██╔╝╚██╗╚██████╔╝██║
    ╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝░╚═════╝░╚═╝
    
    NexUI Library — v3.0
    Premium, fully-featured UI library for Roblox.
    
    CHANGELOG v3:
      • Dual sidebar (icon rail + sub-navigation panel)
      • Global search bar with live filtering
      • Minimize / close buttons
      • Scrolls-to-section from sub-sidebar
      • Enhanced Toggle with glow
      • Enhanced Slider with dynamic handle
      • Enhanced Dropdown with animated popup
      • Color Picker element (HSV square + hue bar)
      • Better notifications with progress bar
      • Accent top-line, better shadows, better theme
      • Window-toggle keybind (RightShift)
      • Drag bounds enforcement
      • Full backward-compatible API
    
    USAGE:
        local Library = loadstring(...)()
        local Window  = Library.new("My Hub")
        local Tab     = Window:new_tab("Combat", "⚔")
        local Section = Tab:new_section("Aimbot")
        Section:element("Toggle", "Enabled", {}, function(s) print(s.Toggle) end):add_keybind()
        Section:element("Slider", "FOV", {default={min=1,max=360,default=90,decimals=0}}, function(s) print(s.Slider) end)
        Section:element("Dropdown", "Bone", {options={"Head","Torso","Random"}}, function(s) print(s.Dropdown) end)
        Section:element("ColorPicker", "ESP Color", {default=Color3.fromRGB(255,0,0)}, function(s) print(s.Color) end)
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
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════
local T = {
    -- Surfaces
    BG          = Color3.fromRGB(8,   8,  12),
    IconBar     = Color3.fromRGB(10, 10,  15),
    Panel       = Color3.fromRGB(14, 14,  20),
    Elevated    = Color3.fromRGB(20, 20,  28),
    Hover       = Color3.fromRGB(28, 28,  38),
    Active      = Color3.fromRGB(35, 35,  48),
    Card        = Color3.fromRGB(16, 16,  23),
    CardHead    = Color3.fromRGB(20, 20,  28),
    -- Accent
    Accent      = Color3.fromRGB(45,125, 255),
    AccentHov   = Color3.fromRGB(75,150, 255),
    AccentDim   = Color3.fromRGB(20, 65, 150),
    AccentGlow  = Color3.fromRGB(35,100, 230),
    -- Text
    Text        = Color3.fromRGB(230,230,242),
    TextSub     = Color3.fromRGB(135,135,158),
    TextMut     = Color3.fromRGB(70,  70, 90),
    TextDis     = Color3.fromRGB(45,  45, 60),
    -- Borders
    Border      = Color3.fromRGB(26, 26, 36),
    BorderLight = Color3.fromRGB(40, 40, 54),
    -- Status
    Success     = Color3.fromRGB(45, 215,115),
    Warning     = Color3.fromRGB(255,185, 35),
    Danger      = Color3.fromRGB(225, 55, 55),
    -- Toggle
    ToggleBg    = Color3.fromRGB(22, 22, 30),
    ToggleKnob  = Color3.fromRGB(85, 85,105),
    -- Slider
    SliderTrack = Color3.fromRGB(20, 20, 28),
    SliderFill  = Color3.fromRGB(45,125,255),
    SliderKnob  = Color3.fromRGB(210,220,255),
}

-- ══════════════════════════════════════════════════════════════
--  UTILITIES
-- ══════════════════════════════════════════════════════════════
local function Tw(obj, props, t, style, dir)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(t or .15, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local function I(class, props, parent)
    local ok, inst = pcall(Instance.new, class)
    if not ok then return nil end
    for k,v in pairs(props or {}) do pcall(function() inst[k]=v end) end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(r,p)  return I("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function Stroke(c,t,p) return I("UIStroke",{Color=c or T.Border,Thickness=t or 1,LineJoinMode=Enum.LineJoinMode.Round,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function Pad(t,b,l,r,p) return I("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},p) end

local function List(parent, gap, sort, dir)
    return I("UIListLayout",{
        SortOrder     = sort or Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, gap or 0),
        FillDirection = dir  or Enum.FillDirection.Vertical,
    }, parent)
end

local function AutoCanvas(scroll)
    local lay = scroll:FindFirstChildOfClass("UIListLayout")
    if not lay then return end
    local function upd() scroll.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+16) end
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    task.defer(upd)
end

local function Shadow(parent, z)
    I("ImageLabel",{
        Name="_Sh",Size=UDim2.new(1,40,1,40),Position=UDim2.new(0,-20,0,-20),
        BackgroundTransparency=1,Image="rbxassetid://5554236805",
        ImageColor3=Color3.new(0,0,0),ImageTransparency=.5,
        ZIndex=(z or 1)-1,ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(23,23,277,277),
    }, parent)
end

local function KeyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.","") end

-- ══════════════════════════════════════════════════════════════
--  WINDOW CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════
function Library.new(title, toggleKey)
    local win        = setmetatable({}, Library)
    win.Title        = title or "NexUI"
    win.Tabs         = {}
    win.ActiveTab    = nil
    win.Open         = true
    win.Minimized    = false
    win._popup       = nil
    win._popupElem   = nil
    win._dropdown    = nil
    win.ToggleKey    = toggleKey or Enum.KeyCode.RightShift

    -- sizes
    local W, H       = 780, 490
    local TOPBAR     = 50
    local ICONW      = 48
    local SUBW       = 155

    -- ── ScreenGui ──────────────────────────────────────────
    local gui = I("ScreenGui",{
        Name="__NexUI_"..math.random(1e4,9e4),
        ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=1000,
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent=game.CoreGui
        elseif gethui then gui.Parent=gethui()
        else gui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
    end)
    if not gui.Parent then gui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
    win.Gui = gui

    -- overlay for popups
    win.Overlay = I("Frame",{Name="Overlay",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=500},gui)

    -- ── Main Frame ─────────────────────────────────────────
    local main = I("Frame",{
        Name="Window",
        Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(.5,-W/2,.5,-H/2),
        BackgroundColor3=T.BG,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },gui)
    Corner(10,main); Stroke(T.Border,1,main); Shadow(main,2)
    win.Main = main
    win._fullSize = UDim2.new(0,W,0,H)

    -- accent top-line (2px gradient)
    local accentLine = I("Frame",{
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=20,
    },main)
    I("UIGradient",{
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0, T.AccentDim),
            ColorSequenceKeypoint.new(.5, T.Accent),
            ColorSequenceKeypoint.new(1, T.AccentDim),
        },
        Transparency=NumberSequence.new{
            NumberSequenceKeypoint.new(0,.6),
            NumberSequenceKeypoint.new(.5,0),
            NumberSequenceKeypoint.new(1,.6),
        },
    }, accentLine)

    -- ── Top Bar ────────────────────────────────────────────
    local topbar = I("Frame",{
        Name="TopBar",Size=UDim2.new(1,0,0,TOPBAR),
        BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10,
    },main)
    Corner(10,topbar)
    I("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=10},topbar)
    I("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=11},topbar)

    -- title
    I("TextLabel",{
        Text=win.Title, Size=UDim2.new(0,180,1,0), Position=UDim2.new(0,ICONW+12,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=14,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    },topbar)

    -- search bar
    local searchFrame = I("Frame",{
        Size=UDim2.new(0,200,0,28), Position=UDim2.new(.5,-100,.5,-14),
        BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=12,
    },topbar)
    Corner(7,searchFrame); Stroke(T.Border,1,searchFrame)

    I("TextLabel",{
        Text="🔍", Size=UDim2.new(0,24,1,0), Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=12,
        Font=Enum.Font.Gotham, ZIndex=13,
    },searchFrame)

    local searchBox = I("TextBox",{
        Text="", PlaceholderText="Search...",
        Size=UDim2.new(1,-32,1,0), Position=UDim2.new(0,28,0,0),
        BackgroundTransparency=1, TextColor3=T.Text, PlaceholderColor3=T.TextDis,
        TextSize=11, Font=Enum.Font.Gotham, ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13,
    },searchFrame)

    -- minimize button
    local minBtn = I("TextButton",{
        Text="─", Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-100,.5,-14),
        BackgroundColor3=T.Elevated, TextColor3=T.TextSub, TextSize=14,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false, ZIndex=12,
    },topbar)
    Corner(6,minBtn)
    minBtn.MouseEnter:Connect(function() Tw(minBtn,{BackgroundColor3=T.Warning,TextColor3=T.BG},.1) end)
    minBtn.MouseLeave:Connect(function() Tw(minBtn,{BackgroundColor3=T.Elevated,TextColor3=T.TextSub},.1) end)

    -- close button
    local closeBtn = I("TextButton",{
        Text="✕", Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-66,.5,-14),
        BackgroundColor3=T.Elevated, TextColor3=T.TextSub, TextSize=12,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false, ZIndex=12,
    },topbar)
    Corner(6,closeBtn)
    closeBtn.MouseEnter:Connect(function() Tw(closeBtn,{BackgroundColor3=T.Danger,TextColor3=Color3.new(1,1,1)},.1) end)
    closeBtn.MouseLeave:Connect(function() Tw(closeBtn,{BackgroundColor3=T.Elevated,TextColor3=T.TextSub},.1) end)
    closeBtn.MouseButton1Click:Connect(function() win:SetOpen(false) end)

    -- minimize logic
    minBtn.MouseButton1Click:Connect(function()
        win.Minimized = not win.Minimized
        if win.Minimized then
            Tw(main,{Size=UDim2.new(0,W,0,TOPBAR+2)},.25)
        else
            Tw(main,{Size=win._fullSize},.25)
        end
    end)

    -- user info (right side)
    local userFrame = I("Frame",{
        Size=UDim2.new(0,160,1,0), Position=UDim2.new(1,-168,0,0),
        BackgroundTransparency=1, ZIndex=12,
    },topbar)

    I("TextLabel",{
        Text=LocalPlayer.DisplayName,
        Size=UDim2.new(1,-40,0.5,1), Position=UDim2.new(0,0,0,3),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=11,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12,
    },userFrame)
    I("TextLabel",{
        Text=os.date("%d/%m/%Y"),
        Size=UDim2.new(1,-40,0.5,-1), Position=UDim2.new(0,0,0.5,2),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=9,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12,
    },userFrame)

    local avatar = I("Frame",{
        Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-36,.5,-16),
        BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=12,
    },topbar)
    Corner(16,avatar)
    Stroke(T.AccentDim,2,avatar)
    I("TextLabel",{
        Text=string.upper(string.sub(LocalPlayer.Name,1,1)),
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        TextColor3=Color3.new(1,1,1), TextSize=13,
        Font=Enum.Font.GothamBold, ZIndex=13,
    },avatar)

    -- ── Draggable ──────────────────────────────────────────
    do
        local dragging, start, origin
        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging=true; start=inp.Position; origin=main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = inp.Position - start
                local vp = workspace.CurrentCamera.ViewportSize
                local nx = math.clamp(origin.X.Offset+d.X, -W+120, vp.X-120)
                local ny = math.clamp(origin.Y.Offset+d.Y, 0, vp.Y-60)
                main.Position = UDim2.new(origin.X.Scale,nx,origin.Y.Scale,ny)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
    end

    -- ── Icon Sidebar (Primary Nav) ─────────────────────────
    local iconBar = I("Frame",{
        Name="IconBar",
        Size=UDim2.new(0,ICONW,1,-TOPBAR),
        Position=UDim2.new(0,0,0,TOPBAR),
        BackgroundColor3=T.IconBar,
        BorderSizePixel=0, ZIndex=8,
    },main)
    I("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=9},iconBar)

    local iconScroll = I("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), ZIndex=9,
    },iconBar)
    List(iconScroll,4); Pad(10,10,0,0,iconScroll); AutoCanvas(iconScroll)
    win.IconScroll = iconScroll

    -- ── Sub Sidebar (Secondary Nav) ────────────────────────
    local subSide = I("Frame",{
        Name="SubSidebar",
        Size=UDim2.new(0,SUBW,1,-TOPBAR),
        Position=UDim2.new(0,ICONW,0,TOPBAR),
        BackgroundColor3=T.Panel,
        BorderSizePixel=0, ZIndex=6,
    },main)
    I("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=7},subSide)

    local subScroll = I("ScrollingFrame",{
        Size=UDim2.new(1,-1,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0), ZIndex=7,
    },subSide)
    List(subScroll,2); Pad(10,10,8,8,subScroll); AutoCanvas(subScroll)
    win.SubScroll = subScroll

    -- ── Content Area ───────────────────────────────────────
    local content = I("Frame",{
        Name="Content",
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

    -- ── Global keybind listener ────────────────────────────
    UserInputService.InputBegan:Connect(function(inp, gpe)
        -- toggle window
        if inp.KeyCode == win.ToggleKey and not gpe then
            win:SetOpen(not win.Open)
            return
        end
        if gpe then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if elem._keybind and inp.KeyCode == elem._keybind then
                if elem._keybindMode=="Toggle" then
                    if elem.Type=="Toggle" and elem._setValue then
                        local cur = Library.Flags[flag] and Library.Flags[flag].Toggle or false
                        elem._setValue(not cur)
                    end
                elseif elem._keybindMode=="Hold" then
                    if elem.Type=="Toggle" and elem._setValue then elem._setValue(true) end
                end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
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
--  TAB CREATION
-- ══════════════════════════════════════════════════════════════
function Library:new_tab(name, icon)
    local win = self
    icon = icon or string.upper(string.sub(name,1,1))

    local tab = {
        Name     = name,
        Icon     = icon,
        Sections = {},
        Active   = false,
    }

    -- ── Icon sidebar button ────────────────────────────────
    local iconBtn = I("TextButton",{
        Name=name, Text="",
        Size=UDim2.new(1,0,0,42),
        BackgroundColor3=T.IconBar,
        BackgroundTransparency=.5,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=10,
    },win.IconScroll)
    Corner(8,iconBtn)
    tab.IconBtn = iconBtn

    -- active indicator (left bar)
    local indicator = I("Frame",{
        Size=UDim2.new(0,3,0,18), Position=UDim2.new(0,2,.5,-9),
        BackgroundColor3=T.TextMut, BorderSizePixel=0, ZIndex=11,
    },iconBtn)
    Corner(2,indicator)
    tab.Indicator = indicator

    -- icon character
    local iconLbl = I("TextLabel",{
        Text=icon,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, TextColor3=T.TextMut,
        TextSize=16, Font=Enum.Font.GothamBold, ZIndex=11,
    },iconBtn)
    tab.IconLabel = iconLbl

    -- tooltip (shows tab name on hover)
    local tooltip = I("TextLabel",{
        Text=" "..name.." ",
        Size=UDim2.new(0,0,0,22), AutomaticSize=Enum.AutomaticSize.X,
        Position=UDim2.new(1,8,.5,-11),
        BackgroundColor3=T.Elevated, TextColor3=T.Text,
        TextSize=11, Font=Enum.Font.Gotham, BorderSizePixel=0,
        Visible=false, ZIndex=900,
    },iconBtn)
    Corner(5,tooltip); Stroke(T.BorderLight,1,tooltip)

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
    iconBtn.MouseButton1Click:Connect(function()
        win:SelectTab(tab)
    end)

    -- ── Sub sidebar container (one per tab) ────────────────
    local subContainer = I("Frame",{
        Name=name.."_sub",
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0,
        Visible=false, ZIndex=7,
    },win.SubScroll)
    List(subContainer,2)
    tab.SubContainer = subContainer

    -- sub sidebar header
    I("TextLabel",{
        Text=string.upper(name), Size=UDim2.new(1,0,0,28),
        BackgroundTransparency=1, TextColor3=T.TextMut,
        TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
    },subContainer)

    -- ── Content page ───────────────────────────────────────
    local page = I("ScrollingFrame",{
        Name=name.."_page",
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        Visible=false, ZIndex=5,
    },win.Content)
    List(page,10); Pad(12,14,12,14,page); AutoCanvas(page)
    tab.Page = page

    table.insert(win.Tabs, tab)
    if #win.Tabs==1 then win:SelectTab(tab) end

    -- ════════════════════════════════════════════════════════
    --  SECTION CREATION
    -- ════════════════════════════════════════════════════════
    function tab:new_section(sectionName)
        local section = { Name=sectionName, Elements={} }

        -- ── Sub-sidebar entry ──────────────────────────────
        local subEntry = I("TextButton",{
            Name=sectionName, Text="",
            Size=UDim2.new(1,0,0,28),
            BackgroundColor3=T.Panel, BackgroundTransparency=.5,
            BorderSizePixel=0, AutoButtonColor=false, ZIndex=8,
        },subContainer)
        Corner(6,subEntry)
        section._subEntry = subEntry

        local diamond = I("TextLabel",{
            Text="◆", Size=UDim2.new(0,16,1,0), Position=UDim2.new(0,4,0,0),
            BackgroundTransparency=1, TextColor3=T.TextMut,
            TextSize=7, Font=Enum.Font.GothamBold, ZIndex=9,
        },subEntry)

        local subLbl = I("TextLabel",{
            Text=sectionName,
            Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,20,0,0),
            BackgroundTransparency=1, TextColor3=T.TextSub,
            TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
        },subEntry)
        section._subLbl = subLbl
        section._diamond = diamond

        subEntry.MouseEnter:Connect(function()
            Tw(subEntry,{BackgroundTransparency=0,BackgroundColor3=T.Hover},.1)
        end)
        subEntry.MouseLeave:Connect(function()
            Tw(subEntry,{BackgroundTransparency=.5,BackgroundColor3=T.Panel},.1)
        end)
        subEntry.MouseButton1Click:Connect(function()
            -- scroll content to this section
            task.defer(function()
                if section.Frame then
                    local sf = section.Frame
                    local targetY = sf.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
                    TweenService:Create(page, TweenInfo.new(.35, Enum.EasingStyle.Quart), {CanvasPosition=Vector2.new(0,math.max(0,targetY-6))}):Play()
                end
            end)
            -- highlight
            Tw(diamond,{TextColor3=T.Accent},.15)
            Tw(subLbl,{TextColor3=T.Text},.15)
            task.delay(.8,function()
                Tw(diamond,{TextColor3=T.TextMut},.3)
                Tw(subLbl,{TextColor3=T.TextSub},.3)
            end)
        end)

        -- ── Section card ───────────────────────────────────
        local card = I("Frame",{
            Name=sectionName,
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=T.Card, BorderSizePixel=0, ZIndex=6,
        },page)
        Corner(9,card); Stroke(T.Border,1,card)
        section.Frame = card

        -- card header
        local header = I("Frame",{
            Size=UDim2.new(1,0,0,38),
            BackgroundColor3=T.CardHead, BorderSizePixel=0, ZIndex=7,
        },card)
        Corner(9,header)
        I("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.CardHead,BorderSizePixel=0,ZIndex=7},header)
        I("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=8},header)

        -- accent pill
        local pill = I("Frame",{
            Size=UDim2.new(0,3,0,14), Position=UDim2.new(0,10,.5,-7),
            BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=8,
        },header)
        Corner(2,pill)

        I("TextLabel",{
            Text=string.upper(sectionName),
            Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,20,0,0),
            BackgroundTransparency=1, TextColor3=T.TextSub,
            TextSize=10, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
        },header)

        -- elements container
        local ec = I("Frame",{
            Name="Elements",
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, BorderSizePixel=0, ZIndex=7,
        },card)
        List(ec,1); Pad(6,8,8,8,ec)
        section.Container = ec

        -- ════════════════════════════════════════════════════
        --  ELEMENT FACTORY
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

            -- helper: row
            local function Row(h)
                local f = I("Frame",{
                    Size=UDim2.new(1,0,0,h or 36),
                    BackgroundColor3=T.BG, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=7,
                },ec)
                Corner(6,f); return f
            end

            -- ══════════════════════════════════════════════
            --  TOGGLE (enhanced with glow)
            -- ══════════════════════════════════════════════
            if eType=="Toggle" then
                Library.Flags[flag] = {Toggle=false, Active=false}
                local row = Row(38)

                local hoverBg = I("Frame",{
                    Size=UDim2.new(1,0,1,0), BackgroundColor3=T.Hover,
                    BackgroundTransparency=1, BorderSizePixel=0, ZIndex=7,
                },row); Corner(6,hoverBg)

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-85,1,0), Position=UDim2.new(0,12,0,0),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                -- switch track
                local sw = I("Frame",{
                    Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-48,.5,-10),
                    BackgroundColor3=T.ToggleBg, BorderSizePixel=0, ZIndex=9,
                },row)
                Corner(10,sw); Stroke(T.BorderLight,1,sw)

                -- glow frame (behind switch)
                local glow = I("Frame",{
                    Size=UDim2.new(0,46,0,28), Position=UDim2.new(1,-52,.5,-14),
                    BackgroundColor3=T.AccentGlow, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=8,
                },row)
                Corner(14,glow)

                -- knob
                local knob = I("Frame",{
                    Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,3,.5,-7),
                    BackgroundColor3=T.ToggleKnob, BorderSizePixel=0, ZIndex=10,
                },sw)
                Corner(7,knob)

                -- gear (keybind)
                local gear = I("TextButton",{
                    Text="⚙", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-74,.5,-10),
                    BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=13,
                    Font=Enum.Font.GothamBold, ZIndex=10, Visible=false,
                },row)

                local toggled = false
                local function SetToggle(val, silent)
                    toggled = val
                    Library.Flags[flag].Toggle = val
                    Library.Flags[flag].Active = val
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

                local click = I("TextButton",{
                    Text="", Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1, ZIndex=11,
                },row)
                click.MouseButton1Click:Connect(function() SetToggle(not toggled) end)
                click.MouseEnter:Connect(function() Tw(hoverBg,{BackgroundTransparency=.92},.1) end)
                click.MouseLeave:Connect(function() Tw(hoverBg,{BackgroundTransparency=1},.1) end)

                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem,gear) end)

                elem._gear=gear; elem._row=row
                function elem:add_keybind()
                    self._hasKeybind=true; gear.Visible=true; return self
                end
                function elem:set_value(v) SetToggle(v,false) end

            -- ══════════════════════════════════════════════
            --  SLIDER (enhanced)
            -- ══════════════════════════════════════════════
            elseif eType=="Slider" then
                local cfg  = options.default or {}
                local vMin = cfg.min or 0
                local vMax = cfg.max or 100
                local vDef = cfg.default or vMin
                local vDec = cfg.decimals or 0

                Library.Flags[flag] = {Slider=vDef}
                local row = Row(52)

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(.6,0,0,22), Position=UDim2.new(0,12,0,4),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local valLbl = I("TextLabel",{
                    Text=(vDec>0 and string.format("%."..vDec.."f",vDef) or tostring(vDef)),
                    Size=UDim2.new(.4,-12,0,22), Position=UDim2.new(.6,0,0,4),
                    BackgroundTransparency=1, TextColor3=T.Accent, TextSize=12,
                    Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=9,
                },row)

                -- track
                local track = I("Frame",{
                    Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,0,36),
                    BackgroundColor3=T.SliderTrack, BorderSizePixel=0, ZIndex=9,
                    ClipsDescendants=true,
                },row)
                Corner(3,track)

                local fill = I("Frame",{
                    Size=UDim2.new((vDef-vMin)/(vMax-vMin),0,1,0),
                    BackgroundColor3=T.SliderFill, BorderSizePixel=0, ZIndex=10,
                },track)
                Corner(3,fill)

                -- fill glow
                I("UIGradient",{
                    Color=ColorSequence.new{
                        ColorSequenceKeypoint.new(0,T.AccentDim),
                        ColorSequenceKeypoint.new(1,T.Accent),
                    },
                },fill)

                -- handle
                local handle = I("Frame",{
                    Size=UDim2.new(0,14,0,14), BackgroundColor3=T.SliderKnob,
                    BorderSizePixel=0, ZIndex=11,
                },row)
                Corner(7,handle); Stroke(T.Accent,2,handle)

                local function Fmt(v) return vDec>0 and string.format("%."..vDec.."f",v) or tostring(math.floor(v+.5)) end

                local function PosHandle()
                    local pct = (Library.Flags[flag].Slider-vMin)/(vMax-vMin)
                    local tx  = track.AbsolutePosition.X
                    local tw  = track.AbsoluteSize.X
                    handle.Position = UDim2.new(0, tx - row.AbsolutePosition.X + pct*tw - 7, 0, 30)
                end

                local function SetSlider(v, silent)
                    local f = 10^vDec
                    local r = math.floor(v*f+.5)/f
                    r = math.clamp(r,vMin,vMax)
                    Library.Flags[flag].Slider = r
                    fill.Size = UDim2.new((r-vMin)/(vMax-vMin),0,1,0)
                    valLbl.Text = Fmt(r)
                    PosHandle()
                    if not silent then pcall(callback,{Slider=r}) end
                end
                elem._setValue=SetSlider
                elem._getValue=function() return Library.Flags[flag].Slider end
                task.defer(PosHandle)

                local draggingS = false
                local function Update(inp)
                    local rel = inp.Position.X - track.AbsolutePosition.X
                    local pct = math.clamp(rel/math.max(track.AbsoluteSize.X,1),0,1)
                    SetSlider(vMin+pct*(vMax-vMin))
                end

                local trackClick = I("TextButton",{
                    Text="", Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,28),
                    BackgroundTransparency=1, ZIndex=12,
                },row)
                trackClick.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingS=true; Update(inp) end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingS and inp.UserInputType==Enum.UserInputType.MouseMovement then Update(inp) end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingS=false end
                end)

                elem._row=row
                function elem:set_value(v) SetSlider(v) end

            -- ══════════════════════════════════════════════
            --  DROPDOWN (enhanced)
            -- ══════════════════════════════════════════════
            elseif eType=="Dropdown" then
                local opts   = options.options or {"Option"}
                local defOpt = options.default or opts[1]
                Library.Flags[flag] = {Dropdown=defOpt}
                local row = Row(58)

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,12,0,4),
                    BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=11,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local dropFrame = I("Frame",{
                    Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,22),
                    BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=9,
                },row)
                Corner(7,dropFrame); Stroke(T.BorderLight,1,dropFrame)

                local selLbl = I("TextLabel",{
                    Text=defOpt, Size=UDim2.new(1,-34,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
                },dropFrame)

                local chevron = I("TextLabel",{
                    Text="▾", Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-24,0,0),
                    BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=12,
                    Font=Enum.Font.Gotham, ZIndex=10,
                },dropFrame)

                local function SetDD(val,silent)
                    Library.Flags[flag].Dropdown=val
                    selLbl.Text=val
                    if not silent then pcall(callback,{Dropdown=val}) end
                end
                elem._setValue=SetDD
                elem._getValue=function() return Library.Flags[flag].Dropdown end

                local clickArea = I("TextButton",{
                    Text="", Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1, ZIndex=11,
                },dropFrame)
                clickArea.MouseButton1Click:Connect(function()
                    -- animate chevron
                    Tw(chevron,{Rotation=180},.2)
                    win:_openDropdown(opts,dropFrame,function(v,s)
                        SetDD(v,s)
                        Tw(chevron,{Rotation=0},.2)
                    end, function()
                        Tw(chevron,{Rotation=0},.2)
                    end)
                end)
                clickArea.MouseEnter:Connect(function() Tw(dropFrame,{BackgroundColor3=T.Hover},.1) end)
                clickArea.MouseLeave:Connect(function() Tw(dropFrame,{BackgroundColor3=T.Elevated},.1) end)

                elem._row=row
                function elem:set_value(v) SetDD(v) end

            -- ══════════════════════════════════════════════
            --  COMBO (multi-select)
            -- ══════════════════════════════════════════════
            elseif eType=="Combo" then
                local opts   = options.options or {}
                local defSel = options.default or {}
                Library.Flags[flag] = {Combo={table.unpack(defSel)}}
                local row = Row(0); row.AutomaticSize=Enum.AutomaticSize.Y

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-10,0,24), Position=UDim2.new(0,12,0,4),
                    BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=11,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local checks = I("Frame",{
                    Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,28),
                    AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=9,
                },row)
                List(checks,4)
                I("Frame",{Size=UDim2.new(1,0,0,6),BackgroundTransparency=1,LayoutOrder=999},checks)

                for _,opt in ipairs(opts) do
                    local isSel = table.find(defSel,opt)~=nil
                    local cr = I("Frame",{
                        Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
                        BorderSizePixel=0, ZIndex=9,
                    },checks)

                    local cb = I("Frame",{
                        Size=UDim2.new(0,15,0,15), Position=UDim2.new(0,2,.5,-7),
                        BackgroundColor3=isSel and T.Accent or T.ToggleBg,
                        BorderSizePixel=0, ZIndex=10,
                    },cr)
                    Corner(4,cb); Stroke(T.BorderLight,1,cb)

                    local ck = I("TextLabel",{
                        Text="✓", Size=UDim2.new(1,0,1,0),
                        BackgroundTransparency=1, TextColor3=Color3.new(1,1,1),
                        TextSize=9, Font=Enum.Font.GothamBold, Visible=isSel, ZIndex=11,
                    },cb)

                    I("TextLabel",{
                        Text=opt, Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,22,0,0),
                        BackgroundTransparency=1, TextColor3=T.Text, TextSize=11,
                        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
                    },cr)

                    local cp = I("TextButton",{
                        Text="", Size=UDim2.new(1,0,1,0),
                        BackgroundTransparency=1, ZIndex=12,
                    },cr)
                    cp.MouseButton1Click:Connect(function()
                        local cur = Library.Flags[flag].Combo
                        local idx = table.find(cur,opt)
                        if idx then
                            table.remove(cur,idx); ck.Visible=false
                            Tw(cb,{BackgroundColor3=T.ToggleBg},.12)
                        else
                            table.insert(cur,opt); ck.Visible=true
                            Tw(cb,{BackgroundColor3=T.Accent},.12)
                        end
                        pcall(callback,{Combo=cur})
                    end)
                end
                elem._row=row

            -- ══════════════════════════════════════════════
            --  BUTTON (with ripple feedback)
            -- ══════════════════════════════════════════════
            elseif eType=="Button" then
                local row = Row(40)
                local btn = I("TextButton",{
                    Text=eName,
                    Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,.5,-15),
                    BackgroundColor3=T.Elevated, TextColor3=T.Text,
                    TextSize=12, Font=Enum.Font.Gotham, BorderSizePixel=0,
                    AutoButtonColor=false, ZIndex=9,
                    ClipsDescendants=true,
                },row)
                Corner(7,btn); Stroke(T.BorderLight,1,btn)

                btn.MouseButton1Click:Connect(function()
                    Tw(btn,{BackgroundColor3=T.Accent,TextColor3=Color3.new(1,1,1)},.08)
                    task.delay(.2,function() Tw(btn,{BackgroundColor3=T.Elevated,TextColor3=T.Text},.2) end)
                    pcall(callback,{})
                end)
                btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=T.Hover},.1) end)
                btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=T.Elevated},.1) end)
                elem._row=row

            -- ══════════════════════════════════════════════
            --  TEXTBOX (enhanced focus)
            -- ══════════════════════════════════════════════
            elseif eType=="TextBox" then
                Library.Flags[flag] = {Text=options.default or ""}
                local row = Row(58)

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,12,0,4),
                    BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=11,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local tb = I("TextBox",{
                    Text=options.default or "", PlaceholderText=options.placeholder or "Enter value...",
                    Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,22),
                    BackgroundColor3=T.Elevated, TextColor3=T.Text,
                    PlaceholderColor3=T.TextDis, TextSize=12, Font=Enum.Font.Gotham,
                    ClearTextOnFocus=false, BorderSizePixel=0,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)
                Corner(7,tb); local st=Stroke(T.BorderLight,1,tb); Pad(0,0,10,10,tb)

                -- focus glow
                local focusGlow = I("Frame",{
                    Size=UDim2.new(1,8,1,8), Position=UDim2.new(0,-4,0,-4+22),
                    BackgroundColor3=T.AccentGlow, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=8,
                },row)
                Corner(10,focusGlow)

                tb.Focused:Connect(function()
                    Tw(st,{Color=T.Accent},.15)
                    Tw(tb,{BackgroundColor3=T.Hover},.15)
                    Tw(focusGlow,{BackgroundTransparency=.9},.2)
                end)
                tb.FocusLost:Connect(function(enter)
                    Tw(st,{Color=T.BorderLight},.15)
                    Tw(tb,{BackgroundColor3=T.Elevated},.15)
                    Tw(focusGlow,{BackgroundTransparency=1},.2)
                    Library.Flags[flag].Text=tb.Text
                    pcall(callback,{Text=tb.Text,Enter=enter})
                end)
                tb:GetPropertyChangedSignal("Text"):Connect(function()
                    Library.Flags[flag].Text=tb.Text
                end)

                elem._row=row; elem._tb=tb
                function elem:set_value(v) tb.Text=tostring(v); Library.Flags[flag].Text=tostring(v) end

            -- ══════════════════════════════════════════════
            --  COLOR PICKER
            -- ══════════════════════════════════════════════
            elseif eType=="ColorPicker" then
                local defColor = options.default or Color3.fromRGB(255,0,0)
                Library.Flags[flag] = {Color=defColor}
                local h,s,v = Color3.toHSV(defColor)

                local row = Row(38)

                I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,12,0,0),
                    BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9,
                },row)

                local preview = I("TextButton",{
                    Text="", Size=UDim2.new(0,28,0,22),
                    Position=UDim2.new(1,-42,.5,-11),
                    BackgroundColor3=defColor, BorderSizePixel=0,
                    AutoButtonColor=false, ZIndex=9,
                },row)
                Corner(6,preview); Stroke(T.BorderLight,1,preview)
                elem._preview = preview

                local pickerOpen = false
                local pickerFrame = nil

                local function UpdateColor(silent)
                    local c = Color3.fromHSV(h,s,v)
                    Library.Flags[flag].Color = c
                    preview.BackgroundColor3 = c
                    if not silent then pcall(callback,{Color=c}) end
                end

                preview.MouseButton1Click:Connect(function()
                    if pickerOpen and pickerFrame then
                        pickerFrame:Destroy(); pickerFrame=nil; pickerOpen=false
                        return
                    end
                    pickerOpen=true

                    local pf = I("Frame",{
                        Size=UDim2.new(0,220,0,190),
                        BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=600,
                    },win.Overlay)
                    Corner(9,pf); Stroke(T.BorderLight,1,pf); Shadow(pf,600)
                    pickerFrame=pf

                    task.defer(function()
                        local ap = preview.AbsolutePosition
                        pf.Position = UDim2.new(0,ap.X-190,0,ap.Y+30)
                    end)

                    -- header
                    I("TextLabel",{
                        Text="COLOR  ·  "..eName,
                        Size=UDim2.new(1,-16,0,24), Position=UDim2.new(0,10,0,4),
                        BackgroundTransparency=1, TextColor3=T.TextSub,
                        TextSize=9, Font=Enum.Font.GothamBold,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
                    },pf)

                    -- SV square
                    local svSize = 150
                    local svFrame = I("Frame",{
                        Size=UDim2.new(0,svSize,0,svSize),
                        Position=UDim2.new(0,10,0,30),
                        BackgroundColor3=Color3.fromHSV(h,1,1),
                        BorderSizePixel=0, ZIndex=601,
                        ClipsDescendants=true,
                    },pf)
                    Corner(5,svFrame)

                    -- white overlay (saturation)
                    local whiteOv = I("Frame",{
                        Size=UDim2.new(1,0,1,0),
                        BackgroundColor3=Color3.new(1,1,1),
                        BorderSizePixel=0, ZIndex=602,
                    },svFrame)
                    I("UIGradient",{
                        Transparency=NumberSequence.new{
                            NumberSequenceKeypoint.new(0,0),
                            NumberSequenceKeypoint.new(1,1),
                        },
                    },whiteOv)

                    -- black overlay (value)
                    local blackOv = I("Frame",{
                        Size=UDim2.new(1,0,1,0),
                        BackgroundColor3=Color3.new(0,0,0),
                        BorderSizePixel=0, ZIndex=603,
                    },svFrame)
                    I("UIGradient",{
                        Transparency=NumberSequence.new{
                            NumberSequenceKeypoint.new(0,1),
                            NumberSequenceKeypoint.new(1,0),
                        },
                        Rotation=90,
                    },blackOv)

                    -- SV cursor
                    local svCursor = I("Frame",{
                        Size=UDim2.new(0,10,0,10),
                        Position=UDim2.new(s,  -5, 1-v, -5),
                        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=605,
                    },svFrame)
                    Corner(5,svCursor); Stroke(Color3.new(1,1,1),2,svCursor)

                    -- Hue bar (vertical, right side)
                    local hueBar = I("Frame",{
                        Size=UDim2.new(0,20,0,svSize),
                        Position=UDim2.new(0,svSize+16,0,30),
                        BackgroundColor3=Color3.new(1,1,1),
                        BorderSizePixel=0, ZIndex=601,
                    },pf)
                    Corner(4,hueBar)

                    I("UIGradient",{
                        Color=ColorSequence.new{
                            ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,1,1)),
                            ColorSequenceKeypoint.new(.167, Color3.fromHSV(.167,1,1)),
                            ColorSequenceKeypoint.new(.333, Color3.fromHSV(.333,1,1)),
                            ColorSequenceKeypoint.new(.5,   Color3.fromHSV(.5,1,1)),
                            ColorSequenceKeypoint.new(.667, Color3.fromHSV(.667,1,1)),
                            ColorSequenceKeypoint.new(.833, Color3.fromHSV(.833,1,1)),
                            ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
                        },
                        Rotation=90,
                    },hueBar)

                    -- hue cursor
                    local hueCursor = I("Frame",{
                        Size=UDim2.new(1,4,0,4),
                        Position=UDim2.new(0,-2,h,-2),
                        BackgroundColor3=Color3.new(1,1,1),
                        BorderSizePixel=0, ZIndex=602,
                    },hueBar)
                    Corner(2,hueCursor)

                    -- SV drag
                    local svDrag=false
                    local svBtn = I("TextButton",{
                        Text="", Size=UDim2.new(1,0,1,0),
                        BackgroundTransparency=1, ZIndex=606,
                    },svFrame)
                    svBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if svDrag and inp.UserInputType==Enum.UserInputType.MouseMovement then
                            local rx = math.clamp((inp.Position.X-svFrame.AbsolutePosition.X)/svSize,0,1)
                            local ry = math.clamp((inp.Position.Y-svFrame.AbsolutePosition.Y)/svSize,0,1)
                            s=rx; v=1-ry
                            svCursor.Position=UDim2.new(s,-5,1-v,-5)
                            UpdateColor()
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
                    end)

                    -- Hue drag
                    local hueDrag=false
                    local hueBtn = I("TextButton",{
                        Text="", Size=UDim2.new(1,0,1,0),
                        BackgroundTransparency=1, ZIndex=602,
                    },hueBar)
                    hueBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if hueDrag and inp.UserInputType==Enum.UserInputType.MouseMovement then
                            local ry = math.clamp((inp.Position.Y-hueBar.AbsolutePosition.Y)/svSize,0,1)
                            h=ry
                            hueCursor.Position=UDim2.new(0,-2,h,-2)
                            svFrame.BackgroundColor3=Color3.fromHSV(h,1,1)
                            UpdateColor()
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
                    end)

                    -- outside click to close
                    local oc; oc = UserInputService.InputBegan:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                            task.defer(function()
                                if not pf or not pf.Parent then oc:Disconnect() return end
                                local mp=UserInputService:GetMouseLocation()
                                local pp,ps=pf.AbsolutePosition,pf.AbsoluteSize
                                if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
                                    pf:Destroy(); pickerFrame=nil; pickerOpen=false; oc:Disconnect()
                                end
                            end)
                        end
                    end)
                end)

                elem._row=row
                function elem:set_value(c)
                    h,s,v=Color3.toHSV(c)
                    Library.Flags[flag].Color=c
                    preview.BackgroundColor3=c
                end

            -- ══════════════════════════════════════════════
            --  LABEL
            -- ══════════════════════════════════════════════
            elseif eType=="Label" then
                local row = Row(0); row.AutomaticSize=Enum.AutomaticSize.Y
                local lbl = I("TextLabel",{
                    Text=eName, Size=UDim2.new(1,-24,0,0),
                    AutomaticSize=Enum.AutomaticSize.Y,
                    Position=UDim2.new(0,12,0,8),
                    BackgroundTransparency=1, TextColor3=T.TextSub,
                    TextSize=11, Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true, ZIndex=9,
                },row)
                I("Frame",{Size=UDim2.new(1,0,0,8),BackgroundTransparency=1},row)
                elem._row=row
                function elem:set_text(t) lbl.Text=t end

            -- ══════════════════════════════════════════════
            --  SEPARATOR
            -- ══════════════════════════════════════════════
            elseif eType=="Separator" then
                local row = Row(22)
                I("Frame",{
                    Size=UDim2.new(1,-24,0,1), Position=UDim2.new(0,12,.5,0),
                    BackgroundColor3=T.Border, BorderSizePixel=0, ZIndex=9,
                },row)
                if eName and eName~="" then
                    I("TextLabel",{
                        Text=" "..eName.." ",
                        Size=UDim2.new(0,0,0,14), AutomaticSize=Enum.AutomaticSize.X,
                        Position=UDim2.new(.5,0,.5,-7),
                        BackgroundColor3=T.Card, TextColor3=T.TextMut,
                        TextSize=10, Font=Enum.Font.Gotham,
                        BorderSizePixel=0, ZIndex=10,
                    },row)
                end
                elem._row=row
            end

            Library.Elements[flag]=elem
            table.insert(section.Elements,elem)
            return elem
        end -- section:element

        table.insert(tab.Sections, section)
        return section
    end -- tab:new_section

    return tab
end -- Library:new_tab

-- ══════════════════════════════════════════════════════════════
--  TAB SWITCHING
-- ══════════════════════════════════════════════════════════════
function Library:SelectTab(target)
    for _,t in ipairs(self.Tabs) do
        t.Active = false
        t.Page.Visible = false
        t.SubContainer.Visible = false
        Tw(t.IconBtn,{BackgroundTransparency=.5,BackgroundColor3=self.Main and T.IconBar or T.IconBar},.15)
        Tw(t.IconLabel,{TextColor3=T.TextMut},.15)
        Tw(t.Indicator,{BackgroundColor3=T.TextMut,Size=UDim2.new(0,3,0,18)},.15)
    end
    target.Active = true
    target.Page.Visible = true
    target.SubContainer.Visible = true
    Tw(target.IconBtn,{BackgroundTransparency=0,BackgroundColor3=T.Active},.15)
    Tw(target.IconLabel,{TextColor3=T.Accent},.15)
    Tw(target.Indicator,{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,0,24)},.15)
    self.ActiveTab = target
    self:_closePopups()
end

-- ══════════════════════════════════════════════════════════════
--  POPUP HELPERS
-- ══════════════════════════════════════════════════════════════
function Library:_closePopups()
    if self._popup then pcall(function() self._popup:Destroy() end); self._popup=nil; self._popupElem=nil end
    if self._dropdown then pcall(function() self._dropdown:Destroy() end); self._dropdown=nil end
end

-- ══════════════════════════════════════════════════════════════
--  KEYBIND POPUP (enhanced)
-- ══════════════════════════════════════════════════════════════
function Library:_openKeybindPopup(elem, anchor)
    if self._popup then
        local wasThis = self._popupElem==elem
        self:_closePopups()
        if wasThis then return end
    end
    self._popupElem = elem

    local popup = I("Frame",{
        Size=UDim2.new(0,200,0,150),
        BackgroundColor3=T.Elevated, BorderSizePixel=0, ZIndex=600,
    },self.Overlay)
    Corner(9,popup); Stroke(T.BorderLight,1,popup); Shadow(popup,600)
    self._popup = popup

    task.defer(function()
        local ap,as = anchor.AbsolutePosition, anchor.AbsoluteSize
        popup.Position = UDim2.new(0, math.clamp(ap.X-200+as.X+4,0,1000), 0, ap.Y+as.Y+8)
    end)

    -- header
    I("TextLabel",{
        Text="KEYBIND  ·  "..elem.Name,
        Size=UDim2.new(1,-20,0,24), Position=UDim2.new(0,12,0,6),
        BackgroundTransparency=1, TextColor3=T.TextSub,
        TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
    },popup)

    -- key button
    local keyStr = elem._keybind and KeyName(elem._keybind) or "None"
    local keyBtn = I("TextButton",{
        Text=keyStr, Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,32),
        BackgroundColor3=T.Panel, TextColor3=T.Text,
        TextSize=12, Font=Enum.Font.Gotham,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=601,
    },popup)
    Corner(6,keyBtn); Stroke(T.Border,1,keyBtn)

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true; keyBtn.Text="Press a key..."; keyBtn.TextColor3=T.Accent
        Tw(keyBtn,{BackgroundColor3=T.Hover},.1)
        local conn; conn=UserInputService.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                elem._keybind=inp.KeyCode
                keyBtn.Text=KeyName(inp.KeyCode)
                keyBtn.TextColor3=T.Text
                Tw(keyBtn,{BackgroundColor3=T.Panel},.1)
                listening=false; conn:Disconnect()
            end
        end)
    end)
    keyBtn.MouseEnter:Connect(function() Tw(keyBtn,{BackgroundColor3=T.Hover},.1) end)
    keyBtn.MouseLeave:Connect(function() if not listening then Tw(keyBtn,{BackgroundColor3=T.Panel},.1) end end)

    -- clear bind button
    local clearBtn = I("TextButton",{
        Text="Clear", Size=UDim2.new(0,50,0,20),
        Position=UDim2.new(1,-60,0,37),
        BackgroundTransparency=1, TextColor3=T.Danger,
        TextSize=10, Font=Enum.Font.GothamBold, ZIndex=602,
    },popup)
    clearBtn.MouseButton1Click:Connect(function()
        elem._keybind=nil; keyBtn.Text="None"; keyBtn.TextColor3=T.TextSub
    end)

    -- mode label
    I("TextLabel",{
        Text="MODE", Size=UDim2.new(1,-20,0,16), Position=UDim2.new(0,12,0,72),
        BackgroundTransparency=1, TextColor3=T.TextMut, TextSize=9,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=601,
    },popup)

    -- mode track
    local mTrack = I("Frame",{
        Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,88),
        BackgroundColor3=T.Panel, BorderSizePixel=0, ZIndex=601,
    },popup)
    Corner(8,mTrack)

    local function MBtn(label,xOff,active)
        local mb = I("TextButton",{
            Text=label, Size=UDim2.new(.5,-3,1,-4),
            Position=UDim2.new(xOff, xOff==0 and 2 or 1, 0, 2),
            BackgroundColor3=active and T.Accent or T.Panel,
            TextColor3=active and Color3.new(1,1,1) or T.TextSub,
            TextSize=11, Font=Enum.Font.Gotham,
            BorderSizePixel=0, AutoButtonColor=false, ZIndex=602,
        },mTrack)
        Corner(6,mb); return mb
    end

    local tBtn = MBtn("Toggle",0,   elem._keybindMode=="Toggle")
    local hBtn = MBtn("Hold",  .5, elem._keybindMode=="Hold")

    local function SetMode(m)
        elem._keybindMode=m
        Tw(tBtn,{BackgroundColor3=m=="Toggle" and T.Accent or T.Panel},.12)
        tBtn.TextColor3 = m=="Toggle" and Color3.new(1,1,1) or T.TextSub
        Tw(hBtn,{BackgroundColor3=m=="Hold" and T.Accent or T.Panel},.12)
        hBtn.TextColor3 = m=="Hold" and Color3.new(1,1,1) or T.TextSub
    end
    tBtn.MouseButton1Click:Connect(function() SetMode("Toggle") end)
    hBtn.MouseButton1Click:Connect(function() SetMode("Hold") end)

    -- close on outside click
    local oc; oc=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not popup or not popup.Parent then oc:Disconnect() return end
                local mp=UserInputService:GetMouseLocation()
                local pp,ps=popup.AbsolutePosition,popup.AbsoluteSize
                if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
                    self:_closePopups(); oc:Disconnect()
                end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  DROPDOWN POPUP (enhanced)
-- ══════════════════════════════════════════════════════════════
function Library:_openDropdown(options, anchor, setFn, onClose)
    if self._dropdown then
        self._dropdown:Destroy(); self._dropdown=nil
        if onClose then onClose() end
        return
    end

    local IH, MAX = 30, 7
    local shown   = math.min(#options, MAX)
    local totalH  = shown*IH + 12

    local dd = I("Frame",{
        Size=UDim2.new(0,anchor.AbsoluteSize.X,0,0),
        BackgroundColor3=T.Elevated, BorderSizePixel=0,
        ZIndex=600, ClipsDescendants=true,
    },self.Overlay)
    Corner(8,dd); Stroke(T.BorderLight,1,dd); Shadow(dd,600)
    self._dropdown = dd

    task.defer(function()
        local ap,as = anchor.AbsolutePosition, anchor.AbsoluteSize
        dd.Position = UDim2.new(0,ap.X,0,ap.Y+as.Y+4)
        -- animate open
        Tw(dd,{Size=UDim2.new(0,as.X,0,totalH)},.2)
    end)

    local scroll = I("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=2,
        ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,#options*IH+12), ZIndex=601,
    },dd)
    List(scroll,1); Pad(5,5,5,5,scroll)

    for _,opt in ipairs(options) do
        local item = I("TextButton",{
            Text=opt, Size=UDim2.new(1,0,0,IH),
            BackgroundColor3=T.Hover, BackgroundTransparency=1,
            TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=602,
        },scroll)
        Corner(5,item); Pad(0,0,10,8,item)

        item.MouseEnter:Connect(function() Tw(item,{BackgroundTransparency=.7},.08) end)
        item.MouseLeave:Connect(function() Tw(item,{BackgroundTransparency=1},.08) end)
        item.MouseButton1Click:Connect(function()
            setFn(opt,false)
            -- animate close
            Tw(dd,{Size=UDim2.new(0,dd.AbsoluteSize.X,0,0)},.15)
            task.delay(.16,function()
                if dd and dd.Parent then dd:Destroy() end
                self._dropdown=nil
            end)
        end)
    end

    local oc; oc=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if not dd or not dd.Parent then oc:Disconnect() return end
                local mp=UserInputService:GetMouseLocation()
                local pp,ps=dd.AbsolutePosition,dd.AbsoluteSize
                if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
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
function Library:Toggle()
    self.Open = not self.Open
    self.Main.Visible = self.Open
end

function Library:SetOpen(state)
    self.Open = state
    if state then
        self.Main.Visible = true
        Tw(self.Main, {Size = self._fullSize}, .2)
    else
        Tw(self.Main, {Size = UDim2.new(0,0,0,0)}, .2)
        task.delay(.21, function() self.Main.Visible = false end)
    end
end

function Library:Destroy()
    pcall(function() self.Gui:Destroy() end)
end

function Library:SaveConfig(name)
    pcall(function()
        local data = {}
        for flag,val in pairs(Library.Flags) do
            local copy = {}
            for k,v in pairs(val) do
                if typeof(v)=="Color3" then
                    copy[k] = {R=v.R,G=v.G,B=v.B,_isColor3=true}
                else
                    copy[k] = v
                end
            end
            data[flag] = copy
        end
        local folder = "NexUI_configs\\"
        pcall(makefolder, folder)
        writefile(folder..name..".json", HttpService:JSONEncode(data))
    end)
end

function Library:LoadConfig(name)
    pcall(function()
        local folder = "NexUI_configs\\"
        local raw = readfile(folder..name..".json")
        local data = HttpService:JSONDecode(raw)
        for flag,val in pairs(data) do
            -- restore Color3
            for k,v in pairs(val) do
                if type(v)=="table" and v._isColor3 then
                    val[k] = Color3.new(v.R,v.G,v.B)
                end
            end
            Library.Flags[flag] = val
            local elem = Library.Elements[flag]
            if elem and elem._setValue then
                if elem.Type=="Toggle"      then pcall(elem._setValue,val.Toggle,true) end
                if elem.Type=="Slider"      then pcall(elem._setValue,val.Slider,true) end
                if elem.Type=="Dropdown"    then pcall(elem._setValue,val.Dropdown,true) end
                if elem.Type=="ColorPicker" then pcall(elem.set_value,elem,val.Color) end
            end
        end
    end)
end

function Library:ListConfigs()
    local out = {}
    pcall(function()
        local folder = "NexUI_configs\\"
        pcall(makefolder, folder)
        for _,f in next, listfiles(folder) do
            table.insert(out, f:gsub(folder,""):gsub("%.json$",""))
        end
    end)
    return out
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM (enhanced with progress bar)
-- ══════════════════════════════════════════════════════════════
Library._notifHolder = nil

function Library:Notify(title, desc, duration, nType)
    if not Library._notifHolder or not Library._notifHolder.Parent then
        local ng = I("ScreenGui",{
            Name="__NexUI_Notif", ResetOnSpawn=false,
            ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=2000,
        })
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(ng); ng.Parent=game.CoreGui
            else ng.Parent=LocalPlayer:WaitForChild("PlayerGui") end
        end)
        Library._notifHolder = I("Frame",{
            Size=UDim2.new(0,300,1,0), Position=UDim2.new(1,-315,0,0),
            BackgroundTransparency=1, BorderSizePixel=0,
        },ng)
        List(Library._notifHolder,8)
        Pad(12,12,0,0,Library._notifHolder)
    end

    duration = duration or 3.5
    nType = nType or "info"
    local accent = ({
        info=T.Accent, success=T.Success, warning=T.Warning, error=T.Danger,
    })[nType] or T.Accent

    local nf = I("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=T.Panel, BorderSizePixel=0,
        BackgroundTransparency=1, ZIndex=10, ClipsDescendants=true,
    },Library._notifHolder)
    Corner(9,nf); Stroke(T.Border,1,nf)

    -- accent bar left
    I("Frame",{
        Size=UDim2.new(0,3,1,0), BackgroundColor3=accent,
        BorderSizePixel=0, ZIndex=11,
    },nf)

    -- progress bar bottom
    local prog = I("Frame",{
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=accent, BorderSizePixel=0, ZIndex=12,
    },nf)

    local inner = I("Frame",{
        Size=UDim2.new(1,-3,0,0), Position=UDim2.new(0,3,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=11,
    },nf)

    I("TextLabel",{
        Text=title or "Notification",
        Size=UDim2.new(1,-16,0,22), Position=UDim2.new(0,10,0,8),
        BackgroundTransparency=1, TextColor3=T.Text, TextSize=12,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    },inner)

    if desc and desc~="" then
        I("TextLabel",{
            Text=desc, Size=UDim2.new(1,-16,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            Position=UDim2.new(0,10,0,28),
            BackgroundTransparency=1, TextColor3=T.TextSub, TextSize=11,
            Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true, ZIndex=12,
        },inner)
    end
    I("Frame",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1},inner)

    -- animate in
    Tw(nf,{BackgroundTransparency=0},.25)

    -- progress bar countdown
    Tw(prog,{Size=UDim2.new(0,0,0,2)},duration,Enum.EasingStyle.Linear)

    task.delay(duration,function()
        Tw(nf,{BackgroundTransparency=1},.35)
        task.delay(.4,function() pcall(function() nf:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════════════════════
return Library
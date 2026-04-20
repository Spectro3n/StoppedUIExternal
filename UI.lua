local Library    = {}
Library.__index  = Library
Library.Flags    = {}
Library.Elements = {}
Library.Windows  = {}
Library._themed  = {}
Library._deps    = {}

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
        BG=Color3.fromRGB(18,18,22),IconBar=Color3.fromRGB(22,22,26),Panel=Color3.fromRGB(26,26,30),
        Elevated=Color3.fromRGB(34,34,38),Hover=Color3.fromRGB(42,42,48),Active=Color3.fromRGB(50,50,56),
        Card=Color3.fromRGB(24,24,28),CardHead=Color3.fromRGB(30,30,34),
        Accent=Color3.fromRGB(160,165,175),AccentDim=Color3.fromRGB(90,92,100),AccentGlow=Color3.fromRGB(130,135,145),
        Text=Color3.fromRGB(220,220,225),TextSub=Color3.fromRGB(130,130,140),
        TextMut=Color3.fromRGB(68,68,78),TextDis=Color3.fromRGB(44,44,52),
        Border=Color3.fromRGB(36,36,42),BorderLight=Color3.fromRGB(50,50,58),
        Success=Color3.fromRGB(75,210,120),Warning=Color3.fromRGB(245,190,60),Danger=Color3.fromRGB(220,65,65),
        ToggleBg=Color3.fromRGB(28,28,32),ToggleKnob=Color3.fromRGB(80,80,90),
        SliderTrack=Color3.fromRGB(26,26,30),SliderFill=Color3.fromRGB(160,165,175),SliderKnob=Color3.fromRGB(220,222,228),
    },
    Stopped = {
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
        BG=Color3.fromRGB(10,12,18),IconBar=Color3.fromRGB(12,14,22),Panel=Color3.fromRGB(16,18,28),
        Elevated=Color3.fromRGB(24,26,40),Hover=Color3.fromRGB(32,34,52),Active=Color3.fromRGB(40,42,60),
        Card=Color3.fromRGB(18,20,30),CardHead=Color3.fromRGB(22,24,36),
        Accent=Color3.fromRGB(80,140,255),AccentDim=Color3.fromRGB(40,90,150),AccentGlow=Color3.fromRGB(60,110,220),
        Text=Color3.fromRGB(230,235,245),TextSub=Color3.fromRGB(140,150,165),
        TextMut=Color3.fromRGB(75,85,100),TextDis=Color3.fromRGB(50,60,70),
        Border=Color3.fromRGB(30,35,45),BorderLight=Color3.fromRGB(45,52,65),
        Success=Color3.fromRGB(45,215,115),Warning=Color3.fromRGB(255,185,35),Danger=Color3.fromRGB(225,55,55),
        ToggleBg=Color3.fromRGB(24,26,36),ToggleKnob=Color3.fromRGB(90,100,115),
        SliderTrack=Color3.fromRGB(22,24,34),SliderFill=Color3.fromRGB(80,140,255),SliderKnob=Color3.fromRGB(200,220,255),
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
    if not theme then warn("[NexUI] Theme not found: " .. tostring(name)); return end
    Library.CurrentTheme = name
    for k, v in pairs(theme) do T[k] = v end
    local alive = {}
    for _, e in ipairs(Library._themed) do
        if e[1] and typeof(e[1]) == "Instance" then
            local ok = pcall(function() return e[1].Parent end)
            if ok then
                pcall(function()
                    TS:Create(e[1], TweenInfo.new(.4, Enum.EasingStyle.Quint), {[e[2]] = T[e[3]]}):Play()
                end)
                table.insert(alive, e)
            end
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

local function RegUpdate(o, p, k)
    if not o then return end
    for _, t in ipairs(Library._themed) do
        if t[1] == o and t[2] == p then
            t[3] = k
            pcall(function() o[p] = T[k] end)
            return
        end
    end
    Reg(o, p, k)
end

local function UnReg(o, p)
    for i = #Library._themed, 1, -1 do
        local t = Library._themed[i]
        if t[1] == o and t[2] == p then
            table.remove(Library._themed, i)
        end
    end
end

-- ═══════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════
local function Tw(o, p, t, s, d)
    if not o then return end
    local ok = pcall(function() return o.Parent end)
    if not ok then return end
    pcall(function()
        TS:Create(o, TweenInfo.new(t or .2, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p):Play()
    end)
end

local function TwWait(o, p, t, s, d)
    if not o then return nil end
    local ok = pcall(function() return o.Parent end)
    if not ok then return nil end
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
    return I("UIPadding", {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
    }, p)
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

local function KeyName(kc)
    if not kc then return "None" end
    return tostring(kc):gsub("Enum%.KeyCode%.", "")
end

local function IsOut(pos, f)
    if not f then return true end
    local ok, p, s = pcall(function() return f.AbsolutePosition, f.AbsoluteSize end)
    if not ok then return true end
    return pos.X < p.X or pos.X > p.X + s.X or pos.Y < p.Y or pos.Y > p.Y + s.Y
end

local function Color3ToHex(c)
    return string.format("#%02X%02X%02X", math.floor(c.R*255+.5), math.floor(c.G*255+.5), math.floor(c.B*255+.5))
end

local function HexToColor3(hex)
    hex = hex:gsub("#","")
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

-- ★ Shallow compare for MultiDropdown dirty state
local function ShallowEqual(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return a == b end
    for k, v in pairs(a) do if b[k] ~= v then return false end end
    for k, v in pairs(b) do if a[k] ~= v then return false end end
    return true
end

-- Connection manager
local function NewConnBag()
    local bag = {}
    function bag:Add(conn)
        if conn then table.insert(bag, conn) end
        return conn
    end
    function bag:DisconnectAll()
        for i = #bag, 1, -1 do
            if type(bag[i]) == "userdata" or (type(bag[i]) == "table" and bag[i].Disconnect) then
                pcall(function() bag[i]:Disconnect() end)
            end
            bag[i] = nil
        end
    end
    return bag
end

-- Dependency check
local function CheckDeps(changedFlag)
    for depFlag, dep in pairs(Library._deps) do
        if dep.target == changedFlag then
            local elem = Library.Elements[depFlag]
            local flags = Library.Flags[changedFlag]
            if elem and elem._row and flags then
                local ok, vis = pcall(dep.condition, flags)
                if ok then elem._row.Visible = vis and true or false end
            end
        end
    end
end

-- Common element methods
local function InjectElementMethods(elem)
    function elem:set_visible(bool)
        if self._row then self._row.Visible = bool end
    end
    function elem:set_callback(fn)
        self._callback = fn
    end
    function elem:get_value()
        if self._getValue then return self._getValue() end
        return Library.Flags[self.Flag]
    end
    function elem:depends_on(targetFlag, conditionFn)
        Library._deps[self.Flag] = {target = targetFlag, condition = conditionFn}
        local flags = Library.Flags[targetFlag]
        if flags then
            local ok, vis = pcall(conditionFn, flags)
            if ok and not vis and self._row then self._row.Visible = false end
        end
        return self
    end
end

-- ★ DIRTY STATE: cria o indicador de alteração
local function CreateDirtyDot(parent, yOff)
    local dot = I("Frame", {
        Size = UDim2.new(0, 5, 0, 5),
        Position = UDim2.new(0, 2, 0, yOff or 12),
        BackgroundColor3 = T.Warning, BorderSizePixel = 0,
        Visible = false, ZIndex = 12,
    }, parent)
    Cn(3, dot); Reg(dot, "BackgroundColor3", "Warning")
    return dot
end

local function UpdateDirty(dot, current, default, elemType)
    if not dot then return end
    local dirty = false
    if elemType == "MultiDropdown" then
        dirty = not ShallowEqual(current, default)
    elseif elemType == "ColorPicker" then
        dirty = Color3ToHex(current) ~= Color3ToHex(default)
    else
        dirty = current ~= default
    end
    if dirty and not dot.Visible then
        dot.Visible = true
        dot.Size = UDim2.new(0, 0, 0, 0)
        Tw(dot, {Size = UDim2.new(0, 5, 0, 5)}, .2, Enum.EasingStyle.Back)
    elseif not dirty and dot.Visible then
        Tw(dot, {Size = UDim2.new(0, 0, 0, 0)}, .12)
        task.delay(.13, function()
            if dot and dot.Parent then dot.Visible = false end
        end)
    end
end

-- ★ FROSTED GLASS: overlay sutil para painéis
local function ApplyFrost(parent, zBase)
    local ov = I("Frame", {
        Name = "_frost", Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.BG, BackgroundTransparency = .80,
        BorderSizePixel = 0, ZIndex = (zBase or 1) + 1,
    }, parent)
    Reg(ov, "BackgroundColor3", "BG")
    Cn(12, ov)
    I("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, .92),
            NumberSequenceKeypoint.new(.4, .99),
            NumberSequenceKeypoint.new(.7, .96),
            NumberSequenceKeypoint.new(1, .93),
        },
        Rotation = 135,
    }, ov)
    return ov
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
    win._allConns = NewConnBag()

    local W, H = 780, 490
    local TB, DK, GAP = 46, 56, 10

    -- ScreenGui
    local gui = I("ScreenGui", {
        Name = "__NexUI_" .. math.random(1e4, 9e4),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
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

    -- Overlay (★ ZIndex alto para popups)
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
    Reg(tooltipLbl, "BackgroundColor3", "Elevated"); Reg(tooltipLbl, "TextColor3", "Text")
    win._tooltipLabel = tooltipLbl

    local tooltipConn
    function win:_showTooltip(text)
        if not text or text == "" then return end
        tooltipLbl.Text = text; tooltipLbl.Visible = true
        if tooltipConn then tooltipConn:Disconnect() end
        -- ★ Heartbeat em vez de RenderStepped
        tooltipConn = RS.Heartbeat:Connect(function()
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
        ClipsDescendants = false, BackgroundTransparency = .4,
    }, gui)
    Cn(12, main); Shadow(main, 2); Reg(main, "BackgroundColor3", "BG")
    win.Main = main; win._fullSize = UDim2.new(0, W, 0, H)

    -- ★ Frosted Glass no main
    ApplyFrost(main, 2)

    task.defer(function()
        Tw(main, {Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 0}, .55, Enum.EasingStyle.Back)
    end)

    -- ══ Top Bar ══
    local topbar = I("Frame", {
        Name = "TB", Size = UDim2.new(1, 0, 0, TB),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 10,
    }, main)
    Cn(12, topbar); Reg(topbar, "BackgroundColor3", "Panel")
    local tbFill = I("Frame", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 10,
    }, topbar)
    Reg(tbFill, "BackgroundColor3", "Panel")



    local tbDiv = I("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 11,
    }, topbar)
    Reg(tbDiv, "BackgroundColor3", "Border")

    local titleLbl = I("TextLabel", {
        Text = win.Title, Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    }, topbar)
    Reg(titleLbl, "TextColor3", "Text")

    -- Search
    local searchFrame = I("Frame", {
        Size = UDim2.new(0, 185, 0, 26), Position = UDim2.new(.5, -92, .5, -13),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 14,
    }, topbar)
    Cn(7, searchFrame); Reg(searchFrame, "BackgroundColor3", "Elevated")
    local searchStroke = St(T.Border, 1, searchFrame); Reg(searchStroke, "Color", "Border")

    I("TextLabel", {
        Text = "🔍", Size = UDim2.new(0, 22, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 11,
        Font = Enum.Font.Gotham, ZIndex = 15,
    }, searchFrame)

    local searchBox = I("TextBox", {
        Text = "", PlaceholderText = "Search...",
        Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text,
        PlaceholderColor3 = T.TextDis, TextSize = 11, Font = Enum.Font.Gotham,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
    }, searchFrame)
    Reg(searchBox, "TextColor3", "Text"); Reg(searchBox, "PlaceholderColor3", "TextDis")

    -- Avatar (player headshot)
    local avatar = I("Frame", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, .5, -15),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 12,
        ClipsDescendants = true,
    }, topbar)
    Cn(15, avatar); Reg(avatar, "BackgroundColor3", "Elevated")
    St(T.BorderLight, 1.5, avatar)

    local avatarImg = I("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ZIndex = 13, ScaleType = Enum.ScaleType.Crop,
    }, avatar)
    Cn(15, avatarImg)
    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and thumb then avatarImg.Image = thumb end
    end)

    I("TextLabel", {
        Text = LP.DisplayName, Size = UDim2.new(0, 95, 0, 13),
        Position = UDim2.new(1, -148, 0, 9),
        BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 10,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    }, topbar)

    I("TextLabel", {
        Text = os.date("%d/%m/%Y"), Size = UDim2.new(0, 95, 0, 11),
        Position = UDim2.new(1, -148, 0, 24),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 9,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    }, topbar)

    -- ══ DRAG (★ Heartbeat em vez de RenderStepped) ══
    do
        local dragging, dragInput, mStart, fStart = false, nil, nil, nil
        local targetPos = main.Position

        function win:_attachDrag(guiElement)
            win._allConns:Add(guiElement.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true; mStart = inp.Position; fStart = main.Position; targetPos = fStart
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end))
            win._allConns:Add(guiElement.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
            end))
        end

        win:_attachDrag(topbar)

        win._allConns:Add(UIS.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging and mStart then
                local d = inp.Position - mStart
                targetPos = UDim2.new(fStart.X.Scale, fStart.X.Offset + d.X, fStart.Y.Scale, fStart.Y.Offset + d.Y)
            end
        end))
        -- ★ Heartbeat
        win._allConns:Add(RS.Heartbeat:Connect(function()
            if dragging then
                local cX, cY = main.Position.X.Offset, main.Position.Y.Offset
                local tX, tY = targetPos.X.Offset, targetPos.Y.Offset
                local f = .22
                main.Position = UDim2.new(targetPos.X.Scale, cX + (tX - cX)*f, targetPos.Y.Scale, cY + (tY - cY)*f)
            end
        end))
    end

    -- ══ Dynamic Island (replaces sidebars & bottom dock) ══
    local islandWrap = I("Frame", {
        Name = "IslandWrap",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 1, 6),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        ZIndex = 30,
    }, main)

    local dynamicIsland = I("Frame", {
        Name = "DynamicIsland",
        Size = UDim2.new(0, 40, 0, 36), -- Initial size (small pill)
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.Elevated,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 31, ClipsDescendants = true,
    }, islandWrap)
    Cn(18, dynamicIsland); Shadow(dynamicIsland, 25)
    Reg(dynamicIsland, "BackgroundColor3", "Elevated")
    local islandStroke = St(T.BorderLight, 1, dynamicIsland)
    Reg(islandStroke, "Color", "BorderLight")

    local islandList = I("Frame", {
        Name = "IslandList",
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 32,
    }, dynamicIsland)
    local islandLayout = I("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, islandList)
    Pd(0, 0, 6, 6, islandList)
    win.IslandList = islandList
    win.DynamicIsland = dynamicIsland
    win.IslandHovered = false

    local function UpdateIslandState()
        if not win.DynamicIsland then return end
        local expanded = win.IslandHovered
        for _, t in ipairs(win.Tabs) do
            if t.Active then
                Tw(t.DockBtn, {Size = UDim2.new(0, expanded and 44 or 40, 0, expanded and 36 or 36)}, .4, Enum.EasingStyle.Exponential)
                if t.IconLabel then Tw(t.IconLabel, {TextTransparency = 0}, .2) end
                if t.IconImage then Tw(t.IconImage, {ImageTransparency = 0}, .2) end
            else
                Tw(t.DockBtn, {Size = UDim2.new(0, expanded and 36 or 0, 0, 36)}, .4, Enum.EasingStyle.Exponential)
                if t.IconLabel then Tw(t.IconLabel, {TextTransparency = expanded and 0.4 or 1}, .3) end
                if t.IconImage then Tw(t.IconImage, {ImageTransparency = expanded and 0.4 or 1}, .3) end
            end
        end
        local targetWidth = math.max(40, islandLayout.AbsoluteContentSize.X + 16)
        Tw(win.DynamicIsland, {Size = UDim2.new(0, targetWidth, 0, 36)}, .4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    end

    islandLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if win.DynamicIsland then
            local targetWidth = math.max(40, islandLayout.AbsoluteContentSize.X + 16)
            Tw(win.DynamicIsland, {Size = UDim2.new(0, targetWidth, 0, 36)}, .2, Enum.EasingStyle.Linear)
        end
    end)

    win:_attachDrag(dynamicIsland)

    islandWrap.MouseEnter:Connect(function() win.IslandHovered = true; UpdateIslandState() end)
    islandWrap.MouseLeave:Connect(function() win.IslandHovered = false; UpdateIslandState() end)
    win.UpdateIslandState = UpdateIslandState

    -- ══ Content ══
    local content = I("Frame", {
        Size = UDim2.new(1, 0, 1, -(TB + DK)),
        Position = UDim2.new(0, 0, 0, TB),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4, ClipsDescendants = true,
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
            end
        end
    end)

    -- ══ Global Keybind Handler ══
    win._globalConns:Add(UIS.InputBegan:Connect(function(inp, gpe)
        if inp.KeyCode == win.ToggleKey then
            win:SetOpen(not win.Open); return
        end
        if gpe or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if not elem._keybind or inp.KeyCode ~= elem._keybind then continue end
            local mode = elem._keybindMode or "Toggle"
            if elem.Type == "Toggle" and elem._setValue then
                if mode == "Toggle" then
                    local cur = Library.Flags[flag] and Library.Flags[flag].Toggle or false
                    elem._setValue(not cur)
                elseif mode == "Hold" then
                    elem._setValue(true)
                elseif mode == "Always" then
                    if not (Library.Flags[flag] and Library.Flags[flag].Toggle) then
                        elem._setValue(true)
                    end
                end
            elseif elem.Type == "Keybind" then
                if mode == "Toggle" then
                    local cur = Library.Flags[flag] and Library.Flags[flag].Active or false
                    Library.Flags[flag].Active = not cur
                    pcall(elem._callback, {Keybind = inp.KeyCode, Active = not cur, Mode = mode})
                elseif mode == "Hold" then
                    Library.Flags[flag].Active = true
                    pcall(elem._callback, {Keybind = inp.KeyCode, Active = true, Mode = mode})
                elseif mode == "Always" then
                    Library.Flags[flag].Active = true
                    pcall(elem._callback, {Keybind = inp.KeyCode, Active = true, Mode = mode})
                end
                if elem._updateVisual then elem._updateVisual() end
            end
        end
    end))

    win._globalConns:Add(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for flag, elem in pairs(Library.Elements) do
            if not elem._keybind or inp.KeyCode ~= elem._keybind then continue end
            local mode = elem._keybindMode or "Toggle"
            if mode == "Hold" then
                if elem.Type == "Toggle" and elem._setValue then
                    elem._setValue(false)
                elseif elem.Type == "Keybind" then
                    Library.Flags[flag].Active = false
                    pcall(elem._callback, {Keybind = inp.KeyCode, Active = false, Mode = mode})
                    if elem._updateVisual then elem._updateVisual() end
                end
            end
        end
    end))

    table.insert(Library.Windows, win)
    return win
end

-- ═══════════════════════════════════════════════════
--  WATERMARK (★ Heartbeat)
-- ═══════════════════════════════════════════════════
function Library:Watermark(enabled, customText)
    -- Watermark feature removed as requested.
end

-- ═══════════════════════════════════════════════════
--  KEYBIND LIST
-- ═══════════════════════════════════════════════════
function Library:KeybindList(enabled)
    if not enabled then
        if self._kbList then self._kbList.Visible = false end; return
    end
    if not self._kbList then
        local kbl = I("Frame", {
            Size = UDim2.new(0, 180, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 10, .5, -100),
            BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 90, BackgroundTransparency = .1,
        }, self.Gui)
        Cn(8, kbl); St(T.Border, 1, kbl); Pd(6, 6, 8, 8, kbl)
        Reg(kbl, "BackgroundColor3", "Panel")

        local kbTitle = I("TextLabel", {
            Text = "KEYBINDS", Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 9,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 91, LayoutOrder = 0, Active = true,
        }, kbl)
        Ls(kbl, 3)
        self._kbList = kbl; self._kbItems = {}

        -- Make Draggable
        local dragInput, dragStart, startPos
        kbTitle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragStart = input.Position
                startPos = kbl.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragStart = nil
                    end
                end)
            end
        end)
        kbTitle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragStart then
                local delta = input.Position - dragStart
                kbl.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

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
                    local show = false
                    if elem._keybind then
                        if elem.Type == "Toggle" and Library.Flags[flag] and Library.Flags[flag].Toggle then
                            show = true
                        elseif elem.Type == "Keybind" and Library.Flags[flag] and Library.Flags[flag].Active then
                            show = true
                        end
                    end
                    if show then
                        local row = I("Frame", {
                            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
                            ZIndex = 91, LayoutOrder = order,
                        }, kbl)
                        I("TextLabel", {
                            Text = elem.Name, Size = UDim2.new(1, -35, 1, 0),
                            BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 10,
                            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 92,
                        }, row)
                        local modeTag = elem._keybindMode == "Hold" and "H" or
                                       elem._keybindMode == "Always" and "A" or "T"
                        I("TextLabel", {
                            Text = "[" .. KeyName(elem._keybind) .. " " .. modeTag .. "]",
                            Size = UDim2.new(0, 45, 1, 0), Position = UDim2.new(1, -45, 0, 0),
                            BackgroundTransparency = 1, TextColor3 = T.Accent, TextSize = 9,
                            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 92,
                        }, row)
                        table.insert(self._kbItems, row); order = order + 1
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
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 801, ClipsDescendants = true,
    }, self.Overlay)
    Cn(12, dialog); St(T.BorderLight, 1, dialog); Shadow(dialog, 801)
    Reg(dialog, "BackgroundColor3", "Elevated")

    local tw = TwWait(dialog, {Size = UDim2.new(0, 320, 0, 160)}, .35, Enum.EasingStyle.Back)
    if tw then tw.Completed:Wait() end

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
        local ct = TwWait(dialog, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = .5}, .2)
        Tw(dim, {BackgroundTransparency = 1}, .2)
        if ct then ct.Completed:Wait() end
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

    -- Dynamic Island Pill
    local isImageIcon = type(icon) == "string" and (tonumber(icon) ~= nil or string.find(icon, "rbxassetid://", 1, true))

    local dockBtn = I("TextButton", {
        Name = name, Text = "",
        Size = UDim2.new(0, 0, 0, 36), -- Initial size 0 (hidden) until active or hovered
        BackgroundColor3 = T.Hover,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 32,
        ClipsDescendants = true,
    }, win.IslandList)
    Cn(12, dockBtn)
    Reg(dockBtn, "BackgroundColor3", "Hover")
    tab.DockBtn = dockBtn

    local dockGlow = I("Frame", {
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.AccentGlow,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 31,
    }, dockBtn)
    Cn(14, dockGlow)
    Reg(dockGlow, "BackgroundColor3", "AccentGlow")
    tab.DockGlow = dockGlow

    local dockDot = I("Frame", {
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(0.5, 0, 1, -2),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0, ZIndex = 33,
    }, dockBtn)
    Cn(2, dockDot)
    Reg(dockDot, "BackgroundColor3", "Accent")
    tab.DockDot = dockDot

    local iconLbl, iconImg
    if isImageIcon then
        local imgId = tonumber(icon) and ("rbxassetid://" .. icon) or icon
        iconImg = I("ImageLabel", {
            Image = imgId,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1, ImageTransparency = 1,
            ImageColor3 = T.Text,
            ZIndex = 33,
        }, dockBtn)
        Reg(iconImg, "ImageColor3", "Text")
        tab.IconImage = iconImg
    else
        iconLbl = I("TextLabel", {
            Text = icon, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, TextColor3 = T.Text, TextTransparency = 1,
            TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 33,
        }, dockBtn)
        Reg(iconLbl, "TextColor3", "Text")
        tab.IconLabel = iconLbl
    end

    local tt = I("TextLabel", {
        Text = " " .. name .. " ", Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0.5, 0, 1, 10),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
        TextSize = 10, Font = Enum.Font.Gotham, BorderSizePixel = 0,
        Visible = false, ZIndex = 900, BackgroundTransparency = .05,
    }, dockBtn)
    Cn(5, tt); St(T.BorderLight, 1, tt)
    Reg(tt, "BackgroundColor3", "Elevated"); Reg(tt, "TextColor3", "Text")

    dockBtn.MouseEnter:Connect(function()
        tt.Visible = true
        if not tab.Active then
            Tw(dockBtn, {BackgroundTransparency = 0.5}, .15)
        end
    end)
    dockBtn.MouseLeave:Connect(function()
        tt.Visible = false
        if not tab.Active then
            Tw(dockBtn, {BackgroundTransparency = 1}, .15)
        end
    end)
    dockBtn.MouseButton1Click:Connect(function() win:SelectTab(tab) end)
    win:_attachDrag(dockBtn)



    -- Page
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
        Name = "L", Size = UDim2.new(.5, -GAP/2, 0, 0), Position = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, colFrame)
    local lLay = Ls(leftCol, GAP)

    local rightCol = I("Frame", {
        Name = "R", Size = UDim2.new(.5, -GAP/2, 0, 0), Position = UDim2.new(.5, GAP/2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, colFrame)
    local rLay = Ls(rightCol, GAP)

    tab.LeftCol = leftCol; tab.RightCol = rightCol; tab.ColFrame = colFrame

    local updatingCanvas = false
    local function UpdCanvas()
        if updatingCanvas then return end
        updatingCanvas = true
        task.defer(function()
            updatingCanvas = false
            if not lLay or not rLay or not lLay.Parent or not rLay.Parent then return end
            pcall(function()
                local maxH = math.max(lLay.AbsoluteContentSize.Y, rLay.AbsoluteContentSize.Y, 10)
                if colFrame and page then
                    colFrame.Size = UDim2.new(1, -20, 0, maxH)
                    page.CanvasSize = UDim2.new(0, 0, 0, maxH + 30)
                end
            end)
        end)
    end
    if lLay then lLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas) end
    if rLay then rLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas) end
    task.defer(UpdCanvas)

    table.insert(win.Tabs, tab)
    if #win.Tabs == 1 then win:SelectTab(tab) end

    -- ═══════════════════════════════════════
    --  SECTION
    -- ═══════════════════════════════════════
    function tab:new_section(sectionName, side, sectionOptions)
        side = side or "Left"
        sectionOptions = sectionOptions or {}
        local targetCol = side == "Right" and rightCol or leftCol
        local section = {Name = sectionName, Elements = {}, Side = side}

        -- Card
        local card = I("Frame", {
            Name = sectionName, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Card, BorderSizePixel = 0, ZIndex = 6, ClipsDescendants = true,
        }, targetCol)
        Cn(10, card); St(T.Border, 1, card); Ls(card, 0)
        Reg(card, "BackgroundColor3", "Card")
        section.Frame = card

        -- ★ Frosted Glass nos cards
        -- ApplyFrost(card, 6)

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
        local sqFrame = I("Frame", {
            Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = T.CardHead, BorderSizePixel = 0, ZIndex = 7,
        }, hd)
        Reg(sqFrame, "BackgroundColor3", "CardHead")


        local pill = I("Frame", {
            Size = UDim2.new(0, 3, 0, 12), Position = UDim2.new(0, 8, .5, -6),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 8,
        }, hd)
        Cn(2, pill); Reg(pill, "BackgroundColor3", "Accent")

        I("TextLabel", {
            Text = string.upper(sectionName),
            Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1, TextColor3 = T.TextSub,
            TextSize = 9, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
        }, hd)

        -- Collapse
        local collapseArrow = I("TextLabel", {
            Text = ">", Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -24, .5, -9),
            BackgroundTransparency = 1, TextColor3 = T.TextMut,
            TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 9,
            Rotation = 90
        }, hd)
        Reg(collapseArrow, "TextColor3", "TextMut")

        -- Elements container
        local ec = I("Frame", {
            Name = "El", Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, LayoutOrder = 2,
        }, card)
        Ls(ec, 1); Pd(5, 7, 7, 7, ec)
        section.Container = ec

        local collapsed = sectionOptions.collapsed or false
        if collapsed then ec.Visible = false; collapseArrow.Rotation = -90 end

        local collapseBtn = I("TextButton", {
            Text = "", Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, ZIndex = 9,
        }, hd)
        collapseBtn.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            ec.Visible = not collapsed
            Tw(collapseArrow, {Rotation = collapsed and 0 or 90}, .2, Enum.EasingStyle.Back)
            Tw(pill, {BackgroundColor3 = collapsed and T.TextMut or T.Accent}, .2)
        end)

        function section:set_collapsed(state)
            collapsed = state; ec.Visible = not state
            collapseArrow.Rotation = state and 0 or 90
            pill.BackgroundColor3 = state and T.TextMut or T.Accent
        end

        -- ═══ SUB-FOLDER ═══
        function section:sub_folder(folderName)
            local fRow = I("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, ClipsDescendants = true,
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

            I("TextLabel", {
                Text = folderName, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1, TextColor3 = T.TextSub,
                TextSize = 10, Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
            }, fBtn)

            local fContent = I("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, Visible = false,
            }, fRow)
            Ls(fContent, 1); Pd(2, 4, 8, 0, fContent)

            local fOpen = false
            fBtn.MouseButton1Click:Connect(function()
                fOpen = not fOpen; fContent.Visible = fOpen
                Tw(fArrow, {Rotation = fOpen and 90 or 0}, .2, Enum.EasingStyle.Back)
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

        -- ═══════════════════════════════
        --  ELEMENT FACTORY
        -- ═══════════════════════════════
        function section:element(eType, eName, arg1, arg2, targetContainer_override)
            local options, callback, targetContainer
            if type(arg1) == "function" then
                callback = arg1
                if type(arg2) == "table" then
                    options = arg2; targetContainer = targetContainer_override
                else options = {}; targetContainer = arg2 or targetContainer_override end
            else
                options = type(arg1) == "table" and arg1 or {}
                callback = type(arg2) == "function" and arg2 or function() end
                targetContainer = targetContainer_override
            end

            local container = targetContainer or ec
            local flag = options.flag or (sectionName .. "_" .. eName)
            local tooltipText = options.tooltip
            local descText = options.desc

            local elem = {
                Type = eType, Name = eName, Flag = flag,
                _keybind = nil, _keybindMode = "Toggle", _hasKeybind = false,
                _setValue = nil, _getValue = nil, _callback = callback,
                _default = nil, _dirtyDot = nil,
            }

            -- Row base
            local function Row(h, hasDesc)
                local totalH = h or 34
                if hasDesc and descText then totalH = totalH + 14 end
                local f = I("Frame", {
                    Size = UDim2.new(1, 0, 0, totalH),
                    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
                }, container)
                Cn(6, f)
                if tooltipText and tooltipText ~= "" then
                    local tTimer
                    local hBtn = I("TextButton", {
                        Text = "", Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1, ZIndex = 1, AutoButtonColor = false,
                    }, f)
                    hBtn.MouseEnter:Connect(function()
                        tTimer = task.delay(.8, function() win:_showTooltip(tooltipText) end)
                    end)
                    hBtn.MouseLeave:Connect(function()
                        if tTimer then pcall(task.cancel, tTimer) end
                        win:_hideTooltip()
                    end)
                end
                return f, totalH
            end

            local function AddDesc(row, yOffset)
                if descText then
                    local d = I("TextLabel", {
                        Text = descText, Size = UDim2.new(1, -16, 0, 12),
                        Position = UDim2.new(0, 8, 0, yOffset or 22),
                        BackgroundTransparency = 1, TextColor3 = T.TextMut,
                        TextSize = 9, Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                    }, row)
                    Reg(d, "TextColor3", "TextMut")
                end
            end

            -- ═══ TOGGLE (★ dirty state) ═══
            if eType == "Toggle" then
                local defVal = options.default or false
                Library.Flags[flag] = {Toggle = defVal, Active = defVal}
                elem._default = defVal
                local row = Row(34, true)

                -- ★ Dirty indicator
                local dirtyDot = CreateDirtyDot(row, descText and 7 or 11)
                elem._dirtyDot = dirtyDot

                local hov = I("Frame", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.Hover,
                    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
                }, row)
                Cn(6, hov)

                local lbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -75, 0, 20),
                    Position = UDim2.new(0, 8, 0, descText and 3 or 7),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(lbl, "TextColor3", "Text"); AddDesc(row, 20)

                local sw = I("Frame", {
                    Size = UDim2.new(0, 34, 0, 17), Position = UDim2.new(1, -42, 0, descText and 5 or 8),
                    BackgroundColor3 = T.ToggleBg, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(9, sw); St(T.BorderLight, 1, sw)

                local gl = I("Frame", {
                    Size = UDim2.new(0, 42, 0, 25), Position = UDim2.new(1, -46, 0, descText and 1 or 4),
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
                    Position = UDim2.new(1, -66, 0, descText and 5 or 8),
                    BackgroundTransparency = 1, TextColor3 = T.TextMut,
                    TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 13, Visible = false,
                }, row)
                Reg(gear, "TextColor3", "TextMut")

                local isLocked = options.locked == true
                local toggled = defVal
                if isLocked then toggled = false end

                local function Set(val, silent)
                    if isLocked then return end -- STRICT LOCK
                    toggled = val
                    Library.Flags[flag].Toggle = val; Library.Flags[flag].Active = val
                    if val then
                        RegUpdate(sw, "BackgroundColor3", "Accent")
                        UnReg(kn, "BackgroundColor3")
                        Tw(sw, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, .22)
                        Tw(kn, {Position = UDim2.new(0, 20, .5, -5), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0}, .22, Enum.EasingStyle.Back)
                        Tw(gl, {BackgroundTransparency = .78}, .35)
                    else
                        RegUpdate(sw, "BackgroundColor3", "ToggleBg")
                        RegUpdate(kn, "BackgroundColor3", "ToggleKnob")
                        Tw(sw, {BackgroundColor3 = T.ToggleBg, BackgroundTransparency = 0}, .22)
                        Tw(kn, {Position = UDim2.new(0, 3, .5, -5), BackgroundColor3 = T.ToggleKnob, BackgroundTransparency = 0}, .22, Enum.EasingStyle.Back)
                        Tw(gl, {BackgroundTransparency = 1}, .22)
                    end
                    UpdateDirty(dirtyDot, val, elem._default, "Toggle")
                    if not silent then pcall(callback, {Toggle = val}) end
                    CheckDeps(flag)
                end
                elem._setValue = Set; elem._getValue = function() return toggled end
                if toggled then task.defer(function() Set(true, true) end) end

                local click = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, ZIndex = 11,
                }, row)
                local hovering = false
                click.MouseButton1Click:Connect(function() Set(not toggled) end)
                click.MouseEnter:Connect(function() hovering = true; Tw(hov, {BackgroundTransparency = .88}, .12) end)
                click.MouseLeave:Connect(function() hovering = false; Tw(hov, {BackgroundTransparency = 1}, .12) end)
                
                if isLocked then
                    I("TextLabel", {
                        Text = "🔒", Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(1, -66, 0, descText and 5 or 8),
                        BackgroundTransparency = 1, TextColor3 = T.TextMut,
                        TextSize = 12, Font = Enum.Font.Gotham, ZIndex = 13,
                    }, row)
                    sw.BackgroundTransparency = 0.5
                    kn.BackgroundTransparency = 0.5
                    lbl.TextColor3 = T.TextDis
                    Reg(lbl, "TextColor3", "TextDis")
                end

                gear.MouseButton1Click:Connect(function() win:_openKeybindPopup(elem, gear) end)

                elem._gear = gear; elem._row = row
                function elem:add_keybind(defaultKey, defaultMode)
                    self._hasKeybind = true; gear.Visible = true
                    if defaultKey then self._keybind = defaultKey end
                    if defaultMode then self._keybindMode = defaultMode end
                    return self
                end
                function elem:set_value(v) Set(v, false) end

            -- ═══ SLIDER (★ dirty state, suffix, click-to-type) ═══
            elseif eType == "Slider" then
                local mn = options.min or 0
                local mx = options.max or 100
                local df = options.default or mn
                local dc = options.decimals or 0
                local suffix = options.suffix or ""
                if mx <= mn then mx = mn + 1 end
                df = math.clamp(df, mn, mx)
                Library.Flags[flag] = {Slider = df}
                elem._default = df

                local trackY = descText and 38 or 30
                local row = Row(descText and 60 or 46)

                -- ★ Dirty
                local dirtyDot = CreateDirtyDot(row, 7)
                elem._dirtyDot = dirtyDot

                local nameLbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(.55, 0, 0, 18),
                    Position = UDim2.new(0, 8, 0, 3),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(nameLbl, "TextColor3", "Text")
                if descText then AddDesc(row, 18) end

                local function Fmt(v)
                    if dc > 0 then return string.format("%."..dc.."f", v) .. suffix
                    else return tostring(math.floor(v + .5)) .. suffix end
                end

                local valLbl = I("TextButton", {
                    Text = Fmt(df), Size = UDim2.new(.45, -8, 0, 18),
                    Position = UDim2.new(.55, 0, 0, 3),
                    BackgroundTransparency = 1, TextColor3 = T.Accent, TextSize = 11,
                    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right,
                    AutoButtonColor = false, ZIndex = 9,
                }, row)
                Reg(valLbl, "TextColor3", "Accent")

                local editBox = I("TextBox", {
                    Text = "", Size = UDim2.new(0, 55, 0, 18),
                    Position = UDim2.new(1, -63, 0, 3),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 11, Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0, Visible = false, ZIndex = 15,
                    TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = true,
                }, row)
                Cn(4, editBox); St(T.Accent, 1, editBox)
                Reg(editBox, "BackgroundColor3", "Elevated"); Reg(editBox, "TextColor3", "Text")

                local track = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 5), Position = UDim2.new(0, 8, 0, trackY),
                    BackgroundColor3 = T.SliderTrack, BorderSizePixel = 0, ZIndex = 9, ClipsDescendants = true,
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
                local fillGlow = St(T.AccentGlow, 1, fill); fillGlow.Transparency = 1

                local handle = I("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundColor3 = T.SliderKnob, BorderSizePixel = 0, ZIndex = 11,
                }, row)
                Cn(6, handle); Reg(handle, "BackgroundColor3", "SliderKnob")
                local handleStroke = St(T.Accent, 2, handle); Reg(handleStroke, "Color", "Accent")

                local ftip = I("TextLabel", {
                    Text = "", Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 10, Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0, Visible = false, ZIndex = 20,
                }, row)
                Cn(4, ftip); St(T.BorderLight, 1, ftip); Pd(0, 0, 6, 6, ftip)
                Reg(ftip, "BackgroundColor3", "Elevated"); Reg(ftip, "TextColor3", "Text")

                local function PosHandle()
                    if not track or not track.Parent or not row or not row.Parent then return end
                    local range = mx - mn; if range <= 0 then range = 1 end
                    local pct = math.clamp((Library.Flags[flag].Slider - mn) / range, 0, 1)
                    local tx, tw2 = track.AbsolutePosition.X, math.max(track.AbsoluteSize.X, 1)
                    local rx = row.AbsolutePosition.X
                    handle.Position = UDim2.new(0, tx - rx + pct * tw2 - 6, 0, trackY - 3)
                    ftip.Position = UDim2.new(0, tx - rx + pct * tw2 - 15, 0, trackY - 20)
                end

                local function SetSlider(v, silent)
                    local range = mx - mn; if range <= 0 then range = 1 end
                    local factor = 10 ^ dc
                    local r = math.clamp(math.floor(v * factor + .5) / factor, mn, mx)
                    Library.Flags[flag].Slider = r
                    fill.Size = UDim2.new(math.clamp((r - mn) / range, 0, 1), 0, 1, 0)
                    valLbl.Text = Fmt(r); ftip.Text = Fmt(r)
                    PosHandle()
                    UpdateDirty(dirtyDot, r, elem._default, "Slider")
                    if not silent then pcall(callback, {Slider = r}) end
                    CheckDeps(flag)
                end
                elem._setValue = SetSlider; elem._getValue = function() return Library.Flags[flag].Slider end
                task.spawn(function()
                    task.wait()  -- aguarda 1 frame para o layout ser calculado
                    PosHandle()
                end)

                track:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if track.AbsoluteSize.X > 0 then PosHandle() end
                end)

                valLbl.MouseButton1Click:Connect(function()
                    valLbl.Visible = false; editBox.Visible = true
                    editBox.Text = tostring(Library.Flags[flag].Slider); editBox:CaptureFocus()
                end)
                editBox.FocusLost:Connect(function()
                    local num = tonumber(editBox.Text)
                    if num then SetSlider(num) end
                    editBox.Visible = false; valLbl.Visible = true
                end)

                local sDragging = false
                local trackBtn = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, trackY - 6),
                    BackgroundTransparency = 1, ZIndex = 12,
                }, row)

                trackBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sDragging = true; ftip.Visible = true
                        Tw(handle, {Size = UDim2.new(0, 16, 0, 16)}, .12, Enum.EasingStyle.Back)
                        Tw(fillGlow, {Transparency = .3}, .15)
                        local tw2 = math.max(track.AbsoluteSize.X, 1)
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw2, 0, 1)
                        SetSlider(mn + pct * (mx - mn))
                    end
                end)
                win._allConns:Add(UIS.InputChanged:Connect(function(inp)
                    if sDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local tw2 = math.max(track.AbsoluteSize.X, 1)
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw2, 0, 1)
                        SetSlider(mn + pct * (mx - mn))
                    end
                end))
                win._allConns:Add(UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and sDragging then
                        sDragging = false; ftip.Visible = false
                        Tw(handle, {Size = UDim2.new(0, 12, 0, 12)}, .15, Enum.EasingStyle.Back)
                        Tw(fillGlow, {Transparency = 1}, .2)
                    end
                end))

                elem._row = row
                function elem:set_value(v) SetSlider(v) end
                function elem:set_range(newMin, newMax)
                    mn = newMin; mx = newMax; if mx <= mn then mx = mn + 1 end
                    SetSlider(math.clamp(Library.Flags[flag].Slider, mn, mx))
                end

            -- ═══ DROPDOWN (★ dirty state, search >7) ═══
            elseif eType == "Dropdown" then
                local opts = options.options or {"Option"}
                local defOpt = options.default or opts[1]
                Library.Flags[flag] = {Dropdown = defOpt}
                elem._default = defOpt
                local ddY = descText and 32 or 20
                local row = Row(descText and 64 or 52)

                local dirtyDot = CreateDirtyDot(row, 6)
                elem._dirtyDot = dirtyDot

                I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 8, 0, 2),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 10,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                if descText then AddDesc(row, 16) end

                local df2 = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, ddY),
                    BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(6, df2); St(T.BorderLight, 1, df2); Reg(df2, "BackgroundColor3", "Elevated")

                local sel = I("TextLabel", {
                    Text = defOpt, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
                }, df2)
                Reg(sel, "TextColor3", "Text")

                local ch = I("TextLabel", {
                    Text = "▾", Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 11,
                    Font = Enum.Font.Gotham, ZIndex = 10,
                }, df2)

                local function SetDD(v, s)
                    Library.Flags[flag].Dropdown = v; sel.Text = v
                    UpdateDirty(dirtyDot, v, elem._default, "Dropdown")
                    if not s then pcall(callback, {Dropdown = v}) end
                    CheckDeps(flag)
                end
                elem._setValue = SetDD; elem._getValue = function() return Library.Flags[flag].Dropdown end

                local ca = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 11,
                }, df2)
                ca.MouseButton1Click:Connect(function()
                    Tw(ch, {Rotation = 180}, .2)
                    win:_openDropdown(opts, df2, function(v) SetDD(v); Tw(ch, {Rotation = 0}, .2) end,
                        function() Tw(ch, {Rotation = 0}, .2) end)
                end)
                ca.MouseEnter:Connect(function() Tw(df2, {BackgroundColor3 = T.Hover}, .12) end)
                ca.MouseLeave:Connect(function() Tw(df2, {BackgroundColor3 = T.Elevated}, .12) end)

                elem._row = row; elem._opts = opts; elem._df = df2
                function elem:set_value(v) SetDD(v) end
                function elem:set_options(newOpts, keepVal)
                    opts = newOpts; self._opts = newOpts
                    if not keepVal or not table.find(newOpts, Library.Flags[flag].Dropdown) then
                        SetDD(newOpts[1] or "")
                    end
                end

            -- ═══ MULTI-SELECT DROPDOWN (★ dirty state) ═══
            elseif eType == "MultiDropdown" then
                local opts = options.options or {"Option"}
                local defSelected = {}
                if options.default then
                    for _, v in ipairs(options.default) do defSelected[v] = true end
                end
                Library.Flags[flag] = {Selected = defSelected}
                -- ★ Deep copy default for dirty
                local defCopy = {}
                for k, v in pairs(defSelected) do defCopy[k] = v end
                elem._default = defCopy

                local function GetDisplay()
                    local names = {}
                    for _, o in ipairs(opts) do if defSelected[o] then table.insert(names, o) end end
                    if #names == 0 then return "None"
                    elseif #names <= 2 then return table.concat(names, ", ")
                    else return #names .. " selected" end
                end

                local ddY = descText and 32 or 20
                local row = Row(descText and 64 or 52)

                local dirtyDot = CreateDirtyDot(row, 6)
                elem._dirtyDot = dirtyDot

                I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 8, 0, 2),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 10,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                if descText then AddDesc(row, 16) end

                local mdf = I("Frame", {
                    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, ddY),
                    BackgroundColor3 = T.Elevated, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(6, mdf); St(T.BorderLight, 1, mdf); Reg(mdf, "BackgroundColor3", "Elevated")

                local msel = I("TextLabel", {
                    Text = GetDisplay(), Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
                }, mdf)
                Reg(msel, "TextColor3", "Text")

                local mch = I("TextLabel", {
                    Text = "▾", Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 11,
                    Font = Enum.Font.Gotham, ZIndex = 10,
                }, mdf)

                local function SetMulti(newSel, s)
                    defSelected = newSel; Library.Flags[flag].Selected = newSel
                    msel.Text = GetDisplay()
                    UpdateDirty(dirtyDot, newSel, elem._default, "MultiDropdown")
                    if not s then pcall(callback, {Selected = newSel}) end
                    CheckDeps(flag)
                end
                elem._setValue = SetMulti; elem._getValue = function() return Library.Flags[flag].Selected end

                local mca = I("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 11,
                }, mdf)
                mca.MouseButton1Click:Connect(function()
                    Tw(mch, {Rotation = 180}, .2)
                    win:_openMultiDropdown(opts, defSelected, mdf,
                        function(ns) SetMulti(ns) end,
                        function() Tw(mch, {Rotation = 0}, .2) end)
                end)
                mca.MouseEnter:Connect(function() Tw(mdf, {BackgroundColor3 = T.Hover}, .12) end)
                mca.MouseLeave:Connect(function() Tw(mdf, {BackgroundColor3 = T.Elevated}, .12) end)

                elem._row = row; elem._opts = opts
                function elem:set_value(sel) SetMulti(sel) end
                function elem:set_options(newOpts, keepSel)
                    opts = newOpts; self._opts = newOpts
                    if not keepSel then SetMulti({})
                    else
                        local cleaned = {}
                        for _, o in ipairs(newOpts) do
                            if defSelected[o] then cleaned[o] = true end
                        end
                        SetMulti(cleaned)
                    end
                end

            -- ═══ BUTTON ═══
            elseif eType == "Button" then
                local row = Row(descText and 50 or 36)
                if descText then AddDesc(row, 30) end
                local btn = I("TextButton", {
                    Text = eName, Size = UDim2.new(1, -16, 0, 26),
                    Position = UDim2.new(0, 8, 0, descText and 3 or 5),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 11, Font = Enum.Font.Gotham,
                    BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 9, ClipsDescendants = true,
                }, row)
                Cn(6, btn); St(T.BorderLight, 1, btn)
                Reg(btn, "BackgroundColor3", "Elevated"); Reg(btn, "TextColor3", "Text")

                btn.MouseButton1Click:Connect(function()
                    Tw(btn, {BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1,1,1)}, .06)
                    task.delay(.15, function()
                        Tw(btn, {BackgroundColor3 = T.Elevated, TextColor3 = T.Text}, .2)
                    end)
                    pcall(callback, {})
                end)
                btn.MouseEnter:Connect(function() Tw(btn, {BackgroundColor3 = T.Hover}, .12) end)
                btn.MouseLeave:Connect(function() Tw(btn, {BackgroundColor3 = T.Elevated}, .12) end)
                elem._row = row; elem._btn = btn
                function elem:set_text(t) btn.Text = t end

            -- ═══ TEXTBOX ═══
            elseif eType == "TextBox" then
                Library.Flags[flag] = {Text = options.default or ""}
                local row = Row(descText and 66 or 52)

                I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -8, 0, 16), Position = UDim2.new(0, 8, 0, 2),
                    BackgroundTransparency = 1, TextColor3 = T.TextSub, TextSize = 10,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                if descText then AddDesc(row, 16) end

                local tbY = descText and 32 or 20
                local tb = I("TextBox", {
                    Text = options.default or "", PlaceholderText = options.placeholder or "Enter...",
                    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, tbY),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    PlaceholderColor3 = T.TextDis, TextSize = 11, Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false, BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Cn(6, tb); Reg(tb, "BackgroundColor3", "Elevated"); Reg(tb, "TextColor3", "Text")
                local tbSt = St(T.BorderLight, 1, tb); Pd(0, 0, 8, 8, tb)

                tb.Focused:Connect(function()
                    Tw(tbSt, {Color = T.Accent}, .15); Tw(tb, {BackgroundColor3 = T.Hover}, .15)
                end)
                tb.FocusLost:Connect(function(enter)
                    Tw(tbSt, {Color = T.BorderLight}, .15); Tw(tb, {BackgroundColor3 = T.Elevated}, .15)
                    Library.Flags[flag].Text = tb.Text
                    pcall(callback, {Text = tb.Text, Enter = enter})
                    CheckDeps(flag)
                end)
                tb:GetPropertyChangedSignal("Text"):Connect(function()
                    Library.Flags[flag].Text = tb.Text
                end)

                elem._row = row; elem._tb = tb
                elem._getValue = function() return Library.Flags[flag].Text end
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
                elem._row = row; elem._lbl = lbl
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
                        Position = UDim2.new(.5, 0, .5, -6), AnchorPoint = Vector2.new(.5, 0),
                        BackgroundColor3 = T.Card, TextColor3 = T.TextMut,
                        TextSize = 9, Font = Enum.Font.Gotham, BorderSizePixel = 0, ZIndex = 10,
                    }, row)
                    Reg(sepLbl, "BackgroundColor3", "Card"); Reg(sepLbl, "TextColor3", "TextMut")
                end
                elem._row = row

            -- ═══ COLORPICKER (★ dirty state) ═══
            elseif eType == "ColorPicker" then
                local defaultColor = options.default or T.Accent
                Library.Flags[flag] = {Color = defaultColor}
                elem._default = defaultColor
                local row = Row(34, true)

                local dirtyDot = CreateDirtyDot(row, descText and 7 or 11)
                elem._dirtyDot = dirtyDot

                local cpLbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -75, 0, 20),
                    Position = UDim2.new(0, 8, 0, descText and 3 or 7),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(cpLbl, "TextColor3", "Text"); AddDesc(row, 20)

                local hexSmall = I("TextLabel", {
                    Text = Color3ToHex(defaultColor),
                    Size = UDim2.new(0, 50, 0, 14),
                    Position = UDim2.new(1, -82, 0, descText and 6 or 10),
                    BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 9,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
                }, row)
                Reg(hexSmall, "TextColor3", "TextMut")

                local preview = I("Frame", {
                    Size = UDim2.new(0, 24, 0, 17),
                    Position = UDim2.new(1, -32, 0, descText and 5 or 8),
                    BackgroundColor3 = defaultColor, BorderSizePixel = 0, ZIndex = 9,
                }, row)
                Cn(5, preview); St(T.BorderLight, 1, preview)

                local function SetColor(c, silent)
                    Library.Flags[flag].Color = c
                    preview.BackgroundColor3 = c; hexSmall.Text = Color3ToHex(c)
                    UpdateDirty(dirtyDot, c, elem._default, "ColorPicker")
                    if not silent then pcall(callback, {Color = c}) end
                    CheckDeps(flag)
                end
                elem._setValue = SetColor
                elem._getValue = function() return Library.Flags[flag].Color end

                local cpBtn = I("TextButton", {
                    Text = "", Size = UDim2.new(0, 24, 0, 17),
                    Position = UDim2.new(1, -32, 0, descText and 5 or 8),
                    BackgroundTransparency = 1, ZIndex = 11,
                }, row)
                cpBtn.MouseButton1Click:Connect(function()
                    win:_openColorPicker(elem, preview, Library.Flags[flag].Color, SetColor)
                end)

                elem._row = row
                function elem:set_value(c) SetColor(c) end

            -- ═══ KEYBIND (standalone) ═══
            elseif eType == "Keybind" then
                local defKey = options.default
                local defMode = options.mode or "Toggle"
                Library.Flags[flag] = {Keybind = defKey, Active = false, Mode = defMode}
                elem._keybind = defKey; elem._keybindMode = defMode
                local row = Row(34, true)

                local kbLbl = I("TextLabel", {
                    Text = eName, Size = UDim2.new(1, -120, 0, 20),
                    Position = UDim2.new(0, 8, 0, descText and 3 or 7),
                    BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                }, row)
                Reg(kbLbl, "TextColor3", "Text"); AddDesc(row, 20)

                local modeBtn = I("TextButton", {
                    Text = defMode:sub(1, 1),
                    Size = UDim2.new(0, 22, 0, 17),
                    Position = UDim2.new(1, -80, 0, descText and 5 or 8),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.TextSub,
                    TextSize = 9, Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 10,
                }, row)
                Cn(4, modeBtn); St(T.Border, 1, modeBtn)
                Reg(modeBtn, "BackgroundColor3", "Elevated")

                local modes = {"Toggle", "Hold", "Always"}
                modeBtn.MouseButton1Click:Connect(function()
                    local cur = table.find(modes, elem._keybindMode) or 1
                    local next = modes[(cur % #modes) + 1]
                    elem._keybindMode = next; Library.Flags[flag].Mode = next
                    modeBtn.Text = next:sub(1, 1)
                    Tw(modeBtn, {BackgroundColor3 = T.Accent}, .08)
                    task.delay(.15, function() Tw(modeBtn, {BackgroundColor3 = T.Elevated}, .15) end)
                end)

                local keyBtn = I("TextButton", {
                    Text = defKey and KeyName(defKey) or "None",
                    Size = UDim2.new(0, 48, 0, 17),
                    Position = UDim2.new(1, -52, 0, descText and 5 or 8),
                    BackgroundColor3 = T.Elevated, TextColor3 = T.Text,
                    TextSize = 10, Font = Enum.Font.Gotham,
                    BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 10,
                }, row)
                Cn(4, keyBtn); St(T.BorderLight, 1, keyBtn)
                Reg(keyBtn, "BackgroundColor3", "Elevated"); Reg(keyBtn, "TextColor3", "Text")

                local kbListening = false; local kbListenConn
                keyBtn.MouseButton1Click:Connect(function()
                    if kbListening then return end
                    kbListening = true; keyBtn.Text = "..."; keyBtn.TextColor3 = T.Accent
                    Tw(keyBtn, {BackgroundColor3 = T.Hover}, .1)
                    if kbListenConn then kbListenConn:Disconnect() end
                    kbListenConn = UIS.InputBegan:Connect(function(inp, gpe)
                        if gpe then return end
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            elem._keybind = inp.KeyCode
                            Library.Flags[flag].Keybind = inp.KeyCode
                            keyBtn.Text = KeyName(inp.KeyCode); keyBtn.TextColor3 = T.Text
                            Tw(keyBtn, {BackgroundColor3 = T.Elevated}, .1)
                            kbListening = false
                            if kbListenConn then kbListenConn:Disconnect(); kbListenConn = nil end
                        end
                    end)
                    win._allConns:Add(kbListenConn)
                end)
                keyBtn.MouseEnter:Connect(function()
                    if not kbListening then Tw(keyBtn, {BackgroundColor3 = T.Hover}, .1) end
                end)
                keyBtn.MouseLeave:Connect(function()
                    if not kbListening then Tw(keyBtn, {BackgroundColor3 = T.Elevated}, .1) end
                end)

                function elem._updateVisual()
                    local active = Library.Flags[flag] and Library.Flags[flag].Active
                    Tw(keyBtn, {BackgroundColor3 = active and T.AccentDim or T.Elevated}, .15)
                end

                elem._row = row; elem._hasKeybind = true
                elem._getValue = function() return Library.Flags[flag] end
                function elem:set_value(key, mode)
                    if key then
                        elem._keybind = key; Library.Flags[flag].Keybind = key
                        keyBtn.Text = KeyName(key)
                    end
                    if mode then
                        elem._keybindMode = mode; Library.Flags[flag].Mode = mode
                        modeBtn.Text = mode:sub(1, 1)
                    end
                end

            end -- close if/elseif chain

            InjectElementMethods(elem)
            Library.Elements[flag] = elem
            table.insert(section.Elements, elem)
            return elem
        end -- section:element

        table.insert(tab.Sections, section)
        return section
    end -- tab:new_section

    return tab
end -- Library:new_tab

-- ═══════════════════════════════════════════════════
--  TAB SWITCHING
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
        t.Active = false
        Tw(t.DockBtn, {BackgroundTransparency = 1}, .18)
        Tw(t.DockGlow, {BackgroundTransparency = 1}, .18)
        Tw(t.DockDot, {Size = UDim2.new(0, 0, 0, 3)}, .18)
    end

    target.Active = true
    Tw(target.DockBtn, {BackgroundTransparency = 0.7}, .22, Enum.EasingStyle.Back)
    Tw(target.DockGlow, {BackgroundTransparency = 0.8}, .3)
    Tw(target.DockDot, {Size = UDim2.new(0, 14, 0, 3)}, .28, Enum.EasingStyle.Back)

    if self.UpdateIslandState then self.UpdateIslandState() end

    task.delay(.12, function()
        target.Page.Visible = true
        if target.ColFrame then
            target.ColFrame.Position = UDim2.new(.04, 0, 0, 8)
            Tw(target.ColFrame, {Position = UDim2.new(0, 10, 0, 10)}, .4, Enum.EasingStyle.Exponential)
        end
        for i, sec in ipairs(target.Sections) do
            if sec.Frame then
                sec.Frame.BackgroundTransparency = .5
                task.delay(i * .06, function() Tw(sec.Frame, {BackgroundTransparency = 0}, .35) end)
            end
        end
    end)

    self.ActiveTab = target; self:_closePopups()
end

-- ═══════════════════════════════════════════════════
--  POPUP SYSTEM
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

-- ═══ KEYBIND POPUP ═══
function Library:_openKeybindPopup(elem, anchor)
    if self._popup then
        local was = self._popupElem == elem
        self:_closePopups()
        if was then return end
    end
    self._popupElem = elem; local conns = self._popupConns

    local pop = I("Frame", {
        Size = UDim2.new(0, 190, 0, 155),
        BackgroundColor3 = T.Elevated, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 600,
    }, self.Overlay)
    Cn(9, pop); St(T.BorderLight, 1, pop); Shadow(pop, 600)
    Reg(pop, "BackgroundColor3", "Elevated"); self._popup = pop

    task.defer(function()
        if not anchor or not anchor.Parent then return end
        local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
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
        Text = keyStr, Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 27),
        BackgroundColor3 = T.Panel, TextColor3 = T.Text,
        TextSize = 11, Font = Enum.Font.Gotham,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 601,
    }, pop)
    Cn(6, keyBtn); St(T.Border, 1, keyBtn)
    Reg(keyBtn, "BackgroundColor3", "Panel"); Reg(keyBtn, "TextColor3", "Text")

    local listening = false; local listenConn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; keyBtn.Text = "Press key..."; keyBtn.TextColor3 = T.Accent
        Tw(keyBtn, {BackgroundColor3 = T.Hover}, .1)
        if listenConn then listenConn:Disconnect() end
        listenConn = UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                elem._keybind = inp.KeyCode
                if Library.Flags[elem.Flag] then Library.Flags[elem.Flag].Keybind = inp.KeyCode end
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

    I("TextButton", {
        Text = "Clear", Size = UDim2.new(0, 40, 0, 16), Position = UDim2.new(1, -48, 0, 32),
        BackgroundTransparency = 1, TextColor3 = T.Danger,
        TextSize = 9, Font = Enum.Font.GothamBold, ZIndex = 602,
    }, pop).MouseButton1Click:Connect(function()
        elem._keybind = nil
        if Library.Flags[elem.Flag] then Library.Flags[elem.Flag].Keybind = nil end
        keyBtn.Text = "None"; keyBtn.TextColor3 = T.TextSub
    end)

    I("TextLabel", {
        Text = "MODE", Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 0, 62),
        BackgroundTransparency = 1, TextColor3 = T.TextMut,
        TextSize = 8, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local mTrack = I("Frame", {
        Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 78),
        BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 601,
    }, pop)
    Cn(7, mTrack); Reg(mTrack, "BackgroundColor3", "Panel")

    local function MBtn(label, xScale, active)
        local w = label == "Always" and UDim2.new(.34, -2, 1, -4) or UDim2.new(.33, -2, 1, -4)
        local mb = I("TextButton", {
            Text = label, Size = w, Position = UDim2.new(xScale, 2, 0, 2),
            BackgroundColor3 = active and T.Accent or T.Panel,
            TextColor3 = active and Color3.new(1,1,1) or T.TextSub,
            TextSize = 9, Font = Enum.Font.Gotham,
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 602,
        }, mTrack)
        Cn(5, mb); return mb
    end

    local tBtn = MBtn("Toggle", 0, elem._keybindMode == "Toggle")
    local hBtn = MBtn("Hold", .33, elem._keybindMode == "Hold")
    local aBtn = MBtn("Always", .66, elem._keybindMode == "Always")

    local function SetMode(m)
        elem._keybindMode = m
        if Library.Flags[elem.Flag] then Library.Flags[elem.Flag].Mode = m end
        for _, b in ipairs({{tBtn, "Toggle"}, {hBtn, "Hold"}, {aBtn, "Always"}}) do
            Tw(b[1], {BackgroundColor3 = m  == b[2] and T.Accent or T.Panel}, .12)
            b[1].TextColor3 = m == b[2] and Color3.new(1,1,1) or T.TextSub
        end
    end
    tBtn.MouseButton1Click:Connect(function() SetMode("Toggle") end)
    hBtn.MouseButton1Click:Connect(function() SetMode("Hold") end)
    aBtn.MouseButton1Click:Connect(function() SetMode("Always") end)

    -- Status
    I("TextLabel", {
        Text = "Keybind will " .. (elem._keybindMode == "Hold" and "hold" or
               elem._keybindMode == "Always" and "always enable" or "toggle"),
        Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 0, 112),
        BackgroundTransparency = 1, TextColor3 = T.TextMut,
        TextSize = 8, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local ready = false
    task.delay(.25, function() ready = true end)
    conns:Add(UIS.InputBegan:Connect(function(inp)
        if not ready then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if pop and pop.Parent and IsOut(inp.Position, pop) then self:_closePopups() end
            end)
        end
    end))
end

-- ═══ DROPDOWN (overlay + search >7) ═══
function Library:_openDropdown(opts, anchor, setFn, onClose)
    if self._dropdown then
        self._dropdown:Destroy(); self._dropdown = nil
        self._dropConns:DisconnectAll()
        if onClose then onClose() end; return
    end

    local conns = self._dropConns
    local IH, MX = 26, 7
    local hasSearch = #opts > MX
    local shown = math.min(#opts, MX)
    local totalH = shown * IH + 10 + (hasSearch and 30 or 0)

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
        local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
        dd.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 3)
        Tw(dd, {Size = UDim2.new(0, as.X, 0, totalH)}, .25, Enum.EasingStyle.Back)
    end)

    local innerFrame = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 601,
    }, dd)
    Ls(innerFrame, 2); Pd(4, 4, 4, 4, innerFrame)

    local ddSearchBox
    if hasSearch then
        ddSearchBox = I("TextBox", {
            Text = "", PlaceholderText = "Search...",
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = T.Panel, TextColor3 = T.Text,
            PlaceholderColor3 = T.TextDis, TextSize = 10, Font = Enum.Font.Gotham,
            ClearTextOnFocus = false, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 602,
        }, innerFrame)
        Cn(4, ddSearchBox); Pd(0, 0, 6, 6, ddSearchBox)
        Reg(ddSearchBox, "BackgroundColor3", "Panel"); Reg(ddSearchBox, "TextColor3", "Text")
    end

    local scr = I("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, hasSearch and -28 or 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #opts * IH + 4), ZIndex = 601,
    }, innerFrame)
    Ls(scr, 1)

    local itemBtns = {}
    for idx, opt in ipairs(opts) do
        local item = I("TextButton", {
            Name = opt, Text = opt, Size = UDim2.new(1, 0, 0, IH),
            BackgroundColor3 = T.Hover, BackgroundTransparency = 1,
            TextColor3 = T.Text, TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 602,
        }, scr)
        Cn(4, item); Pd(0, 0, 8, 6, item)
        table.insert(itemBtns, item)

        item.TextTransparency = 1
        task.delay(idx * .02, function() Tw(item, {TextTransparency = 0}, .18) end)

        item.MouseEnter:Connect(function() Tw(item, {BackgroundTransparency = .65}, .08) end)
        item.MouseLeave:Connect(function() Tw(item, {BackgroundTransparency = 1}, .08) end)
        item.MouseButton1Click:Connect(function()
            setFn(opt)
            Tw(dd, {Size = UDim2.new(0, dd.AbsoluteSize.X, 0, 0)}, .15)
            task.delay(.16, function()
                if dd and dd.Parent then dd:Destroy() end
                self._dropdown = nil; conns:DisconnectAll()
            end)
        end)
    end

    if ddSearchBox then
        ddSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(ddSearchBox.Text)
            for _, btn in ipairs(itemBtns) do
                btn.Visible = q == "" or string.find(string.lower(btn.Name), q, 1, true) ~= nil
            end
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
                        self._dropdown = nil; conns:DisconnectAll()
                        if onClose then onClose() end
                    end)
                end
            end)
        end
    end))
end

-- ═══ MULTI-DROPDOWN ═══
function Library:_openMultiDropdown(opts, selected, anchor, onUpdate, onClose)
    if self._dropdown then
        self._dropdown:Destroy(); self._dropdown = nil
        self._dropConns:DisconnectAll()
        if onClose then onClose() end; return
    end

    local conns = self._dropConns
    local IH, MX = 28, 7
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
        local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
        dd.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 3)
        Tw(dd, {Size = UDim2.new(0, as.X, 0, totalH)}, .25, Enum.EasingStyle.Back)
    end)

    local scr = I("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #opts * IH + 10), ZIndex = 601,
    }, dd)
    Ls(scr, 1); Pd(4, 4, 4, 4, scr)

    for idx, opt in ipairs(opts) do
        local item = I("TextButton", {
            Text = "", Size = UDim2.new(1, 0, 0, IH),
            BackgroundColor3 = T.Hover, BackgroundTransparency = 1,
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 602,
        }, scr)
        Cn(4, item)

        local ck = I("Frame", {
            Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 6, .5, -7),
            BackgroundColor3 = selected[opt] and T.Accent or T.Panel,
            BorderSizePixel = 0, ZIndex = 603,
        }, item)
        Cn(3, ck); St(T.BorderLight, 1, ck)

        local ckMark = I("TextLabel", {
            Text = "✓", Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
            TextSize = 9, Font = Enum.Font.GothamBold, ZIndex = 604,
            Visible = selected[opt] == true,
        }, ck)

        I("TextLabel", {
            Text = opt, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 26, 0, 0),
            BackgroundTransparency = 1, TextColor3 = T.Text, TextSize = 10,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 603,
        }, item)

        item.MouseEnter:Connect(function() Tw(item, {BackgroundTransparency = .65}, .08) end)
        item.MouseLeave:Connect(function() Tw(item, {BackgroundTransparency = 1}, .08) end)
        item.MouseButton1Click:Connect(function()
            selected[opt] = not selected[opt] or nil
            local isOn = selected[opt] == true
            Tw(ck, {BackgroundColor3 = isOn and T.Accent or T.Panel}, .12)
            ckMark.Visible = isOn
            if isOn then
                Tw(ck, {Size = UDim2.new(0, 16, 0, 16)}, .06)
                task.delay(.06, function() Tw(ck, {Size = UDim2.new(0, 14, 0, 14)}, .06) end)
            end
            onUpdate(selected)
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
                        self._dropdown = nil; conns:DisconnectAll()
                        if onClose then onClose() end
                    end)
                end
            end)
        end
    end))
end

-- ═══ COLOR PICKER POPUP ═══
function Library:_openColorPicker(elem, anchor, currentColor, onColorChange)
    if self._popup then
        local was = self._popupElem == elem
        self:_closePopups()
        if was then return end
    end
    self._popupElem = elem
    local conns = self._popupConns

    local cH, cS, cV = Color3.toHSV(currentColor)
    local SQ_W, SQ_H, HUE_W = 170, 120, 20

    local pop = I("Frame", {
        Size = UDim2.new(0, 240, 0, 285),
        BackgroundColor3 = T.Elevated, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 600,
    }, self.Overlay)
    Cn(9, pop); St(T.BorderLight, 1, pop); Shadow(pop, 600)
    Reg(pop, "BackgroundColor3", "Elevated")
    self._popup = pop

    task.defer(function()
        if not anchor or not anchor.Parent then return end
        local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
        local ovPos = self.Overlay and self.Overlay.AbsolutePosition or Vector2.new(0,0)
        local popX = ap.X - ovPos.X - 240 - 10
        if popX < 10 then popX = ap.X - ovPos.X + as.X + 10 end
        local scrY = self.Gui and self.Gui:FindFirstChild("Main") and self.Gui.Main.AbsoluteSize.Y or 500
        pop.Position = UDim2.new(0, popX, 0, math.clamp(ap.Y - ovPos.Y - (285/2) + (as.Y/2), 10, scrY - 290))
        Tw(pop, {BackgroundTransparency = 0}, .22, Enum.EasingStyle.Back)
    end)

    I("TextLabel", {
        Text = "COLOR  ·  " .. elem.Name,
        Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1, TextColor3 = T.TextSub,
        TextSize = 8, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    -- SV Square
    local svBg = I("Frame", {
        Size = UDim2.new(0, SQ_W, 0, SQ_H), Position = UDim2.new(0, 10, 0, 26),
        BackgroundColor3 = Color3.fromHSV(cH, 1, 1), BorderSizePixel = 0, ZIndex = 601,
        ClipsDescendants = true,
    }, pop)
    Cn(6, svBg)

    local whiteOv = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 602,
    }, svBg)
    I("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        },
    }, whiteOv)

    local blackOv = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0, ZIndex = 603,
    }, svBg)
    I("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        },
        Rotation = 90,
    }, blackOv)

    local svCursor = I("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 605,
    }, svBg)
    St(Color3.new(1, 1, 1), 2, svCursor)
    Cn(5, svCursor)

    -- Hue Bar
    local hueBar = I("Frame", {
        Size = UDim2.new(0, HUE_W, 0, SQ_H), Position = UDim2.new(0, SQ_W + 16, 0, 26),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 601,
        ClipsDescendants = true,
    }, pop)
    Cn(4, hueBar)
    I("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        },
        Rotation = 90,
    }, hueBar)

    local hueInd = I("Frame", {
        Size = UDim2.new(1, 4, 0, 4), Position = UDim2.new(0, -2, 0, 0),
        AnchorPoint = Vector2.new(0, .5),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 605,
    }, hueBar)
    Cn(2, hueInd); St(Color3.new(.2, .2, .2), 1, hueInd)

    -- Preview
    local prevFrame = I("Frame", {
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, SQ_W + 16 + HUE_W + 8, 0, 26),
        BackgroundColor3 = currentColor, BorderSizePixel = 0, ZIndex = 601,
    }, pop)
    Cn(6, prevFrame); St(T.BorderLight, 1, prevFrame)

    -- Hex Input
    I("TextLabel", {
        Text = "HEX", Size = UDim2.new(0, 30, 0, 12),
        Position = UDim2.new(0, 10, 0, SQ_H + 32),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 8,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local hexBox = I("TextBox", {
        Text = Color3ToHex(currentColor),
        Size = UDim2.new(0, 80, 0, 22), Position = UDim2.new(0, 10, 0, SQ_H + 46),
        BackgroundColor3 = T.Panel, TextColor3 = T.Text, TextSize = 10,
        Font = Enum.Font.Gotham, BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 602,
    }, pop)
    Cn(4, hexBox); Pd(0, 0, 6, 6, hexBox); St(T.Border, 1, hexBox)
    Reg(hexBox, "BackgroundColor3", "Panel"); Reg(hexBox, "TextColor3", "Text")

    -- RGB Label
    local rgbLbl = I("TextLabel", {
        Text = string.format("R:%d G:%d B:%d",
            math.floor(currentColor.R * 255 + .5),
            math.floor(currentColor.G * 255 + .5),
            math.floor(currentColor.B * 255 + .5)),
        Size = UDim2.new(0, 120, 0, 12),
        Position = UDim2.new(0, 100, 0, SQ_H + 49),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 8,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    -- Presets
    I("TextLabel", {
        Text = "PRESETS", Size = UDim2.new(1, -20, 0, 12),
        Position = UDim2.new(0, 10, 0, SQ_H + 74),
        BackgroundTransparency = 1, TextColor3 = T.TextMut, TextSize = 8,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 601,
    }, pop)

    local presets = {
        Color3.fromRGB(255,55,55), Color3.fromRGB(255,128,0), Color3.fromRGB(255,255,0),
        Color3.fromRGB(0,200,0), Color3.fromRGB(0,200,200), Color3.fromRGB(45,125,255),
        Color3.fromRGB(130,80,255), Color3.fromRGB(235,65,100), Color3.fromRGB(255,255,255),
        Color3.fromRGB(120,120,120),
    }

    local presetRow = I("Frame", {
        Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 10, 0, SQ_H + 88),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 601,
    }, pop)
    I("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
    }, presetRow)

    local function UpdateAll(h, s, v, silent)
        cH, cS, cV = h, s, v
        local c = Color3.fromHSV(h, s, v)
        svBg.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueInd.Position = UDim2.new(0, -2, h, 0)
        prevFrame.BackgroundColor3 = c
        hexBox.Text = Color3ToHex(c)
        rgbLbl.Text = string.format("R:%d G:%d B:%d",
            math.floor(c.R * 255 + .5), math.floor(c.G * 255 + .5), math.floor(c.B * 255 + .5))
        if not silent then onColorChange(c) end
    end

    UpdateAll(cH, cS, cV, true)

    for i, pc in ipairs(presets) do
        local pb = I("TextButton", {
            Text = "", Size = UDim2.new(0, 18, 0, 18),
            BackgroundColor3 = pc, BorderSizePixel = 0, AutoButtonColor = false,
            ZIndex = 602, LayoutOrder = i,
        }, presetRow)
        Cn(4, pb); St(T.BorderLight, 1, pb)
        pb.MouseButton1Click:Connect(function()
            local ph, ps, pv = Color3.toHSV(pc)
            UpdateAll(ph, ps, pv)
        end)
        pb.MouseEnter:Connect(function() Tw(pb, {Size = UDim2.new(0, 20, 0, 20)}, .08) end)
        pb.MouseLeave:Connect(function() Tw(pb, {Size = UDim2.new(0, 18, 0, 18)}, .08) end)
    end

    -- Hex input
    hexBox.FocusLost:Connect(function()
        local c = HexToColor3(hexBox.Text)
        if c then
            local h, s, v = Color3.toHSV(c)
            UpdateAll(h, s, v)
        else
            hexBox.Text = Color3ToHex(Color3.fromHSV(cH, cS, cV))
        end
    end)

    -- SV Drag
    local svDrag = false
    local svBtn = I("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 606,
    }, svBg)

    svBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            svDrag = true
            local relX = math.clamp((inp.Position.X - svBg.AbsolutePosition.X) / SQ_W, 0, 1)
            local relY = math.clamp((inp.Position.Y - svBg.AbsolutePosition.Y) / SQ_H, 0, 1)
            UpdateAll(cH, relX, 1 - relY)
        end
    end)
    conns:Add(UIS.InputChanged:Connect(function(inp)
        if svDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((inp.Position.X - svBg.AbsolutePosition.X) / SQ_W, 0, 1)
            local relY = math.clamp((inp.Position.Y - svBg.AbsolutePosition.Y) / SQ_H, 0, 1)
            UpdateAll(cH, relX, 1 - relY)
        end
    end))

    -- Hue Drag
    local hueDrag = false
    local hueBtn = I("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 606,
    }, hueBar)

    hueBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDrag = true
            local relY = math.clamp((inp.Position.Y - hueBar.AbsolutePosition.Y) / SQ_H, 0, 1)
            UpdateAll(relY, cS, cV)
        end
    end)
    conns:Add(UIS.InputChanged:Connect(function(inp)
        if hueDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local relY = math.clamp((inp.Position.Y - hueBar.AbsolutePosition.Y) / SQ_H, 0, 1)
            UpdateAll(relY, cS, cV)
        end
    end))

    -- Release drag
    conns:Add(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            svDrag = false; hueDrag = false
        end
    end))

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
        self:_closePopups()
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
    self._allConns:DisconnectAll()
    self:_closePopups()
    pcall(function() self._blur:Destroy() end)
    pcall(function() self.Gui:Destroy() end)
end

-- ═══════════════════════════════════════════════════
--  GET / SET FLAGS
-- ═══════════════════════════════════════════════════
function Library:GetFlag(flag)
    return Library.Flags[flag]
end

function Library:SetFlag(flag, key, value)
    if not Library.Flags[flag] then return end
    Library.Flags[flag][key] = value
    local elem = Library.Elements[flag]
    if not elem then return end
    if elem.Type == "Toggle" and key == "Toggle" and elem._setValue then
        elem._setValue(value, true)
    elseif elem.Type == "Slider" and key == "Slider" and elem._setValue then
        elem._setValue(value, true)
    elseif elem.Type == "Dropdown" and key == "Dropdown" and elem._setValue then
        elem._setValue(value, true)
    elseif elem.Type == "MultiDropdown" and key == "Selected" and elem._setValue then
        elem._setValue(value, true)
    elseif elem.Type == "TextBox" and key == "Text" and elem._tb then
        elem._tb.Text = tostring(value)
    elseif elem.Type == "ColorPicker" and key == "Color" and elem._setValue then
        elem._setValue(value, true)
    elseif elem.Type == "Keybind" and key == "Keybind" and elem.set_value then
        elem:set_value(value)
    end
    CheckDeps(flag)
end

Library._notifHolder = nil
Library._notifQueue = {}
Library._notifProcessing = false
Library._notifPool = {}       -- ★ Pool
Library._POOL_MAX = 8         -- ★ Max pooled cards

-- ★ Ensures the holder ScreenGui + Frame exist
local function EnsureNotifHolder()
    if Library._notifHolder and Library._notifHolder.Parent then
        return Library._notifHolder
    end
    local ng = I("ScreenGui", {
        Name = "__NexUI_N", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2000,
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(ng); ng.Parent = game.CoreGui
        elseif gethui then ng.Parent = gethui()
        else ng.Parent = LP:WaitForChild("PlayerGui") end
    end)
    if not ng.Parent then ng.Parent = LP:WaitForChild("PlayerGui") end

    local holder = I("Frame", {
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -312, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, ng)
    local hl = Ls(holder, 8)
    hl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Pd(12, 12, 0, 0, holder)

    Library._notifHolder = holder
    return holder
end

-- ★ Recycle a notification card back to pool
local function RecycleNotif(card)
    if not card or not card.Parent then return end
    card.Visible = false
    -- Clear children except structural ones
    for _, ch in ipairs(card:GetChildren()) do
        if ch.Name ~= "_accentBar" and ch.Name ~= "_corner" and ch.Name ~= "_stroke" then
            pcall(function() ch:Destroy() end)
        end
    end
    if #Library._notifPool < Library._POOL_MAX then
        card.Parent = nil
        table.insert(Library._notifPool, card)
    else
        pcall(function() card:Destroy() end)
    end
end

-- ★ Get or create a notification card
local function AcquireNotifCard(holder, accentColor)
    local card
    if #Library._notifPool > 0 then
        card = table.remove(Library._notifPool)
        card.Parent = nil -- will be reparented via wrapper
        card.Visible = true
        card.Position = UDim2.new(1.2, 0, 0, 0)
        card.BackgroundTransparency = .3
        -- Update accent bar color
        local bar = card:FindFirstChild("_accentBar")
        if bar then bar.BackgroundColor3 = accentColor end
    else
        card = I("Frame", {
            Size = UDim2.new(1, 0, 0, 42),
            Position = UDim2.new(1.2, 0, 0, 0),
            BackgroundColor3 = T.Panel, BorderSizePixel = 0,
            BackgroundTransparency = .3, ZIndex = 10, ClipsDescendants = true,
        })
        local cn = Cn(10, card); cn.Name = "_corner"
        local st = St(T.Border, 1, card); st.Name = "_stroke"

        -- Accent bar
        local bar = I("Frame", {
            Name = "_accentBar",
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = accentColor, BorderSizePixel = 0, ZIndex = 11,
        }, card)
    end
    return card
end

local function ProcessNotifQueue()
    if Library._notifProcessing then return end
    Library._notifProcessing = true
    task.spawn(function()
        local ok, err = pcall(function()
            while #Library._notifQueue > 0 do
                local data = table.remove(Library._notifQueue, 1)
                Library:_showNotification(data.title, data.desc, data.duration, data.nType, data.actions)
                task.wait(.3)
            end
        end)
        Library._notifProcessing = false  -- ← agora SEMPRE roda, com ou sem erro
        if not ok then
            warn("[NexUI] Notif queue error: " .. tostring(err))
        end
    end)
end

-- ★ Public API: agora aceita actions (botões interativos)
-- actions = { {text="Update", callback=fn}, {text="Ignore", callback=fn} }
function Library:Notify(title, desc, duration, nType, actions)
    table.insert(Library._notifQueue, {
        title = title or "Notification",
        desc = desc or "",
        duration = duration or 4,
        nType = nType or "info",
        actions = actions,
    })
    ProcessNotifQueue()
end

function Library:_showNotification(title, desc, duration, nType, actions)
    local holder = EnsureNotifHolder()

    local ac = ({
        info = T.Accent, success = T.Success,
        warning = T.Warning, error = T.Danger,
    })[nType] or T.Accent

    local iconText = ({
        info = "ℹ", success = "✓", warning = "⚠", error = "✕",
    })[nType] or "ℹ"

    -- ★ Wrapper com tamanho mínimo explícito (fix AutomaticSize bug)
    local wr = I("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    }, holder)

    -- ★ Acquire card from pool or create new
    local nf = AcquireNotifCard(holder, ac)
    nf.Parent = wr

    -- Content container
    local inner = I("Frame", {
        Name = "inner",
        Size = UDim2.new(1, -3, 0, 0), Position = UDim2.new(0, 3, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 11,
    }, nf)
    local innerLay = Ls(inner, 3); Pd(10, 10, 10, 10, inner)
    local updatingInner = false
    innerLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if updatingInner then return end
        updatingInner = true
        task.defer(function()
            updatingInner = false
            pcall(function()
                if innerLay.Parent then
                    local h = innerLay.AbsoluteContentSize.Y + 20
                    nf.Size = UDim2.new(1, 0, 0, h)
                    wr.Size = UDim2.new(1, 0, 0, h)
                end
            end)
        end)
    end)

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

    local iconLbl = I("TextLabel", {
        Text = iconText, Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, TextColor3 = ac,
        TextSize = 10, Font = Enum.Font.GothamBold, ZIndex = 13,
        TextTransparency = 1,
    }, titleRow)

    local tLbl = I("TextLabel", {
        Text = title or "Notification",
        Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1, TextColor3 = T.Text,
        TextSize = 11, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 13,
    }, titleRow)

    -- Description
    local dLbl
    if desc and desc ~= "" then
        dLbl = I("TextLabel", {
            Text = desc,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, TextColor3 = T.TextSub,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            TextTransparency = 1, ZIndex = 12, LayoutOrder = 2,
        }, inner)
    end

    -- ★ Interactive Actions (botões CTA)
    local hasActions = actions and #actions > 0
    if hasActions then
        local actRow = I("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ZIndex = 12, LayoutOrder = 3,
        }, inner)
        I("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }, actRow)

        for idx, act in ipairs(actions) do
            local isPrimary = idx == 1
            local actBtn = I("TextButton", {
                Text = act.text or "Action",
                Size = UDim2.new(0, 0, 0, 22),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = isPrimary and ac or T.Hover,
                TextColor3 = isPrimary and Color3.new(1, 1, 1) or T.TextSub,
                TextSize = 9, Font = Enum.Font.GothamBold,
                BorderSizePixel = 0, AutoButtonColor = false,
                ZIndex = 13, LayoutOrder = idx,
            }, actRow)
            Cn(5, actBtn); Pd(0, 0, 8, 8, actBtn)
            if not isPrimary then St(T.BorderLight, 1, actBtn) end

            actBtn.MouseEnter:Connect(function()
                Tw(actBtn, {BackgroundColor3 = isPrimary and T.AccentGlow or T.Active}, .08)
            end)
            actBtn.MouseLeave:Connect(function()
                Tw(actBtn, {BackgroundColor3 = isPrimary and ac or T.Hover}, .08)
            end)
            actBtn.MouseButton1Click:Connect(function()
                if act.callback then task.spawn(act.callback) end
                -- Dismiss after click
                task.spawn(function()
                    if nf and nf.Parent then
                        Tw(nf, {Position = UDim2.new(1.3, 0, 0, 0)}, .35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                        task.delay(.4, function()
                            RecycleNotif(nf)
                            if wr and wr.Parent then pcall(function() wr:Destroy() end) end
                        end)
                    end
                end)
            end)
        end
    end

    -- Spacer
    I("Frame", {Size = UDim2.new(1, 0, 0, 3), BackgroundTransparency = 1, LayoutOrder = 4}, inner)

    -- Progress bar
    local pC = I("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Elevated, BorderSizePixel = 0,
        ZIndex = 12, LayoutOrder = 5,
    }, inner)
    Cn(1, pC)

    local pF = I("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ac, BorderSizePixel = 0, ZIndex = 13,
    }, pC)
    Cn(1, pF)

    -- ★ Hover pause state
    local dismissed = false
    local hovered = false
    local remainingScale = 1   -- quanto falta da barra (1 = full)
    local pausedAt = nil

    -- ═══ ENTRY ANIMATION (sequenciada) ═══
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
    task.delay(.15, function()
        if iconLbl and iconLbl.Parent then Tw(iconLbl, {TextTransparency = 0}, .25) end
    end)
    task.delay(.18, function()
        if not tLbl or not tLbl.Parent then return end
        Tw(tLbl, {TextTransparency = 0}, .3)
    end)
    task.delay(.26, function()
        if dLbl and dLbl.Parent then Tw(dLbl, {TextTransparency = .1}, .3) end
    end)

    -- ★ Dismiss function com reciclagem
    local function Dismiss()
        if dismissed then return end
        dismissed = true
        if tLbl and tLbl.Parent then Tw(tLbl, {TextTransparency = .5}, .15) end
        if dLbl and dLbl.Parent then Tw(dLbl, {TextTransparency = .6}, .15) end
        if dot and dot.Parent then Tw(dot, {BackgroundTransparency = .5}, .15) end
        if iconLbl and iconLbl.Parent then Tw(iconLbl, {TextTransparency = .5}, .15) end
        task.delay(.08, function()
            if nf and nf.Parent then Tw(nf, {BackgroundTransparency = .4}, .2) end
        end)
        task.delay(.12, function()
            if nf and nf.Parent then
                Tw(nf, {Position = UDim2.new(1.3, 0, 0, 0)}, .45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            end
        end)
        task.delay(.6, function()
            RecycleNotif(nf)
            if wr and wr.Parent then pcall(function() wr:Destroy() end) end
        end)
    end

    -- ★ Progress bar com pausa no hover
    task.delay(.35, function()
        if not pF or not pF.Parent then return end
        local totalTime = duration - .5
        local startTick = tick()

        -- Começa a barra
        local progressTween = TS:Create(pF,
            TweenInfo.new(totalTime, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 1, 0)})
        progressTween:Play()

        task.spawn(function()
            local startTime = tick()
            local localPauseStart = nil
            local pausedDuration = 0

            while not dismissed do
                task.wait(.05)
                if not nf or not nf.Parent then dismissed = true; break end
                if not pF or not pF.Parent then break end

                if hovered and not localPauseStart then
                    localPauseStart = tick()
                    progressTween:Pause()
                elseif not hovered and localPauseStart then
                    pausedDuration = pausedDuration + (tick() - localPauseStart)
                    local elapsed = localPauseStart - startTime
                    local remaining = math.max(totalTime - elapsed, .1)
                    localPauseStart = nil

                    progressTween:Cancel()
                    progressTween = TS:Create(pF,
                        TweenInfo.new(remaining, Enum.EasingStyle.Linear),
                        {Size = UDim2.new(0, 0, 1, 0)})
                    progressTween:Play()
                end

                local active = tick() - startTime - pausedDuration
                if active >= totalTime then break end
            end
            if not dismissed then Dismiss() end
        end)
    end)

    -- ★ Click dismiss + hover detection
    local disBtn = I("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 14,
    }, nf)
    disBtn.MouseButton1Click:Connect(Dismiss)
    disBtn.MouseEnter:Connect(function()
        hovered = true
        if not dismissed and nf and nf.Parent then
            Tw(nf, {BackgroundTransparency = .05}, .1)
        end
    end)
    disBtn.MouseLeave:Connect(function()
        hovered = false
        if not dismissed and nf and nf.Parent then
            Tw(nf, {BackgroundTransparency = 0}, .1)
        end
    end)
end

-- ═══════════════════════════════════════════════════
return Library
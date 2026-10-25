--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           STREET LIFE REMASTERED                             ║
║           SOVEREIGN PANEL — ELITE EDITION                    ║
║                                                              ║
║           Authorized User: 9266010098                        ║
║           Classification: OWNER ONLY                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local VirtualUser     = game:GetService("VirtualUser")
local Lighting        = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ══════════════════════════════════════════
-- AUTHORIZATION
-- ══════════════════════════════════════════
if LP.UserId ~= 9266010098 then
    -- Silent exit for unauthorized users
    return
end

-- ══════════════════════════════════════════
-- FRAMEWORK
-- ══════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Connections  = {}
local DrawnObjects = {}
local Active       = true

-- ══════════════════════════════════════════
-- CONFIGURATION
-- ══════════════════════════════════════════
local Config = {

    ESP = {
        Enabled       = false,
        Boxes         = true,
        BoxFill       = false,
        Names         = true,
        Distance      = true,
        HealthBars    = true,
        HeadDot       = true,
        Tracers       = false,
        Skeleton      = false,
        VisibilityCheck = false,
        RainbowMode   = false,
        TeamColor     = false,
        Color         = Color3.fromRGB(220, 50, 50),
    },

    Aimbot = {
        Enabled       = false,
        FOV           = 150,
        ShowFOV       = true,
        FOVColor      = Color3.fromRGB(255, 255, 255),
        Smoothness    = 0.15,
        Key           = Enum.UserInputType.MouseButton2,
        TargetPart    = "Head",
        TriggerBot    = false,
        VisibleOnly   = false,
    },

    Player = {
        InfStamina    = true,
        InfHealth     = false,
        GodMode       = false,
        AutoHeal      = false,
        SpeedEnabled  = false,
        SpeedValue    = 50,
        InfJump       = false,
        SuperJump     = false,
        JumpPower     = 150,
        NoClip        = false,
        Invisible     = false,
        NoRagdoll     = false,
        FlyEnabled    = false,
        FlySpeed      = 80,
        AntiAFK       = true,
    },

    World = {
        Fullbright    = false,
        AntiGravity   = false,
        Gravity       = 196.2,
        FreezeAll     = false,
        KillAura      = false,
        KillAuraRange = 20,
    },

}

-- ══════════════════════════════════════════
-- UTILITIES
-- ══════════════════════════════════════════
local function GetChar()  return LP.Character end
local function GetRoot()  local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()   local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function GetPRoot(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end

local function IsAlive(p)
    local c=p.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetDist(p)
    local r=GetRoot()
    local pr=GetPRoot(p)
    return (r and pr) and math.floor((r.Position-pr.Position).Magnitude) or 0
end

local RainbowHue = 0
local function NextRainbow()
    RainbowHue = (RainbowHue + 0.003) % 1
    return Color3.fromHSV(RainbowHue, 1, 1)
end

local function Notify(title, body, duration, icon)
    Rayfield:Notify({
        Title    = title,
        Content  = body,
        Duration = duration or 3,
        Image    = icon or "info",
    })
end

local function Track(connection)
    table.insert(Connections, connection)
    return connection
end

local function NewDrawing(kind)
    local obj = Drawing.new(kind)
    table.insert(DrawnObjects, obj)
    return obj
end

local function IsVisible(part)
    local root = GetRoot()
    if not root then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {GetChar(), part.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local dir = part.Position - root.Position
    return workspace:Raycast(root.Position, dir.Unit * dir.Magnitude, params) == nil
end

local function HideDrawings(obj)
    for k, v in pairs(obj) do
        if k == "Bones" then
            for _, b in ipairs(v) do b.Visible = false end
        elseif v.Visible ~= nil then
            v.Visible = false
        end
    end
end

-- ══════════════════════════════════════════
-- UNLOAD
-- ══════════════════════════════════════════
local function Unload()
    Active = false

    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, d in ipairs(DrawnObjects) do
        pcall(function() d:Remove() end)
    end

    local hum = GetHum()
    if hum then
        hum.WalkSpeed  = 16
        hum.JumpPower  = 50
        hum.AutoRotate = true
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end)
    end

    local char = GetChar()
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
                p.LocalTransparencyModifier = 0
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local pr = GetPRoot(p)
            if pr then pr.Anchored = false end
        end
    end

    Lighting.Brightness     = 2
    Lighting.ClockTime      = 14
    Lighting.FogEnd         = 100000
    Lighting.GlobalShadows  = true
    Lighting.Ambient        = Color3.fromRGB(127, 127, 127)
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    workspace.Gravity       = 196.2

    local h = GetHum()
    if h then Cam.CameraSubject = h end

    local r = GetRoot()
    if r then
        local bv = r:FindFirstChild("SovereignBV")
        local bg = r:FindFirstChild("SovereignBG")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end

    Notify("Sovereign Panel", "Session terminated. Farewell.", 5, "log-out")
    task.wait(1.5)
    pcall(function() Rayfield:Destroy() end)
end

-- ══════════════════════════════════════════
-- FOV CIRCLE
-- ══════════════════════════════════════════
local FovCircle = NewDrawing("Circle")
FovCircle.Thickness = 1
FovCircle.Filled    = false
FovCircle.NumSides  = 256
FovCircle.Visible   = false

-- ══════════════════════════════════════════
-- CROSSHAIR
-- ══════════════════════════════════════════
local Crosshair = {
    H   = NewDrawing("Line"),
    V   = NewDrawing("Line"),
    Dot = NewDrawing("Circle"),
    TL  = NewDrawing("Line"),
    TR  = NewDrawing("Line"),
    BL  = NewDrawing("Line"),
    BR  = NewDrawing("Line"),
}
for _, v in pairs(Crosshair) do v.Visible = false end
Crosshair.H.Thickness   = 1
Crosshair.V.Thickness   = 1
Crosshair.H.Color       = Color3.fromRGB(255,255,255)
Crosshair.V.Color       = Color3.fromRGB(255,255,255)
Crosshair.Dot.Radius    = 1.5
Crosshair.Dot.Filled    = true
Crosshair.Dot.NumSides  = 64
Crosshair.Dot.Color     = Color3.fromRGB(255,50,50)
for _, k in ipairs({"TL","TR","BL","BR"}) do
    Crosshair[k].Thickness = 1.5
    Crosshair[k].Color = Color3.fromRGB(255,255,255)
end

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
local ESPCache = {}

local SkeletonMap = {
    {"Head","UpperTorso"},    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},   {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},   {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}

local function BuildESP(player)
    if player == LP then return end
    if ESPCache[player] then
        for k, o in pairs(ESPCache[player]) do
            if k == "Bones" then for _, b in ipairs(o) do pcall(function() b:Remove() end) end
            elseif o.Visible ~= nil then pcall(function() o:Remove() end) end
        end
    end

    local function D(t) return NewDrawing(t) end
    local E = {}

    -- Box
    E.Box           = D("Square") E.Box.Thickness = 1.2 E.Box.Filled = false
    E.BoxFill       = D("Square") E.BoxFill.Filled = true E.BoxFill.Transparency = 0.12 E.BoxFill.Thickness = 0

    -- Corner brackets (aesthetic corners)
    E.CornerTL1     = D("Line") E.CornerTL1.Thickness = 2
    E.CornerTL2     = D("Line") E.CornerTL2.Thickness = 2
    E.CornerTR1     = D("Line") E.CornerTR1.Thickness = 2
    E.CornerTR2     = D("Line") E.CornerTR2.Thickness = 2
    E.CornerBL1     = D("Line") E.CornerBL1.Thickness = 2
    E.CornerBL2     = D("Line") E.CornerBL2.Thickness = 2
    E.CornerBR1     = D("Line") E.CornerBR1.Thickness = 2
    E.CornerBR2     = D("Line") E.CornerBR2.Thickness = 2

    -- Text
    E.Name          = D("Text") E.Name.Size=13 E.Name.Center=true E.Name.Outline=true E.Name.Font=Drawing.Fonts.UI
    E.Dist          = D("Text") E.Dist.Size=11 E.Dist.Center=true E.Dist.Outline=true E.Dist.Font=Drawing.Fonts.UI E.Dist.Color=Color3.fromRGB(200,200,200)
    E.HealthText    = D("Text") E.HealthText.Size=10 E.HealthText.Center=true E.HealthText.Outline=true E.HealthText.Font=Drawing.Fonts.UI

    -- Health bar
    E.HealthBG      = D("Square") E.HealthBG.Filled=true E.HealthBG.Color=Color3.fromRGB(15,15,15) E.HealthBG.Transparency=0.4 E.HealthBG.Thickness=0
    E.HealthBar     = D("Square") E.HealthBar.Filled=true E.HealthBar.Thickness=0

    -- Head dot
    E.HeadDot       = D("Circle") E.HeadDot.Radius=4 E.HeadDot.Filled=true E.HeadDot.NumSides=64 E.HeadDot.Thickness=1
    E.HeadDotOutline= D("Circle") E.HeadDotOutline.Radius=5 E.HeadDotOutline.Filled=false E.HeadDotOutline.NumSides=64 E.HeadDotOutline.Thickness=1 E.HeadDotOutline.Color=Color3.fromRGB(0,0,0)

    -- Tracer
    E.Tracer        = D("Line") E.Tracer.Thickness=1

    -- Skeleton
    E.Bones = {}
    for i = 1, #SkeletonMap do
        local l = D("Line") l.Thickness=0.8 l.Visible=false
        table.insert(E.Bones, l)
    end

    for k, v in pairs(E) do
        if k ~= "Bones" and v.Visible ~= nil then v.Visible = false end
    end

    ESPCache[player] = E
end

local function InitPlayer(p)
    BuildESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        BuildESP(p)
    end)
    p.CharacterRemoving:Connect(function()
        if ESPCache[p] then HideDrawings(ESPCache[p]) end
    end)
end

-- ══════════════════════════════════════════
-- RENDER LOOP
-- ══════════════════════════════════════════
Track(RunService.RenderStepped:Connect(function()
    if not Active then return end

    local ViewX = Cam.ViewportSize.X
    local ViewY = Cam.ViewportSize.Y
    local Center = Vector2.new(ViewX/2, ViewY/2)

    -- ── FOV Circle ──
    FovCircle.Position = Center
    FovCircle.Radius   = Config.Aimbot.FOV
    FovCircle.Color    = Config.Aimbot.FOVColor
    FovCircle.Visible  = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled

    -- ── Crosshair ──
    local cx, cy = Center.X, Center.Y
    local cSize, cGap = 8, 3
    Crosshair.H.From   = Vector2.new(cx-(cSize+cGap), cy)
    Crosshair.H.To     = Vector2.new(cx-(cGap), cy)
    Crosshair.V.From   = Vector2.new(cx, cy-(cSize+cGap))
    Crosshair.V.To     = Vector2.new(cx, cy-(cGap))

    -- Corner brackets style crosshair
    local bSize = 5
    Crosshair.TL.From = Vector2.new(cx-(cSize+cGap), cy) Crosshair.TL.To = Vector2.new(cx+(cSize+cGap), cy)
    Crosshair.V.From  = Vector2.new(cx, cy-(cSize+cGap)) Crosshair.V.To  = Vector2.new(cx, cy+(cSize+cGap))

    for _, k in ipairs({"H","V","Dot","TL","TR","BL","BR"}) do
        Crosshair[k].Visible = Config.Aimbot.Enabled
    end
    Crosshair.Dot.Position = Center

    if Config.ESP.RainbowMode then NextRainbow() end

    -- ── ESP ──
    for player, E in pairs(ESPCache) do
        if not player or not player.Parent then
            HideDrawings(E) continue
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if not (char and root and hum and hum.Health > 0 and Config.ESP.Enabled) then
            HideDrawings(E) continue
        end

        local rootSP, onScreen = Cam:WorldToViewportPoint(root.Position)
        local headSP = Cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local feetSP = Cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

        if not onScreen then HideDrawings(E) continue end

        -- Determine color
        local Col
        if Config.ESP.VisibilityCheck then
            Col = (head and IsVisible(head)) and Color3.fromRGB(50,255,100) or Color3.fromRGB(255,50,50)
        elseif Config.ESP.RainbowMode then
            Col = Color3.fromHSV(RainbowHue, 1, 1)
        elseif Config.ESP.TeamColor then
            Col = player.TeamColor.Color
        else
            Col = Config.ESP.Color
        end

        local SP   = Vector2.new(rootSP.X, rootSP.Y)
        local HP2D = Vector2.new(headSP.X, headSP.Y)
        local FP2D = Vector2.new(feetSP.X, feetSP.Y)
        local BH   = math.abs(HP2D.Y - FP2D.Y)
        local BW   = BH * 0.52
        local BX   = SP.X - BW/2
        local BY   = HP2D.Y
        local CLen = math.min(BW, BH) * 0.22

        -- ── Corner Bracket Box ──
        -- Top Left
        E.CornerTL1.From=Vector2.new(BX,BY)          E.CornerTL1.To=Vector2.new(BX+CLen,BY)           E.CornerTL1.Color=Col E.CornerTL1.Visible=Config.ESP.Boxes
        E.CornerTL2.From=Vector2.new(BX,BY)          E.CornerTL2.To=Vector2.new(BX,BY+CLen)           E.CornerTL2.Color=Col E.CornerTL2.Visible=Config.ESP.Boxes
        -- Top Right
        E.CornerTR1.From=Vector2.new(BX+BW,BY)       E.CornerTR1.To=Vector2.new(BX+BW-CLen,BY)        E.CornerTR1.Color=Col E.CornerTR1.Visible=Config.ESP.Boxes
        E.CornerTR2.From=Vector2.new(BX+BW,BY)       E.CornerTR2.To=Vector2.new(BX+BW,BY+CLen)        E.CornerTR2.Color=Col E.CornerTR2.Visible=Config.ESP.Boxes
        -- Bottom Left
        E.CornerBL1.From=Vector2.new(BX,BY+BH)       E.CornerBL1.To=Vector2.new(BX+CLen,BY+BH)        E.CornerBL1.Color=Col E.CornerBL1.Visible=Config.ESP.Boxes
        E.CornerBL2.From=Vector2.new(BX,BY+BH)       E.CornerBL2.To=Vector2.new(BX,BY+BH-CLen)        E.CornerBL2.Color=Col E.CornerBL2.Visible=Config.ESP.Boxes
        -- Bottom Right
        E.CornerBR1.From=Vector2.new(BX+BW,BY+BH)    E.CornerBR1.To=Vector2.new(BX+BW-CLen,BY+BH)     E.CornerBR1.Color=Col E.CornerBR1.Visible=Config.ESP.Boxes
        E.CornerBR2.From=Vector2.new(BX+BW,BY+BH)    E.CornerBR2.To=Vector2.new(BX+BW,BY+BH-CLen)     E.CornerBR2.Color=Col E.CornerBR2.Visible=Config.ESP.Boxes

        -- Full box (thin, behind corners)
        E.Box.Size=Vector2.new(BW,BH) E.Box.Position=Vector2.new(BX,BY) E.Box.Color=Color3.fromRGB(0,0,0) E.Box.Transparency=0.5 E.Box.Visible=Config.ESP.Boxes
        E.BoxFill.Size=Vector2.new(BW,BH) E.BoxFill.Position=Vector2.new(BX,BY) E.BoxFill.Color=Col E.BoxFill.Visible=Config.ESP.Boxes and Config.ESP.BoxFill

        -- Name
        E.Name.Position=Vector2.new(SP.X, HP2D.Y-17) E.Name.Text=player.DisplayName E.Name.Color=Col E.Name.Visible=Config.ESP.Names

        -- Distance
        E.Dist.Position=Vector2.new(SP.X, FP2D.Y+4) E.Dist.Text=GetDist(player).." m" E.Dist.Visible=Config.ESP.Distance

        -- Health bar
        local HPct  = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        local HCol  = Color3.fromRGB(math.floor(255*(1-HPct)), math.floor(220*HPct), 30)
        local BarH  = BH * HPct
        E.HealthBG.Size     = Vector2.new(4, BH)
        E.HealthBG.Position = Vector2.new(BX-7, BY)
        E.HealthBG.Visible  = Config.ESP.HealthBars
        E.HealthBar.Size    = Vector2.new(4, BarH)
        E.HealthBar.Position= Vector2.new(BX-7, BY+(BH-BarH))
        E.HealthBar.Color   = HCol
        E.HealthBar.Visible = Config.ESP.HealthBars

        -- Health % text
        E.HealthText.Position = Vector2.new(BX-9, BY + BH/2 - 5)
        E.HealthText.Text     = math.floor(HPct*100).."%"
        E.HealthText.Color    = HCol
        E.HealthText.Visible  = Config.ESP.HealthBars

        -- Head dot
        if head then
            local hdSP, hdOn = Cam:WorldToViewportPoint(head.Position)
            E.HeadDot.Position        = Vector2.new(hdSP.X, hdSP.Y)
            E.HeadDot.Color           = Col
            E.HeadDot.Visible         = Config.ESP.HeadDot and hdOn
            E.HeadDotOutline.Position = Vector2.new(hdSP.X, hdSP.Y)
            E.HeadDotOutline.Visible  = Config.ESP.HeadDot and hdOn
        else
            E.HeadDot.Visible = false
            E.HeadDotOutline.Visible = false
        end

        -- Tracer
        E.Tracer.From    = Vector2.new(ViewX/2, ViewY)
        E.Tracer.To      = FP2D
        E.Tracer.Color   = Col
        E.Tracer.Visible = Config.ESP.Tracers

        -- Skeleton
        for i, bone in ipairs(SkeletonMap) do
            local b1 = char:FindFirstChild(bone[1])
            local b2 = char:FindFirstChild(bone[2])
            local BL = E.Bones[i]
            if b1 and b2 and Config.ESP.Skeleton then
                local s1, o1 = Cam:WorldToViewportPoint(b1.Position)
                local s2, o2 = Cam:WorldToViewportPoint(b2.Position)
                if o1 and o2 then
                    BL.From=Vector2.new(s1.X,s1.Y) BL.To=Vector2.new(s2.X,s2.Y)
                    BL.Color=Col BL.Visible=true
                else BL.Visible=false end
            else BL.Visible=false end
        end
    end
end))

Track(Players.PlayerAdded:Connect(function(p) InitPlayer(p) end))
Track(Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        for k, o in pairs(ESPCache[p]) do
            if k=="Bones" then for _,b in ipairs(o) do pcall(function() b:Remove() end) end
            elseif o.Visible~=nil then pcall(function() o:Remove() end) end
        end
        ESPCache[p] = nil
    end
end))
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then InitPlayer(p) end
end

-- ══════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════
local function AcquireTarget()
    local Center    = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    local Best, BestDist = nil, Config.Aimbot.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or not IsAlive(p) then continue end
        local char = p.Character
        local target = char and char:FindFirstChild(Config.Aimbot.TargetPart)
        local head   = char and char:FindFirstChild("Head")
        if not target then continue end
        if Config.Aimbot.VisibleOnly and (not head or not IsVisible(head)) then continue end
        local sp, onScreen = Cam:WorldToViewportPoint(target.Position)
        if not onScreen then continue end
        local d = (Vector2.new(sp.X, sp.Y) - Center).Magnitude
        if d < BestDist then BestDist=d Best=target end
    end

    return Best
end

Track(RunService.RenderStepped:Connect(function()
    if not Active or not Config.Aimbot.Enabled then return end
    local key = Config.Aimbot.Key
    local held = (typeof(key)=="EnumItem" and key.EnumType==Enum.UserInputType)
        and UserInputService:IsMouseButtonPressed(key)
        or (typeof(key)=="EnumItem" and key.EnumType==Enum.KeyCode and UserInputService:IsKeyDown(key))
    if not held then return end
    local target = AcquireTarget()
    if not target then return end
    local _, on = Cam:WorldToViewportPoint(target.Position)
    if not on then return end
    Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, target.Position), 1 - Config.Aimbot.Smoothness)
end))

Track(RunService.Heartbeat:Connect(function()
    if not Active or not Config.Aimbot.TriggerBot then return end
    local target = AcquireTarget()
    if not target then return end
    local sp, on = Cam:WorldToViewportPoint(target.Position)
    if not on then return end
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    if (Vector2.new(sp.X, sp.Y) - center).Magnitude < 12 then
        mouse1click()
    end
end))

-- ══════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════
Track(RunService.Heartbeat:Connect(function()
    if not Active then return end
    local char = GetChar()
    local hum  = GetHum()
    local root = GetRoot()
    local C    = Config.Player
    local W    = Config.World

    -- Infinite Stamina
    if C.InfStamina and char then
        local scan = {char, LP, LP:FindFirstChild("leaderstats"), LP:FindFirstChild("PlayerGui"), LP:FindFirstChild("PlayerScripts"), LP:FindFirstChild("Backpack")}
        for _, src in ipairs(scan) do
            if not src then continue end
            for _, v in ipairs(src:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("FloatValue") then
                    local n = v.Name:lower()
                    if n:find("stam") or n:find("sprint") or n:find("energy") or n:find("endur") or
                       n=="runstamina" or n=="currentstamina" or n=="sprintbar" or n=="sprintmeter" then
                        v.Value = v.MaxValue or 100
                    end
                end
            end
        end
    end

    if (C.InfHealth or C.GodMode) and hum then hum.Health = hum.MaxHealth end
    if C.AutoHeal and hum and hum.Health < hum.MaxHealth then hum.Health = math.min(hum.Health + 0.5, hum.MaxHealth) end
    if hum then hum.WalkSpeed = C.SpeedEnabled and C.SpeedValue or 16 end
    if hum then hum.JumpPower = C.SuperJump and C.JumpPower or 50 end

    if C.NoClip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier = C.Invisible and 1 or 0
            end
        end
    end

    if C.NoRagdoll and hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if hum:GetState()==Enum.HumanoidStateType.Ragdoll or hum:GetState()==Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end

    if W.Fullbright then
        Lighting.Brightness=10 Lighting.ClockTime=14 Lighting.FogEnd=1e6
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    end

    workspace.Gravity = W.AntiGravity and 10 or W.Gravity

    if W.KillAura and root then
        for _, p in ipairs(Players:GetPlayers()) do
            if p==LP or not IsAlive(p) then continue end
            local pr = GetPRoot(p)
            if pr and (root.Position-pr.Position).Magnitude <= W.KillAuraRange then
                local ph = p.Character:FindFirstChildOfClass("Humanoid")
                if ph then ph.Health = 0 end
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr = GetPRoot(p)
        if pr then pr.Anchored = W.FreezeAll end
    end
end))

Track(UserInputService.JumpRequest:Connect(function()
    if not Active or not Config.Player.InfJump then return end
    local h = GetHum()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

Track(LP.Idled:Connect(function()
    if not Active or not Config.Player.AntiAFK then return end
    VirtualUser:Button2Down(Vector2.zero, Cam.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.zero, Cam.CFrame)
end))

-- ══════════════════════════════════════════
-- FLY
-- ══════════════════════════════════════════
local FlyBV, FlyBG, FlyCon

local function BeginFlight()
    local r = GetRoot() if not r then return end
    FlyBV = Instance.new("BodyVelocity", r)
    FlyBV.Name = "SovereignBV"
    FlyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    FlyBV.Velocity = Vector3.zero
    FlyBG = Instance.new("BodyGyro", r)
    FlyBG.Name = "SovereignBG"
    FlyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    FlyBG.D = 100 FlyBG.P = 1e4
    FlyBG.CFrame = r.CFrame

    FlyCon = Track(RunService.RenderStepped:Connect(function()
        if not Active or not Config.Player.FlyEnabled then
            if FlyBV then FlyBV:Destroy() end
            if FlyBG then FlyBG:Destroy() end
            if FlyCon then FlyCon:Disconnect() end
            return
        end
        local UI = UserInputService
        local Dir = Vector3.zero
        if UI:IsKeyDown(Enum.KeyCode.W) then Dir=Dir+Cam.CFrame.LookVector end
        if UI:IsKeyDown(Enum.KeyCode.S) then Dir=Dir-Cam.CFrame.LookVector end
        if UI:IsKeyDown(Enum.KeyCode.A) then Dir=Dir-Cam.CFrame.RightVector end
        if UI:IsKeyDown(Enum.KeyCode.D) then Dir=Dir+Cam.CFrame.RightVector end
        if UI:IsKeyDown(Enum.KeyCode.Space)     then Dir=Dir+Vector3.new(0,1,0) end
        if UI:IsKeyDown(Enum.KeyCode.LeftShift) then Dir=Dir-Vector3.new(0,1,0) end
        FlyBV.Velocity = Dir * Config.Player.FlySpeed
        FlyBG.CFrame   = Cam.CFrame
    end))
end

local function EndFlight()
    Config.Player.FlyEnabled = false
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if FlyCon then FlyCon:Disconnect() end
    local h = GetHum()
    if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end
end

-- ══════════════════════════════════════════════════════════════
-- INTERFACE
-- ══════════════════════════════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name            = "Sovereign  ·  Street Life",
    LoadingTitle    = "Street Life Remastered",
    LoadingSubtitle = "Sovereign Panel  —  Elite Edition",
    Theme           = "DarkBlue",
    DisableRayfieldPrompts  = true,
    DisableBuildWarnings    = true,
    ConfigurationSaving     = { Enabled = false },
    KeySystem               = false,
})

-- ──────────────────────────────────────────
-- HOME
-- ──────────────────────────────────────────
local Home = Window:CreateTab("Home", "home")
Home:CreateSection("Sovereign Panel")
Home:CreateLabel("Street Life Remastered  ·  Elite Edition")
Home:CreateLabel("Authorized  ·  " .. LP.DisplayName .. "  ·  " .. LP.UserId)
Home:CreateDivider()

Home:CreateButton({Name="󰋚  Session Report", Callback=function()
    local lines = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local status = IsAlive(p) and "Alive" or "Dead"
        local dist   = GetDist(p)
        table.insert(lines, string.format("%-20s %5dm  %s", p.DisplayName, dist, status))
    end
    Notify("Session Report  ("..#lines.." players)", table.concat(lines,"\n"), 12, "users")
end})

Home:CreateButton({Name="󰑓  Rejoin Server", Callback=function()
    TeleportService:Teleport(game.PlaceId, LP)
end})

Home:CreateDivider()

Home:CreateButton({Name="󰈆  Terminate Session", Callback=function()
    Unload()
end})

-- ──────────────────────────────────────────
-- ESP
-- ──────────────────────────────────────────
local ESPTab = Window:CreateTab("Visuals", "eye")
ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({Name="Enable ESP",          CurrentValue=false, Flag="e1",  Callback=function(v) Config.ESP.Enabled=v end})
ESPTab:CreateDivider()
ESPTab:CreateToggle({Name="Corner Boxes",         CurrentValue=true,  Flag="e2",  Callback=function(v) Config.ESP.Boxes=v end})
ESPTab:CreateToggle({Name="Box Fill",             CurrentValue=false, Flag="e3",  Callback=function(v) Config.ESP.BoxFill=v end})
ESPTab:CreateToggle({Name="Player Names",         CurrentValue=true,  Flag="e4",  Callback=function(v) Config.ESP.Names=v end})
ESPTab:CreateToggle({Name="Distance",             CurrentValue=true,  Flag="e5",  Callback=function(v) Config.ESP.Distance=v end})
ESPTab:CreateToggle({Name="Health Bars",          CurrentValue=true,  Flag="e6",  Callback=function(v) Config.ESP.HealthBars=v end})
ESPTab:CreateToggle({Name="Head Indicator",       CurrentValue=true,  Flag="e7",  Callback=function(v) Config.ESP.HeadDot=v end})
ESPTab:CreateToggle({Name="Tracers",              CurrentValue=false, Flag="e8",  Callback=function(v) Config.ESP.Tracers=v end})
ESPTab:CreateToggle({Name="Skeleton",             CurrentValue=false, Flag="e9",  Callback=function(v) Config.ESP.Skeleton=v end})
ESPTab:CreateDivider()
ESPTab:CreateToggle({Name="Visibility Check  [ 🟢 Seen · 🔴 Hidden ]", CurrentValue=false, Flag="e10", Callback=function(v)
    Config.ESP.VisibilityCheck=v
    Notify("Visibility Check", v and "Active  ·  Green = visible  ·  Red = obstructed" or "Inactive", 3, "eye")
end})
ESPTab:CreateDivider()
ESPTab:CreateToggle({Name="Rainbow Mode",         CurrentValue=false, Flag="e11", Callback=function(v) Config.ESP.RainbowMode=v end})
ESPTab:CreateToggle({Name="Team Colors",          CurrentValue=false, Flag="e12", Callback=function(v) Config.ESP.TeamColor=v end})
ESPTab:CreateColorPicker({Name="ESP Color", Color=Color3.fromRGB(220,50,50), Flag="ec", Callback=function(v) Config.ESP.Color=v end})

-- ──────────────────────────────────────────
-- AIMBOT
-- ──────────────────────────────────────────
local AimTab = Window:CreateTab("Aimbot", "crosshair")
AimTab:CreateSection("Aim Assistance")
AimTab:CreateToggle({Name="Enable Aimbot",        CurrentValue=false, Flag="a1",  Callback=function(v) Config.Aimbot.Enabled=v end})
AimTab:CreateToggle({Name="TriggerBot",           CurrentValue=false, Flag="a2",  Callback=function(v) Config.Aimbot.TriggerBot=v end})
AimTab:CreateToggle({Name="Visible Targets Only", CurrentValue=false, Flag="a3",  Callback=function(v)
    Config.Aimbot.VisibleOnly=v
    Notify("Visible Only", v and "Active  ·  Will only target players in line of sight" or "Inactive", 3, "eye")
end})
AimTab:CreateDivider()
AimTab:CreateToggle({Name="Show FOV Ring",        CurrentValue=true,  Flag="a4",  Callback=function(v) Config.Aimbot.ShowFOV=v end})
AimTab:CreateColorPicker({Name="FOV Ring Color",  Color=Color3.fromRGB(255,255,255), Flag="afc", Callback=function(v) Config.Aimbot.FOVColor=v end})
AimTab:CreateSlider({Name="FOV Radius", Range={50,800}, Increment=10, Suffix=" px",  CurrentValue=150, Flag="a5", Callback=function(v) Config.Aimbot.FOV=v end})
AimTab:CreateSlider({Name="Smoothness", Range={0,99},   Increment=1,  Suffix="%",    CurrentValue=15,  Flag="a6", Callback=function(v) Config.Aimbot.Smoothness=v/100 end})
AimTab:CreateDivider()
AimTab:CreateDropdown({Name="Target Hitbox",
    Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso","LeftUpperArm","RightUpperArm"},
    CurrentOption={"Head"}, Flag="a7",
    Callback=function(v) Config.Aimbot.TargetPart=v[1] end})
AimTab:CreateDropdown({Name="Activation Key",
    Options={"RightClick","LeftClick","Q","E","F","C","X","Z"},
    CurrentOption={"RightClick"}, Flag="a8",
    Callback=function(v)
        local Map={RightClick=Enum.UserInputType.MouseButton2, LeftClick=Enum.UserInputType.MouseButton1,
            Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, F=Enum.KeyCode.F,
            C=Enum.KeyCode.C, X=Enum.KeyCode.X, Z=Enum.KeyCode.Z}
        Config.Aimbot.Key=Map[v[1]]
    end})

-- ──────────────────────────────────────────
-- PLAYERS
-- ──────────────────────────────────────────
local PlTab = Window:CreateTab("Players", "users")
PlTab:CreateSection("Player Operations")
PlTab:CreateButton({Name="󰓋  Teleport to Nearest", Callback=function()
    local r=GetRoot() if not r then return end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetPRoot(p) if not pr then continue end
        local d=(r.Position-pr.Position).Magnitude
        if d<bd then bd=d best=pr end
    end
    if best then r.CFrame=best.CFrame+Vector3.new(0,5,0) Notify("Displacement","Relocated to nearest player.",3,"map-pin") end
end})

PlTab:CreateButton({Name="󰂖  Spectate Nearest", Callback=function()
    local r=GetRoot() if not r then return end
    local best,bd,bp=nil,math.huge,nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetPRoot(p) if not pr then continue end
        local d=(r.Position-pr.Position).Magnitude
        if d<bd then bd=d best=pr bp=p end
    end
    if bp then
        Cam.CameraSubject=bp.Character:FindFirstChildOfClass("Humanoid")
        Notify("Spectating", bp.DisplayName, 3, "eye")
    end
end})

PlTab:CreateButton({Name="󰑓  Restore Camera", Callback=function()
    local h=GetHum() if h then Cam.CameraSubject=h Notify("Camera","Restored to self.",2,"refresh-cw") end
end})

PlTab:CreateButton({Name="󰳗  Converge All to Self", Callback=function()
    local r=GetRoot() if not r then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetPRoot(p) if not pr then continue end
        pr.CFrame=r.CFrame+Vector3.new(math.random(-4,4),2,math.random(-4,4))
    end
    Notify("Convergence","All players relocated to your position.",3,"users")
end})

PlTab:CreateButton({Name="󰯈  Eliminate All", Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health=0 end
    end
    Notify("Elimination","All players neutralized.",3,"skull")
end})

PlTab:CreateDivider()
PlTab:CreateToggle({Name="Kill Aura",             CurrentValue=false, Flag="p1", Callback=function(v) Config.World.KillAura=v Notify("Kill Aura",v and "Active" or "Inactive",2,"zap") end})
PlTab:CreateSlider({Name="Kill Aura Radius", Range={5,120}, Increment=1, Suffix=" studs", CurrentValue=20, Flag="p2", Callback=function(v) Config.World.KillAuraRange=v end})
PlTab:CreateDivider()
PlTab:CreateToggle({Name="Immobilize All Players", CurrentValue=false, Flag="p3", Callback=function(v) Config.World.FreezeAll=v Notify("Freeze",v and "All players immobilized" or "Released",2,"thermometer") end})

-- ──────────────────────────────────────────
-- SELF
-- ──────────────────────────────────────────
local SelfTab = Window:CreateTab("Self", "zap")
SelfTab:CreateSection("Character")
SelfTab:CreateToggle({Name="Infinite Stamina",    CurrentValue=true,  Flag="s1",  Callback=function(v) Config.Player.InfStamina=v  Notify("Stamina",  v and "Infinite" or "Normal",  2,"zap")          end})
SelfTab:CreateToggle({Name="Infinite Health",     CurrentValue=false, Flag="s2",  Callback=function(v) Config.Player.InfHealth=v   Notify("Health",   v and "Infinite" or "Normal",  2,"heart")        end})
SelfTab:CreateToggle({Name="God Mode",            CurrentValue=false, Flag="s3",  Callback=function(v) Config.Player.GodMode=v     Notify("God Mode", v and "Active"   or "Inactive", 2,"shield")       end})
SelfTab:CreateToggle({Name="Auto Regeneration",   CurrentValue=false, Flag="s4",  Callback=function(v) Config.Player.AutoHeal=v    Notify("Auto Heal",v and "Active"   or "Inactive", 2,"activity")     end})
SelfTab:CreateDivider()
SelfTab:CreateToggle({Name="Speed Override",      CurrentValue=false, Flag="s5",  Callback=function(v) Config.Player.SpeedEnabled=v Notify("Speed",   v and "Active"   or "Normal",   2,"wind")         end})
SelfTab:CreateSlider({Name="Walk Speed",  Range={16,500}, Increment=1,  Suffix=" u/s",   CurrentValue=50,  Flag="s6",  Callback=function(v) Config.Player.SpeedValue=v end})
SelfTab:CreateToggle({Name="Infinite Jump",       CurrentValue=false, Flag="s7",  Callback=function(v) Config.Player.InfJump=v     Notify("Inf Jump", v and "Active"   or "Inactive", 2,"chevrons-up")  end})
SelfTab:CreateToggle({Name="Super Jump",          CurrentValue=false, Flag="s8",  Callback=function(v) Config.Player.SuperJump=v   Notify("Super Jump",v and "Active"  or "Inactive", 2,"chevrons-up")  end})
SelfTab:CreateSlider({Name="Jump Power", Range={50,600}, Increment=10, Suffix=" pw",     CurrentValue=150, Flag="s9",  Callback=function(v) Config.Player.JumpPower=v end})
SelfTab:CreateDivider()
SelfTab:CreateToggle({Name="Phase (NoClip)",      CurrentValue=false, Flag="s10", Callback=function(v) Config.Player.NoClip=v      Notify("NoClip",   v and "Active"   or "Inactive", 2,"layers")       end})
SelfTab:CreateToggle({Name="Cloak (Local Only)",  CurrentValue=false, Flag="s11", Callback=function(v) Config.Player.Invisible=v   Notify("Invisible",v and "Active"   or "Inactive", 2,"eye-off")      end})
SelfTab:CreateToggle({Name="No Ragdoll",          CurrentValue=false, Flag="s12", Callback=function(v) Config.Player.NoRagdoll=v   Notify("No Ragdoll",v and "Active"  or "Inactive", 2,"shield")       end})
SelfTab:CreateDivider()
SelfTab:CreateToggle({Name="Flight",              CurrentValue=false, Flag="s13", Callback=function(v)
    Config.Player.FlyEnabled=v
    if v then BeginFlight() Notify("Flight","Active  ·  WASD + Space / Shift",4,"navigation")
    else EndFlight() Notify("Flight","Inactive",2,"navigation") end
end})
SelfTab:CreateSlider({Name="Flight Speed", Range={10,600}, Increment=5, Suffix=" u/s",   CurrentValue=80,  Flag="s14", Callback=function(v) Config.Player.FlySpeed=v end})

-- ──────────────────────────────────────────
-- WORLD
-- ──────────────────────────────────────────
local WorldTab = Window:CreateTab("World", "globe")
WorldTab:CreateSection("Environment")
WorldTab:CreateToggle({Name="Fullbright",          CurrentValue=false, Flag="w1", Callback=function(v) Config.World.Fullbright=v   Notify("Fullbright",   v and "Active" or "Inactive",2,"sun")       end})
WorldTab:CreateToggle({Name="Zero Gravity",        CurrentValue=false, Flag="w2", Callback=function(v) Config.World.AntiGravity=v  Notify("Anti-Gravity", v and "Active" or "Inactive",2,"arrow-up")  end})
WorldTab:CreateSlider({Name="Gravity",   Range={0,400}, Increment=5, Suffix=" u/s²", CurrentValue=196, Flag="w3", Callback=function(v)
    Config.World.Gravity=v
    if not Config.World.AntiGravity then workspace.Gravity=v end
end})
WorldTab:CreateSlider({Name="Time of Day", Range={0,24}, Increment=1, Suffix=":00", CurrentValue=14, Flag="w4", Callback=function(v) Lighting.ClockTime=v end})
WorldTab:CreateDivider()
WorldTab:CreateButton({Name="󱊡  Detonate All Players", Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetPRoot(p) if not pr then continue end
        local e=Instance.new("Explosion")
        e.Position=pr.Position e.BlastRadius=12 e.BlastPressure=8e6
        e.Parent=workspace
    end
    Notify("Detonation","All targets neutralized.",3,"zap")
end})
WorldTab:CreateButton({Name="󰄰  Deploy Flood", Callback=function()
    if workspace:FindFirstChild("SovereignFlood") then
        Notify("Flood","Already deployed.",2,"droplets") return
    end
    local p=Instance.new("Part")
    p.Name="SovereignFlood" p.Size=Vector3.new(4096,1,4096)
    p.Position=Vector3.new(0,4,0) p.Anchored=true
    p.Color=Color3.fromRGB(0,100,220) p.Material=Enum.Material.Neon
    p.Transparency=0.35 p.CanCollide=false p.Parent=workspace
    Notify("Flood","Deployed.",3,"droplets")
end})
WorldTab:CreateButton({Name="󰆴  Retract Flood", Callback=function()
    local f=workspace:FindFirstChild("SovereignFlood")
    if f then f:Destroy() Notify("Flood","Retracted.",2,"trash")
    else Notify("Flood","Not deployed.",2,"info") end
end})
WorldTab:CreateDivider()
WorldTab:CreateToggle({Name="Anti-AFK",            CurrentValue=true,  Flag="w5", Callback=function(v) Config.Player.AntiAFK=v    Notify("Anti-AFK",     v and "Active" or "Inactive",2,"shield")     end})

-- ══════════════════════════════════════════
-- BOOT NOTIFICATION
-- ══════════════════════════════════════════
task.wait(0.5)
Notify(
    "Sovereign Panel  ·  Elite Edition",
    "Session initialized.\nAuthorized as  " .. LP.DisplayName .. ".",
    7,
    "shield"
)

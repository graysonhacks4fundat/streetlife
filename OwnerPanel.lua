--[[
    ╔═══════════════════════════════════════════╗
    ║     STREET LIFE REMASTERED                ║
    ║     OWNER PANEL - ULTIMATE EDITION        ║
    ║     Owner: 9266010098                     ║
    ╚═══════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

if LP.UserId ~= 9266010098 then return end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Connections = {}
local DrawnObjects = {}
local Loaded = true

local S = {
    ESP = {
        On=false, Name=true, Box=true, Dist=true,
        Health=true, Head=true, Tracer=false,
        Team=false, Rainbow=false, Fill=false,
        Color=Color3.fromRGB(255,50,50),
        SkeletonESP=false,
        VisCheck=false,
    },
    Aim = {
        On=false, FOV=150, ShowFOV=true, Smooth=0.15,
        Key=Enum.UserInputType.MouseButton2, Part="Head",
        FOVColor=Color3.fromRGB(255,255,255),
        TriggerBot=false,
    },
    Misc = {
        Stamina=true, InfHealth=false, Speed=false, SpeedVal=50,
        Jump=false, NoClip=false, Fly=false, FlySpeed=80,
        Bright=false, AFK=true, GodMode=false,
        SuperJump=false, JumpPower=150,
        Invisible=false, FreezeAll=false,
        KillAura=false, KillAuraRange=20,
        AutoHeal=false,
    },
    World = {
        Gravity=196.2, AntiGravity=false,
    },
}

-- ============================================================
-- HELPERS
-- ============================================================
local function Char() return LP.Character end
local function Root() local c=Char() return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c=Char() return c and c:FindFirstChildOfClass("Humanoid") end
local function Alive(p) local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid") return h and h.Health>0 end
local function GetRoot(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function Dist(p)
    local r=Root() local pr=GetRoot(p)
    return (r and pr) and math.floor((r.Position-pr.Position).Magnitude) or 0
end
local hue=0
local function RainbowColor() hue=(hue+0.003)%1 return Color3.fromHSV(hue,1,1) end
local function Notify(t,c,d,i) Rayfield:Notify({Title=t,Content=c,Duration=d or 3,Image=i or "info"}) end
local function Track(con) table.insert(Connections,con) return con end
local function AddDraw(obj) table.insert(DrawnObjects,obj) return obj end

local function IsVisible(targetPart)
    local root=Root()
    if not root then return false end
    local rayParams=RaycastParams.new()
    rayParams.FilterDescendantsInstances={Char(), targetPart.Parent}
    rayParams.FilterType=Enum.RaycastFilterType.Exclude
    local dir=targetPart.Position-root.Position
    local result=workspace:Raycast(root.Position, dir.Unit*dir.Magnitude, rayParams)
    return result==nil
end

local function HideESPObject(o)
    for k,v in pairs(o) do
        if k=="bones" then
            for _,b in ipairs(v) do b.Visible=false end
        elseif v.Visible~=nil then
            v.Visible=false
        end
    end
end

-- ============================================================
-- UNLOAD
-- ============================================================
local function Unload()
    Loaded=false
    for _,c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(DrawnObjects) do pcall(function() d:Remove() end) end
    local hum=Hum()
    if hum then hum.WalkSpeed=16 hum.JumpPower=50 hum.AutoRotate=true end
    local char=Char()
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true p.LocalTransparencyModifier=0 end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then local pr=GetRoot(p) if pr then pr.Anchored=false end end
    end
    Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=100000
    Lighting.GlobalShadows=true
    Lighting.Ambient=Color3.fromRGB(127,127,127)
    Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    workspace.Gravity=196.2
    local h=Hum() if h then Cam.CameraSubject=h end
    local r=Root()
    if r then
        local bv=r:FindFirstChild("OwnerBV") local bg=r:FindFirstChild("OwnerBG")
        if bv then bv:Destroy() end if bg then bg:Destroy() end
    end
    Notify("Owner Panel","Unloaded. Goodbye 👋",4,"log-out")
    task.wait(1)
    Rayfield:Destroy()
end

-- ============================================================
-- FOV + CROSSHAIR
-- ============================================================
local FovCircle=AddDraw(Drawing.new("Circle"))
FovCircle.Thickness=1.5 FovCircle.Filled=false FovCircle.NumSides=128 FovCircle.Visible=false

local CH={
    h=AddDraw(Drawing.new("Line")),
    v=AddDraw(Drawing.new("Line")),
    dot=AddDraw(Drawing.new("Circle")),
}
CH.h.Thickness=1.5 CH.h.Color=Color3.fromRGB(255,255,255) CH.h.Visible=false
CH.v.Thickness=1.5 CH.v.Color=Color3.fromRGB(255,255,255) CH.v.Visible=false
CH.dot.Radius=2 CH.dot.Filled=true CH.dot.Color=Color3.fromRGB(255,50,50) CH.dot.Visible=false CH.dot.NumSides=32

-- ============================================================
-- ESP
-- ============================================================
local ESP={}
local SkeletonBones={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function MakeESP(p)
    if p==LP then return end
    if ESP[p] then
        for k,o in pairs(ESP[p]) do
            if k=="bones" then for _,b in ipairs(o) do pcall(function() b:Remove() end) end
            elseif o.Visible~=nil then pcall(function() o:Remove() end) end
        end
    end
    local function D(t) return AddDraw(Drawing.new(t)) end
    local o={}
    o.box=D("Square") o.box.Thickness=1.5 o.box.Filled=false
    o.fill=D("Square") o.fill.Filled=true o.fill.Transparency=0.15 o.fill.Thickness=0
    o.name=D("Text") o.name.Size=13 o.name.Center=true o.name.Outline=true o.name.Font=Drawing.Fonts.UI
    o.dist=D("Text") o.dist.Size=11 o.dist.Center=true o.dist.Outline=true o.dist.Font=Drawing.Fonts.UI o.dist.Color=Color3.fromRGB(220,220,220)
    o.hbg=D("Square") o.hbg.Filled=true o.hbg.Color=Color3.fromRGB(0,0,0) o.hbg.Transparency=0.5 o.hbg.Thickness=0
    o.hbar=D("Square") o.hbar.Filled=true o.hbar.Thickness=0
    o.dot=D("Circle") o.dot.Radius=4 o.dot.Filled=true o.dot.NumSides=32 o.dot.Thickness=1
    o.tracer=D("Line") o.tracer.Thickness=1
    o.bones={}
    for i=1,#SkeletonBones do
        local l=D("Line") l.Thickness=1 l.Visible=false
        table.insert(o.bones,l)
    end
    for k,v in pairs(o) do if k~="bones" and v.Visible~=nil then v.Visible=false end end
    ESP[p]=o
end

local function SetupPlayerESP(p)
    MakeESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        MakeESP(p)
    end)
    p.CharacterRemoving:Connect(function()
        if ESP[p] then HideESPObject(ESP[p]) end
    end)
end

Track(RunService.RenderStepped:Connect(function()
    if not Loaded then return end

    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    FovCircle.Position=center FovCircle.Radius=S.Aim.FOV FovCircle.Color=S.Aim.FOVColor
    FovCircle.Visible=S.Aim.ShowFOV and S.Aim.On

    local cx,cy=center.X,center.Y
    CH.h.From=Vector2.new(cx-10,cy) CH.h.To=Vector2.new(cx+10,cy) CH.h.Visible=S.Aim.On
    CH.v.From=Vector2.new(cx,cy-10) CH.v.To=Vector2.new(cx,cy+10) CH.v.Visible=S.Aim.On
    CH.dot.Position=center CH.dot.Visible=S.Aim.On

    if S.ESP.Rainbow then RainbowColor() end

    for p,o in pairs(ESP) do

        -- Safety check: stale entry
        if not p or not p.Parent then
            HideESPObject(o)
            continue
        end

        local char=p.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local head=char and char:FindFirstChild("Head")

        -- Hide if no character, dead, or ESP off
        if not(char and root and hum and hum.Health>0 and S.ESP.On) then
            HideESPObject(o)
            continue
        end

        local rp,on=Cam:WorldToViewportPoint(root.Position)
        local hp=Cam:WorldToViewportPoint(root.Position+Vector3.new(0,3,0))
        local fp=Cam:WorldToViewportPoint(root.Position-Vector3.new(0,3,0))

        -- Hide if off screen
        if not on then
            HideESPObject(o)
            continue
        end

        -- Color logic
        local col
        if S.ESP.VisCheck then
            local visible=head and IsVisible(head)
            col=visible and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)
        elseif S.ESP.Rainbow then
            col=Color3.fromHSV(hue,1,1)
        elseif S.ESP.Team then
            col=p.TeamColor.Color
        else
            col=S.ESP.Color
        end

        local sp=Vector2.new(rp.X,rp.Y)
        local h2=Vector2.new(hp.X,hp.Y)
        local f2=Vector2.new(fp.X,fp.Y)
        local bh=math.abs(h2.Y-f2.Y) local bw=bh*0.55 local bx=sp.X-bw/2

        o.box.Size=Vector2.new(bw,bh) o.box.Position=Vector2.new(bx,h2.Y) o.box.Color=col o.box.Visible=S.ESP.Box
        o.fill.Size=Vector2.new(bw,bh) o.fill.Position=Vector2.new(bx,h2.Y) o.fill.Color=col o.fill.Visible=S.ESP.Box and S.ESP.Fill
        o.name.Position=Vector2.new(sp.X,h2.Y-16) o.name.Text="["..p.DisplayName.."]" o.name.Color=col o.name.Visible=S.ESP.Name
        o.dist.Position=Vector2.new(sp.X,f2.Y+3) o.dist.Text="📍 "..Dist(p).."m" o.dist.Visible=S.ESP.Dist

        local hp2=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local hcol=Color3.fromRGB(math.floor(255*(1-hp2)),math.floor(255*hp2),30)
        local barH=bh*hp2
        o.hbg.Size=Vector2.new(4,bh) o.hbg.Position=Vector2.new(bx-6,h2.Y) o.hbg.Visible=S.ESP.Health
        o.hbar.Size=Vector2.new(4,barH) o.hbar.Position=Vector2.new(bx-6,h2.Y+(bh-barH)) o.hbar.Color=hcol o.hbar.Visible=S.ESP.Health

        if head then
            local hdp,hdon=Cam:WorldToViewportPoint(head.Position)
            o.dot.Position=Vector2.new(hdp.X,hdp.Y) o.dot.Color=col o.dot.Visible=S.ESP.Head and hdon
        else
            o.dot.Visible=false
        end

        o.tracer.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
        o.tracer.To=f2 o.tracer.Color=col o.tracer.Visible=S.ESP.Tracer

        for i,bone in ipairs(SkeletonBones) do
            local p1=char:FindFirstChild(bone[1])
            local p2=char:FindFirstChild(bone[2])
            local bl=o.bones[i]
            if p1 and p2 and S.ESP.SkeletonESP then
                local s1,on1=Cam:WorldToViewportPoint(p1.Position)
                local s2,on2=Cam:WorldToViewportPoint(p2.Position)
                if on1 and on2 then
                    bl.From=Vector2.new(s1.X,s1.Y) bl.To=Vector2.new(s2.X,s2.Y)
                    bl.Color=col bl.Visible=true
                else bl.Visible=false end
            else bl.Visible=false end
        end
    end
end))

Track(Players.PlayerAdded:Connect(function(p)
    SetupPlayerESP(p)
end))

Track(Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        for k,o in pairs(ESP[p]) do
            if k=="bones" then for _,b in ipairs(o) do pcall(function() b:Remove() end) end
            elseif o.Visible~=nil then pcall(function() o:Remove() end) end
        end
        ESP[p]=nil
    end
end))

for _,p in ipairs(Players:GetPlayers()) do
    if p~=LP then SetupPlayerESP(p) end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function GetTarget()
    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local closest,closestD=nil,S.Aim.FOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not Alive(p) then continue end
        local t=p.Character and p.Character:FindFirstChild(S.Aim.Part)
        if not t then continue end
        local pos,on=Cam:WorldToViewportPoint(t.Position)
        if not on then continue end
        local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
        if d<closestD then closestD=d closest=t end
    end
    return closest
end

Track(RunService.RenderStepped:Connect(function()
    if not Loaded or not S.Aim.On then return end
    local holding=UserInputService:IsMouseButtonPressed(S.Aim.Key) or
        (typeof(S.Aim.Key)=="EnumItem" and S.Aim.Key.EnumType==Enum.KeyCode and UserInputService:IsKeyDown(S.Aim.Key))
    if not holding then return end
    local target=GetTarget()
    if not target then return end
    local _,on=Cam:WorldToViewportPoint(target.Position)
    if not on then return end
    Cam.CFrame=Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position,target.Position),1-S.Aim.Smooth)
end))

Track(RunService.Heartbeat:Connect(function()
    if not Loaded or not S.Aim.TriggerBot then return end
    local target=GetTarget()
    if not target then return end
    local pos,on=Cam:WorldToViewportPoint(target.Position)
    if not on then return end
    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    if (Vector2.new(pos.X,pos.Y)-center).Magnitude<15 then
        mouse1click()
    end
end))

-- ============================================================
-- MAIN HEARTBEAT
-- ============================================================
Track(RunService.Heartbeat:Connect(function()
    if not Loaded then return end
    local char=Char() local hum=Hum() local root=Root()

    if S.Misc.Stamina and char then
        local targets={char,LP,LP:FindFirstChild("leaderstats"),LP:FindFirstChild("PlayerGui"),LP:FindFirstChild("PlayerScripts"),LP:FindFirstChild("Backpack")}
        for _,tgt in ipairs(targets) do
            if not tgt then continue end
            for _,v in ipairs(tgt:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("FloatValue") then
                    local n=v.Name:lower()
                    if n=="stamina" or n=="energy" or n=="sprint" or n=="endurance" or
                       n=="sprintenergy" or n=="stam" or n=="sprintbar" or n=="sprintmeter" or
                       n=="runstamina" or n=="currentstamina" or n:find("stam") or
                       n:find("sprint") or n:find("energy") or n:find("endur") then
                        v.Value=v.MaxValue or 100
                    end
                end
            end
        end
    end

    if (S.Misc.InfHealth or S.Misc.GodMode) and hum then hum.Health=hum.MaxHealth end
    if S.Misc.AutoHeal and hum and hum.Health<hum.MaxHealth then hum.Health=math.min(hum.Health+0.5,hum.MaxHealth) end
    if hum then hum.WalkSpeed=S.Misc.Speed and S.Misc.SpeedVal or 16 end
    if hum then hum.JumpPower=S.Misc.SuperJump and S.Misc.JumpPower or 50 end

    if S.Misc.NoClip and char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    if S.Misc.Bright then
        Lighting.Brightness=10 Lighting.ClockTime=14 Lighting.FogEnd=1e6
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    end

    workspace.Gravity=S.World.AntiGravity and 10 or S.World.Gravity

    if S.Misc.KillAura and root then
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP or not Alive(p) then continue end
            local pr=GetRoot(p)
            if pr and (root.Position-pr.Position).Magnitude<=S.Misc.KillAuraRange then
                local ph=p.Character:FindFirstChildOfClass("Humanoid")
                if ph then ph.Health=0 end
            end
        end
    end

    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier=S.Misc.Invisible and 1 or 0
            end
        end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetRoot(p)
        if pr then pr.Anchored=S.Misc.FreezeAll end
    end
end))

Track(UserInputService.JumpRequest:Connect(function()
    if not Loaded then return end
    if S.Misc.Jump then local h=Hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end))

Track(LP.Idled:Connect(function()
    if not Loaded then return end
    if S.Misc.AFK then
        VirtualUser:Button2Down(Vector2.zero,Cam.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.zero,Cam.CFrame)
    end
end))

-- ============================================================
-- FLY
-- ============================================================
local FlyBV,FlyBG,FlyCon
local function StartFly()
    local r=Root() if not r then return end
    FlyBV=Instance.new("BodyVelocity",r) FlyBV.Name="OwnerBV"
    FlyBV.MaxForce=Vector3.new(1e9,1e9,1e9) FlyBV.Velocity=Vector3.zero
    FlyBG=Instance.new("BodyGyro",r) FlyBG.Name="OwnerBG"
    FlyBG.MaxTorque=Vector3.new(1e9,1e9,1e9) FlyBG.D=100 FlyBG.P=1e4 FlyBG.CFrame=r.CFrame
    FlyCon=Track(RunService.RenderStepped:Connect(function()
        if not Loaded or not S.Misc.Fly then
            if FlyBV then FlyBV:Destroy() end
            if FlyBG then FlyBG:Destroy() end
            if FlyCon then FlyCon:Disconnect() end
            return
        end
        local UI=UserInputService local d=Vector3.zero
        if UI:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector end
        if UI:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector end
        if UI:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
        if UI:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
        if UI:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UI:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
        FlyBV.Velocity=d*S.Misc.FlySpeed FlyBG.CFrame=Cam.CFrame
    end))
end

local function StopFly()
    S.Misc.Fly=false
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if FlyCon then FlyCon:Disconnect() end
    local h=Hum() if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end
end

-- ============================================================
-- RAYFIELD UI
-- ============================================================
local Win=Rayfield:CreateWindow({
    Name="⚡ Street Life | OWNER ULTIMATE",
    LoadingTitle="Street Life Remastered",
    LoadingSubtitle="👑 Owner Panel — ULTIMATE EDITION",
    Theme="DarkBlue",
    DisableRayfieldPrompts=true,
    DisableBuildWarnings=true,
    ConfigurationSaving={Enabled=false},
    KeySystem=false,
})

-- HOME TAB
local HT=Win:CreateTab("Home","home")
HT:CreateSection("Welcome, Owner")
HT:CreateLabel("Street Life Remastered — Owner Panel")
HT:CreateLabel("UserId: 9266010098 | Ultimate Edition")
HT:CreateDivider()
HT:CreateButton({Name="📋 List All Players",Callback=function()
    local t={} for _,p in ipairs(Players:GetPlayers()) do
        table.insert(t,string.format("%s | %dm | %s | ID:%s",
            p.DisplayName,Dist(p),Alive(p) and "✅ Alive" or "💀 Dead",p.UserId))
    end
    Notify("Players ("..#t..")",table.concat(t,"\n"),10,"users")
end})
HT:CreateButton({Name="🔄 Rejoin Server",Callback=function()
    TeleportService:Teleport(game.PlaceId,LP)
end})
HT:CreateDivider()
HT:CreateButton({Name="❌ UNLOAD PANEL",Callback=function()
    Unload()
end})

-- ESP TAB
local ET=Win:CreateTab("ESP","eye")
ET:CreateSection("Visuals")
ET:CreateToggle({Name="Enable ESP",CurrentValue=false,Flag="e1",Callback=function(v) S.ESP.On=v end})
ET:CreateDivider()
ET:CreateToggle({Name="Boxes",CurrentValue=true,Flag="e2",Callback=function(v) S.ESP.Box=v end})
ET:CreateToggle({Name="Fill Boxes",CurrentValue=false,Flag="e3",Callback=function(v) S.ESP.Fill=v end})
ET:CreateToggle({Name="Names",CurrentValue=true,Flag="e4",Callback=function(v) S.ESP.Name=v end})
ET:CreateToggle({Name="Distance",CurrentValue=true,Flag="e5",Callback=function(v) S.ESP.Dist=v end})
ET:CreateToggle({Name="Health Bars",CurrentValue=true,Flag="e6",Callback=function(v) S.ESP.Health=v end})
ET:CreateToggle({Name="Head Dot",CurrentValue=true,Flag="e7",Callback=function(v) S.ESP.Head=v end})
ET:CreateToggle({Name="Tracers",CurrentValue=false,Flag="e8",Callback=function(v) S.ESP.Tracer=v end})
ET:CreateToggle({Name="Skeleton ESP",CurrentValue=false,Flag="e9",Callback=function(v) S.ESP.SkeletonESP=v end})
ET:CreateDivider()
ET:CreateToggle({Name="🟢 Visibility Check",CurrentValue=false,Flag="e12",Callback=function(v)
    S.ESP.VisCheck=v
    Notify("Visibility Check",v and "ON — 🟢 Visible / 🔴 Hidden" or "OFF",3,"eye")
end})
ET:CreateDivider()
ET:CreateToggle({Name="🌈 Rainbow Mode",CurrentValue=false,Flag="e10",Callback=function(v) S.ESP.Rainbow=v end})
ET:CreateToggle({Name="Team Colors",CurrentValue=false,Flag="e11",Callback=function(v) S.ESP.Team=v end})
ET:CreateColorPicker({Name="ESP Color",Color=Color3.fromRGB(255,50,50),Flag="ec",Callback=function(v) S.ESP.Color=v end})

-- AIMBOT TAB
local AT=Win:CreateTab("Aimbot","crosshair")
AT:CreateSection("Aim Assistance")
AT:CreateToggle({Name="Enable Aimbot",CurrentValue=false,Flag="a1",Callback=function(v) S.Aim.On=v end})
AT:CreateToggle({Name="TriggerBot",CurrentValue=false,Flag="a2",Callback=function(v) S.Aim.TriggerBot=v end})
AT:CreateDivider()
AT:CreateToggle({Name="Show FOV Circle",CurrentValue=true,Flag="a3",Callback=function(v) S.Aim.ShowFOV=v end})
AT:CreateColorPicker({Name="FOV Color",Color=Color3.fromRGB(255,255,255),Flag="ac",Callback=function(v) S.Aim.FOVColor=v FovCircle.Color=v end})
AT:CreateSlider({Name="FOV Radius",Range={50,800},Increment=10,Suffix=" px",CurrentValue=150,Flag="a4",Callback=function(v) S.Aim.FOV=v end})
AT:CreateSlider({Name="Smoothness",Range={0,99},Increment=1,Suffix="%",CurrentValue=15,Flag="a5",Callback=function(v) S.Aim.Smooth=v/100 end})
AT:CreateDivider()
AT:CreateDropdown({Name="Target Part",Options={"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm"},CurrentOption={"Head"},Flag="a6",Callback=function(v) S.Aim.Part=v[1] end})
AT:CreateDropdown({Name="Aim Key",Options={"RightClick","LeftClick","Q","E","F","C","X","Z"},CurrentOption={"RightClick"},Flag="a7",Callback=function(v)
    local k={RightClick=Enum.UserInputType.MouseButton2,LeftClick=Enum.UserInputType.MouseButton1,
        Q=Enum.KeyCode.Q,E=Enum.KeyCode.E,F=Enum.KeyCode.F,C=Enum.KeyCode.C,X=Enum.KeyCode.X,Z=Enum.KeyCode.Z}
    S.Aim.Key=k[v[1]]
end})

-- PLAYERS TAB
local PT=Win:CreateTab("Players","users")
PT:CreateSection("Player Control")
PT:CreateButton({Name="🔍 Teleport to Closest",Callback=function()
    local r=Root() if not r then return end
    local cl,cd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetRoot(p) if not pr then continue end
        local d=(r.Position-pr.Position).Magnitude if d<cd then cd=d cl=pr end
    end
    if cl then r.CFrame=cl.CFrame+Vector3.new(0,5,0) Notify("Teleported","Moved to closest player.",3,"map-pin") end
end})
PT:CreateButton({Name="👁️ Spectate Closest",Callback=function()
    local r=Root() if not r then return end
    local cl,cd,cp=nil,math.huge,nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetRoot(p) if not pr then continue end
        local d=(r.Position-pr.Position).Magnitude if d<cd then cd=d cl=pr cp=p end
    end
    if cp then Cam.CameraSubject=cp.Character:FindFirstChildOfClass("Humanoid") Notify("Spectating",cp.DisplayName,3,"eye") end
end})
PT:CreateButton({Name="🎥 Reset Camera",Callback=function()
    local h=Hum() if h then Cam.CameraSubject=h Notify("Camera","Reset.",2,"refresh-cw") end
end})
PT:CreateButton({Name="🧲 Teleport ALL to Me",Callback=function()
    local r=Root() if not r then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetRoot(p) if not pr then continue end
        pr.CFrame=r.CFrame+Vector3.new(math.random(-5,5),2,math.random(-5,5))
    end
    Notify("Teleport All","Pulled everyone to you.",3,"users")
end})
PT:CreateButton({Name="💀 Kill All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health=0 end
    end
    Notify("Kill All","Done. 💀",3,"skull")
end})
PT:CreateDivider()
PT:CreateToggle({Name="⚰️ Kill Aura",CurrentValue=false,Flag="p1",Callback=function(v) S.Misc.KillAura=v Notify("Kill Aura",v and "ON" or "OFF",2,"zap") end})
PT:CreateSlider({Name="Kill Aura Range",Range={5,100},Increment=1,Suffix=" studs",CurrentValue=20,Flag="p2",Callback=function(v) S.Misc.KillAuraRange=v end})
PT:CreateDivider()
PT:CreateToggle({Name="🧊 Freeze All Players",CurrentValue=false,Flag="p3",Callback=function(v) S.Misc.FreezeAll=v Notify("Freeze All",v and "ON" or "OFF",2,"thermometer") end})

-- MISC TAB
local MT=Win:CreateTab("Misc","zap")
MT:CreateSection("Player Cheats")
MT:CreateToggle({Name="⚡ Infinite Stamina",CurrentValue=true,Flag="m1",Callback=function(v) S.Misc.Stamina=v Notify("Inf Stamina",v and "ON" or "OFF",2,"zap") end})
MT:CreateToggle({Name="❤️ Infinite Health",CurrentValue=false,Flag="m2",Callback=function(v) S.Misc.InfHealth=v Notify("Inf Health",v and "ON" or "OFF",2,"heart") end})
MT:CreateToggle({Name="🛡️ God Mode",CurrentValue=false,Flag="m3",Callback=function(v) S.Misc.GodMode=v Notify("God Mode",v and "ON" or "OFF",3,"shield") end})
MT:CreateToggle({Name="💊 Auto Heal",CurrentValue=false,Flag="m4",Callback=function(v) S.Misc.AutoHeal=v Notify("Auto Heal",v and "ON" or "OFF",2,"activity") end})
MT:CreateDivider()
MT:CreateToggle({Name="💨 Speed Boost",CurrentValue=false,Flag="m5",Callback=function(v) S.Misc.Speed=v Notify("Speed",v and "ON" or "OFF",2,"wind") end})
MT:CreateSlider({Name="Walk Speed",Range={16,500},Increment=1,Suffix=" spd",CurrentValue=50,Flag="m6",Callback=function(v) S.Misc.SpeedVal=v end})
MT:CreateToggle({Name="🦘 Infinite Jump",CurrentValue=false,Flag="m7",Callback=function(v) S.Misc.Jump=v Notify("Inf Jump",v and "ON" or "OFF",2,"chevrons-up") end})
MT:CreateToggle({Name="🚀 Super Jump",CurrentValue=false,Flag="m8",Callback=function(v) S.Misc.SuperJump=v Notify("Super Jump",v and "ON" or "OFF",2,"chevrons-up") end})
MT:CreateSlider({Name="Jump Power",Range={50,500},Increment=10,Suffix=" power",CurrentValue=150,Flag="m9",Callback=function(v) S.Misc.JumpPower=v end})
MT:CreateToggle({Name="👻 NoClip",CurrentValue=false,Flag="m10",Callback=function(v) S.Misc.NoClip=v Notify("NoClip",v and "ON" or "OFF",2,"layers") end})
MT:CreateToggle({Name="🫥 Invisible (Local)",CurrentValue=false,Flag="m11",Callback=function(v) S.Misc.Invisible=v Notify("Invisible",v and "ON" or "OFF",3,"eye-off") end})
MT:CreateDivider()
MT:CreateToggle({Name="🛸 Fly",CurrentValue=false,Flag="m12",Callback=function(v)
    S.Misc.Fly=v
    if v then StartFly() Notify("Fly","WASD + Space/Shift",4,"navigation")
    else StopFly() Notify("Fly","OFF",2,"navigation") end
end})
MT:CreateSlider({Name="Fly Speed",Range={10,500},Increment=5,Suffix=" spd",CurrentValue=80,Flag="m13",Callback=function(v) S.Misc.FlySpeed=v end})

-- WORLD TAB
local WT=Win:CreateTab("World","globe")
WT:CreateSection("World Control")
WT:CreateToggle({Name="☀️ Fullbright",CurrentValue=false,Flag="w1",Callback=function(v) S.Misc.Bright=v Notify("Fullbright",v and "ON" or "OFF",2,"sun") end})
WT:CreateToggle({Name="🌌 Anti Gravity",CurrentValue=false,Flag="w2",Callback=function(v) S.World.AntiGravity=v Notify("Anti Gravity",v and "ON" or "OFF",2,"arrow-up") end})
WT:CreateSlider({Name="Gravity",Range={0,400},Increment=5,Suffix=" grav",CurrentValue=196,Flag="w3",Callback=function(v) S.World.Gravity=v if not S.World.AntiGravity then workspace.Gravity=v end end})
WT:CreateSlider({Name="Time of Day",Range={0,24},Increment=1,Suffix=":00",CurrentValue=14,Flag="w4",Callback=function(v) Lighting.ClockTime=v end})
WT:CreateDivider()
WT:CreateButton({Name="💥 Explode All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pr=GetRoot(p) if not pr then continue end
        local e=Instance.new("Explosion")
        e.Position=pr.Position e.BlastRadius=10 e.BlastPressure=5e6
        e.Parent=workspace
    end
    Notify("Explosion","Boom! 💥",3,"zap")
end})
WT:CreateButton({Name="🌊 Flood Server",Callback=function()
    local part=Instance.new("Part")
    part.Size=Vector3.new(2048,1,2048)
    part.Position=Vector3.new(0,3,0)
    part.Anchored=true
    part.Color=Color3.fromRGB(0,120,255)
    part.Material=Enum.Material.Neon
    part.Transparency=0.4
    part.Name="OwnerFlood"
    part.Parent=workspace
    Notify("Flood","Flood placed. 🌊",3,"droplets")
end})
WT:CreateButton({Name="🗑️ Remove Flood",Callback=function()
    local f=workspace:FindFirstChild("OwnerFlood")
    if f then f:Destroy() Notify("Flood","Removed.",2,"trash") end
end})
WT:CreateDivider()
WT:CreateToggle({Name="🚫 Anti-AFK",CurrentValue=true,Flag="w5",Callback=function(v) S.Misc.AFK=v Notify("Anti-AFK",v and "ON" or "OFF",2,"shield") end})

-- ============================================================
-- STARTUP
-- ============================================================
Notify("👑 Owner Panel","Ultimate Edition loaded. Welcome, "..LP.DisplayName.."! 🔥",6,"shield")

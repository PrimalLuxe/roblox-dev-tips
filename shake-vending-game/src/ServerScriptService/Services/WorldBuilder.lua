local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")

local Machines=require(ReplicatedStorage.Shared.MachineDefinitions)
local Config=require(ReplicatedStorage.Shared.Config)
local MachineArtDirector=require(script.Parent.MachineArtDirector)

local WorldBuilder={}

local function importedFolder()local a=ReplicatedStorage:FindFirstChild("Assets");return a and a:FindFirstChild("ImportedModels")end
local function source(key)local f=importedFolder();return f and f:FindFirstChild(key)end
local function sanitizeClone(root,collisions)
    for _,d in ipairs(root:GetDescendants())do
        if d:IsA("BaseScript")or d:IsA("ModuleScript")or d:IsA("RemoteEvent")or d:IsA("RemoteFunction")or d:IsA("BindableEvent")or d:IsA("BindableFunction")or d:IsA("Tool")or d:IsA("Humanoid")or d:IsA("AnimationController")or d:IsA("ClickDetector")or d:IsA("ProximityPrompt")then d:Destroy()
        elseif d:IsA("BasePart")then d.Anchored=true;d.CanTouch=false;d.CanQuery=true;d.Massless=true;d.CanCollide=collisions==true end
    end
end
local function ensureModel(obj)if obj:IsA("Model")then return obj end;local m=Instance.new("Model");obj.Parent=m;if obj:IsA("BasePart")then m.PrimaryPart=obj end;return m end
local function scaleLongest(model,target)local ok,s=pcall(function()return model:GetExtentsSize()end);if not ok or not s then return end;local l=math.max(s.X,s.Y,s.Z);if l>0 then pcall(function()model:ScaleTo(model:GetScale()*(target/l))end)end end
local function placeOnGround(model,pos,yaw)local _,s=model:GetBoundingBox();model:PivotTo(CFrame.new(pos+Vector3.new(0,s.Y/2,0))*CFrame.Angles(0,math.rad(yaw or 0),0))end

local function part(parent,name,size,cf,color,material,transparency,collide)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.CanCollide=collide~=false;p.CanTouch=false;p.CanQuery=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function studPart(parent,name,size,cf,color,material)local p=part(parent,name,size,cf,color,material,0,true);p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Inlet;return p end
local function localCF(pos,yaw,x,y,z)return CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)*CFrame.new(x,y,z)end
local function surfaceSign(parent,name,size,cf,title,subtitle,accent,bg)
    local p=part(parent,name,size,cf,bg or Color3.fromRGB(247,241,222),Enum.Material.SmoothPlastic,0,false)
    local trim=Instance.new("SurfaceGui");trim.Face=Enum.NormalId.Front;trim.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;trim.PixelsPerStud=48;trim.LightInfluence=.25;trim.Parent=p
    local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundColor3=bg or Color3.fromRGB(247,241,222);f.BorderSizePixel=0;f.Parent=trim
    local stripe=Instance.new("Frame");stripe.Size=UDim2.new(0,10,1,-14);stripe.Position=UDim2.fromOffset(8,7);stripe.BackgroundColor3=accent;stripe.BorderSizePixel=0;stripe.Parent=f
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(28,8);t.Size=UDim2.new(1,-38,.55,-4);t.Text=title;t.TextColor3=Color3.fromRGB(31,49,70);t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=f
    local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.new(0,28,.56,0);s.Size=UDim2.new(1,-38,.35,-3);s.Text=subtitle or"";s.TextColor3=accent;s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.TextXAlignment=Enum.TextXAlignment.Left;s.Parent=f
    return p
end
local function cloneWorldAsset(key,longest,pos,yaw,parent,name)
    local src=source(key);if not src then return nil end
    local m=ensureModel(src:Clone());sanitizeClone(m,true);scaleLongest(m,longest);m.Name=name or key;m.Parent=parent;placeOnGround(m,pos,yaw);return m
end
local function isTextured(p)return(p:IsA("MeshPart")and p.TextureID and p.TextureID~="")or p:FindFirstChildWhichIsA("SurfaceAppearance")~=nil end
local function restyleMachine(model,def)
    for _,d in ipairs(model:GetDescendants())do if d:IsA("BasePart")and not isTextured(d)then local c=d.Color;local neutral=(math.max(c.R,c.G,c.B)-math.min(c.R,c.G,c.B))<.18;local n=d.Name:lower();if neutral or n:find("body")or n:find("frame")or n:find("case")or n:find("shell")then d.Color=def.Color:Lerp(c,.22)end;if d.Material~=Enum.Material.Glass and d.Material~=Enum.Material.Neon then d.Material=Enum.Material.SmoothPlastic end end end
    local hl=Instance.new("Highlight");hl.Name="MachineAccent";hl.FillTransparency=1;hl.OutlineTransparency=.90;hl.OutlineColor=def.Accent;hl.DepthMode=Enum.HighlightDepthMode.Occluded;hl.Parent=model
end
local function findTray(model)for _,d in ipairs(model:GetDescendants())do if d:IsA("BasePart")then local n=d.Name:lower();if n:find("dispens")or n:find("tray")or n:find("output")then return d end end end end

local function makeMachine(machineId,def,pos,yaw)
    local src=source(def.AssetVariant or"VendingMachineDetailed")or source("VendingMachineDetailed")or source("VendingMachine");if not src then return nil end
    local model=Instance.new("Model");model.Name=machineId;model:SetAttribute("MachineId",machineId);model:SetAttribute("UnlockCost",def.UnlockCost);model:SetAttribute("WorldId",def.WorldId or"Downtown");model:SetAttribute("EventOnly",def.EventOnly==true);model.Parent=Workspace.Machines
    local shell=ensureModel(src:Clone());shell.Name="Shell";shell.Parent=model;sanitizeClone(shell,false);scaleLongest(shell,10.5);restyleMachine(shell,def);placeOnGround(shell,pos,yaw)
    local ok,e=pcall(function()MachineArtDirector.Apply(model,shell,machineId)end);if not ok then warn("[ShakeVM] machine art failed",machineId,e)end
    local cf,size=shell:GetBoundingBox();local root=part(model,"Root",Vector3.new(math.max(5,size.X),math.max(8,size.Y),math.max(3,size.Z)),cf,Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false);root.CanQuery=false;model.PrimaryPart=root
    local collision=part(model,"CollisionHull",Vector3.new(math.max(3.7,size.X*.90),math.max(6,size.Y*.96),math.max(1.9,size.Z*.74)),cf,Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,true);collision.CanQuery=false
    local tray=findTray(shell);local drop=part(model,"DropSpawn",Vector3.new(.25,.25,.25),CFrame.new(cf.Position),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false);drop.CanQuery=false
    if tray then drop.CFrame=CFrame.new(tray.Position+Vector3.new(0,math.max(.55,tray.Size.Y*.5+.42),0))else drop.CFrame=CFrame.new(cf.Position+Vector3.new(0,-size.Y*.28,-size.Z*.57))end
    local prompt=Instance.new("ProximityPrompt");prompt.Name="ShakePrompt";prompt.ActionText="SHAKE";prompt.ObjectText=def.DisplayName;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.HoldDuration=.12;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Style=Enum.ProximityPromptStyle.Default;prompt.Parent=root
    return model
end

local BUILDING_STYLES={
    CornerStore={Body=Color3.fromRGB(218,205,177),Trim=Color3.fromRGB(43,116,183),Accent=Color3.fromRGB(205,64,59),Glass=Color3.fromRGB(157,207,226),Title="CORNER MARKET",Sub="DRINKS • SNACKS",Type="Corner"},
    SugarRush={Body=Color3.fromRGB(247,214,226),Trim=Color3.fromRGB(236,83,153),Accent=Color3.fromRGB(244,188,54),Glass=Color3.fromRGB(213,228,241),Title="SUGAR RUSH",Sub="CANDY • SWEETS",Type="Candy"},
    Energy={Body=Color3.fromRGB(52,59,66),Trim=Color3.fromRGB(63,194,104),Accent=Color3.fromRGB(56,157,216),Glass=Color3.fromRGB(109,164,177),Title="ENERGY LAB",Sub="SPORT • POWER",Type="Energy"},
    ToyCapsule={Body=Color3.fromRGB(196,190,224),Trim=Color3.fromRGB(96,70,176),Accent=Color3.fromRGB(62,166,214),Glass=Color3.fromRGB(165,211,232),Title="CAPSULE ARCADE",Sub="GACHA • TOYS",Type="Toy"},
    Luxury={Body=Color3.fromRGB(227,216,190),Trim=Color3.fromRGB(184,139,40),Accent=Color3.fromRGB(40,49,63),Glass=Color3.fromRGB(176,203,207),Title="PREMIUM RESERVE",Sub="LUXURY • RARE",Type="Luxury"},
    Unknown={Body=Color3.fromRGB(100,101,99),Trim=Color3.fromRGB(193,126,47),Accent=Color3.fromRGB(52,53,57),Glass=Color3.fromRGB(106,121,120),Title="SERVICE DEPOT",Sub="AUTHORIZED ACCESS",Type="Service"},
}
local function storefront(parent,id,pos,yaw)
    local st=BUILDING_STYLES[id];local m=Instance.new("Model");m.Name=id.."Storefront";m.Parent=parent
    local w,h,d=26,13,16;local base=localCF(pos,yaw,0,h/2,0)
    part(m,"Body",Vector3.new(w,h,d),base,st.Body,Enum.Material.SmoothPlastic,0,true)
    part(m,"Roof",Vector3.new(w+1.5,.65,d+1.5),localCF(pos,yaw,0,h+.25,0),st.Trim,Enum.Material.SmoothPlastic,0,true)
    part(m,"Cornice",Vector3.new(w+.45,.42,.65),localCF(pos,yaw,0,h-.55,-d/2-.27),st.Accent,Enum.Material.SmoothPlastic,0,false)
    local frontZ=-d/2-.06;local windowY=6.2
    for _,x in ipairs({-7.2,0,7.2})do
        local win=part(m,"Window",Vector3.new(5.8,5.2,.18),localCF(pos,yaw,x,windowY,frontZ),st.Glass,Enum.Material.Glass,.26,false);win.Reflectance=.04
        part(m,"WindowTop",Vector3.new(6,.18,.28),localCF(pos,yaw,x,8.82,frontZ-.05),st.Trim,Enum.Material.Metal,0,false)
        part(m,"WindowBottom",Vector3.new(6,.18,.28),localCF(pos,yaw,x,3.58,frontZ-.05),st.Trim,Enum.Material.Metal,0,false)
    end
    local door=part(m,"DoorGlass",Vector3.new(3.2,6,.20),localCF(pos,yaw,0,3.1,frontZ-.10),st.Glass,Enum.Material.Glass,.18,false);part(m,"DoorHandle",Vector3.new(.10,1.25,.16),door.CFrame*CFrame.new(1.05,0,-.18),st.Accent,Enum.Material.Metal,0,false)
    surfaceSign(m,"StoreSign",Vector3.new(16,2.1,.35),localCF(pos,yaw,0,10.9,frontZ-.28),st.Title,st.Sub,st.Trim,Color3.fromRGB(247,241,222))
    if st.Type=="Corner"then
        for i=-4,4 do part(m,"Awning"..i,Vector3.new(2.35,.22,2.4),localCF(pos,yaw,i*2.45,8.9,frontZ-1),i%2==0 and st.Accent or Color3.fromRGB(245,237,213),Enum.Material.SmoothPlastic,0,false)end
        for i=1,3 do part(m,"Crate"..i,Vector3.new(1.5,.8,1.2),localCF(pos,yaw,-10+i*1.2,.45,frontZ-1.5),Color3.fromRGB(166,112,63),Enum.Material.WoodPlanks,0,true)end
    elseif st.Type=="Candy"then
        for i=-4,4 do local b=part(m,"CandyBulb"..i,Vector3.new(.42,.42,.42),localCF(pos,yaw,i*1.65,12.3,frontZ-.45),i%2==0 and st.Trim or st.Accent,Enum.Material.Glass,.05,false);b.Shape=Enum.PartType.Ball end
        part(m,"StripeL",Vector3.new(.45,8,.45),localCF(pos,yaw,-12,4.2,frontZ-.5),st.Trim,Enum.Material.SmoothPlastic,0,false);part(m,"StripeR",Vector3.new(.45,8,.45),localCF(pos,yaw,12,4.2,frontZ-.5),st.Accent,Enum.Material.SmoothPlastic,0,false)
    elseif st.Type=="Energy"then
        for i=-2,2 do part(m,"PowerStrip"..i,Vector3.new(.18,10,.32),localCF(pos,yaw,i*4.5,6.5,frontZ-.25)*CFrame.Angles(0,0,math.rad(i%2==0 and 7 or-7)),i%2==0 and st.Trim or st.Accent,Enum.Material.Neon,0,false)end
    elseif st.Type=="Toy"then
        part(m,"MarqueeBox",Vector3.new(20,3,.7),localCF(pos,yaw,0,10.7,frontZ-.55),st.Trim,Enum.Material.SmoothPlastic,0,false)
        for i=-7,7 do local b=part(m,"MarqueeBulb"..i,Vector3.new(.22,.22,.22),localCF(pos,yaw,i*1.2,12.05,frontZ-.96),i%2==0 and st.Accent or Color3.fromRGB(247,208,64),Enum.Material.Neon,0,false);b.Shape=Enum.PartType.Ball end
    elseif st.Type=="Luxury"then
        for _,x in ipairs({-11,-8,8,11})do part(m,"Column"..x,Vector3.new(.55,11,.55),localCF(pos,yaw,x,5.7,frontZ-.65),st.Trim,Enum.Material.Marble,0,false)end
        part(m,"GoldBand",Vector3.new(23,.22,.30),localCF(pos,yaw,0,9.25,frontZ-.4),st.Trim,Enum.Material.Metal,0,false)
    elseif st.Type=="Service"then
        local shutter=part(m,"Shutter",Vector3.new(11,8,.22),localCF(pos,yaw,0,4.2,frontZ-.25),Color3.fromRGB(70,72,74),Enum.Material.Metal,0,false)
        for i=-4,4 do part(m,"ShutterLine"..i,Vector3.new(10.7,.08,.05),shutter.CFrame*CFrame.new(0,i*.72,-.14),Color3.fromRGB(126,126,120),Enum.Material.Metal,0,false)end
        for i=-4,4 do part(m,"Hazard"..i,Vector3.new(1.5,.26,.20),localCF(pos,yaw,i*1.45,9.1,frontZ-.34)*CFrame.Angles(0,0,math.rad(i%2==0 and 14 or-14)),i%2==0 and st.Trim or st.Accent,Enum.Material.SmoothPlastic,0,false)end
    end
    return m
end

local function lamp(parent,pos)
    part(parent,"LampPost",Vector3.new(.34,7,.34),CFrame.new(pos+Vector3.new(0,3.5,0)),Color3.fromRGB(55,62,68),Enum.Material.Metal,0,true)
    local head=part(parent,"LampHead",Vector3.new(1,.4,1),CFrame.new(pos+Vector3.new(0,7.1,0)),Color3.fromRGB(47,53,59),Enum.Material.Metal,0,false)
    local glow=part(parent,"LampGlow",Vector3.new(.58,.18,.58),head.CFrame*CFrame.new(0,-.27,0),Color3.fromRGB(255,223,156),Enum.Material.Neon,0,false)
    local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,219,155);light.Brightness=.85;light.Range=18;light.Shadows=false;light.Parent=glow
end
local function bench(parent,pos,yaw)
    local m=Instance.new("Model");m.Name="Bench";m.Parent=parent;local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
    part(m,"Seat",Vector3.new(5,.35,1.4),cf*CFrame.new(0,1,0),Color3.fromRGB(153,103,62),Enum.Material.WoodPlanks,0,true)
    part(m,"Back",Vector3.new(5,1.8,.25),cf*CFrame.new(0,1.95,.58)*CFrame.Angles(math.rad(-8),0,0),Color3.fromRGB(153,103,62),Enum.Material.WoodPlanks,0,false)
    for _,x in ipairs({-2,2})do part(m,"Leg"..x,Vector3.new(.25,1,.9),cf*CFrame.new(x,.45,0),Color3.fromRGB(58,62,65),Enum.Material.Metal,0,true)end
end

local DISTRICTS={
    {Id="CornerStore",Machine=Vector3.new(-50,0,29),Yaw=28},
    {Id="SugarRush",Machine=Vector3.new(0,0,48),Yaw=0},
    {Id="Energy",Machine=Vector3.new(50,0,29),Yaw=-28},
    {Id="ToyCapsule",Machine=Vector3.new(52,0,-38),Yaw=-145},
    {Id="Luxury",Machine=Vector3.new(0,0,-54),Yaw=180},
    {Id="Unknown",Machine=Vector3.new(-52,0,-38),Yaw=145},
}

local function setLighting()
    Lighting.ClockTime=15.2;Lighting.Brightness=1.65;Lighting.ExposureCompensation=-.12
    Lighting.Ambient=Color3.fromRGB(72,78,88);Lighting.OutdoorAmbient=Color3.fromRGB(110,119,132);Lighting.EnvironmentDiffuseScale=.34;Lighting.EnvironmentSpecularScale=.48
    local bloom=Lighting:FindFirstChild("ShakeBloom")or Instance.new("BloomEffect");bloom.Name="ShakeBloom";bloom.Intensity=.06;bloom.Size=18;bloom.Threshold=1.65;bloom.Parent=Lighting
    local cc=Lighting:FindFirstChild("ShakeColor")or Instance.new("ColorCorrectionEffect");cc.Name="ShakeColor";cc.Saturation=.04;cc.Contrast=.055;cc.Brightness=-.015;cc.Parent=Lighting
    local atm=Lighting:FindFirstChild("ShakeAtmosphere")or Instance.new("Atmosphere");atm.Name="ShakeAtmosphere";atm.Density=.18;atm.Offset=.10;atm.Color=Color3.fromRGB(199,218,232);atm.Decay=Color3.fromRGB(95,112,126);atm.Glare=.04;atm.Haze=.55;atm.Parent=Lighting
end

function WorldBuilder:Init()
    setLighting()
    local old=Workspace:FindFirstChild("ShakeHub");if old then old:Destroy()end;local oldM=Workspace:FindFirstChild("Machines");if oldM then oldM:Destroy()end
    local hub=Instance.new("Folder");hub.Name="ShakeHub";hub.Parent=Workspace;local machines=Instance.new("Folder");machines.Name="Machines";machines.Parent=Workspace
    if Config.RequireCreatorStoreAssets and not ReplicatedStorage:GetAttribute("CreatorAssetsReady")then
        studPart(hub,"SetupFloor",Vector3.new(70,1,44),CFrame.new(0,-.5,0),Color3.fromRGB(72,161,86))
        local p=surfaceSign(hub,"SetupNotice",Vector3.new(26,8,.5),CFrame.new(0,6,-10),"ASSETS NOT READY","ENABLE: GAME SETTINGS > SECURITY > ALLOW LOADING THIRD PARTY ASSETS",Color3.fromRGB(219,144,54),Color3.fromRGB(247,241,222));p.CanCollide=false
        return
    end

    studPart(hub,"Ground",Vector3.new(220,1,190),CFrame.new(0,-.55,-5),Color3.fromRGB(82,154,84))
    part(hub,"RoadNorthSouth",Vector3.new(34,.32,164),CFrame.new(0,.04,-5),Color3.fromRGB(58,63,69),Enum.Material.Asphalt,0,true)
    part(hub,"RoadEastWest",Vector3.new(176,.32,32),CFrame.new(0,.05,-4),Color3.fromRGB(58,63,69),Enum.Material.Asphalt,0,true)
    part(hub,"CentralPlaza",Vector3.new(58,.42,52),CFrame.new(0,.12,-3),Color3.fromRGB(211,204,184),Enum.Material.Concrete,0,true)
    for _,z in ipairs({-83,73})do part(hub,"EdgeRoad"..z,Vector3.new(176,.30,18),CFrame.new(0,.03,z),Color3.fromRGB(64,69,74),Enum.Material.Asphalt,0,true)end
    for _,x in ipairs({-92,92})do part(hub,"EdgeRoad"..x,Vector3.new(18,.30,150),CFrame.new(x,.03,-5),Color3.fromRGB(64,69,74),Enum.Material.Asphalt,0,true)end
    for _,x in ipairs({-30,30})do part(hub,"NSCurb"..x,Vector3.new(.6,.36,158),CFrame.new(x,.26,-5),Color3.fromRGB(186,184,174),Enum.Material.Concrete,0,true)end
    for _,z in ipairs({-20,20})do part(hub,"EWCurb"..z,Vector3.new(170,.36,.6),CFrame.new(0,.26,z),Color3.fromRGB(186,184,174),Enum.Material.Concrete,0,true)end
    for i=1,9 do
        part(hub,"RoadStripeN"..i,Vector3.new(.18,.03,5),CFrame.new(-4,.23,-72+i*15),Color3.fromRGB(231,199,91),Enum.Material.SmoothPlastic,0,false)
        part(hub,"RoadStripeS"..i,Vector3.new(.18,.03,5),CFrame.new(4,.23,-72+i*15),Color3.fromRGB(231,199,91),Enum.Material.SmoothPlastic,0,false)
    end
    for i=1,10 do part(hub,"RoadStripeE"..i,Vector3.new(5,.03,.18),CFrame.new(-76+i*14,.23,-8),Color3.fromRGB(231,199,91),Enum.Material.SmoothPlastic,0,false)end

    for _,d in ipairs(DISTRICTS)do
        local def=Machines[d.Id];local behind=(CFrame.new(d.Machine)*CFrame.Angles(0,math.rad(d.Yaw),0)*CFrame.new(0,0,18)).Position
        storefront(hub,d.Id,behind,d.Yaw)
        local pad=part(hub,d.Id.."MachinePad",Vector3.new(18,.40,15),CFrame.new(d.Machine+Vector3.new(0,.16,0))*CFrame.Angles(0,math.rad(d.Yaw),0),Color3.fromRGB(194,194,184),Enum.Material.Concrete,0,true)
        part(hub,d.Id.."PadInset",Vector3.new(15.5,.05,12.5),pad.CFrame*CFrame.new(0,.23,0),def.Color:Lerp(Color3.fromRGB(225,222,209),.73),Enum.Material.SmoothPlastic,0,false)
        makeMachine(d.Id,def,d.Machine,d.Yaw)
    end

    surfaceSign(hub,"DowntownDirectory",Vector3.new(13,5,.45),CFrame.new(-18,3.1,8)*CFrame.Angles(0,math.rad(18),0),"DOWNTOWN","SHAKE • HUNT • COLLECT",Color3.fromRGB(49,142,207))
    surfaceSign(hub,"PassportDirectory",Vector3.new(10,4,.4),CFrame.new(18,2.6,8)*CFrame.Angles(0,math.rad(-18),0),"VENDING PASSPORT","WORLD 1 • DOWNTOWN",Color3.fromRGB(210,159,43))

    local sell=cloneWorldAsset("SellATM",5.3,Vector3.new(-13,0,-9),180,hub,"SellStation");if sell then sell:SetAttribute("Interaction","Sell")end
    local passport=cloneWorldAsset("SellATM",4.5,Vector3.new(0,0,-14),180,hub,"PassportKiosk");if passport then passport:SetAttribute("Interaction","Passport")end
    local upgrade=cloneWorldAsset("LowPolyShop",8.5,Vector3.new(14,0,-10),180,hub,"UpgradeKiosk")
    if not upgrade then surfaceSign(hub,"UpgradeFallback",Vector3.new(8,4,.4),CFrame.new(14,2.3,-10)*CFrame.Angles(0,math.rad(180),0),"UPGRADES","POWER • LUCK • BAG",Color3.fromRGB(70,176,106))end

    for _,p in ipairs({Vector3.new(-25,0,14),Vector3.new(25,0,14),Vector3.new(-25,0,-22),Vector3.new(25,0,-22),Vector3.new(-68,0,-3),Vector3.new(68,0,-3)})do lamp(hub,p)end
    bench(hub,Vector3.new(-21,0,9),15);bench(hub,Vector3.new(21,0,9),-15);bench(hub,Vector3.new(-21,0,-17),165);bench(hub,Vector3.new(21,0,-17),195)

    local spawn=Instance.new("SpawnLocation");spawn.Name="HubSpawn";spawn.Size=Vector3.new(8,.8,8);spawn.CFrame=CFrame.new(0,.57,7);spawn.Anchored=true;spawn.Neutral=true;spawn.Material=Enum.Material.SmoothPlastic;spawn.Color=Color3.fromRGB(71,153,203);spawn.Transparency=.18;spawn.TopSurface=Enum.SurfaceType.Smooth;spawn.BottomSurface=Enum.SurfaceType.Smooth;spawn.Parent=hub

    local board=part(hub,"GlobalBoard",Vector3.new(23,10,.7),CFrame.new(0,5.4,31),Color3.fromRGB(38,45,54),Enum.Material.Metal,0,true)
    local bg=Instance.new("SurfaceGui");bg.Name="BoardGui";bg.Face=Enum.NormalId.Front;bg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;bg.PixelsPerStud=34;bg.LightInfluence=.35;bg.Parent=board
    local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(24,31,40);frame.BorderSizePixel=0;frame.Parent=bg
    local header=Instance.new("TextLabel");header.Size=UDim2.new(1,-30,0,80);header.Position=UDim2.fromOffset(15,14);header.BackgroundTransparency=1;header.Text="TOP RAREST THIS HOUR";header.TextColor3=Color3.fromRGB(238,192,63);header.Font=Enum.Font.GothamBlack;header.TextSize=30;header.Parent=frame
    local boardLabel=Instance.new("TextLabel");boardLabel.Name="BoardLabel";boardLabel.Position=UDim2.fromOffset(24,98);boardLabel.Size=UDim2.new(1,-48,1,-118);boardLabel.BackgroundTransparency=1;boardLabel.TextColor3=Color3.fromRGB(243,244,239);boardLabel.Text="Loading rare finds...";boardLabel.Font=Enum.Font.GothamBold;boardLabel.TextSize=22;boardLabel.TextWrapped=true;boardLabel.TextYAlignment=Enum.TextYAlignment.Top;boardLabel.Parent=frame
end

return WorldBuilder

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Machines = require(ReplicatedStorage.Shared.MachineDefinitions)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldBuilder = {}

local function importedFolder()
    local assets=ReplicatedStorage:FindFirstChild("Assets")
    return assets and assets:FindFirstChild("ImportedModels")
end

local function source(key)
    local f=importedFolder(); return f and f:FindFirstChild(key)
end

local function sanitizeClone(root, collisions)
    for _,d in ipairs(root:GetDescendants()) do
        if d:IsA("BaseScript") or d:IsA("ModuleScript") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("Tool") or d:IsA("Humanoid") or d:IsA("AnimationController") or d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
            d:Destroy()
        elseif d:IsA("BasePart") then
            d.Anchored=true; d.CanTouch=false; d.CanQuery=true; d.Massless=true
            d.CanCollide=collisions==true
        end
    end
end

local function ensureModel(obj)
    if obj:IsA("Model") then return obj end
    local m=Instance.new("Model"); obj.Parent=m; if obj:IsA("BasePart") then m.PrimaryPart=obj end; return m
end

local function scaleLongest(model,target)
    local ok,size=pcall(function() return model:GetExtentsSize() end)
    if not ok or not size or math.max(size.X,size.Y,size.Z)<=0 then return end
    local longest=math.max(size.X,size.Y,size.Z)
    pcall(function() model:ScaleTo(model:GetScale()*(target/longest)) end)
end

local function placeOnGround(model,position,yaw)
    local _,size=model:GetBoundingBox()
    model:PivotTo(CFrame.new(position+Vector3.new(0,size.Y/2,0))*CFrame.Angles(0,math.rad(yaw or 0),0))
end

local function studPart(parent,name,size,cf,color,material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.Plastic
    p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Inlet;p.Parent=parent
    return p
end

local function billboard(part,title,subtitle,accent)
    local gui=Instance.new("BillboardGui");gui.Name="MachineBillboard";gui.Size=UDim2.fromOffset(300,100);gui.StudsOffset=Vector3.new(0,6.2,0);gui.AlwaysOnTop=true;gui.Adornee=part;gui.Parent=part
    local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(25,29,38);bg.BackgroundTransparency=0.08;bg.BorderSizePixel=0;bg.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,15);corner.Parent=bg
    local st=Instance.new("UIStroke");st.Color=accent;st.Thickness=2;st.Transparency=0.08;st.Parent=bg
    local t=Instance.new("TextLabel");t.Name="Title";t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(10,8);t.Size=UDim2.new(1,-20,0,42);t.Text=title;t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=bg
    local s=Instance.new("TextLabel");s.Name="Subtitle";s.BackgroundTransparency=1;s.Position=UDim2.fromOffset(10,53);s.Size=UDim2.new(1,-20,0,30);s.Text=subtitle;s.TextColor3=accent;s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Parent=bg
    return gui
end

local function isTextured(part)
    if part:IsA("MeshPart") and part.TextureID and part.TextureID~="" then return true end
    return part:FindFirstChildWhichIsA("SurfaceAppearance")~=nil
end

local function restyleMachine(model,def)
    local neutralCount=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            if d:IsA("Part") and d.Transparency<0.7 then
                if d.Size.X>0.35 and d.Size.Z>0.35 then d.TopSurface=Enum.SurfaceType.Studs end
            end
            if not isTextured(d) then
                local c=d.Color
                local maxc=math.max(c.R,c.G,c.B);local minc=math.min(c.R,c.G,c.B)
                local neutral=(maxc-minc)<0.18
                local name=d.Name:lower()
                local structural=name:find("body") or name:find("frame") or name:find("case") or name:find("side") or name:find("shell")
                if neutral or structural then
                    d.Color=def.Color:Lerp(c,0.22);neutralCount+=1
                end
                if d.Material~=Enum.Material.Glass and d.Material~=Enum.Material.Neon then d.Material=Enum.Material.Plastic end
            end
        end
    end
    local hl=Instance.new("Highlight");hl.Name="MachineAccent";hl.FillTransparency=1;hl.OutlineTransparency=0.55;hl.OutlineColor=def.Accent;hl.DepthMode=Enum.HighlightDepthMode.Occluded;hl.Parent=model
    return neutralCount
end

local function cloneWorldAsset(key,longest,pos,yaw)
    local src=source(key); if not src then return nil end
    local model=ensureModel(src:Clone());sanitizeClone(model,true);scaleLongest(model,longest);model.Parent=Workspace.ShakeHub;placeOnGround(model,pos,yaw);return model
end

local function findTray(model)
    local candidates={"tray","dispense","slot","pickup","drop","output"}
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local n=d.Name:lower()
            for _,needle in ipairs(candidates) do if n:find(needle) then return d end end
        end
    end
end

local function makeMachine(machineId,def,position,yaw)
    local src=source(def.AssetVariant or "VendingMachineDetailed") or source("VendingMachineDetailed") or source("VendingMachine")
    if not src then return nil end

    local model=Instance.new("Model");model.Name=machineId;model:SetAttribute("MachineId",machineId);model:SetAttribute("UnlockCost",def.UnlockCost);model:SetAttribute("WorldId",def.WorldId or "Downtown");model:SetAttribute("EventOnly",def.EventOnly==true);model.Parent=Workspace.Machines
    local shell=ensureModel(src:Clone());shell.Name="Shell";shell.Parent=model;sanitizeClone(shell,false);scaleLongest(shell,9.3);restyleMachine(shell,def);placeOnGround(shell,position,yaw or 0)

    local cf,size=shell:GetBoundingBox()
    local root=Instance.new("Part");root.Name="Root";root.Size=Vector3.new(math.max(5,size.X),math.max(8,size.Y),math.max(3,size.Z));root.CFrame=cf;root.Transparency=1;root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Parent=model;model.PrimaryPart=root
    -- Donor models often contain many internal product parts. Keep those non-collidable and use
    -- one predictable collision hull so players never snag on invisible/free-model internals.
    local collision=Instance.new("Part");collision.Name="CollisionHull";collision.Size=Vector3.new(math.max(3.5,size.X*0.88),math.max(6,size.Y*0.96),math.max(1.8,size.Z*0.72));collision.CFrame=cf;collision.Transparency=1;collision.Anchored=true;collision.CanCollide=true;collision.CanTouch=false;collision.CanQuery=false;collision.Parent=model

    local tray=findTray(shell)
    local dropSpawn=Instance.new("Part");dropSpawn.Name="DropSpawn";dropSpawn.Size=Vector3.new(0.25,0.25,0.25);dropSpawn.Transparency=1;dropSpawn.Anchored=true;dropSpawn.CanCollide=false;dropSpawn.CanQuery=false;dropSpawn.CanTouch=false
    if tray then
        -- Use the donor model's real dispenser/tray when it has one. Position the reveal just
        -- above the tray instead of assuming which local axis the original creator called "front".
        dropSpawn.CFrame=CFrame.new(tray.Position+Vector3.new(0,math.max(0.55,tray.Size.Y*0.5+0.42),0))
    else
        dropSpawn.CFrame=CFrame.new(cf.Position+Vector3.new(0,-size.Y*0.28,-size.Z*0.57))
    end
    dropSpawn.Parent=model

    local prompt=Instance.new("ProximityPrompt");prompt.Name="ShakePrompt";prompt.ActionText="SHAKE";prompt.ObjectText=def.DisplayName;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.HoldDuration=0.16;prompt.MaxActivationDistance=11;prompt.RequiresLineOfSight=false;prompt.Parent=root

    local req=def.UnlockRequirements or {}
    local subtitle
    if def.EventOnly then
        subtitle="EVENT HUNT • BLACKOUT / MYSTERY"
    elseif def.UnlockCost==0 then
        subtitle="FREE • SHAKE NOW"
    elseif req.Discoveries then
        subtitle=string.format("LOCKED • %d CATALOG • $%s",req.Discoveries,tostring(def.UnlockCost))
    else
        subtitle="UNLOCK  $"..tostring(def.UnlockCost)
    end
    billboard(root,def.DisplayName:upper(),subtitle,def.Accent)
    return model
end

local function setLighting()
    Lighting.ClockTime=14.2
    Lighting.Brightness=2.4
    Lighting.Ambient=Color3.fromRGB(105,115,135)
    Lighting.OutdoorAmbient=Color3.fromRGB(145,155,175)
    Lighting.EnvironmentDiffuseScale=0.42
    Lighting.EnvironmentSpecularScale=0.68
    local bloom=Lighting:FindFirstChild("ShakeBloom") or Instance.new("BloomEffect");bloom.Name="ShakeBloom";bloom.Intensity=0.22;bloom.Size=24;bloom.Threshold=1.2;bloom.Parent=Lighting
    local cc=Lighting:FindFirstChild("ShakeColor") or Instance.new("ColorCorrectionEffect");cc.Name="ShakeColor";cc.Saturation=0.12;cc.Contrast=0.05;cc.Brightness=0.02;cc.Parent=Lighting
end

function WorldBuilder:Init()
    setLighting()
    local old=Workspace:FindFirstChild("ShakeHub");if old then old:Destroy() end
    local machinesOld=Workspace:FindFirstChild("Machines");if machinesOld then machinesOld:Destroy() end

    local hub=Instance.new("Folder");hub.Name="ShakeHub";hub.Parent=Workspace
    local machinesFolder=Instance.new("Folder");machinesFolder.Name="Machines";machinesFolder.Parent=Workspace

    if Config.RequireCreatorStoreAssets and not ReplicatedStorage:GetAttribute("CreatorAssetsReady") then
        local floor=studPart(hub,"SetupFloor",Vector3.new(50,1,28),CFrame.new(0,-0.5,0),Color3.fromRGB(76,185,82))
        local anchor=studPart(hub,"SetupAnchor",Vector3.new(1,1,1),CFrame.new(0,4,0),Color3.new(1,1,1));anchor.Transparency=1;anchor.CanCollide=false
        local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(760,210);gui.AlwaysOnTop=true;gui.Adornee=anchor;gui.Parent=anchor
        local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundColor3=Color3.fromRGB(26,29,37);l.TextColor3=Color3.new(1,1,1);l.TextWrapped=true;l.TextScaled=true;l.Font=Enum.Font.GothamBlack;l.Text="CREATOR STORE ASSETS NOT LOADED\nGame Settings > Security > Allow Loading Third Party Assets\nStop Play, enable it, then Play again.";l.Parent=gui
        local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,18);c.Parent=l
        return
    end

    -- Compact commercial district: donor buildings create the visible architecture; generated
    -- geometry is limited to paths/studded trim/signage/collision so the hub never becomes an
    -- AI-looking field of primitive buildings.
    studPart(hub,"Grass",Vector3.new(96,1,86),CFrame.new(0,-0.5,-7),Color3.fromRGB(66,198,88))
    studPart(hub,"CentralPlaza",Vector3.new(36,0.65,30),CFrame.new(0,0.08,-6),Color3.fromRGB(232,226,205))
    studPart(hub,"NorthWalk",Vector3.new(18,0.5,25),CFrame.new(0,0.12,14),Color3.fromRGB(207,216,224))
    studPart(hub,"SouthWalk",Vector3.new(18,0.5,25),CFrame.new(0,0.12,-27),Color3.fromRGB(207,216,224))
    studPart(hub,"WestWalk",Vector3.new(28,0.5,13),CFrame.new(-25,0.12,-7),Color3.fromRGB(207,216,224))
    studPart(hub,"EastWalk",Vector3.new(28,0.5,13),CFrame.new(25,0.12,-7),Color3.fromRGB(207,216,224))

    local districts={
        {Id="CornerStore",Machine=Vector3.new(-25,0,10),Yaw=28,FacadeKey="HubShop",Facade=Vector3.new(-38,0,19),FacadeYaw=116,FacadeSize=21,Label="CORNER STORE",Sub="DRINKS • SNACKS",Accent=Color3.fromRGB(83,164,235)},
        {Id="SugarRush",Machine=Vector3.new(0,0,17),Yaw=0,FacadeKey="CollectionShop",Facade=Vector3.new(0,0,31),FacadeYaw=180,FacadeSize=20,Label="SUGAR RUSH",Sub="CANDY • SWEETS",Accent=Color3.fromRGB(255,116,190)},
        {Id="Energy",Machine=Vector3.new(25,0,10),Yaw=-28,FacadeKey="LowPolyShop",Facade=Vector3.new(38,0,19),FacadeYaw=244,FacadeSize=18,Label="ENERGY",Sub="SPORT • POWER",Accent=Color3.fromRGB(92,220,126)},
        {Id="ToyCapsule",Machine=Vector3.new(27,0,-21),Yaw=-145,FacadeKey="LowPolyShop",Facade=Vector3.new(39,0,-30),FacadeYaw=300,FacadeSize=18,Label="TOY CAPSULE",Sub="GACHA • TOYS",Accent=Color3.fromRGB(126,192,255)},
        {Id="Luxury",Machine=Vector3.new(0,0,-29),Yaw=180,FacadeKey="CollectionShop",Facade=Vector3.new(0,0,-43),FacadeYaw=0,FacadeSize=19,Label="LUXURY",Sub="PREMIUM • RARE",Accent=Color3.fromRGB(242,201,91)},
        {Id="Unknown",Machine=Vector3.new(-27,0,-21),Yaw=145,FacadeKey="LowPolyShop",Facade=Vector3.new(-39,0,-30),FacadeYaw=60,FacadeSize=18,Label="SERVICE ACCESS",Sub="AUTHORIZED STAFF",Accent=Color3.fromRGB(151,137,166)},
    }

    for i,d in ipairs(districts) do
        local def=Machines[d.Id]
        local facade=cloneWorldAsset(d.FacadeKey,d.FacadeSize,d.Facade,d.FacadeYaw)
        if facade then facade.Name=d.Id.."Facade" end
        local pad=studPart(hub,d.Id.."Pad",Vector3.new(15,0.6,13),CFrame.new(d.Machine+Vector3.new(0,0.06,0))*CFrame.Angles(0,math.rad(d.Yaw),0),def.Color:Lerp(Color3.new(1,1,1),0.72))
        pad.CanCollide=true
        local sign=Instance.new("Part");sign.Name=d.Id.."DistrictSign";sign.Size=Vector3.one;sign.CFrame=CFrame.new(d.Machine+Vector3.new(0,4.2,0));sign.Transparency=1;sign.Anchored=true;sign.CanCollide=false;sign.Parent=hub
        local g=billboard(sign,d.Label,d.Sub,d.Accent);g.StudsOffset=Vector3.new(0,2.3,0)
        makeMachine(d.Id,def,d.Machine,d.Yaw)
    end

    -- Donor landscaping frames the loop without blocking the immediate spawn sightline.
    for i,pos in ipairs({Vector3.new(-43,0,5),Vector3.new(43,0,5),Vector3.new(-43,0,-13),Vector3.new(43,0,-13),Vector3.new(-16,0,-43),Vector3.new(16,0,-43)}) do
        local tree=cloneWorldAsset("PineTree",7.5,pos,(i*31)%360);if tree then tree.Name="CreatorTree"..i end
    end
    for i,pos in ipairs({Vector3.new(-15,0,-36),Vector3.new(15,0,-36)}) do
        local plot=cloneWorldAsset("GardenPlot",11,pos,i==1 and -12 or 12);if plot then plot.Name="CreatorGardenPlot"..i end
    end

    local sell=cloneWorldAsset("SellATM",5.2,Vector3.new(-8,0,-5),180)
    if sell then sell.Name="SellStation";sell:SetAttribute("Interaction","Sell") end
    local upgrade=cloneWorldAsset("LowPolyShop",10,Vector3.new(8,0,-5),180)
    if upgrade then upgrade.Name="UpgradeKiosk" end
    local passport=cloneWorldAsset("SellATM",4.4,Vector3.new(0,0,-15),180)
    if passport then passport.Name="PassportKiosk";passport:SetAttribute("Interaction","Passport") end
    local passportAnchor=Instance.new("Part");passportAnchor.Name="PassportAnchor";passportAnchor.Size=Vector3.one;passportAnchor.CFrame=CFrame.new(0,5.4,-15);passportAnchor.Transparency=1;passportAnchor.Anchored=true;passportAnchor.CanCollide=false;passportAnchor.Parent=hub
    billboard(passportAnchor,"VENDING PASSPORT","WORLD GOALS • HUNT LIST • STAMPS",Color3.fromRGB(255,211,76)).StudsOffset=Vector3.new(0,0,0)

    local spawn=Instance.new("SpawnLocation");spawn.Name="HubSpawn";spawn.Size=Vector3.new(7,0.8,7);spawn.CFrame=CFrame.new(0,0.55,2.5);spawn.Anchored=true;spawn.Neutral=true;spawn.Material=Enum.Material.Plastic;spawn.Color=Color3.fromRGB(94,205,255);spawn.TopSurface=Enum.SurfaceType.Studs;spawn.BottomSurface=Enum.SurfaceType.Inlet;spawn.Parent=hub

    local titleAnchor=Instance.new("Part");titleAnchor.Name="TitleAnchor";titleAnchor.Size=Vector3.one;titleAnchor.CFrame=CFrame.new(0,8,5);titleAnchor.Transparency=1;titleAnchor.Anchored=true;titleAnchor.CanCollide=false;titleAnchor.Parent=hub
    billboard(titleAnchor,"DOWNTOWN VENDING DISTRICT","SHAKE • HUNT • COLLECT • STAMP YOUR PASSPORT",Color3.fromRGB(98,214,255)).StudsOffset=Vector3.new(0,0,0)

    local galleryAnchor=Instance.new("Part");galleryAnchor.Name="GalleryAnchor";galleryAnchor.Size=Vector3.one;galleryAnchor.CFrame=CFrame.new(0,6,-38);galleryAnchor.Transparency=1;galleryAnchor.Anchored=true;galleryAnchor.CanCollide=false;galleryAnchor.Parent=hub
    billboard(galleryAnchor,"COLLECTION GALLERY","PLACE YOUR 6 RAREST DROPS • INSPECT • FLEX",Color3.fromRGB(255,207,76)).StudsOffset=Vector3.new(0,0,0)

    -- Global board uses a studded frame but is content, not a fake prop/item model.
    local board=studPart(hub,"GlobalBoard",Vector3.new(20,9,0.6),CFrame.new(0,5.2,24),Color3.fromRGB(35,40,52))
    local boardGui=Instance.new("SurfaceGui");boardGui.Name="BoardGui";boardGui.Face=Enum.NormalId.Front;boardGui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;boardGui.PixelsPerStud=36;boardGui.Parent=board
    local boardLabel=Instance.new("TextLabel");boardLabel.Name="BoardLabel";boardLabel.Size=UDim2.fromScale(1,1);boardLabel.BackgroundColor3=Color3.fromRGB(26,30,39);boardLabel.TextColor3=Color3.new(1,1,1);boardLabel.Text="TOP RAREST THIS HOUR\nLoading...";boardLabel.Font=Enum.Font.GothamBold;boardLabel.TextSize=25;boardLabel.TextWrapped=true;boardLabel.TextYAlignment=Enum.TextYAlignment.Top;boardLabel.Parent=boardGui
end

return WorldBuilder

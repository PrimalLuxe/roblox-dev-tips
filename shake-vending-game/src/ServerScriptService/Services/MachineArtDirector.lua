local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)

local MachineArtDirector={}
local STYLES={
    CornerStore={Body=Color3.fromRGB(239,236,220),Accent=Color3.fromRGB(53,132,214),Secondary=Color3.fromRGB(215,69,66),Glass=Color3.fromRGB(194,225,238),Label="COLD DRINKS",Shape="Corner"},
    SugarRush={Body=Color3.fromRGB(255,238,245),Accent=Color3.fromRGB(242,91,163),Secondary=Color3.fromRGB(255,207,73),Glass=Color3.fromRGB(255,224,240),Label="SWEET DROP",Shape="Candy"},
    Energy={Body=Color3.fromRGB(48,53,61),Accent=Color3.fromRGB(76,220,116),Secondary=Color3.fromRGB(67,191,235),Glass=Color3.fromRGB(164,211,221),Label="POWER UP",Shape="Sport"},
    ToyCapsule={Body=Color3.fromRGB(233,229,250),Accent=Color3.fromRGB(111,82,198),Secondary=Color3.fromRGB(82,190,237),Glass=Color3.fromRGB(199,232,255),Label="CAPSULE PRIZES",Shape="Toy"},
    Luxury={Body=Color3.fromRGB(243,237,220),Accent=Color3.fromRGB(205,157,46),Secondary=Color3.fromRGB(31,42,60),Glass=Color3.fromRGB(220,237,240),Label="PREMIUM RESERVE",Shape="Luxury"},
    Unknown={Body=Color3.fromRGB(116,113,106),Accent=Color3.fromRGB(218,151,64),Secondary=Color3.fromRGB(58,54,61),Glass=Color3.fromRGB(159,165,160),Label="SERVICE UNIT",Shape="Service"},
}

local function part(parent,name,size,cf,color,material,transparency)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Plastic;p.Transparency=transparency or 0
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function cylinder(parent,name,size,cf,color,material)local p=part(parent,name,size,cf,color,material);p.Shape=Enum.PartType.Cylinder;return p end
local function labelOn(p,value,textColor,bg)
    local gui=Instance.new("SurfaceGui");gui.Name="ArtLabel";gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=54;gui.Parent=p
    local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=bg;frame.BorderSizePixel=0;frame.Parent=gui
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.new(1,-12,1,-8);t.Position=UDim2.fromOffset(6,4);t.Text=value;t.TextColor3=textColor;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=frame
end
local function machineItems(id)
    local list={};for _,d in pairs(Items)do if type(d)=="table"and d.Id and d.Machine==id then table.insert(list,d)end end
    table.sort(list,function(a,b)return(a.BaseOneIn or 1)<(b.BaseOneIn or 1)end);return list
end
local function prepareProduct(m,target)
    for _,d in ipairs(m:GetDescendants())do if d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end end
    local ok,s=pcall(function()return m:GetExtentsSize()end);if ok and s then local longest=math.max(s.X,s.Y,s.Z);if longest>0 then pcall(function()m:ScaleTo(m:GetScale()*(target/longest))end)end end
end

local function addProductBay(facade,front,size,machineId,style)
    local w=math.clamp(size.X*.58,2.7,4.1);local h=math.clamp(size.Y*.49,3.2,4.7);local bay=front*CFrame.new(-size.X*.105,math.clamp(size.Y*.10,.55,1),-.02)
    part(facade,"BayBacking",Vector3.new(w,h,.18),bay*CFrame.new(0,0,.22),Color3.fromRGB(25,31,40),Enum.Material.SmoothPlastic)
    local glass=part(facade,"DisplayGlass",Vector3.new(w,h,.09),bay*CFrame.new(0,0,-.03),style.Glass,Enum.Material.Glass,.54);glass.Reflectance=.06
    for _,x in ipairs({-w/2-.065,w/2+.065})do part(facade,"BaySide",Vector3.new(.13,h+.28,.18),bay*CFrame.new(x,0,-.07),style.Accent)end
    for _,y in ipairs({-h/2-.065,h/2+.065})do part(facade,"BayRail",Vector3.new(w+.4,.13,.18),bay*CFrame.new(0,y,-.07),style.Accent)end
    for row=1,3 do part(facade,"Shelf"..row,Vector3.new(w-.18,.08,.40),bay*CFrame.new(0,-h/2+row*(h/4),.06),Color3.fromRGB(210,215,218),Enum.Material.Metal)end
    local slots={{-.28,.27},{.02,.27},{.30,.27},{-.28,.01},{.02,.01},{.30,.01},{-.28,-.25},{.02,-.25},{.30,-.25}}
    local defs=machineItems(machineId);for i=1,math.min(#defs,#slots)do local d=defs[i];local m=Factory.Create(d.Id,"None");if m then m.Name="Product_"..d.Id;prepareProduct(m,math.clamp(w*.18,.48,.72));m.Parent=facade;local s=slots[i];m:PivotTo(bay*CFrame.new(s[1]*w,s[2]*h,-.16)*CFrame.Angles(0,math.rad((i%3-1)*8),0))end end
    local lightPart=part(facade,"InteriorLight",Vector3.new(w-.4,.08,.08),bay*CFrame.new(0,h/2-.18,.12),Color3.fromRGB(255,244,212),Enum.Material.Neon)
    local light=Instance.new("SurfaceLight");light.Face=Enum.NormalId.Front;light.Angle=120;light.Brightness=.5;light.Range=4;light.Color=Color3.fromRGB(255,244,220);light.Shadows=false;light.Parent=lightPart
end

local function addControls(facade,front,size,style)
    local x=size.X*.315;local w=math.clamp(size.X*.22,1,1.45);local h=math.clamp(size.Y*.50,3.4,4.8);local cf=front*CFrame.new(x,math.clamp(size.Y*.08,.45,.9),-.07)
    part(facade,"ControlColumn",Vector3.new(w,h,.24),cf,style.Body)
    part(facade,"ScreenHousing",Vector3.new(w-.22,.72,.12),cf*CFrame.new(0,h*.31,-.17),Color3.fromRGB(28,38,50))
    local screen=part(facade,"MachineScreen",Vector3.new(w-.34,.50,.07),cf*CFrame.new(0,h*.31,-.24),Color3.fromRGB(92,201,228),Enum.Material.Neon);labelOn(screen,"READY\nSHAKE",Color3.fromRGB(20,31,42),Color3.fromRGB(116,224,239))
    for row=0,3 do for col=0,2 do local n=row*3+col+1;local key=part(facade,"Key"..n,Vector3.new(w*.17,.19,.08),cf*CFrame.new((col-1)*(w*.24),h*.07-row*.29,-.18),Color3.fromRGB(232,234,229));labelOn(key,tostring(n<=9 and n or(n==10 and"*"or n==11 and"0"or"#")),Color3.fromRGB(38,43,50),Color3.fromRGB(236,238,234))end end
    part(facade,"CardReader",Vector3.new(w-.34,.46,.13),cf*CFrame.new(0,-h*.31,-.18),Color3.fromRGB(38,45,54))
    part(facade,"CardSlot",Vector3.new(w*.50,.055,.03),cf*CFrame.new(0,-h*.31,-.255),style.Accent,Enum.Material.Neon)
    part(facade,"CoinSlot",Vector3.new(.10,.34,.04),cf*CFrame.new(w*.25,-h*.42,-.25),Color3.fromRGB(122,127,132),Enum.Material.Metal)
end

local function addHardware(facade,front,size,style)
    local y=-size.Y*.33;local w=math.clamp(size.X*.48,2.3,3.4)
    part(facade,"TrayBezel",Vector3.new(w,.78,.34),front*CFrame.new(-size.X*.08,y,-.10),style.Secondary)
    part(facade,"DispenseTray",Vector3.new(w-.28,.48,.22),front*CFrame.new(-size.X*.08,y,-.30),Color3.fromRGB(20,25,31))
    local access=part(facade,"AccessPanel",Vector3.new(size.X*.28,.76,.12),front*CFrame.new(size.X*.28,y,-.11),style.Body)
    for i=-2,2 do part(facade,"Vent"..i,Vector3.new(.06,.42,.04),access.CFrame*CFrame.new(i*.12,0,-.09),Color3.fromRGB(70,75,78),Enum.Material.Metal)end
    part(facade,"FootL",Vector3.new(.42,.22,.52),front*CFrame.new(-size.X*.32,-size.Y*.49,.12),Color3.fromRGB(45,48,52),Enum.Material.Metal)
    part(facade,"FootR",Vector3.new(.42,.22,.52),front*CFrame.new(size.X*.32,-size.Y*.49,.12),Color3.fromRGB(45,48,52),Enum.Material.Metal)
end

local function addMarquee(facade,front,size,style)
    local w=math.clamp(size.X*.94,4.4,6.2);local h=math.clamp(size.Y*.12,.72,1.05);local y=size.Y*.46-h*.35
    local cap=part(facade,"Marquee",Vector3.new(w,h,.28),front*CFrame.new(0,y,-.10),style.Accent);labelOn(cap,style.Label,Color3.fromRGB(255,251,236),style.Accent)
    if style.Shape=="Corner"then for i=-2,2 do part(facade,"AwningStripe"..i,Vector3.new(w/5-.04,.16,.38),front*CFrame.new(i*(w/5),y-h*.62,-.15),i%2==0 and style.Secondary or Color3.fromRGB(246,240,220))end
    elseif style.Shape=="Candy"then for i=-2,2 do cylinder(facade,"CandyBulb"..i,Vector3.new(.24,.24,.24),front*CFrame.new(i*.55,y+h*.58,-.18)*CFrame.Angles(0,0,math.rad(90)),i%2==0 and style.Secondary or style.Accent)end
    elseif style.Shape=="Sport"then part(facade,"EnergyFinL",Vector3.new(.18,h*1.55,.44),front*CFrame.new(-w*.48,y,-.02)*CFrame.Angles(0,0,math.rad(-10)),style.Secondary);part(facade,"EnergyFinR",Vector3.new(.18,h*1.55,.44),front*CFrame.new(w*.48,y,-.02)*CFrame.Angles(0,0,math.rad(10)),style.Secondary)
    elseif style.Shape=="Toy"then for i=-1,1 do local b=part(facade,"Capsule"..i,Vector3.new(.42,.42,.42),front*CFrame.new(i*.62,y+h*.62,-.22),i==0 and style.Secondary or style.Accent,Enum.Material.Glass,.18);b.Shape=Enum.PartType.Ball end
    elseif style.Shape=="Luxury"then part(facade,"GoldInlayL",Vector3.new(.08,h*1.25,.36),front*CFrame.new(-w*.42,y,-.04),style.Accent,Enum.Material.Metal);part(facade,"GoldInlayR",Vector3.new(.08,h*1.25,.36),front*CFrame.new(w*.42,y,-.04),style.Accent,Enum.Material.Metal)
    elseif style.Shape=="Service"then for i=-2,2 do part(facade,"Caution"..i,Vector3.new(w/5-.03,.12,.34),front*CFrame.new(i*(w/5),y-h*.62,-.15)*CFrame.Angles(0,0,math.rad(i%2==0 and 16 or -16)),i%2==0 and style.Accent or style.Secondary)end end
end

function MachineArtDirector.Apply(machine,shell,machineId)
    local style=STYLES[machineId]or STYLES.CornerStore;local cf,size=shell:GetBoundingBox();local facade=Instance.new("Model")
    facade.Name="OlympusKitbash";facade:SetAttribute("ArtDirected",true);facade:SetAttribute("ProductFamily",machineId);facade.Parent=shell
    local front=cf*CFrame.new(0,0,-size.Z/2-.12);addMarquee(facade,front,size,style);addProductBay(facade,front,size,machineId,style);addControls(facade,front,size,style);addHardware(facade,front,size,style)
    part(facade,"SideTrimL",Vector3.new(.16,size.Y*.74,.24),cf*CFrame.new(-size.X/2-.05,0,-size.Z/2+.12),style.Secondary)
    part(facade,"SideTrimR",Vector3.new(.16,size.Y*.74,.24),cf*CFrame.new(size.X/2+.05,0,-size.Z/2+.12),style.Secondary)
    local event=part(facade,"EventLight",Vector3.new(.18,.18,.18),front*CFrame.new(size.X*.37,size.Y*.40,-.22),style.Accent,Enum.Material.Neon);event.Shape=Enum.PartType.Ball
    machine:SetAttribute("ArtDirectionVersion",2);return facade
end
return MachineArtDirector

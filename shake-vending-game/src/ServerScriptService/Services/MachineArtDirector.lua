local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)

local MachineArtDirector={}

local STYLES={
    CornerStore={Body=Color3.fromRGB(229,222,199),Dark=Color3.fromRGB(37,57,72),Accent=Color3.fromRGB(49,134,211),Accent2=Color3.fromRGB(205,63,59),Glass=Color3.fromRGB(152,206,226),Label="COLD DRINKS",Kind="Corner"},
    SugarRush={Body=Color3.fromRGB(248,219,231),Dark=Color3.fromRGB(91,45,78),Accent=Color3.fromRGB(239,82,157),Accent2=Color3.fromRGB(245,194,57),Glass=Color3.fromRGB(224,211,235),Label="SWEET DROP",Kind="Candy"},
    Energy={Body=Color3.fromRGB(47,54,61),Dark=Color3.fromRGB(25,30,35),Accent=Color3.fromRGB(69,205,111),Accent2=Color3.fromRGB(55,164,222),Glass=Color3.fromRGB(100,157,170),Label="POWER UP",Kind="Energy"},
    ToyCapsule={Body=Color3.fromRGB(205,198,232),Dark=Color3.fromRGB(54,44,79),Accent=Color3.fromRGB(105,76,190),Accent2=Color3.fromRGB(68,177,226),Glass=Color3.fromRGB(181,218,236),Label="CAPSULE PRIZES",Kind="Toy"},
    Luxury={Body=Color3.fromRGB(230,219,193),Dark=Color3.fromRGB(31,38,49),Accent=Color3.fromRGB(197,148,43),Accent2=Color3.fromRGB(48,58,73),Glass=Color3.fromRGB(184,210,213),Label="PREMIUM RESERVE",Kind="Luxury"},
    Unknown={Body=Color3.fromRGB(93,96,95),Dark=Color3.fromRGB(34,35,38),Accent=Color3.fromRGB(202,135,54),Accent2=Color3.fromRGB(57,58,63),Glass=Color3.fromRGB(111,130,129),Label="SERVICE UNIT",Kind="Service"},
}

local function part(parent,name,size,cf,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
    p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end
local function cylinder(parent,name,size,cf,color,material,transparency)
    local p=part(parent,name,size,cf,color,material,transparency,false);p.Shape=Enum.PartType.Cylinder;return p
end
local function ball(parent,name,diameter,cf,color,material,transparency)
    local p=part(parent,name,Vector3.new(diameter,diameter,diameter),cf,color,material,transparency,false);p.Shape=Enum.PartType.Ball;return p
end
local function textFace(p,value,fg,bg,pixels)
    local gui=Instance.new("SurfaceGui");gui.Name="ArtLabel";gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=pixels or 72;gui.LightInfluence=.12;gui.Parent=p
    local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundColor3=bg;f.BorderSizePixel=0;f.Parent=gui
    local border=Instance.new("UIStroke");border.Color=fg;border.Thickness=2;border.Transparency=.35;border.Parent=f
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(8,5);t.Size=UDim2.new(1,-16,1,-10);t.Text=value;t.TextColor3=fg;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=f
    return t
end
local function localPart(parent,name,size,base,x,y,z,color,material,transparency,collide,rot)
    local cf=base*CFrame.new(x,y,z)
    if rot then cf=cf*CFrame.Angles(math.rad(rot.X or 0),math.rad(rot.Y or 0),math.rad(rot.Z or 0))end
    return part(parent,name,size,cf,color,material,transparency,collide)
end

local function itemList(machineId)
    local out={}
    for _,d in pairs(Items)do if type(d)=="table"and d.Id and d.Machine==machineId then table.insert(out,d)end end
    table.sort(out,function(a,b)return(a.BaseOneIn or 1)<(b.BaseOneIn or 1)end)
    return out
end

local function miniProduct(parent,item,cf,scale)
    scale=scale or 1
    local m=Instance.new("Model");m.Name="Product_"..item.Id;m:SetAttribute("BaseItemId",item.Id);m.Parent=parent
    local c=item.Color or Color3.fromRGB(220,220,220);local dark=c:Lerp(Color3.new(0,0,0),.34);local light=c:Lerp(Color3.new(1,1,1),.34)
    local f=item.VisualFamily or "Box"
    local function mp(name,size,off,color,material,shape)
        local p=part(m,name,size*scale,cf*off,color or c,material or Enum.Material.SmoothPlastic,0,false);if shape then p.Shape=shape end;return p
    end
    if f=="Can" then
        mp("Can",Vector3.new(.58,1.10,.58),CFrame.new(),c,Enum.Material.Metal,Enum.PartType.Cylinder)
        mp("Top",Vector3.new(.61,.055,.61),CFrame.new(0,.54,0),light,Enum.Material.Metal,Enum.PartType.Cylinder)
        mp("Band",Vector3.new(.60,.18,.60),CFrame.new(0,.10,0),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    elseif f=="Bottle" then
        mp("Bottle",Vector3.new(.56,.92,.56),CFrame.new(0,-.08,0),c,Enum.Material.Glass,Enum.PartType.Cylinder)
        mp("Neck",Vector3.new(.28,.30,.28),CFrame.new(0,.50,0),light,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
        mp("Cap",Vector3.new(.33,.12,.33),CFrame.new(0,.70,0),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    elseif f=="Bag" then
        mp("Bag",Vector3.new(.82,1.02,.28),CFrame.new(),c)
        mp("SealTop",Vector3.new(.86,.10,.32),CFrame.new(0,.50,0),light)
        mp("SealBottom",Vector3.new(.86,.10,.32),CFrame.new(0,-.50,0),dark)
    elseif f=="Bar" then
        mp("Bar",Vector3.new(.70,.98,.26),CFrame.new(),c)
        for i=-1,1 do mp("Wrap"..i,Vector3.new(.73,.055,.29),CFrame.new(0,i*.26,-.02),i==0 and light or dark)end
    elseif f=="Ball" then
        mp("Ball",Vector3.new(.76,.76,.76),CFrame.new(),c,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        mp("Dot",Vector3.new(.18,.18,.18),CFrame.new(.20,.18,-.34),light,Enum.Material.Neon,Enum.PartType.Ball)
    elseif f=="Capsule" then
        mp("CapsuleBottom",Vector3.new(.72,.42,.72),CFrame.new(0,-.18,0),c,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        mp("CapsuleTop",Vector3.new(.72,.42,.72),CFrame.new(0,.18,0),light,Enum.Material.Glass,Enum.PartType.Ball)
        mp("Band",Vector3.new(.76,.10,.76),CFrame.new(),dark,Enum.Material.Metal,Enum.PartType.Cylinder)
    elseif f=="Robot" then
        mp("Body",Vector3.new(.62,.58,.38),CFrame.new(0,-.10,0),c)
        mp("Head",Vector3.new(.52,.42,.42),CFrame.new(0,.39,0),light)
        mp("EyeL",Vector3.new(.08,.08,.05),CFrame.new(-.14,.40,-.23),Color3.fromRGB(90,220,255),Enum.Material.Neon)
        mp("EyeR",Vector3.new(.08,.08,.05),CFrame.new(.14,.40,-.23),Color3.fromRGB(90,220,255),Enum.Material.Neon)
        mp("ArmL",Vector3.new(.16,.50,.16),CFrame.new(-.40,-.08,0),dark)
        mp("ArmR",Vector3.new(.16,.50,.16),CFrame.new(.40,-.08,0),dark)
    elseif f=="Duck" then
        mp("Body",Vector3.new(.72,.56,.58),CFrame.new(0,-.05,0),c,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        mp("Head",Vector3.new(.48,.48,.48),CFrame.new(.14,.36,-.03),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        mp("Beak",Vector3.new(.28,.12,.18),CFrame.new(.15,.30,-.32),Color3.fromRGB(245,145,44))
    elseif f=="Plush" then
        mp("Body",Vector3.new(.62,.62,.48),CFrame.new(0,-.08,0),c,Enum.Material.Fabric,Enum.PartType.Ball)
        mp("Head",Vector3.new(.54,.54,.50),CFrame.new(0,.40,0),light,Enum.Material.Fabric,Enum.PartType.Ball)
        mp("EarL",Vector3.new(.18,.48,.18),CFrame.new(-.16,.78,0),light,Enum.Material.Fabric)
        mp("EarR",Vector3.new(.18,.48,.18),CFrame.new(.16,.78,0),light,Enum.Material.Fabric)
    elseif f=="Lollipop" then
        mp("Stick",Vector3.new(.10,.82,.10),CFrame.new(0,-.24,0),Color3.fromRGB(235,228,210))
        mp("Candy",Vector3.new(.56,.56,.18),CFrame.new(0,.35,0),c,Enum.Material.Glass,Enum.PartType.Cylinder)
    else
        mp("Box",Vector3.new(.72,.82,.46),CFrame.new(),c)
        mp("Label",Vector3.new(.52,.30,.04),CFrame.new(0,.02,-.25),light)
    end
    return m
end

local function buildBody(shell,art,base,style)
    localPart(shell,"BackCase",Vector3.new(6.6,10.5,3.8),base,0,0,.18,style.Dark,Enum.Material.Metal,0,true)
    localPart(shell,"MainCase",Vector3.new(6.15,10.05,3.55),base,0,.08,-.02,style.Body,Enum.Material.SmoothPlastic,0,false)
    localPart(shell,"LeftRail",Vector3.new(.34,9.7,3.72),base,-3.08,.08,.02,style.Accent2,Enum.Material.Metal,0,false)
    localPart(shell,"RightRail",Vector3.new(.34,9.7,3.72),base,3.08,.08,.02,style.Accent,Enum.Material.Metal,0,false)
    localPart(shell,"TopCap",Vector3.new(6.45,.42,3.82),base,0,5.12,.03,style.Dark,Enum.Material.Metal,0,false)
    localPart(shell,"BottomPlinth",Vector3.new(6.55,.52,3.95),base,0,-5.05,.08,style.Dark,Enum.Material.Metal,0,true)
    for _,x in ipairs({-2.45,2.45})do localPart(shell,"Foot"..x,Vector3.new(.70,.30,1.25),base,x,-5.43,.70,Color3.fromRGB(35,38,42),Enum.Material.Metal,0,true)end
    local marquee=localPart(art,"Marquee",Vector3.new(5.72,1.20,.34),base,0,4.30,-1.93,style.Accent,Enum.Material.SmoothPlastic,0,false)
    textFace(marquee,style.Label,Color3.fromRGB(255,250,233),style.Accent,86)
    localPart(art,"MarqueeLip",Vector3.new(6.0,.16,.58),base,0,3.66,-1.84,style.Dark,Enum.Material.Metal,0,false)
    localPart(art,"BayVoid",Vector3.new(4.05,5.80,.28),base,-.55,.42,-1.88,Color3.fromRGB(20,25,31),Enum.Material.SmoothPlastic,0,false)
    local glass=localPart(art,"DisplayGlass",Vector3.new(4.16,5.88,.10),base,-.55,.42,-2.08,style.Glass,Enum.Material.Glass,.46,false);glass.Reflectance=.06
    for _,x in ipairs({-2.67,1.57})do localPart(art,"GlassSide"..x,Vector3.new(.18,6.12,.28),base,x,.42,-2.02,style.Dark,Enum.Material.Metal,0,false)end
    for _,y in ipairs({-2.62,3.45})do localPart(art,"GlassRail"..y,Vector3.new(4.43,.18,.28),base,-.55,y,-2.02,style.Dark,Enum.Material.Metal,0,false)end
    for row=1,3 do
        local y=-1.98+(row-1)*1.76
        localPart(art,"Shelf"..row,Vector3.new(3.82,.10,.72),base,-.55,y,-1.68,Color3.fromRGB(184,189,191),Enum.Material.Metal,0,false)
        localPart(art,"PriceRail"..row,Vector3.new(3.78,.16,.12),base,-.55,y-.48,-2.04,style.Accent,Enum.Material.SmoothPlastic,0,false)
        for col=1,4 do
            local x=-2.0+(col-1)*.96
            localPart(art,"Coil"..row.."_"..col,Vector3.new(.50,.055,.055),base,x,y-.06,-2.09,Color3.fromRGB(218,222,220),Enum.Material.Metal,0,false,{Z=0})
        end
    end
    localPart(art,"ControlTower",Vector3.new(1.48,6.04,.36),base,2.18,.28,-1.91,style.Dark,Enum.Material.Metal,0,false)
    local screen=localPart(art,"MachineScreen",Vector3.new(1.13,.92,.08),base,2.18,2.56,-2.14,Color3.fromRGB(94,211,228),Enum.Material.Neon,0,false)
    textFace(screen,"READY\nSHAKE",Color3.fromRGB(16,38,49),Color3.fromRGB(110,226,238),95)
    localPart(art,"ScreenBezel",Vector3.new(1.32,1.10,.12),base,2.18,2.56,-2.05,style.Accent,Enum.Material.Metal,0,false)
    screen.CFrame=base*CFrame.new(2.18,2.56,-2.15)
    for row=0,3 do for col=0,2 do
        local idx=row*3+col+1
        local key=localPart(art,"Key"..idx,Vector3.new(.27,.22,.08),base,1.86+col*.31,1.55-row*.33,-2.15,Color3.fromRGB(224,226,220),Enum.Material.SmoothPlastic,0,false)
        textFace(key,idx<=9 and tostring(idx)or(idx==10 and"*"or idx==11 and"0"or"#"),style.Dark,Color3.fromRGB(224,226,220),90)
    end end
    localPart(art,"CardReader",Vector3.new(1.10,.52,.12),base,2.18,-.44,-2.13,Color3.fromRGB(42,47,52),Enum.Material.Metal,0,false)
    localPart(art,"CardLED",Vector3.new(.72,.055,.035),base,2.18,-.44,-2.21,style.Accent,Enum.Material.Neon,0,false)
    localPart(art,"CoinPlate",Vector3.new(.72,.72,.10),base,2.18,-1.23,-2.12,Color3.fromRGB(87,92,95),Enum.Material.Metal,0,false)
    localPart(art,"CoinSlot",Vector3.new(.10,.38,.035),base,2.18,-1.23,-2.20,Color3.fromRGB(25,27,29),Enum.Material.Metal,0,false)
    localPart(art,"TrayBezel",Vector3.new(3.88,.94,.40),base,-.58,-3.47,-1.93,style.Accent2,Enum.Material.Metal,0,false)
    local tray=localPart(art,"DispenseTray",Vector3.new(3.45,.54,.24),base,-.58,-3.45,-2.18,Color3.fromRGB(18,22,27),Enum.Material.SmoothPlastic,0,false)
    localPart(art,"TrayFlap",Vector3.new(3.30,.12,.20),base,-.58,-3.16,-2.21,Color3.fromRGB(56,61,65),Enum.Material.Rubber,0,false)
    local access=localPart(art,"AccessPanel",Vector3.new(1.50,1.55,.14),base,2.15,-3.18,-2.04,style.Body,Enum.Material.Metal,0,false)
    for i=-3,3 do part(art,"Vent"..i,Vector3.new(.07,.82,.035),access.CFrame*CFrame.new(i*.17,0,-.09),Color3.fromRGB(69,72,74),Enum.Material.Metal,0,false)end
    for _,v in ipairs({{-2.86,4.72},{2.86,4.72},{-2.86,-4.65},{2.86,-4.65},{1.58,3.18},{2.78,3.18},{1.58,-2.25},{2.78,-2.25}})do
        cylinder(art,"Screw",Vector3.new(.12,.05,.12),base*CFrame.new(v[1],v[2],-2.03)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(110,112,114),Enum.Material.Metal,0)
    end
    local interior=localPart(art,"InteriorLight",Vector3.new(3.60,.08,.08),base,-.55,3.10,-1.90,Color3.fromRGB(255,239,188),Enum.Material.Neon,0,false)
    local sl=Instance.new("SurfaceLight");sl.Face=Enum.NormalId.Front;sl.Brightness=.85;sl.Range=6;sl.Angle=115;sl.Color=Color3.fromRGB(255,238,190);sl.Shadows=false;sl.Parent=interior
    local event=ball(art,"EventLight",.20,base*CFrame.new(2.80,3.15,-2.15),style.Accent,Enum.Material.Neon,0)
    return tray,screen,event
end

local function specialDetails(art,base,style)
    if style.Kind=="Corner" then
        for i=-2,2 do localPart(art,"AwningStripe"..i,Vector3.new(1.05,.16,.72),base,i*1.08,3.55,-2.15,i%2==0 and style.Accent2 or Color3.fromRGB(246,237,213),Enum.Material.SmoothPlastic,0,false,{X=12})end
        localPart(art,"BottleBadge",Vector3.new(.42,1.18,.25),base,-2.62,-3.14,-2.16,style.Accent,Enum.Material.SmoothPlastic,0,false)
    elseif style.Kind=="Candy" then
        for i=-3,3 do ball(art,"CandyBulb"..i,.26,base*CFrame.new(i*.72,4.94,-2.13),i%2==0 and style.Accent2 or style.Accent,Enum.Material.Neon,0)end
        for _,x in ipairs({-2.80,2.80})do localPart(art,"CandyPole"..x,Vector3.new(.25,3.0,.25),base,x,-.70,-2.05,x<0 and style.Accent or style.Accent2,Enum.Material.SmoothPlastic,0,false,{Z=x<0 and-6 or 6})end
    elseif style.Kind=="Energy" then
        for _,x in ipairs({-3.24,3.24})do localPart(art,"PowerFin"..x,Vector3.new(.24,3.8,.82),base,x,1.0,-.25,x<0 and style.Accent or style.Accent2,Enum.Material.Metal,0,false,{Z=x<0 and-8 or 8})end
        for i=-2,2 do localPart(art,"PowerTick"..i,Vector3.new(.07,1.4,.08),base,i*.42,-4.15,-2.12,i%2==0 and style.Accent or style.Accent2,Enum.Material.Neon,0,false,{Z=18})end
    elseif style.Kind=="Toy" then
        local globe=ball(art,"CapsuleGlobe",1.25,base*CFrame.new(2.15,3.95,-2.08),style.Glass,Enum.Material.Glass,.30)
        for i=1,7 do ball(art,"MiniCapsule"..i,.20,globe.CFrame*CFrame.new(math.sin(i*2.2)*.37,-.20+(i%3)*.20,-.10),i%2==0 and style.Accent or style.Accent2,Enum.Material.SmoothPlastic,0)end
        for i=-2,2 do localPart(art,"TicketNotch"..i,Vector3.new(.18,.26,.18),base,i*1.1,4.82,-2.12,style.Accent2,Enum.Material.SmoothPlastic,0,false)end
    elseif style.Kind=="Luxury" then
        for _,x in ipairs({-2.88,2.88})do localPart(art,"GoldInlay"..x,Vector3.new(.10,8.9,.12),base,x,.02,-2.05,style.Accent,Enum.Material.Metal,0,false)end
        localPart(art,"ReserveBase",Vector3.new(5.2,.18,.46),base,0,-4.58,-1.95,style.Accent,Enum.Material.Metal,0,false)
        for i=-3,3 do localPart(art,"DiamondTick"..i,Vector3.new(.18,.18,.18),base,i*.70,4.90,-2.14,style.Accent,Enum.Material.Neon,0,false,{Z=45})end
    elseif style.Kind=="Service" then
        for i=-3,3 do localPart(art,"Hazard"..i,Vector3.new(.88,.18,.12),base,i*.86,3.52,-2.14,i%2==0 and style.Accent or style.Dark,Enum.Material.SmoothPlastic,0,false,{Z=i%2==0 and 15 or-15})end
        for _,x in ipairs({-2.75,2.75})do localPart(art,"CageBar"..x,Vector3.new(.12,5.8,.18),base,x,.10,-2.15,style.Dark,Enum.Material.Metal,0,false)end
    end
end

local function stockProducts(art,base,machineId)
    local defs=itemList(machineId)
    local slots={{-1.90,2.45},{-.92,2.45},{.06,2.45},{1.04,2.45},{-1.90,.69},{-.92,.69},{.06,.69},{1.04,.69},{-1.90,-1.07},{-.92,-1.07},{.06,-1.07},{1.04,-1.07}}
    for i=1,math.min(#defs,#slots)do local s=slots[i];miniProduct(art,defs[i],base*CFrame.new(s[1],s[2],-2.10),.72)end
end

function MachineArtDirector.Build(machine,machineId,def,pos,yaw)
    local style=STYLES[machineId]or STYLES.CornerStore
    local shell=Instance.new("Model");shell.Name="Shell";shell.Parent=machine
    local art=Instance.new("Model");art.Name="OlympusKitbash";art:SetAttribute("HandAuthored",true);art:SetAttribute("MachineFamily",machineId);art.Parent=shell
    local base=CFrame.new(pos+Vector3.new(0,5.45,0))*CFrame.Angles(0,math.rad(yaw or 0),0)
    local tray,screen,event=buildBody(shell,art,base,style)
    specialDetails(art,base,style);stockProducts(art,base,machineId)
    machine:SetAttribute("ArtDirectionVersion",3);machine:SetAttribute("HandBuiltMachine",true)
    return shell,{Base=base,Tray=tray,Screen=screen,EventLight=event,Size=Vector3.new(6.6,10.9,4.0)}
end

function MachineArtDirector.Apply(machine,shell,machineId)
    local existing=shell and shell:FindFirstChild("OlympusKitbash")
    if existing then return existing end
    warn("[ShakeVM] MachineArtDirector.Apply called without authored shell; machine should be constructed with Build")
    return nil
end

return MachineArtDirector

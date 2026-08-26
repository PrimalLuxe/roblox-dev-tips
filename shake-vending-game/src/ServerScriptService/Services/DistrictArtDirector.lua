local DistrictArtDirector={}
local function part(parent,name,size,cf,color,material,trans)local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Plastic;p.Transparency=trans or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p end
local function label(p,value,bg,fg)local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=42;g.Parent=p;local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundColor3=bg;f.BorderSizePixel=0;f.Parent=g;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.new(1,-12,1,-8);t.Position=UDim2.fromOffset(6,4);t.Text=value;t.TextColor3=fg;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=f end
local function localCF(pos,yaw,x,y,z)return CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)*CFrame.new(x,y,z)end
local function cornerStore(parent)
 local pos=Vector3.new(-25,0,10);local yaw=28;local m=Instance.new("Model");m.Name="CornerStoreIdentity";m.Parent=parent
 for i=-2,2 do part(m,"Awning"..i,Vector3.new(1.38,.16,2.1),localCF(pos,yaw,i*1.4,4.7,-1),i%2==0 and Color3.fromRGB(215,69,66)or Color3.fromRGB(247,239,213))end
 local sign=part(m,"ColdDrinksSign",Vector3.new(6.7,1,.18),localCF(pos,yaw,0,5.45,-.95),Color3.fromRGB(53,132,214));label(sign,"CORNER STORE",Color3.fromRGB(53,132,214),Color3.fromRGB(255,250,232))
 part(m,"CrateA",Vector3.new(1.1,.7,.9),localCF(pos,yaw,-4,.4,-.1),Color3.fromRGB(175,123,73),Enum.Material.WoodPlanks);part(m,"CrateB",Vector3.new(.9,.55,.8),localCF(pos,yaw,-3.8,1,-.1),Color3.fromRGB(191,139,83),Enum.Material.WoodPlanks)
end
local function sugar(parent)
 local m=Instance.new("Model");m.Name="SugarRushIdentity";m.Parent=parent;local pink=Color3.fromRGB(242,91,163);local gold=Color3.fromRGB(255,207,73)
 part(m,"CandyPoleL",Vector3.new(.38,4.1,.38),CFrame.new(-4.5,2.05,13.5),pink);part(m,"CandyPoleR",Vector3.new(.38,4.1,.38),CFrame.new(4.5,2.05,13.5),gold)
 local arch=part(m,"CandyHeader",Vector3.new(9.3,.55,.55),CFrame.new(0,4.15,13.5),pink);label(arch,"SUGAR RUSH",pink,Color3.fromRGB(255,248,235))
 for i,x in ipairs({-3.2,-1.6,0,1.6,3.2})do local b=part(m,"CandyOrb"..i,Vector3.new(.55,.55,.55),CFrame.new(x,4.65,13.5),i%2==0 and gold or pink,Enum.Material.Glass,.1);b.Shape=Enum.PartType.Ball end
end
local function energy(parent)
 local pos=Vector3.new(25,0,10);local yaw=-28;local m=Instance.new("Model");m.Name="EnergyIdentity";m.Parent=parent;local green=Color3.fromRGB(76,220,116);local blue=Color3.fromRGB(67,191,235)
 for i=-1,1 do part(m,"Lane"..i,Vector3.new(.16,.035,7),localCF(pos,yaw,i*.55,.33,1.4),i==0 and green or blue,Enum.Material.Neon)end
 part(m,"RailL",Vector3.new(.18,2.4,.32),localCF(pos,yaw,-4.4,1.2,-.4)*CFrame.Angles(0,0,math.rad(-12)),green);part(m,"RailR",Vector3.new(.18,2.4,.32),localCF(pos,yaw,4.4,1.2,-.4)*CFrame.Angles(0,0,math.rad(12)),blue)
 local sign=part(m,"PowerSign",Vector3.new(6.5,.9,.18),localCF(pos,yaw,0,4.9,-.9),Color3.fromRGB(48,53,61));label(sign,"ENERGY LAB",Color3.fromRGB(48,53,61),green)
end
local function toy(parent)
 local pos=Vector3.new(27,0,-21);local yaw=-145;local m=Instance.new("Model");m.Name="ToyCapsuleIdentity";m.Parent=parent;local purple=Color3.fromRGB(111,82,198);local cyan=Color3.fromRGB(82,190,237)
 local sign=part(m,"TicketHeader",Vector3.new(7.1,1,.22),localCF(pos,yaw,0,5,-.8),purple);label(sign,"CAPSULE ARCADE",purple,Color3.fromRGB(255,250,238))
 for i,x in ipairs({-4.1,4.1})do local post=part(m,"CapsulePost"..i,Vector3.new(.65,.65,.65),localCF(pos,yaw,x,.55,-.2),i==1 and purple or cyan,Enum.Material.Glass,.12);post.Shape=Enum.PartType.Ball;part(m,"PostBase"..i,Vector3.new(.35,.7,.35),localCF(pos,yaw,x,.2,-.2),Color3.fromRGB(64,70,82),Enum.Material.Metal)end
end
local function luxury(parent)
 local pos=Vector3.new(0,0,-29);local yaw=180;local m=Instance.new("Model");m.Name="LuxuryIdentity";m.Parent=parent;local gold=Color3.fromRGB(205,157,46);local cream=Color3.fromRGB(243,237,220)
 local sign=part(m,"ReserveSign",Vector3.new(7.4,.9,.18),localCF(pos,yaw,0,5,-.8),cream);label(sign,"PREMIUM RESERVE",cream,Color3.fromRGB(43,49,60))
 for _,x in ipairs({-4,-2.5,2.5,4})do part(m,"Stanchion"..tostring(x),Vector3.new(.12,1.45,.12),localCF(pos,yaw,x,.73,.3),gold,Enum.Material.Metal);local top=part(m,"StanchionTop"..tostring(x),Vector3.new(.26,.26,.26),localCF(pos,yaw,x,1.46,.3),gold,Enum.Material.Metal);top.Shape=Enum.PartType.Ball end
 part(m,"GoldRopeL",Vector3.new(1.5,.07,.07),localCF(pos,yaw,-3.25,1.25,.3),gold,Enum.Material.Metal);part(m,"GoldRopeR",Vector3.new(1.5,.07,.07),localCF(pos,yaw,3.25,1.25,.3),gold,Enum.Material.Metal)
end
local function unknown(parent)
 local pos=Vector3.new(-27,0,-21);local yaw=145;local m=Instance.new("Model");m.Name="ServiceIdentity";m.Parent=parent;local yellow=Color3.fromRGB(218,151,64);local dark=Color3.fromRGB(58,54,61)
 for side=-1,1,2 do local base=localCF(pos,yaw,side*3.8,.75,-.1);part(m,"BarrierPost"..side,Vector3.new(.18,1.5,.18),base,dark,Enum.Material.Metal);for i=-2,2 do part(m,"Hazard"..side.."_"..i,Vector3.new(.62,.16,.18),base*CFrame.new(i*.62,.45,0)*CFrame.Angles(0,0,math.rad(i%2==0 and 15 or -15)),i%2==0 and yellow or dark)end end
 local panel=part(m,"ServicePanel",Vector3.new(3.8,1,.18),localCF(pos,yaw,0,4.7,-.85),Color3.fromRGB(112,110,104));label(panel,"AUTHORIZED SERVICE",Color3.fromRGB(112,110,104),yellow)
end
function DistrictArtDirector:Apply(hub)
 if hub:FindFirstChild("AuthoredDistrictDetails")then return end;local folder=Instance.new("Folder");folder.Name="AuthoredDistrictDetails";folder.Parent=hub
 cornerStore(folder);sugar(folder);energy(folder);toy(folder);luxury(folder);unknown(folder)
end
return DistrictArtDirector

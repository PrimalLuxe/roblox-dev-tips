local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local MachineArtDirector=require(script.Parent.MachineArtDirector)
local DistrictArtDirector=require(script.Parent.DistrictArtDirector)
local WorldPolishService={}
local FACADES={
 {"CornerStoreBuilding",21,Vector3.new(-38,0,19),116,"CornerStorePremiumFacade","CornerStoreFacade"},
 {"EnergyGym",18,Vector3.new(38,0,19),244,"EnergyPremiumFacade","EnergyFacade"},
 {"LuxuryShop",19,Vector3.new(0,0,-43),0,"LuxuryPremiumFacade","LuxuryFacade"},
 {"ServiceWarehouse",18,Vector3.new(-39,0,-30),60,"ServicePremiumFacade","UnknownFacade"},
 {"CandyWorldPack",9,Vector3.new(0,0,26),180,"SugarCandyDressing",nil},
}
local DECOR={
 {"StreetBench",5.2,Vector3.new(-12,0,7),18,"BenchNW"},{"StreetBench",5.2,Vector3.new(12,0,7),-18,"BenchNE"},
 {"StreetBench",5.2,Vector3.new(-12,0,-19),162,"BenchSW"},{"StreetBench",5.2,Vector3.new(12,0,-19),198,"BenchSE"},
 {"StreetLamp",8.5,Vector3.new(-17,0,12),0,"LampNW"},{"StreetLamp",8.5,Vector3.new(17,0,12),0,"LampNE"},
 {"StreetLamp",8.5,Vector3.new(-17,0,-25),180,"LampSW"},{"StreetLamp",8.5,Vector3.new(17,0,-25),180,"LampSE"},
 {"TrashCan",2.1,Vector3.new(-10,0,10),0,"TrashNW"},{"TrashCan",2.1,Vector3.new(10,0,-22),180,"TrashSE"},
 {"ArcadeCabinet",5.8,Vector3.new(34,0,-18),-120,"ToyArcadeA"},{"ArcadeCabinet",5.8,Vector3.new(36,0,-23),-105,"ToyArcadeB"},
}
local function importedFolder()local a=ReplicatedStorage:FindFirstChild("Assets");return a and a:FindFirstChild("ImportedModels")end
local function sanitize(root)
 for _,d in ipairs(root:GetDescendants())do
  if d:IsA("BaseScript")or d:IsA("ModuleScript")or d:IsA("RemoteEvent")or d:IsA("RemoteFunction")or d:IsA("BindableEvent")or d:IsA("BindableFunction")or d:IsA("Tool")or d:IsA("Humanoid")or d:IsA("AnimationController")or d:IsA("ProximityPrompt")or d:IsA("ClickDetector")then d:Destroy()
  elseif d:IsA("BasePart")then d.Anchored=true;d.CanTouch=false;d.CanQuery=true;d.Massless=true;d.CanCollide=true end
 end
end
local function ensureModel(obj)if obj:IsA("Model")then return obj end;local m=Instance.new("Model");obj.Parent=m;if obj:IsA("BasePart")then m.PrimaryPart=obj end;return m end
local function cloneAsset(key,longest,pos,yaw,parent,name)
 local f=importedFolder();local src=f and f:FindFirstChild(key);if not src then return nil end
 local m=ensureModel(src:Clone());sanitize(m);local ok,size=pcall(function()return m:GetExtentsSize()end);if ok and size then local l=math.max(size.X,size.Y,size.Z);if l>0 then pcall(function()m:ScaleTo(m:GetScale()*(longest/l))end)end end
 m.Name=name;m.Parent=parent;local _,s=m:GetBoundingBox();m:PivotTo(CFrame.new(pos+Vector3.new(0,s.Y/2,0))*CFrame.Angles(0,math.rad(yaw),0));return m
end
local function styleBillboard(machine)
 local root=machine:FindFirstChild("Root");local gui=root and root:FindFirstChild("MachineBillboard");local frame=gui and gui:FindFirstChildOfClass("Frame");if not frame then return end
 frame.BackgroundColor3=Color3.fromRGB(255,248,226);frame.BackgroundTransparency=.03;local title=frame:FindFirstChild("Title");local subtitle=frame:FindFirstChild("Subtitle")
 if title then title.TextColor3=Color3.fromRGB(31,49,70);title.TextStrokeTransparency=1 end;if subtitle and machine:GetAttribute("EventOnly")then subtitle.TextColor3=Color3.fromRGB(193,121,58)end
 local stroke=frame:FindFirstChildOfClass("UIStroke");if stroke then stroke.Thickness=2.5;stroke.Transparency=.08 end
end
local function polishMachine(machine)
 if machine:GetAttribute("ArtDirectionVersion")==2 then return end;local shell=machine:FindFirstChild("Shell");if not shell or not shell:IsA("Model")then return end
 local id=machine:GetAttribute("MachineId")or machine.Name;local art=MachineArtDirector.Apply(machine,shell,id);styleBillboard(machine)
 local hl=shell:FindFirstChild("MachineAccent");if hl and hl:IsA("Highlight")then hl.OutlineTransparency=.9 end;local tray=art and art:FindFirstChild("DispenseTray");local spawn=machine:FindFirstChild("DropSpawn");if tray and spawn then spawn.CFrame=CFrame.new(tray.Position+Vector3.new(0,math.max(.45,tray.Size.Y*.5+.35),0))end
end
local function fillFacades(hub)
 for _,d in ipairs(FACADES)do if not hub:FindFirstChild(d[5])then local m=cloneAsset(d[1],d[2],d[3],d[4],hub,d[5]);if m and d[6]then local old=hub:FindFirstChild(d[6]);if old then old:Destroy()end end end end
end
local function fillDecor(hub)for _,d in ipairs(DECOR)do if not hub:FindFirstChild(d[5])then cloneAsset(d[1],d[2],d[3],d[4],hub,d[5])end end end
function WorldPolishService:Init()
 local bloom=Lighting:FindFirstChild("ShakeBloom");if bloom and bloom:IsA("BloomEffect")then bloom.Intensity=.10;bloom.Threshold=1.35 end
 local machines=Workspace:FindFirstChild("Machines");if machines then for _,m in ipairs(machines:GetChildren())do polishMachine(m)end;machines.ChildAdded:Connect(function(m)task.defer(function()polishMachine(m)end)end)end
 local hub=Workspace:FindFirstChild("ShakeHub");if not hub then return end;DistrictArtDirector:Apply(hub);fillFacades(hub);fillDecor(hub)
 task.spawn(function()for _=1,6 do task.wait(2);if not hub.Parent then return end;fillFacades(hub);fillDecor(hub)end end)
end
return WorldPolishService

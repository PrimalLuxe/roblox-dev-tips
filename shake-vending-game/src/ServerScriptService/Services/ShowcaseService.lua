local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util=require(ReplicatedStorage.Shared.Util)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)

local ShowcaseService={}
local NAVY=Color3.fromRGB(29,43,57)
local CREAM=Color3.fromRGB(246,239,220)
local GOLD=Color3.fromRGB(213,165,47)
local BLUE=Color3.fromRGB(49,134,211)

local function getFolder()
    local f=Workspace:FindFirstChild("PlayerShowcases")or Instance.new("Folder");f.Name="PlayerShowcases";f.Parent=Workspace;return f
end
local function part(parent,name,size,cf,color,material,transparency,collide)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
    p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function surfaceText(p,title,sub,accent)
    local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=70;gui.LightInfluence=.18;gui.Parent=p
    local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundColor3=CREAM;f.BorderSizePixel=0;f.Parent=gui
    local st=Instance.new("UIStroke");st.Color=NAVY;st.Thickness=3;st.Parent=f
    local stripe=Instance.new("Frame");stripe.Size=UDim2.new(0,10,1,-14);stripe.Position=UDim2.fromOffset(8,7);stripe.BackgroundColor3=accent or GOLD;stripe.BorderSizePixel=0;stripe.Parent=f
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(28,6);t.Size=UDim2.new(1,-38,.56,-2);t.Text=title;t.TextColor3=NAVY;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=f
    local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.new(0,28,.60,0);s.Size=UDim2.new(1,-38,.27,0);s.Text=sub or"";s.TextColor3=accent or GOLD;s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.TextXAlignment=Enum.TextXAlignment.Left;s.Parent=f
    return s
end
local function prep(model)
    local first
    for _,d in ipairs(model:GetDescendants())do
        if d:IsA("BaseScript")or d:IsA("ModuleScript")or d:IsA("RemoteEvent")or d:IsA("RemoteFunction")or d:IsA("Tool")or d:IsA("ClickDetector")or d:IsA("ProximityPrompt")then d:Destroy()
        elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;first=first or d end
    end
    if model:IsA("Model")and not model.PrimaryPart then model.PrimaryPart=first end
end

function ShowcaseService:GetPosition(player)
    local players=Players:GetPlayers();local index=table.find(players,player)or 1
    local slot=(index-1)%6;local bank=math.floor((index-1)/6)
    return Vector3.new(116-bank*12,0,-50+slot*20),90
end

local function podium(parent,base,yaw,x,z,slot,accent)
    local cf=CFrame.new(base)*CFrame.Angles(0,math.rad(yaw),0)*CFrame.new(x,0,z)
    part(parent,"PodiumBase"..slot,Vector3.new(2.2,.45,2.2),cf*CFrame.new(0,.23,0),NAVY,Enum.Material.Metal,0,true)
    part(parent,"PodiumStep"..slot,Vector3.new(1.75,.50,1.75),cf*CFrame.new(0,.70,0),accent,Enum.Material.SmoothPlastic,0,true)
    local top=part(parent,"PodiumTop"..slot,Vector3.new(1.42,.18,1.42),cf*CFrame.new(0,1.04,0),CREAM,Enum.Material.Marble,0,true)
    local plaque=part(parent,"Plaque"..slot,Vector3.new(2.25,.72,.16),cf*CFrame.new(0,.55,-1.18),CREAM,Enum.Material.SmoothPlastic,0,false)
    surfaceText(plaque,"SLOT "..slot,"CHOOSE ITEM",accent)
    return top,plaque,cf
end

local function setPlaque(plaque,item)
    local def=item and Items[item.BaseItemId]
    local gui=plaque and plaque:FindFirstChildOfClass("SurfaceGui");local f=gui and gui:FindFirstChildOfClass("Frame")
    if not f then return end
    local labels={};for _,d in ipairs(f:GetChildren())do if d:IsA("TextLabel")then table.insert(labels,d)end end
    table.sort(labels,function(a,b)return a.Position.Y.Scale<b.Position.Y.Scale end)
    if item and def then
        if labels[1]then labels[1].Text=string.upper(def.Name)end
        if labels[2]then labels[2].Text=string.upper(item.Rarity).." • 1/"..Util.FormatInteger(item.OneIn or 1);labels[2].TextColor3=Rarities.Get(item.Rarity).Color end
    end
end

local function buildBooth(model,player,base,yaw,score)
    local root=CFrame.new(base)*CFrame.Angles(0,math.rad(yaw),0)
    part(model,"BoothFloor",Vector3.new(10.5,.42,17),root*CFrame.new(0,.22,0),Color3.fromRGB(213,205,186),Enum.Material.Concrete,0,true)
    part(model,"BackWall",Vector3.new(.45,7.5,17),root*CFrame.new(5.0,3.75,0),Color3.fromRGB(45,54,63),Enum.Material.Concrete,0,true)
    for i=-4,4 do part(model,"WallSlat"..i,Vector3.new(.12,6.7,.10),root*CFrame.new(4.73,3.65,i*1.7),i%2==0 and BLUE or GOLD,Enum.Material.SmoothPlastic,0,false)end
    local header=part(model,"HeaderSign",Vector3.new(.34,3.5,10.8),root*CFrame.new(4.68,5.55,0)*CFrame.Angles(0,math.rad(-90),0),CREAM,Enum.Material.SmoothPlastic,0,false)
    surfaceText(header,string.upper(player.DisplayName).."'S SHOWCASE","COLLECTION SCORE  "..Util.FormatInteger(score or 0),GOLD)
    part(model,"HeaderCap",Vector3.new(.65,.28,11.2),root*CFrame.new(4.72,7.36,0),GOLD,Enum.Material.Metal,0,false)
    return root
end

function ShowcaseService:Refresh(player)
    local profile=self.DataService:GetProfile(player);if not profile then return end
    local folder=getFolder();local old=folder:FindFirstChild(tostring(player.UserId));if old then old:Destroy()end
    local model=Instance.new("Model");model.Name=tostring(player.UserId);model:SetAttribute("OwnerUserId",player.UserId);model:SetAttribute("HandBuiltShowcase",true);model.Parent=folder
    local base,yaw=self:GetPosition(player);local root=buildBooth(model,player,base,yaw,profile.CollectionScore)

    for i=1,6 do
        local row=math.floor((i-1)/3);local col=(i-1)%3;local x=-2.8+col*2.8;local z=-4.0+row*7.8
        local top,plaque,cf=podium(model,base,yaw,x,z,i,i%2==0 and BLUE or GOLD)
        local prompt=Instance.new("ProximityPrompt");prompt.ActionText="CHOOSE ITEM";prompt.ObjectText="Showcase Slot "..i;prompt.HoldDuration=0;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=true;prompt.Parent=top
        prompt.Triggered:Connect(function(triggering)if triggering==player then self.RemoteService.Events.OpenPanel:FireClient(player,{Panel="ShowcasePicker",Slot=i})end end)
        local id=profile.Showcase[i]
        if id then
            local _,item=Util.FindInventoryIndex(profile,id)
            if item then
                setPlaque(plaque,item)
                local visual=Factory.Create(item.BaseItemId,item.MutationId)
                if visual then
                    visual.Name="DisplayedItem";visual:SetAttribute("InstanceId",item.InstanceId);visual:SetAttribute("OwnerUserId",player.UserId);visual.Parent=model;prep(visual);pcall(function()visual:ScaleTo(.70)end)
                    local baseCFrame=cf*CFrame.new(0,1.72,0);visual:PivotTo(baseCFrame);visual:SetAttribute("ShowcaseBaseCFrame",baseCFrame)
                    local h=Instance.new("Highlight");h.FillTransparency=.92;h.OutlineTransparency=.10;h.OutlineColor=Rarities.Get(item.Rarity).Color;h.Parent=visual
                    local p=visual:FindFirstChildWhichIsA("BasePart",true);if p then local inspect=Instance.new("ProximityPrompt");inspect.ActionText="INSPECT";inspect.ObjectText=(Items[item.BaseItemId]and Items[item.BaseItemId].Name or item.BaseItemId);inspect.MaxActivationDistance=7;inspect.HoldDuration=0;inspect.RequiresLineOfSight=true;inspect.Parent=p end
                end
            end
        end
    end

    local rarest
    for _,candidate in ipairs(profile.Inventory or{})do if not rarest or(candidate.OneIn or 0)>(rarest.OneIn or 0)then rarest=candidate end end
    if rarest then
        part(model,"FeaturedBase",Vector3.new(4.2,.60,4.2),root*CFrame.new(0,.32,0),NAVY,Enum.Material.Metal,0,true)
        part(model,"FeaturedStep",Vector3.new(3.5,.62,3.5),root*CFrame.new(0,.90,0),GOLD,Enum.Material.Metal,0,true)
        local plaque=part(model,"FeaturedPlaque",Vector3.new(4.7,1.0,.18),root*CFrame.new(0,1.1,-2.25),CREAM,Enum.Material.SmoothPlastic,0,false);surfaceText(plaque,"FEATURED FIND",string.upper(rarest.Rarity).." • 1/"..Util.FormatInteger(rarest.OneIn or 1),Rarities.Get(rarest.Rarity).Color)
        local visual=Factory.Create(rarest.BaseItemId,rarest.MutationId)
        if visual then visual.Name="DisplayedItem";visual.Parent=model;prep(visual);pcall(function()visual:ScaleTo(.95)end);local baseCFrame=root*CFrame.new(0,2.15,0);visual:PivotTo(baseCFrame);visual:SetAttribute("ShowcaseBaseCFrame",baseCFrame);local h=Instance.new("Highlight");h.FillTransparency=.90;h.OutlineTransparency=.05;h.OutlineColor=Rarities.Get(rarest.Rarity).Color;h.Parent=visual end
    end
end

function ShowcaseService:Set(player,slot,instanceId)
    if type(slot)~="number"or slot<1 or slot>6 then return false,"Invalid slot"end
    local profile=self.DataService:GetProfile(player);if not profile then return false,"Profile not loaded"end
    local _,item=Util.FindInventoryIndex(profile,instanceId);if not item then return false,"Item not found"end
    profile.Showcase[slot]=instanceId;self:Refresh(player);return true,"Showcase slot "..slot.." updated"
end

function ShowcaseService:Init(RemoteService,DataService)
    self.RemoteService=RemoteService;self.DataService=DataService
    RemoteService.Events.SetShowcase.OnServerEvent:Connect(function(p,slot,id)if not RemoteService:Allow(p,"showcase",5,8)then return end;local ok,msg=self:Set(p,slot,id);RemoteService.Events.Toast:FireClient(p,{Text=msg,Kind=ok and"Success"or"Warn"})end)
    Players.PlayerAdded:Connect(function(p)task.spawn(function()repeat task.wait()until self.DataService:GetProfile(p)or not p.Parent;if p.Parent then self:Refresh(p)end end)end)
    Players.PlayerRemoving:Connect(function(p)local f=getFolder():FindFirstChild(tostring(p.UserId));if f then f:Destroy()end end)
end
return ShowcaseService

local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util=require(ReplicatedStorage.Shared.Util)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)

local ShowcaseService={}

local function getFolder()
    local f=Workspace:FindFirstChild("PlayerShowcases") or Instance.new("Folder");f.Name="PlayerShowcases";f.Parent=Workspace;return f
end

local function importedPodium()
    local a=ReplicatedStorage:FindFirstChild("Assets");local i=a and a:FindFirstChild("ImportedModels");return i and i:FindFirstChild("Podium")
end

local function prep(model)
    local first
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BaseScript") or d:IsA("ModuleScript") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("Tool") or d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then d:Destroy()
        elseif d:IsA("BasePart") then d.Anchored=true;d.CanCollide=true;d.CanTouch=false;first=first or d end
    end
    if model:IsA("Model") and not model.PrimaryPart then model.PrimaryPart=first end
    return first
end

local function scaleLongest(model,target)
    local ok,size=pcall(function()return model:GetExtentsSize()end);if not ok then return end
    local l=math.max(size.X,size.Y,size.Z);if l>0 then pcall(function()model:ScaleTo(model:GetScale()*(target/l))end)end
end

function ShowcaseService:GetPosition(player)
    local players=Players:GetPlayers();local index=table.find(players,player) or 1
    local col=(index-1)%6;local row=math.floor((index-1)/6)
    return Vector3.new(-31+col*12,0,-18.5-row*8.5)
end

local function addHeader(model,player,basePos,score)
    local anchor=Instance.new("Part");anchor.Name="HeaderAnchor";anchor.Size=Vector3.one;anchor.CFrame=CFrame.new(basePos+Vector3.new(0,4.8,0));anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.Parent=model
    local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(420,88);gui.AlwaysOnTop=true;gui.Adornee=anchor;gui.Parent=anchor
    local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(31,35,45);bg.BackgroundTransparency=0.05;bg.Parent=gui
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,14)
    corner.Parent=bg
    local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Size=UDim2.new(1,-16,0.58,0);name.Position=UDim2.fromOffset(8,3);name.Text=player.DisplayName:upper().."'S RAREST FINDS";name.TextColor3=Color3.new(1,1,1);name.Font=Enum.Font.GothamBlack;name.TextScaled=true;name.Parent=bg
    local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(0,0.58);s.Size=UDim2.new(1,0,0.32,0);s.Text="COLLECTION SCORE  "..Util.FormatInteger(score or 0);s.TextColor3=Color3.fromRGB(255,215,91);s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Parent=bg
end

local function addItemInspect(visual,item)
    local part=visual:FindFirstChildWhichIsA("BasePart",true)
    if not part then return end
    local def=Items[item.BaseItemId]
    local prompt=Instance.new("ProximityPrompt");prompt.ActionText="INSPECT";prompt.ObjectText=(def and def.Name or item.BaseItemId).." • 1/"..Util.FormatInteger(item.OneIn or 1);prompt.HoldDuration=0;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=part
    local gui=Instance.new("BillboardGui");gui.Name="ItemPlaque";gui.Size=UDim2.fromOffset(210,48);gui.StudsOffset=Vector3.new(0,1.25,0);gui.AlwaysOnTop=true;gui.MaxDistance=28;gui.Parent=part
    local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(31,35,45);text.BackgroundTransparency=0.18;text.BorderSizePixel=0;text.Text=(def and def.Name or item.BaseItemId).."\n"..item.Rarity.." • 1/"..Util.FormatInteger(item.OneIn or 1);text.TextColor3=Rarities.Get(item.Rarity).Color;text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,9);corner.Parent=text
end

function ShowcaseService:Refresh(player)
    local profile=self.DataService:GetProfile(player);if not profile then return end
    local podSrc=importedPodium()
    -- A missing Creator Store pedestal is a setup error, not permission to render a cheap
    -- generated block. The normal world already reports missing required visual assets.
    if not podSrc then return end
    local folder=getFolder();local old=folder:FindFirstChild(tostring(player.UserId));if old then old:Destroy() end
    local model=Instance.new("Model");model.Name=tostring(player.UserId);model:SetAttribute("OwnerUserId",player.UserId);model.Parent=folder
    local basePos=self:GetPosition(player);addHeader(model,player,basePos,profile.CollectionScore)
    for i=1,6 do
        local x=-4.1+(i-1)*1.65
        local pedModel
        local pedPrimary
        pedModel=podSrc:Clone();pedModel.Name="Podium"..i;pedModel.Parent=model;pedPrimary=prep(pedModel);scaleLongest(pedModel,1.55)
        local _,size=pedModel:GetBoundingBox();pedModel:PivotTo(CFrame.new(basePos+Vector3.new(x,size.Y/2,-0.2)))
        pedPrimary=pedPrimary or (pedModel:IsA("Model") and pedModel:FindFirstChildWhichIsA("BasePart",true)) or pedModel
        if pedPrimary and pedPrimary:IsA("BasePart") then
            local prompt=Instance.new("ProximityPrompt");prompt.ActionText="CHOOSE ITEM";prompt.ObjectText="Showcase Slot "..i;prompt.HoldDuration=0;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.Parent=pedPrimary
            prompt.Triggered:Connect(function(triggering)
                if triggering==player then self.RemoteService.Events.OpenPanel:FireClient(player,{Panel="ShowcasePicker",Slot=i}) end
            end)
        end

        local id=profile.Showcase[i]
        if id then
            local _,item=Util.FindInventoryIndex(profile,id)
            if item then
                local visual=Factory.Create(item.BaseItemId,item.MutationId)
                if visual then visual.Name="DisplayedItem";visual:SetAttribute("InstanceId",item.InstanceId);visual:SetAttribute("OwnerUserId",player.UserId);visual.Parent=model
                pcall(function()visual:ScaleTo(0.58)end)
                local y=1.7
                if pedModel:IsA("Model") then local _,sz=pedModel:GetBoundingBox();y=sz.Y+0.9 end
                local baseCFrame=CFrame.new(basePos+Vector3.new(x,y,-0.2))*CFrame.Angles(0,math.rad((i-1)*12),0)
                visual:PivotTo(baseCFrame);visual:SetAttribute("ShowcaseBaseCFrame",baseCFrame);addItemInspect(visual,item)
                local h=Instance.new("Highlight");h.FillTransparency=0.88;h.OutlineTransparency=0.15;h.OutlineColor=Rarities.Get(item.Rarity).Color;h.Parent=visual end
            end
        end
    end

    -- Automatic featured centerpiece: the player's rarest owned item is always visible even
    -- when all six editable slots are used for themed displays. This is read-only and does
    -- not alter ownership/showcase protection state.
    local rarest
    for _,candidate in ipairs(profile.Inventory or {}) do
        if not rarest or (candidate.OneIn or 0)>(rarest.OneIn or 0) then rarest=candidate end
    end
    if rarest then
        local featuredPed=podSrc:Clone();featuredPed.Name="FeaturedPodium";featuredPed.Parent=model;prep(featuredPed);scaleLongest(featuredPed,2.15)
        local _,psz=featuredPed:GetBoundingBox();local featuredPos=basePos+Vector3.new(0,psz.Y/2,-2.45);featuredPed:PivotTo(CFrame.new(featuredPos))
        local visual=Factory.Create(rarest.BaseItemId,rarest.MutationId)
        if visual then visual.Name="DisplayedItem";visual:SetAttribute("InstanceId",rarest.InstanceId);visual:SetAttribute("OwnerUserId",player.UserId);visual.Parent=model;pcall(function()visual:ScaleTo(0.78)end)
        local baseCFrame=CFrame.new(basePos+Vector3.new(0,psz.Y+1.15,-2.45));visual:PivotTo(baseCFrame);visual:SetAttribute("ShowcaseBaseCFrame",baseCFrame);addItemInspect(visual,rarest)
        local h=Instance.new("Highlight");h.FillTransparency=0.84;h.OutlineTransparency=0.08;h.OutlineColor=Rarities.Get(rarest.Rarity).Color;h.Parent=visual end
    end
end

function ShowcaseService:Set(player,slot,instanceId)
    if type(slot)~="number" or slot<1 or slot>6 then return false,"Invalid slot" end
    local profile=self.DataService:GetProfile(player);if not profile then return false,"Profile not loaded" end
    local _,item=Util.FindInventoryIndex(profile,instanceId);if not item then return false,"Item not found" end
    profile.Showcase[slot]=instanceId;self:Refresh(player);return true,"Showcase slot "..slot.." updated"
end

function ShowcaseService:Init(RemoteService,DataService)
    self.RemoteService=RemoteService;self.DataService=DataService
    RemoteService.Events.SetShowcase.OnServerEvent:Connect(function(p,slot,id)if not RemoteService:Allow(p,"showcase",5,8) then return end;local ok,msg=self:Set(p,slot,id);RemoteService.Events.Toast:FireClient(p,{Text=msg,Kind=ok and "Success" or "Warn"})end)
    Players.PlayerAdded:Connect(function(p)task.spawn(function()repeat task.wait() until self.DataService:GetProfile(p) or not p.Parent;if p.Parent then self:Refresh(p)end end)end)
    Players.PlayerRemoving:Connect(function(p)local f=getFolder():FindFirstChild(tostring(p.UserId));if f then f:Destroy()end end)
end
return ShowcaseService

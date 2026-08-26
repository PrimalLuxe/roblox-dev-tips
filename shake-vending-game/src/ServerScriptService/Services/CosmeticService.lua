local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.ItemDefinitions)
local Mutations = require(ReplicatedStorage.Shared.MutationDefinitions)
local Factory = require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util = require(ReplicatedStorage.Shared.Util)

local CosmeticService = {}

local function clear(character,slot)
    local folder=character:FindFirstChild("ShakeCosmetics")
    if not folder then return end
    local old=folder:FindFirstChild(slot)
    if old then old:Destroy() end
end

local function weldPart(parent,name,target,size,color,offset,material)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size; p.Color=color; p.Material=material or Enum.Material.Neon
    p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true; p.Anchored=false
    p.CFrame=target.CFrame*offset; p.Parent=parent
    local w=Instance.new("WeldConstraint"); w.Part0=target; w.Part1=p; w.Parent=p
    return p
end

local function wearableModel(container,item,target,offset,scale)
    local model=Factory.CreateFallback(item.BaseItemId,item.MutationId or "None")
    if not model then return nil end
    model.Name="CollectibleWearable"
    model.Parent=container
    pcall(function() model:ScaleTo(scale) end)
    model:PivotTo(target.CFrame*offset)
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored=false; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false; d.Massless=true
            local w=Instance.new("WeldConstraint");w.Part0=target;w.Part1=d;w.Parent=d
        end
    end
    return model
end

function CosmeticService:Apply(player,slot,item)
    local character=player.Character; if not character then return end
    local folder=character:FindFirstChild("ShakeCosmetics") or Instance.new("Folder")
    folder.Name="ShakeCosmetics"; folder.Parent=character
    clear(character,slot)
    local container=Instance.new("Folder"); container.Name=slot; container.Parent=folder

    local def=Items[item.BaseItemId]; local mut=Mutations[item.MutationId] or Mutations.None
    local color=mut.Color or (def and def.Color) or Color3.new(1,1,1)
    local head=character:FindFirstChild("Head")
    local torso=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    if not head or not torso then container:Destroy(); return end

    if slot=="Head" then
        wearableModel(container,item,head,CFrame.new(0,0.95,0)*CFrame.Angles(0,math.rad(-12),0),0.46)
    elseif slot=="Face" then
        wearableModel(container,item,head,CFrame.new(0,0,-0.62)*CFrame.Angles(0,0,math.rad(90)),0.22)
    elseif slot=="ShoulderLeft" then
        wearableModel(container,item,torso,CFrame.new(-1.18,0.52,0)*CFrame.Angles(0,math.rad(18),0),0.33)
    elseif slot=="ShoulderRight" or slot=="Shoulder" then
        wearableModel(container,item,torso,CFrame.new(1.18,0.52,0)*CFrame.Angles(0,math.rad(-18),0),0.33)
    elseif slot=="Back" then
        wearableModel(container,item,torso,CFrame.new(0,0,0.72)*CFrame.Angles(math.rad(8),math.rad(180),0),0.58)
    elseif slot=="Aura" then
        local anchor=weldPart(container,"AuraAnchor",torso,Vector3.new(0.2,0.2,0.2),color,CFrame.new(),Enum.Material.Neon); anchor.Transparency=1
        local attachment=Instance.new("Attachment"); attachment.Name="AuraAttachment"; attachment.Parent=anchor
        local emitter=Instance.new("ParticleEmitter")
        emitter.Rate=12; emitter.Lifetime=NumberRange.new(0.8,1.6); emitter.Speed=NumberRange.new(0.4,1.5)
        emitter.SpreadAngle=Vector2.new(180,180); emitter.LightEmission=0.82
        emitter.Color=ColorSequence.new(color); emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(0.65,0.16),NumberSequenceKeypoint.new(1,0)})
        emitter.Parent=attachment
        if item.MutationId=="Cosmic" or item.MutationId=="Void" or item.MutationId=="Heavenly" or item.MutationId=="Glitched" then
            for i=1,3 do
                local mote=weldPart(container,"AuraMote"..i,torso,Vector3.new(0.12,0.12,0.12),color,CFrame.new(math.cos(i*2.094)*1.4,(i-2)*0.45,math.sin(i*2.094)*0.5),Enum.Material.Neon)
                mote.Shape=Enum.PartType.Ball
            end
        end
    elseif slot=="Trail" then
        local left=weldPart(container,"TrailLeft",torso,Vector3.new(0.1,0.1,0.1),color,CFrame.new(-0.5,-0.8,0.45),Enum.Material.Neon);left.Transparency=1
        local right=weldPart(container,"TrailRight",torso,Vector3.new(0.1,0.1,0.1),color,CFrame.new(0.5,-0.8,0.45),Enum.Material.Neon);right.Transparency=1
        local a0=Instance.new("Attachment"); a0.Parent=left
        local a1=Instance.new("Attachment"); a1.Parent=right
        local trail=Instance.new("Trail"); trail.Attachment0=a0; trail.Attachment1=a1; trail.Color=ColorSequence.new(color); trail.Lifetime=0.35; trail.LightEmission=0.65; trail.Parent=container
    elseif slot=="Title" or slot=="Nameplate" then
        local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(260,42); gui.StudsOffset=Vector3.new(0,slot=="Title" and 3.15 or 2.7,0); gui.AlwaysOnTop=true; gui.Parent=container; gui.Adornee=head
        local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text=(item.DisplayLabel or (def and def.Name) or item.BaseItemId); label.TextColor3=color; label.TextStrokeTransparency=0.35; label.Font=Enum.Font.GothamBlack; label.TextScaled=true; label.Parent=gui
    end
end

function CosmeticService:Equip(player,instanceId,requestedSlot)
    local profile=self.DataService:GetProfile(player); if not profile then return false end
    local _,item=Util.FindInventoryIndex(profile,instanceId); if not item then return false end
    local def=Items[item.BaseItemId]; if not def then return false end
    local slot=requestedSlot or def.CosmeticSlot
    if slot=="Shoulder" then slot="ShoulderRight" end
    if not slot then return false end
    local allowed = slot==def.CosmeticSlot or (def.CosmeticSlot=="Shoulder" and (slot=="ShoulderLeft" or slot=="ShoulderRight"))
    if not allowed then return false end
    profile.Equipped[slot]=instanceId
    self:Apply(player,slot,item)
    return true
end

function CosmeticService:Reapply(player)
    local profile=self.DataService:GetProfile(player); if not profile then return end
    local character=player.Character
    if character then local old=character:FindFirstChild("ShakeCosmetics"); if old then old:Destroy() end end
    for slot,id in pairs(profile.Equipped) do
        if id then
            if type(id)=="string" and id:sub(1,7)=="reward:" then
                local reward=profile.SetRewards[id:sub(8)]
                if reward then self:Apply(player,slot,{BaseItemId=reward.BaseItemId,MutationId=reward.MutationId or "None",Rarity="Divine",OneIn=1,DisplayLabel=reward.Label}) end
            else
                local _,item=Util.FindInventoryIndex(profile,id); if item then self:Apply(player,slot,item) end
            end
        end
    end
end

function CosmeticService:EquipReward(player,rewardId)
    local profile=self.DataService:GetProfile(player); if not profile then return false end
    local reward=profile.SetRewards[rewardId]; if not reward then return false end
    local virtual={BaseItemId=reward.BaseItemId,MutationId=reward.MutationId or "None",Rarity="Divine",OneIn=1,DisplayLabel=reward.Label}
    profile.Equipped[reward.Slot]="reward:"..rewardId
    self:Apply(player,reward.Slot,virtual)
    return true
end

function CosmeticService:SaveOutfit(player,slotIndex)
    local profile=self.DataService:GetProfile(player); slotIndex=tonumber(slotIndex)
    if not profile or not slotIndex or slotIndex<1 or slotIndex>#profile.OutfitSlots then return false end
    profile.OutfitSlots[slotIndex]=Util.DeepCopy(profile.Equipped); return true
end

function CosmeticService:LoadOutfit(player,slotIndex)
    local profile=self.DataService:GetProfile(player); slotIndex=tonumber(slotIndex)
    if not profile or not slotIndex or not profile.OutfitSlots[slotIndex] then return false end
    profile.Equipped=Util.DeepCopy(profile.OutfitSlots[slotIndex])
    local character=player.Character; if character then local old=character:FindFirstChild("ShakeCosmetics"); if old then old:Destroy() end end
    self:Reapply(player); return true
end

function CosmeticService:BindPlayer(player)
    player.CharacterAdded:Connect(function() task.wait(0.8); self:Reapply(player) end)
    if player.Character then task.defer(function() task.wait(0.8); self:Reapply(player) end) end
end

function CosmeticService:Init(RemoteService,DataService)
    self.DataService=DataService
    RemoteService.Events.EquipCosmetic.OnServerEvent:Connect(function(player,id,slot)
        if not RemoteService:Allow(player,"cosmetic",5,8) then return end
        local ok=false
        if type(id)=="string" and id:sub(1,7)=="reward:" then ok=self:EquipReward(player,id:sub(8)) else ok=self:Equip(player,id,slot) end
        if ok then RemoteService.Events.Toast:FireClient(player,{Text="Equipped!",Kind="Success"}) end
    end)
    RemoteService.Events.OutfitAction.OnServerEvent:Connect(function(player,action,index)
        if not RemoteService:Allow(player,"outfit",4,7) then return end
        local ok=false
        if action=="save" then ok=self:SaveOutfit(player,index) elseif action=="load" then ok=self:LoadOutfit(player,index) end
        if ok then RemoteService.Events.Toast:FireClient(player,{Text=(action=="save" and "Saved" or "Loaded").." outfit "..tostring(index),Kind="Success"}) end
    end)
    Players.PlayerAdded:Connect(function(player) self:BindPlayer(player) end)
    for _,player in ipairs(Players:GetPlayers()) do self:BindPlayer(player) end
end

return CosmeticService

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Services=script.Parent:WaitForChild("Services")

-- Remotes exist first so a later startup failure produces a useful client error instead of an infinite yield.
local RemoteService=require(Services.RemoteService);RemoteService:Init()
ReplicatedStorage:SetAttribute("ShakeVM_ServerBootReady", false)
local AssetLoadService=require(Services.AssetLoadService)
local DataService=require(Services.DataService)
local EventService=require(Services.EventService)
local RollService=require(Services.RollService)
local ProgressionService=require(Services.ProgressionService)
local EngagementService=require(Services.EngagementService)
local CollectionService=require(Services.CollectionService)
local InventoryService=require(Services.InventoryService)
local GlobalService=require(Services.GlobalService)
local CosmeticService=require(Services.CosmeticService)
local ShowcaseService=require(Services.ShowcaseService)
local TradingService=require(Services.TradingService)
local SettingsService=require(Services.SettingsService)
local WorldBuilder=require(Services.WorldBuilder)
local UpgradeService=require(Services.UpgradeService)
local MachineService=require(Services.MachineService)
local WorldInteractionService=require(Services.WorldInteractionService)
local Util=require(ReplicatedStorage.Shared.Util)

-- Player profiles/settings must begin loading before potentially slow visual asset work.
-- This lets returning-player comfort/intro settings replicate while the world is still preparing.
DataService:Init()

-- Load and sanitize curated free Creator Store models before building the visual world.
AssetLoadService:Init()
WorldBuilder:Init()
ProgressionService:Init(DataService,RemoteService)
EngagementService:Init(RemoteService,DataService)
EventService:Init(RemoteService)
RollService:Init(DataService,EventService)
CollectionService:Init(DataService,RemoteService,ProgressionService)
InventoryService:Init(DataService,CollectionService,ProgressionService)
GlobalService:Init(RemoteService)
CosmeticService:Init(RemoteService,DataService)
ShowcaseService:Init(RemoteService,DataService)
TradingService:Init(RemoteService,DataService,CosmeticService,ShowcaseService)
SettingsService:Init(RemoteService,DataService,TradingService)
UpgradeService:Init(RemoteService,DataService)
MachineService:Init(RemoteService,DataService,RollService,InventoryService,GlobalService,EventService,ProgressionService,EngagementService)
WorldInteractionService:Init(RemoteService,InventoryService)

RemoteService.Functions.GetSnapshot.OnServerInvoke=function(player)
    local profile=DataService:GetProfile(player);if not profile then return nil end
    return {Profile=Util.DeepCopy(profile),GoalState=ProgressionService:GetState(profile),Engagement=EngagementService:GetState(player),Event=EventService:GetCurrent(),ServerTime=os.time(),CreatorAssetsReady=ReplicatedStorage:GetAttribute("CreatorAssetsReady"),CreatorAssetsError=ReplicatedStorage:GetAttribute("CreatorAssetsError")}
end

RemoteService.Functions.GetPlayerSummary.OnServerInvoke=function(player,userId)
    if type(userId)~="number" then return nil end
    local summary=DataService:GetPublicSummary(userId);local target=Players:GetPlayerByUserId(userId)
    if summary and target then summary.Name=target.Name;summary.DisplayName=target.DisplayName end
    return summary
end

RemoteService.Events.InventoryAction.OnServerEvent:Connect(function(player,action,instanceId)
    if type(action)~="string" then return end
    if action=="sell" and type(instanceId)=="string" then
        local ok,value=InventoryService:Sell(player,instanceId)
        if ok then CosmeticService:Reapply(player);ShowcaseService:Refresh(player);RemoteService.Events.Toast:FireClient(player,{Text="Sold for $"..tostring(value),Kind="Success"})
        else RemoteService.Events.Toast:FireClient(player,{Text="That item is locked/favorited/equipped/showcased.",Kind="Warn"}) end
    elseif action=="mass_commons" or action=="mass_duplicates" or action=="mass_safe" then
        local mode=action=="mass_commons" and "commons" or action=="mass_duplicates" and "duplicates" or "safe"
        local ok,result=InventoryService:MassSell(player,mode)
        if ok then CosmeticService:Reapply(player);ShowcaseService:Refresh(player);RemoteService.Events.Toast:FireClient(player,{Text=string.format("Mass sold %d items for $%d",result.Count,result.Value),Kind="Success"})
        else RemoteService.Events.Toast:FireClient(player,{Text=tostring(result),Kind="Warn"}) end
    elseif action=="lock" and type(instanceId)=="string" then
        local ok,locked=InventoryService:ToggleLock(player,instanceId);if ok then RemoteService.Events.Toast:FireClient(player,{Text=locked and "Item locked" or "Item unlocked",Kind="Info"}) end
    elseif action=="shard" and type(instanceId)=="string" then
        local ok,amount=InventoryService:ConvertToShards(player,instanceId);if ok then CosmeticService:Reapply(player);ShowcaseService:Refresh(player)end
        RemoteService.Events.Toast:FireClient(player,{Text=ok and ("Converted duplicate into "..amount.." Style Shards") or tostring(amount),Kind=ok and "Success" or "Warn"})
    elseif action=="favorite" and type(instanceId)=="string" then
        local ok,favorite=InventoryService:ToggleFavorite(player,instanceId);if ok then RemoteService.Events.Toast:FireClient(player,{Text=favorite and "Added to favorites" or "Removed from favorites",Kind="Info"}) end
    end
end)

ReplicatedStorage:SetAttribute("ShakeVM_ServerBootReady", true)
print("[ShakeVM] Booted Creator-asset vending RNG overhaul")

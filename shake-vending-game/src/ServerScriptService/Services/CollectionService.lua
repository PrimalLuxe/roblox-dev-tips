local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.Config)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Sets=require(ReplicatedStorage.Shared.SetDefinitions)

local CollectionService={}
local rarityPoints={Common=1,Uncommon=2,Rare=5,Epic=12,Legendary=30,Mythic=80,Divine=250,Secret=1000,Global=5000}

local function baseCount(profile)
    local n=0;for _,v in pairs(profile.BaseCollection or {}) do if v then n+=1 end end;return n
end

function CollectionService:CheckMilestones(player)
    local profile=self.DataService:GetProfile(player);if not profile then return end
    profile.Progression=profile.Progression or {};profile.Progression.CollectionMilestones=profile.Progression.CollectionMilestones or {}
    local count=baseCount(profile)
    for _,milestone in ipairs(Config.CollectionMilestones) do
        local key=tostring(milestone.Count)
        if count>=milestone.Count and not profile.Progression.CollectionMilestones[key] then
            profile.Progression.CollectionMilestones[key]=true
            profile.Coins+=(milestone.Coins or 0);profile.StyleShards+=(milestone.Shards or 0)
            if milestone.Count>=60 then
                profile.SetRewards.CatalogLegend={Id="CatalogLegend",Label="VENDING LEGEND",Slot="Title"}
            end
            if self.RemoteService then
                self.RemoteService.Events.Toast:FireClient(player,{Text=string.format("CATALOG %d/60! +%d coins%s",milestone.Count,milestone.Coins or 0,(milestone.Shards or 0)>0 and (" +"..milestone.Shards.." shards") or ""),Kind="New"})
            end
        end
    end
end

function CollectionService:Register(player,item)
    local profile=self.DataService:GetProfile(player);if not profile then return {FirstVariant=false,FirstBase=false,Bonus=0} end
    profile.BaseCollection=profile.BaseCollection or {};profile.Progression=profile.Progression or {}
    local key=item.BaseItemId..":"..item.MutationId
    local firstVariant=not profile.Collection[key]
    local firstBase=not profile.BaseCollection[item.BaseItemId]
    profile.Collection[key]=(profile.Collection[key] or 0)+1

    local def=Items[item.BaseItemId]
    if firstBase then
        profile.BaseCollection[item.BaseItemId]=true
        if self.ProgressionService then task.defer(function() self.ProgressionService:OnDiscovery(player,item.BaseItemId) end) end
        local bonus=math.max(Config.DiscoveryBonusFlat,math.floor((item.Value or 1)*Config.DiscoveryBonusMultiplier))
        -- First discoveries are the early-game engine: they fund the next machine instead of forcing hundreds of shakes.
        profile.Coins+=bonus
        profile.Progression.DiscoveryBonusCoins=(profile.Progression.DiscoveryBonusCoins or 0)+bonus
        if self.RemoteService then self.RemoteService.Events.Toast:FireClient(player,{Text="NEW CATALOG ITEM! +"..tostring(bonus).." discovery coins",Kind="New"}) end
    end

    if firstVariant then
        local score=(rarityPoints[item.Rarity] or 1)*math.max(1,math.floor(math.log10(math.max(10,item.OneIn))))
        score=math.floor(score*(1+math.max(0,(profile.Upgrades.CollectionBonus or 1)-1)*0.05))
        profile.CollectionScore+=score
        if def and def.CosmeticSlot then profile.CosmeticUnlocks[key]={BaseItemId=item.BaseItemId,MutationId=item.MutationId,Slot=def.CosmeticSlot} end
    end

    profile.Statistics.ItemsCollected+=1
    if self.ProgressionService then task.defer(function() self.ProgressionService:Check(player) end) end
    if Rarities.AtLeast(item.Rarity,"Secret") then profile.Statistics.SecretsFound+=1 end
    if item.Rarity=="Global" then profile.Statistics.GlobalsFound+=1 end
    task.defer(function() self:CheckSets(player);self:CheckMilestones(player) end)
    return {FirstVariant=firstVariant,FirstBase=firstBase,Bonus=firstBase and math.max(Config.DiscoveryBonusFlat,math.floor((item.Value or 1)*Config.DiscoveryBonusMultiplier)) or 0}
end

function CollectionService:CheckSets(player)
    local profile=self.DataService:GetProfile(player);if not profile then return end
    for _,setDef in pairs(Sets) do
        if not profile.SetRewards[setDef.Reward.Id] then
            local complete=true
            for _,req in ipairs(setDef.Requirements) do
                local found=false
                for key,count in pairs(profile.Collection) do
                    if count>0 then
                        local base,mutation=key:match("^([^:]+):(.+)$")
                        if base==req.BaseItemId and (not req.MutationId or mutation==req.MutationId) then found=true;break end
                    end
                end
                if not found then complete=false;break end
            end
            if complete then
                profile.SetRewards[setDef.Reward.Id]=setDef.Reward
                if self.RemoteService then self.RemoteService.Events.Toast:FireClient(player,{Text="SET COMPLETE: "..setDef.DisplayName.." — "..setDef.Reward.Label,Kind="New"}) end
            end
        end
    end
end

function CollectionService:Init(DataService,RemoteService,ProgressionService)
    self.DataService=DataService;self.RemoteService=RemoteService;self.ProgressionService=ProgressionService
end
return CollectionService

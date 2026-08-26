local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.Config)
local Util=require(ReplicatedStorage.Shared.Util)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)

local InventoryService={}

function InventoryService:GetCapacity(profile)
    return Config.InventoryBaseCapacity+math.max(0,(profile.Upgrades.Capacity or 1)-1)*25
end

function InventoryService:Add(player,item)
    local profile=self.DataService:GetProfile(player);if not profile then return false,"ProfileNotLoaded" end
    if #profile.Inventory>=self:GetCapacity(profile) then return false,"INVENTORY FULL — use Mass Sell" end
    local settings=profile.Settings or {}
    if settings.AutoLockLegendary~=false and Rarities.Get(item.Rarity).Rank>=5 then item.Locked=true end
    table.insert(profile.Inventory,item)
    local meta=self.CollectionService:Register(player,item)
    return true,meta
end

local function referenced(profile,id)
    if profile.Favorites and profile.Favorites[id] then return true end
    for _,v in pairs(profile.Equipped or {}) do if v==id then return true end end
    for _,v in pairs(profile.Showcase or {}) do if v==id then return true end end
    return false
end

local function sellable(profile,item)
    return item and not item.Locked and not referenced(profile,item.InstanceId)
end

function InventoryService:Sell(player,instanceId)
    local profile=self.DataService:GetProfile(player);if not profile then return false end
    local index,item=Util.FindInventoryIndex(profile,instanceId)
    if not index or not sellable(profile,item) then return false,"ProtectedItem" end
    table.remove(profile.Inventory,index);Util.RemoveItemReferences(profile,instanceId)
    profile.Coins+=item.Value or 0;profile.Statistics.TotalSold+=item.Value or 0
    if self.ProgressionService then task.defer(function() self.ProgressionService:Check(player) end) end
    return true,item.Value or 0
end

function InventoryService:MassSell(player,mode)
    local profile=self.DataService:GetProfile(player);if not profile then return false,"ProfileNotLoaded" end
    local sellIds={}

    if mode=="commons" or mode=="safe" then
        local maxRank=mode=="commons" and 2 or 4
        local kept={}
        for _,item in ipairs(profile.Inventory) do
            if sellable(profile,item) and Rarities.Get(item.Rarity).Rank<=maxRank then
                local key=item.BaseItemId..":"..(item.MutationId or "None")
                if profile.Settings and profile.Settings.KeepOneEach~=false and not kept[key] then kept[key]=true else sellIds[item.InstanceId]=true end
            end
        end
    elseif mode=="duplicates" then
        local groups={}
        for _,item in ipairs(profile.Inventory) do
            local key=item.BaseItemId..":"..item.MutationId;groups[key]=groups[key] or {};table.insert(groups[key],item)
        end
        for _,group in pairs(groups) do
            if #group>1 then
                table.sort(group,function(a,b)return (a.OneIn or 0)>(b.OneIn or 0) end)
                local hasProtected=false
                for _,item in ipairs(group) do if not sellable(profile,item) then hasProtected=true;break end end
                local kept=false
                for _,item in ipairs(group) do
                    if sellable(profile,item) then
                        if hasProtected then sellIds[item.InstanceId]=true
                        elseif kept then sellIds[item.InstanceId]=true
                        else kept=true end
                    end
                end
            end
        end
    else return false,"UnknownMassSellMode" end

    local count,value=0,0
    for i=#profile.Inventory,1,-1 do
        local item=profile.Inventory[i]
        if sellIds[item.InstanceId] then
            value+=item.Value or 0;count+=1;Util.RemoveItemReferences(profile,item.InstanceId);table.remove(profile.Inventory,i)
        end
    end
    profile.Coins+=value;profile.Statistics.TotalSold+=value
    if self.ProgressionService then task.defer(function() self.ProgressionService:Check(player) end) end
    return true,{Count=count,Value=value}
end

function InventoryService:ToggleLock(player,instanceId)
    local profile=self.DataService:GetProfile(player);local _,item=profile and Util.FindInventoryIndex(profile,instanceId)
    if not item then return false end
    item.Locked=not item.Locked;return true,item.Locked
end

function InventoryService:ToggleFavorite(player,instanceId)
    local profile=self.DataService:GetProfile(player);local _,item=profile and Util.FindInventoryIndex(profile,instanceId)
    if not item then return false,"ItemNotFound" end
    profile.Favorites[instanceId]=not profile.Favorites[instanceId] or nil
    return true,profile.Favorites[instanceId]==true
end

function InventoryService:ConvertToShards(player,instanceId)
    local profile=self.DataService:GetProfile(player);if not profile then return false,"ProfileNotLoaded" end
    local index,item=Util.FindInventoryIndex(profile,instanceId);if not index then return false,"ItemNotFound" end
    if not sellable(profile,item) then return false,"Unlock/unfavorite/remove from showcase first" end
    local copies=0;for _,other in ipairs(profile.Inventory) do if other.BaseItemId==item.BaseItemId and other.MutationId==item.MutationId then copies+=1 end end
    if copies<2 then return false,"Keep at least one copy" end
    local rank=Rarities.Get(item.Rarity).Rank
    local shards=math.max(1,math.floor((rank^2)*math.max(1,math.log10(math.max(10,item.OneIn or 1)))))
    table.remove(profile.Inventory,index);Util.RemoveItemReferences(profile,instanceId);profile.StyleShards=(profile.StyleShards or 0)+shards
    return true,shards
end

function InventoryService:Init(DataService,CollectionService,ProgressionService)
    self.DataService=DataService;self.CollectionService=CollectionService;self.ProgressionService=ProgressionService
end
return InventoryService

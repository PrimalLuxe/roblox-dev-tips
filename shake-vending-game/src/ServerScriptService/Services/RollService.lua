local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.ItemDefinitions)
local Mutations = require(ReplicatedStorage.Shared.MutationDefinitions)
local Rarities = require(ReplicatedStorage.Shared.RarityDefinitions)
local Util = require(ReplicatedStorage.Shared.Util)

local RollService = {}

local function chooseWeighted(entries, getWeight)
    local total=0
    for _,entry in ipairs(entries) do total+=math.max(0,getWeight(entry)) end
    if total<=0 then return entries[1],1 end
    local r=math.random()*total;local cursor=0
    for _,entry in ipairs(entries) do
        cursor+=math.max(0,getWeight(entry))
        if r<=cursor then return entry,total end
    end
    return entries[#entries],total
end

local function mutationEntries()
    local out={}
    for name,def in pairs(Mutations) do if name~="TotalWeight" then table.insert(out,{Name=name,Def=def}) end end
    return out
end
local mutationList=mutationEntries()

local function itemWeight(def,luckFactor)
    local rank=Rarities.Get(def.Rarity).Rank
    if rank<=2 then return def.Weight end
    return def.Weight*(1+(luckFactor-1)*0.30*(rank-1))
end

function RollService:Roll(player,machineId,engagement)
    local profile=self.DataService:GetProfile(player);if not profile then return nil,"ProfileNotLoaded" end
    local list=Items.ByMachine[machineId];if not list then return nil,"UnknownMachine" end

    profile.Progression=profile.Progression or {}
    profile.Progression.LuckyMeter=profile.Progression.LuckyMeter or 0

    local event=self.EventService:GetCurrent();local eventApplies=self.EventService:AppliesTo(event,machineId)
    local beginnerRemaining=math.max(0,Config.BeginnerLuckShakes-(profile.Statistics.Shakes or 0))
    local beginner=beginnerRemaining>0 and Config.BeginnerLuckMultiplier or 1
    local luckLevel=math.max(1,profile.Upgrades.Luck or 1)
    local mutationLevel=math.max(1,profile.Upgrades.MutationLuck or 1)
    local comboLuck=(engagement and engagement.LuckMultiplier) or 1
    local comboMutation=(engagement and engagement.MutationMultiplier) or 1
    local luckFactor=(1+(luckLevel-1)*0.12)*(eventApplies and event.Luck or 1)*beginner*comboLuck
    local mutationFactor=(1+(mutationLevel-1)*0.13)*(eventApplies and event.Mutation or 1)*math.sqrt(beginner)*comboMutation

    local pityReady=profile.Progression.LuckyMeter>=Config.LuckyMeterThreshold
    local selectionPool=list
    if pityReady then
        selectionPool={}
        for _,def in ipairs(list) do if Rarities.Get(def.Rarity).Rank>=3 then table.insert(selectionPool,def) end end
        if #selectionPool==0 then selectionPool=list end
    end

    local item,rollTotal=chooseWeighted(selectionPool,function(def)return itemWeight(def,luckFactor)end)

    local naturalTotal=0
    for _,def in ipairs(list) do naturalTotal+=itemWeight(def,luckFactor) end
    local naturalBaseProbability=itemWeight(item,luckFactor)/math.max(1,naturalTotal)
    local naturalBaseOneIn=math.max(1,math.floor(1/math.max(1e-12,naturalBaseProbability)+0.5))
    local rollBaseProbability=itemWeight(item,luckFactor)/math.max(1,rollTotal or naturalTotal)
    local rollBaseOneIn=math.max(1,math.floor(1/math.max(1e-12,rollBaseProbability)+0.5))

    local mutation,mutationTotal=chooseWeighted(mutationList,function(entry)
        if entry.Name=="None" then return entry.Def.Weight end
        return entry.Def.Weight*mutationFactor
    end)

    if eventApplies and event.ForcedMutation and math.random()<0.12 then
        local forced=Mutations[event.ForcedMutation]
        if forced then mutation={Name=event.ForcedMutation,Def=forced} end
    end

    local selectedWeight=mutation.Name=="None" and mutation.Def.Weight or mutation.Def.Weight*mutationFactor
    local mutationProbability=selectedWeight/math.max(1,mutationTotal)
    if eventApplies and event.ForcedMutation then
        if mutation.Name==event.ForcedMutation then mutationProbability=0.12+0.88*mutationProbability else mutationProbability=0.88*mutationProbability end
    end
    local mutationOneIn=math.max(1,math.floor(1/math.max(1e-12,mutationProbability)+0.5))
    local naturalOneIn=math.max(1,naturalBaseOneIn*mutationOneIn)
    local oneIn=math.max(1,rollBaseOneIn*mutationOneIn)

    local baseRank=Rarities.Get(item.Rarity).Rank
    if baseRank>=3 then profile.Progression.LuckyMeter=0 else profile.Progression.LuckyMeter=math.min(Config.LuckyMeterThreshold,profile.Progression.LuckyMeter+1) end

    local value=math.max(1,math.floor(item.BaseValue*mutation.Def.Multiplier))
    local effectiveRarity=Rarities.Effective(item.Rarity,oneIn)
    return {
        InstanceId=Util.Guid(),BaseItemId=item.Id,MutationId=mutation.Name,BaseRarity=item.Rarity,Rarity=effectiveRarity,
        OneIn=oneIn,NaturalOneIn=naturalOneIn,RollAdjusted=pityReady,Value=value,OriginalOwner=player.UserId,CurrentOwner=player.UserId,ObtainedAt=os.time(),ObtainedMachine=machineId,
        ObtainedEvent=eventApplies and event.Id or "Normal",TradeCount=0,TradeHistory={},Locked=false,
        LuckyGuarantee=pityReady,BeginnerLuck=beginnerRemaining>0,BeginnerLuckRemaining=beginnerRemaining,
        ComboCount=engagement and engagement.Count or 0,
    }
end

function RollService:Init(DataService,EventService)
    self.DataService=DataService;self.EventService=EventService
end
return RollService

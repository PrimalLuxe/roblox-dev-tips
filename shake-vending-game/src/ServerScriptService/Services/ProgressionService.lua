local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Util=require(ReplicatedStorage.Shared.Util)
local ProgressionService={}
local function rankReward(rank)return {Coins=math.floor(180*(rank^1.85)),Shards=(rank%2==0) and math.max(1,math.floor(rank/2)) or 0}end
function ProgressionService:EnsureGoals(profile)
    profile.Progression=profile.Progression or {};profile.Progression.Rank=profile.Progression.Rank or 1;local rank=profile.Progression.Rank;local goals=profile.Progression.RankGoals
    if type(goals)~="table" or not goals.ShakesTarget or not goals.ItemsTarget or not goals.SoldTarget then local stats=profile.Statistics;profile.Progression.RankGoals={ShakesStart=stats.Shakes or 0,ShakesTarget=(stats.Shakes or 0)+(8+rank*4),ItemsStart=stats.ItemsCollected or 0,ItemsTarget=(stats.ItemsCollected or 0)+(6+rank*3),SoldStart=stats.TotalSold or 0,SoldTarget=(stats.TotalSold or 0)+math.floor(140*(rank^1.45))} end
    return profile.Progression.RankGoals
end
function ProgressionService:GetState(profile)local goals=self:EnsureGoals(profile);local stats=profile.Statistics;local completed={Shakes=(stats.Shakes or 0)>=goals.ShakesTarget,Items=(stats.ItemsCollected or 0)>=goals.ItemsTarget,Sold=(stats.TotalSold or 0)>=goals.SoldTarget};local n=(completed.Shakes and 1 or 0)+(completed.Items and 1 or 0)+(completed.Sold and 1 or 0);return {Rank=profile.Progression.Rank,Goals=Util.DeepCopy(goals),Completed=completed,CompletedCount=n,Reward=rankReward(profile.Progression.Rank)} end
function ProgressionService:Check(player)local profile=self.DataService:GetProfile(player);if not profile then return end;local state=self:GetState(profile);if state.CompletedCount<3 then return state end;local oldRank=state.Rank;local reward=state.Reward;profile.Coins+=(reward.Coins or 0);profile.StyleShards+=(reward.Shards or 0);profile.Progression.Rank=oldRank+1;profile.Progression.RankGoals=nil;self:EnsureGoals(profile);self.RemoteService.Events.Toast:FireClient(player,{Text=string.format("RANK %d COMPLETE! +$%s%s",oldRank,Util.FormatInteger(reward.Coins),reward.Shards>0 and (" +"..reward.Shards.." shards") or ""),Kind="New"});return self:GetState(profile) end
function ProgressionService:Init(DataService,RemoteService)self.DataService=DataService;self.RemoteService=RemoteService end
return ProgressionService

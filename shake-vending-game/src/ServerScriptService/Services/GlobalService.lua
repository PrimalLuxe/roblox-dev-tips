local Players = game:GetService("Players")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Rarities = require(ReplicatedStorage.Shared.RarityDefinitions)
local Items = require(ReplicatedStorage.Shared.ItemDefinitions)

local GlobalService = {}

local function hourKey(offset)
    return os.date("!%Y%m%d%H", os.time() + (offset or 0))
end

local function getMap(offset)
    return MemoryStoreService:GetSortedMap(Config.HourlyMapPrefix .. hourKey(offset))
end

function GlobalService:SubmitHourly(player,item)
    if (item.OneIn or 1) < 500 then return end
    local def=Items[item.BaseItemId]
    local payload={
        UserId=player.UserId,
        PlayerName=player.Name,
        DisplayName=player.DisplayName,
        BaseItemId=item.BaseItemId,
        ItemName=def and def.Name or item.BaseItemId,
        MutationId=item.MutationId,
        Rarity=item.Rarity,
        OneIn=item.OneIn,
        ObtainedAt=item.ObtainedAt,
        InstanceId=item.InstanceId,
    }
    task.spawn(function()
        local ok,err=pcall(function()
            getMap():SetAsync(item.InstanceId,payload,Config.HourlyBoardTTL,item.OneIn)
        end)
        if not ok then warn("[GlobalService] hourly submit",err) end
    end)
end

function GlobalService:PublishRare(player,item)
    if not Rarities.AtLeast(item.Rarity,Config.GlobalAnnouncementMinTier) then return end
    local def=Items[item.BaseItemId]
    local payload={
        UserId=player.UserId, PlayerName=player.Name, DisplayName=player.DisplayName,
        BaseItemId=item.BaseItemId, ItemName=def and def.Name or item.BaseItemId,
        MutationId=item.MutationId, Rarity=item.Rarity, OneIn=item.OneIn,
        ObtainedAt=item.ObtainedAt, InstanceId=item.InstanceId, ServerJobId=game.JobId,
    }
    self.RemoteService.Events.RareGlobal:FireAllClients(payload)
    task.spawn(function()
        local ok,err=pcall(function() MessagingService:PublishAsync(Config.RareDropTopic,payload) end)
        if not ok then warn("[GlobalService] publish",err) end
    end)
end

function GlobalService:OnCollected(player,item)
    self:SubmitHourly(player,item)
    self:PublishRare(player,item)
end

function GlobalService:GetBoard()
    local combined={}
    local function read(map)
        local ok,rows=pcall(function() return map:GetRangeAsync(Enum.SortDirection.Descending,Config.HourlyBoardSize) end)
        if ok then
            for _,row in ipairs(rows) do table.insert(combined,row.value) end
        end
    end
    read(getMap())
    if #combined < Config.HourlyBoardSize then read(getMap(-3600)) end
    table.sort(combined,function(a,b) return (a.OneIn or 0)>(b.OneIn or 0) end)
    while #combined>Config.HourlyBoardSize do table.remove(combined) end
    return combined
end

function GlobalService:Init(RemoteService)
    self.RemoteService=RemoteService
    local ok,connection=pcall(function()
        return MessagingService:SubscribeAsync(Config.RareDropTopic,function(message)
            if message.Data and message.Data.ServerJobId~=game.JobId then
                RemoteService.Events.RareGlobal:FireAllClients(message.Data)
            end
        end)
    end)
    if not ok then warn("[GlobalService] subscribe failed",connection) end
    RemoteService.Functions.GetHourlyBoard.OnServerInvoke=function(player)
        if not RemoteService:Allow(player,"hourly_board",0.5,2) then return {} end
        return self:GetBoard()
    end
end

return GlobalService

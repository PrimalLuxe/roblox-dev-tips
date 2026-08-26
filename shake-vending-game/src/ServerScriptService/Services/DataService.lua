local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Template = require(ReplicatedStorage.Shared.ProfileTemplate)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = {
    Profiles = {},
    LoadedAt = {},
    StudioJournals = {},
}

local usePersistent = (not RunService:IsStudio()) or Config.StudioUseDataStores

-- IMPORTANT: GetDataStore itself can error in an unpublished Studio place.
-- Do not even acquire persistent stores unless persistence is actually enabled.
local profileStore
local tradeStore
if usePersistent then
    profileStore = DataStoreService:GetDataStore(Config.ProfileStoreName)
    tradeStore = DataStoreService:GetDataStore(Config.TradeJournalStoreName)
end

local function keyFor(userId)
    return "u:" .. tostring(userId)
end

local function applyPlayerSettingsAttributes(player, profile)
    local settings = profile and profile.Settings or {}
    player:SetAttribute("ShakeVM_IntroSeen", settings.IntroSeen == true)
    player:SetAttribute("ShakeVM_ReducedEffects", settings.ReducedEffects == true)
    player:SetAttribute("ShakeVM_ReducedScreenShake", settings.ReducedScreenShake == true)
    player:SetAttribute("ShakeVM_SkipLongReveals", settings.SkipLongReveals == true)
    player:SetAttribute("ShakeVM_MusicEnabled", settings.MusicEnabled ~= false)
    player:SetAttribute("ShakeVM_SFXEnabled", settings.SFXEnabled ~= false)
    player:SetAttribute("ShakeVM_EffectQuality", settings.EffectQuality or "High")
end

local function cleanProfile(profile)
    profile.LastSeenAt = os.time()
    return profile
end

function DataService:GetProfile(playerOrUserId)
    local id = typeof(playerOrUserId) == "Instance" and playerOrUserId.UserId or playerOrUserId
    return self.Profiles[id]
end

function DataService:GetJoinAge(userId)
    local t = self.LoadedAt[userId]
    return t and (os.clock() - t) or 0
end

function DataService:LoadPlayer(player)
    if not usePersistent then
        local loaded = Util.DeepCopy(Template)
        loaded.CreatedAt = os.time(); loaded.LastSeenAt = os.time()
        self.Profiles[player.UserId] = loaded; self.LoadedAt[player.UserId] = os.clock()
        applyPlayerSettingsAttributes(player, loaded)
        return true
    end
    local loaded
    local ok, err = pcall(function()
        loaded = profileStore:UpdateAsync(keyFor(player.UserId), function(old)
            old = old or Util.DeepCopy(Template)
            Util.Reconcile(old, Template)
            if old.CreatedAt == 0 then old.CreatedAt = os.time() end
            old.LastSeenAt = os.time()
            old.Version = Config.DataVersion
            return old
        end)
    end)
    if not ok then
        warn("[DataService] load failed", player.UserId, err)
        player:Kick("Your data could not be loaded safely. Please rejoin.")
        return false
    end
    self.Profiles[player.UserId] = loaded
    self.LoadedAt[player.UserId] = os.clock()
    applyPlayerSettingsAttributes(player, loaded)
    task.spawn(function()
        self:ReconcilePendingTrades(player.UserId)
    end)
    return true
end

function DataService:SaveUserId(userId)
    if not usePersistent then return true end
    local profile = self.Profiles[userId]
    if not profile then return true end
    local snapshot = Util.DeepCopy(cleanProfile(profile))
    local ok, result = pcall(function()
        return profileStore:UpdateAsync(keyFor(userId), function()
            return snapshot
        end)
    end)
    if ok and result then
        self.Profiles[userId] = result
        return true
    end
    warn("[DataService] save failed", userId, result)
    return false
end

function DataService:SavePlayer(player)
    return self:SaveUserId(player.UserId)
end

function DataService:Mutate(playerOrUserId, callback)
    local profile = self:GetProfile(playerOrUserId)
    if not profile then return false, "ProfileNotLoaded" end
    local ok, result = pcall(callback, profile)
    if not ok then return false, result end
    return true, result
end

function DataService:GetPublicSummary(userId)
    local profile = self.Profiles[userId]
    if not profile then return nil end
    local rarest
    for _, item in ipairs(profile.Inventory) do
        if not rarest or (item.OneIn or 1) > (rarest.OneIn or 1) then rarest = item end
    end
    return {
        UserId = userId,
        CollectionCount = (function() local n=0 for _,v in pairs(profile.BaseCollection or {}) do if v then n+=1 end end return n end)(),
        CollectionScore = profile.CollectionScore,
        Rarest = rarest and {
            InstanceId = rarest.InstanceId,
            BaseItemId = rarest.BaseItemId,
            MutationId = rarest.MutationId,
            Rarity = rarest.Rarity,
            OneIn = rarest.OneIn,
        } or nil,
        Equipped = Util.DeepCopy(profile.Equipped),
        Showcase = Util.DeepCopy(profile.Showcase),
    }
end

function DataService:CreateTradeJournal(journal)
    if not usePersistent then self.StudioJournals[journal.Id]=Util.DeepCopy(journal); return true end
    local ok, err = pcall(function()
        tradeStore:SetAsync("t:" .. journal.Id, journal)
    end)
    return ok, err
end

function DataService:UpdateTradeJournal(id, mutate)
    if not usePersistent then local j=self.StudioJournals[id]; if not j then return false,"MissingJournal" end; self.StudioJournals[id]=mutate(j) or j; return true,self.StudioJournals[id] end
    local result
    local ok, err = pcall(function()
        result = tradeStore:UpdateAsync("t:" .. id, function(old)
            if not old then return nil end
            return mutate(old) or old
        end)
    end)
    return ok, result or err
end

function DataService:GetTradeJournal(id)
    if not usePersistent then return self.StudioJournals[id] end
    local result
    local ok, err = pcall(function() result = tradeStore:GetAsync("t:" .. id) end)
    return ok and result or nil, ok and nil or err
end

function DataService:AddPendingTrade(userId, txId)
    local profile = self.Profiles[userId]
    if profile then
        if not table.find(profile.PendingTrades, txId) and not profile.CompletedTrades[txId] then
            table.insert(profile.PendingTrades, txId)
        end
        return self:SaveUserId(userId)
    end
    if not usePersistent then return false, "MissingProfile" end
    local ok, err = pcall(function()
        profileStore:UpdateAsync(keyFor(userId), function(stored)
            stored = stored or Util.DeepCopy(Template)
            Util.Reconcile(stored, Template)
            if not table.find(stored.PendingTrades, txId) and not stored.CompletedTrades[txId] then
                table.insert(stored.PendingTrades, txId)
            end
            return stored
        end)
    end)
    return ok, err
end

local function removeByIds(inventory, ids)
    local wanted = {}
    for _, id in ipairs(ids) do wanted[id] = true end
    local removed = {}
    for i = #inventory, 1, -1 do
        local item = inventory[i]
        if wanted[item.InstanceId] then
            removed[item.InstanceId] = item
            table.remove(inventory, i)
        end
    end
    return removed
end

function DataService:ApplyTradeToUser(userId, txId, journal)
    local function apply(profile)
        Util.Reconcile(profile, Template)
        if profile.CompletedTrades[txId] then return profile, false end
        local isA = journal.A.UserId == userId
        local mine = isA and journal.A or journal.B
        local theirs = isA and journal.B or journal.A

        local removed = removeByIds(profile.Inventory, mine.ItemIds)
        for _, id in ipairs(mine.ItemIds) do
            if not removed[id] then return nil, "OfferedItemMissing" end
            Util.RemoveItemReferences(profile, id)
        end

        local existing = {}
        for _, it in ipairs(profile.Inventory) do existing[it.InstanceId] = true end
        for _, item in ipairs(theirs.Items) do
            if not existing[item.InstanceId] then
                local copy = Util.DeepCopy(item)
                local priorOwner = copy.CurrentOwner
                copy.CurrentOwner = userId
                copy.TradeCount = (copy.TradeCount or 0) + 1
                copy.TradeHistory = copy.TradeHistory or {}
                table.insert(copy.TradeHistory, {From=priorOwner, To=userId, At=os.time(), TradeId=txId})
                while #copy.TradeHistory > 10 do table.remove(copy.TradeHistory, 1) end
                table.insert(profile.Inventory, copy)
            end
        end
        profile.CompletedTrades[txId] = os.time()
        Util.ArrayRemoveValue(profile.PendingTrades, txId)
        profile.Statistics.TradesCompleted += 1
        return profile, true
    end

    local live = self.Profiles[userId]
    if live then
        if live.CompletedTrades[txId] then
            return self:SaveUserId(userId)
        end
        local copy = Util.DeepCopy(live)
        local updated, changedOrErr = apply(copy)
        if not updated then return false, changedOrErr end
        self.Profiles[userId] = updated
        local saved = self:SaveUserId(userId)
        return saved, saved and nil or "SaveFailed"
    end

    if not usePersistent then return false, "MissingProfile" end
    local result, transformError
    local ok, err = pcall(function()
        result = profileStore:UpdateAsync(keyFor(userId), function(profile)
            profile = profile or Util.DeepCopy(Template)
            local updated, why = apply(profile)
            if not updated then transformError = why; return nil end
            return updated
        end)
    end)
    if not ok then return false, err end
    if transformError then return false, transformError end
    return result ~= nil, result and nil or "UpdateRejected"
end

function DataService:ReconcilePendingTrades(userId)
    local profile = self.Profiles[userId]
    if not profile then return end
    local ids = Util.DeepCopy(profile.PendingTrades)
    for _, txId in ipairs(ids) do
        local journal = self:GetTradeJournal(txId)
        if journal and (journal.State == "CommitRequested" or journal.State == "Committed") then
            self:ApplyTradeToUser(userId, txId, journal)
        elseif journal and journal.State == "Aborted" then
            Util.ArrayRemoveValue(profile.PendingTrades, txId)
        end
    end
end

function DataService:ExecuteJournaledTrade(journal)
    if not self:CreateTradeJournal(journal) then return false, "JournalWriteFailed" end

    local aPending = self:AddPendingTrade(journal.A.UserId, journal.Id)
    local bPending = self:AddPendingTrade(journal.B.UserId, journal.Id)
    if not (aPending and bPending) then
        self:UpdateTradeJournal(journal.Id, function(j) j.State = "Aborted" return j end)
        return false, "PrepareProfilesFailed"
    end

    local marked = self:UpdateTradeJournal(journal.Id, function(j)
        j.State = "CommitRequested"
        j.CommitRequestedAt = os.time()
        return j
    end)
    if not marked then return false, "CommitMarkerFailed" end

    local aOk = self:ApplyTradeToUser(journal.A.UserId, journal.Id, journal)
    local bOk = self:ApplyTradeToUser(journal.B.UserId, journal.Id, journal)
    if aOk and bOk then
        self:UpdateTradeJournal(journal.Id, function(j) j.State = "Committed"; j.CommittedAt=os.time(); return j end)
        return true
    end

    return false, "TradePendingReconciliation"
end

function DataService:Init()
    Players.PlayerAdded:Connect(function(player) self:LoadPlayer(player) end)
    for _, p in ipairs(Players:GetPlayers()) do task.spawn(function() self:LoadPlayer(p) end) end

    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayer(player)
        self.Profiles[player.UserId] = nil
        self.LoadedAt[player.UserId] = nil
    end)

    task.spawn(function()
        while true do
            task.wait(Config.AutosaveSeconds)
            for userId in pairs(self.Profiles) do
                task.spawn(function() self:SaveUserId(userId) end)
            end
        end
    end)

    game:BindToClose(function()
        local threads = {}
        for userId in pairs(self.Profiles) do
            table.insert(threads, task.spawn(function() self:SaveUserId(userId) end))
        end
        task.wait(2)
    end)
end

return DataService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Shared.Util)
local Items = require(ReplicatedStorage.Shared.ItemDefinitions)
local Machines = require(ReplicatedStorage.Shared.MachineDefinitions)
local Rarities = require(ReplicatedStorage.Shared.RarityDefinitions)
local Worlds = require(ReplicatedStorage.Shared.WorldDefinitions)

local ProgressionService = {}

local function rankReward(rank)
    return {
        Coins = math.floor(180 * (rank ^ 1.85)),
        Shards = (rank % 2 == 0) and math.max(1, math.floor(rank / 2)) or 0,
    }
end

local function ensureProgression(profile)
    profile.Progression = profile.Progression or {}
    profile.Progression.Passport = profile.Progression.Passport or {CurrentWorld = "Downtown", Worlds = {}}
    profile.Progression.Passport.CurrentWorld = profile.Progression.Passport.CurrentWorld or "Downtown"
    profile.Progression.Passport.Worlds = profile.Progression.Passport.Worlds or {}
    profile.Progression.Passport.Worlds.Downtown = profile.Progression.Passport.Worlds.Downtown or {Stamped = false}
    profile.Progression.HuntList = profile.Progression.HuntList or {}
    profile.Progression.MachineShakes = profile.Progression.MachineShakes or {}
    profile.Progression.MachineMilestones = profile.Progression.MachineMilestones or {}
end

local function countDiscoveries(profile, worldId)
    local count = 0
    for baseItemId, discovered in pairs(profile.BaseCollection or {}) do
        if discovered then
            local def = Items[baseItemId]
            if def and Worlds.GetWorldForMachine(def.Machine) == worldId then
                count += 1
            end
        end
    end
    return count
end

local function highestRarityRank(profile, worldId)
    local best = 0
    for baseItemId, discovered in pairs(profile.BaseCollection or {}) do
        if discovered then
            local def = Items[baseItemId]
            if def and Worlds.GetWorldForMachine(def.Machine) == worldId then
                best = math.max(best, Rarities.Get(def.Rarity).Rank)
            end
        end
    end
    return best
end

local function machineRequirementState(profile, machineId)
    local def = Machines[machineId]
    if not def then return nil end
    local req = def.UnlockRequirements or {}
    local discovered = countDiscoveries(profile, def.WorldId or Worlds.GetWorldForMachine(machineId) or "Downtown")
    local totalShakes = (profile.Statistics and profile.Statistics.Shakes) or 0
    local state = {
        MachineId = machineId,
        DisplayName = def.DisplayName,
        Cost = def.UnlockCost or 0,
        EventOnly = def.EventOnly == true,
        AlreadyUnlocked = profile.UnlockedMachines and profile.UnlockedMachines[machineId] == true,
        Requirements = {},
        Met = true,
    }

    local function add(label, current, target, met)
        table.insert(state.Requirements, {Label = label, Current = current, Target = target, Met = met})
        if not met then state.Met = false end
    end

    if req.PreviousMachine then
        local met = profile.UnlockedMachines and profile.UnlockedMachines[req.PreviousMachine] == true
        add("Previous machine", met and 1 or 0, 1, met)
    end
    if req.Discoveries then add("Catalog discoveries", discovered, req.Discoveries, discovered >= req.Discoveries) end
    if req.TotalShakes then add("Total shakes", totalShakes, req.TotalShakes, totalShakes >= req.TotalShakes) end
    if req.HighestRarity then
        local targetRank = Rarities.Get(req.HighestRarity).Rank
        local currentRank = highestRarityRank(profile, def.WorldId or "Downtown")
        add(req.HighestRarity .. "+ discovery", currentRank, targetRank, currentRank >= targetRank)
    end
    for requiredMachine, requiredShakes in pairs(req.MachineShakes or {}) do
        local current = profile.Progression.MachineShakes[requiredMachine] or 0
        add(Machines[requiredMachine].DisplayName .. " mastery shakes", current, requiredShakes, current >= requiredShakes)
    end

    state.HasCoins = (profile.Coins or 0) >= state.Cost
    state.CanPurchase = state.Met and state.HasCoins and not state.EventOnly
    return state
end

function ProgressionService:EnsureGoals(profile)
    ensureProgression(profile)
    profile.Progression.Rank = profile.Progression.Rank or 1
    local rank = profile.Progression.Rank
    local goals = profile.Progression.RankGoals
    if type(goals) ~= "table" or not goals.ShakesTarget or not goals.ItemsTarget or not goals.SoldTarget then
        local stats = profile.Statistics
        profile.Progression.RankGoals = {
            ShakesStart = stats.Shakes or 0,
            ShakesTarget = (stats.Shakes or 0) + (8 + rank * 4),
            ItemsStart = stats.ItemsCollected or 0,
            ItemsTarget = (stats.ItemsCollected or 0) + (6 + rank * 3),
            SoldStart = stats.TotalSold or 0,
            SoldTarget = (stats.TotalSold or 0) + math.floor(140 * (rank ^ 1.45)),
        }
    end
    return profile.Progression.RankGoals
end

function ProgressionService:GetState(profile)
    local goals = self:EnsureGoals(profile)
    local stats = profile.Statistics
    local completed = {
        Shakes = (stats.Shakes or 0) >= goals.ShakesTarget,
        Items = (stats.ItemsCollected or 0) >= goals.ItemsTarget,
        Sold = (stats.TotalSold or 0) >= goals.SoldTarget,
    }
    local n = (completed.Shakes and 1 or 0) + (completed.Items and 1 or 0) + (completed.Sold and 1 or 0)
    return {
        Rank = profile.Progression.Rank,
        Goals = Util.DeepCopy(goals),
        Completed = completed,
        CompletedCount = n,
        Reward = rankReward(profile.Progression.Rank),
    }
end

function ProgressionService:GetMachineUnlockState(profile, machineId)
    ensureProgression(profile)
    return machineRequirementState(profile, machineId)
end

function ProgressionService:GetMachineUnlockStates(profile)
    ensureProgression(profile)
    local out = {}
    for _, machineId in ipairs(Machines.Order) do
        out[machineId] = machineRequirementState(profile, machineId)
    end
    return out
end

function ProgressionService:CanUnlockMachine(profile, machineId)
    local state = self:GetMachineUnlockState(profile, machineId)
    if not state then return false, "Unknown machine" end
    if state.AlreadyUnlocked and not state.EventOnly then return true end
    if not state.Met then
        local missing = {}
        for _, req in ipairs(state.Requirements) do
            if not req.Met then table.insert(missing, req.Label .. " " .. tostring(req.Current) .. "/" .. tostring(req.Target)) end
        end
        return false, table.concat(missing, " • ")
    end
    if not state.HasCoins then return false, "Need $" .. Util.FormatInteger(state.Cost) end
    return true
end

local function passportWorldState(profile, worldId)
    ensureProgression(profile)
    local world = Worlds.Get(worldId)
    if not world then return nil end
    local progress = profile.Progression.Passport.Worlds[worldId] or {Stamped = false}
    local requirements = world.StampRequirements or {}
    local discovered = countDiscoveries(profile, worldId)
    local state = {
        Id = worldId,
        DisplayName = world.DisplayName,
        Subtitle = world.Subtitle,
        Released = world.Released == true,
        CatalogTotal = world.CatalogTotal or 0,
        Discovered = discovered,
        Stamped = progress.Stamped == true,
        CanStamp = world.Released == true,
        Requirements = {},
        Reward = Util.DeepCopy(world.StampReward or {}),
        NextWorld = world.NextWorld,
    }
    local function add(label, current, target, met)
        table.insert(state.Requirements, {Label = label, Current = current, Target = target, Met = met})
        if not met then state.CanStamp = false end
    end
    if requirements.Discoveries then add("Catalog discoveries", discovered, requirements.Discoveries, discovered >= requirements.Discoveries) end
    if requirements.TotalShakes then
        local shakes = profile.Statistics.Shakes or 0
        add("Total shakes", shakes, requirements.TotalShakes, shakes >= requirements.TotalShakes)
    end
    if requirements.HighestRarity then
        local rank = highestRarityRank(profile, worldId)
        local target = Rarities.Get(requirements.HighestRarity).Rank
        add(requirements.HighestRarity .. "+ discovery", rank, target, rank >= target)
    end
    for machineId, target in pairs(requirements.MachineShakes or {}) do
        local current = profile.Progression.MachineShakes[machineId] or 0
        add(Machines[machineId].DisplayName .. " shakes", current, target, current >= target)
    end
    if state.Stamped then state.CanStamp = false end
    return state
end

function ProgressionService:GetPassportState(profile)
    ensureProgression(profile)
    local worlds = {}
    for _, worldId in ipairs(Worlds.Order) do
        table.insert(worlds, passportWorldState(profile, worldId))
    end
    local hunts = {}
    for _, itemId in ipairs(profile.Progression.HuntList) do
        local def = Items[itemId]
        if def then
            table.insert(hunts, {
                BaseItemId = itemId,
                Name = def.Name,
                MachineId = def.Machine,
                MachineName = Machines[def.Machine] and Machines[def.Machine].DisplayName or def.Machine,
                Rarity = def.Rarity,
                OneIn = def.BaseOneIn,
            })
        end
    end
    return {
        CurrentWorld = profile.Progression.Passport.CurrentWorld,
        Worlds = worlds,
        Hunts = hunts,
        HuntSlots = 3,
    }
end

function ProgressionService:SetHunt(player, itemId, shouldTrack)
    if type(itemId) ~= "string" then return false, "Invalid item" end
    local def = Items[itemId]
    local profile = self.DataService:GetProfile(player)
    if not def or not profile then return false, "Item not found" end
    ensureProgression(profile)
    local hunts = profile.Progression.HuntList
    local index = table.find(hunts, itemId)

    if shouldTrack == false or index then
        if index then table.remove(hunts, index) end
        return true, index and ("Stopped tracking " .. def.Name) or "Not tracked"
    end
    if profile.BaseCollection and profile.BaseCollection[itemId] then return false, "Already discovered" end
    if #hunts >= 3 then return false, "Hunt List is full (3/3)" end
    table.insert(hunts, itemId)
    return true, "Tracking " .. def.Name .. " • " .. Machines[def.Machine].DisplayName
end

function ProgressionService:OnDiscovery(player, itemId)
    local profile = self.DataService:GetProfile(player)
    if not profile then return end
    ensureProgression(profile)
    local index = table.find(profile.Progression.HuntList, itemId)
    if index then
        local def = Items[itemId]
        table.remove(profile.Progression.HuntList, index)
        self.RemoteService.Events.Toast:FireClient(player, {Text = "HUNT COMPLETE — " .. (def and def.Name or itemId), Kind = "New"})
    end
end

function ProgressionService:TryStampWorld(player, worldId)
    if type(worldId) ~= "string" then return false, "Invalid world" end
    local profile = self.DataService:GetProfile(player)
    if not profile then return false, "Profile not loaded" end
    ensureProgression(profile)
    local state = passportWorldState(profile, worldId)
    if not state or not state.Released then return false, "That world is not released yet" end
    if state.Stamped then return false, "Passport already stamped" end
    if not state.CanStamp then return false, "Finish the passport requirements first" end

    profile.Progression.Passport.Worlds[worldId] = profile.Progression.Passport.Worlds[worldId] or {}
    profile.Progression.Passport.Worlds[worldId].Stamped = true
    local reward = Worlds[worldId].StampReward or {}
    profile.Coins += reward.Coins or 0
    profile.StyleShards += reward.Shards or 0
    if reward.Title then
        profile.SetRewards["Passport_" .. worldId] = {Id = "Passport_" .. worldId, Label = reward.Title, Slot = "Title"}
    end
    return true, "PASSPORT STAMPED — " .. Worlds[worldId].DisplayName
end

function ProgressionService:Check(player)
    local profile = self.DataService:GetProfile(player)
    if not profile then return end
    local state = self:GetState(profile)
    if state.CompletedCount < 3 then return state end

    local oldRank = state.Rank
    local reward = state.Reward
    profile.Coins += reward.Coins or 0
    profile.StyleShards += reward.Shards or 0
    profile.Progression.Rank = oldRank + 1
    profile.Progression.RankGoals = nil
    self:EnsureGoals(profile)

    self.RemoteService.Events.Toast:FireClient(player, {
        Text = string.format("RANK %d COMPLETE! +$%s%s", oldRank, Util.FormatInteger(reward.Coins), reward.Shards > 0 and (" +" .. reward.Shards .. " shards") or ""),
        Kind = "New",
    })
    return self:GetState(profile)
end

function ProgressionService:Init(DataService, RemoteService)
    self.DataService = DataService
    self.RemoteService = RemoteService
end

return ProgressionService

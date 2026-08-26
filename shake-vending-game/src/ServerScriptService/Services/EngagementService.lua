local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local EngagementService = {
    Sessions = {},
    Combos = {},
}

local function utcDayKey()
    return os.date("!%Y-%j", os.time())
end

local function ensureDaily(profile)
    profile.Progression = profile.Progression or {}
    profile.Progression.DailyRewards = profile.Progression.DailyRewards or {DayKey="", Playtime=0, Claimed={}}
    local daily = profile.Progression.DailyRewards
    daily.Claimed = daily.Claimed or {}
    if daily.DayKey ~= utcDayKey() then
        daily.DayKey = utcDayKey()
        daily.Playtime = 0
        daily.Claimed = {}
    end
    return daily
end

function EngagementService:Tick(player)
    local profile = self.DataService:GetProfile(player)
    if not profile then return end
    local session = self.Sessions[player.UserId]
    if not session then
        session = {Last=os.clock(), Remainder=0}
        self.Sessions[player.UserId] = session
    end
    local now = os.clock()
    local elapsed = math.max(0, math.min(30, now - session.Last)) + (session.Remainder or 0)
    session.Last = now
    local whole = math.floor(elapsed)
    session.Remainder = elapsed - whole
    if whole > 0 then
        local daily = ensureDaily(profile)
        daily.Playtime = math.max(0, (daily.Playtime or 0) + whole)
    else
        ensureDaily(profile)
    end
end

function EngagementService:RegisterShake(player)
    self:Tick(player)
    local now = os.clock()
    local combo = self.Combos[player.UserId]
    local window = Config.ShakeCombo.WindowSeconds
    if not combo or now - combo.Last > window then
        combo = {Count=1, Last=now}
    else
        combo.Count = math.min(Config.ShakeCombo.MaxCount, combo.Count + 1)
        combo.Last = now
    end
    self.Combos[player.UserId] = combo
    local progress = math.clamp((combo.Count - 1) / math.max(1, Config.ShakeCombo.MaxCount - 1), 0, 1)
    return {
        Count = combo.Count,
        Max = Config.ShakeCombo.MaxCount,
        Remaining = window,
        LuckMultiplier = 1 + progress * Config.ShakeCombo.MaxLuckBonus,
        MutationMultiplier = 1 + progress * Config.ShakeCombo.MaxMutationBonus,
    }
end

function EngagementService:GetState(player)
    self:Tick(player)
    local profile = self.DataService:GetProfile(player)
    if not profile then return nil end
    local daily = ensureDaily(profile)
    local now = os.clock()
    local combo = self.Combos[player.UserId]
    local comboCount, comboRemaining = 0, 0
    if combo then
        comboRemaining = math.max(0, Config.ShakeCombo.WindowSeconds - (now - combo.Last))
        if comboRemaining > 0 then comboCount = combo.Count else self.Combos[player.UserId] = nil end
    end
    local comboProgress = math.clamp((comboCount - 1) / math.max(1, Config.ShakeCombo.MaxCount - 1), 0, 1)
    local gifts = {}
    local readyCount = 0
    for index, reward in ipairs(Config.SessionGifts) do
        local claimed = daily.Claimed[tostring(index)] == true
        local ready = (daily.Playtime or 0) >= reward.Seconds and not claimed
        if ready then readyCount += 1 end
        table.insert(gifts, {
            Index=index,
            Seconds=reward.Seconds,
            Coins=reward.Coins or 0,
            Shards=reward.Shards or 0,
            Claimed=claimed,
            Ready=ready,
            Remaining=math.max(0, reward.Seconds-(daily.Playtime or 0)),
        })
    end
    return {
        Combo={
            Count=comboCount,
            Max=Config.ShakeCombo.MaxCount,
            Remaining=comboRemaining,
            LuckMultiplier=1+comboProgress*Config.ShakeCombo.MaxLuckBonus,
            MutationMultiplier=1+comboProgress*Config.ShakeCombo.MaxMutationBonus,
        },
        Daily={DayKey=daily.DayKey, Playtime=daily.Playtime or 0, Gifts=gifts, ReadyCount=readyCount},
    }
end

function EngagementService:PushState(player)
    local state = self:GetState(player)
    if state and player.Parent then
        self.RemoteService.Events.ProgressionAction:FireClient(player, {Type="EngagementState", State=state})
    end
end

function EngagementService:ClaimGift(player, index)
    if type(index) ~= "number" then return false, "Invalid reward" end
    self:Tick(player)
    local profile = self.DataService:GetProfile(player)
    local reward = Config.SessionGifts[index]
    if not profile or not reward then return false, "Invalid reward" end
    local daily = ensureDaily(profile)
    local key = tostring(index)
    if daily.Claimed[key] then return false, "Already claimed" end
    if (daily.Playtime or 0) < reward.Seconds then return false, "Reward is not ready yet" end
    daily.Claimed[key] = true
    profile.Coins += reward.Coins or 0
    profile.StyleShards += reward.Shards or 0
    return true, reward
end

function EngagementService:Init(RemoteService, DataService)
    self.RemoteService = RemoteService
    self.DataService = DataService
    for _, player in ipairs(Players:GetPlayers()) do self.Sessions[player.UserId] = {Last=os.clock(), Remainder=0} end
    Players.PlayerAdded:Connect(function(player) self.Sessions[player.UserId] = {Last=os.clock(), Remainder=0} end)
    Players.PlayerRemoving:Connect(function(player)
        self:Tick(player)
        self.Sessions[player.UserId] = nil
        self.Combos[player.UserId] = nil
    end)
    RemoteService.Events.ProgressionAction.OnServerEvent:Connect(function(player, action, value)
        if not RemoteService:Allow(player,"progression",5,8) then return end
        if action == "claim_gift" then
            local ok, result = self:ClaimGift(player, tonumber(value))
            if ok then
                RemoteService.Events.Toast:FireClient(player, {Text=string.format("PLAYTIME GIFT! +$%d%s", result.Coins or 0, (result.Shards or 0)>0 and (" +"..result.Shards.." shards") or ""), Kind="New"})
            else
                RemoteService.Events.Toast:FireClient(player, {Text=tostring(result), Kind="Warn"})
            end
            self:PushState(player)
        elseif action == "request_engagement" then
            self:PushState(player)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(5)
            for _, player in ipairs(Players:GetPlayers()) do
                self:Tick(player)
            end
        end
    end)
end

return EngagementService

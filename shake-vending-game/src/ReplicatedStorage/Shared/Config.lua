local Config = {
    DataVersion = 3,
    StudioUseDataStores = false,

    -- Visual pipeline: the normal game uses sanitized FREE Creator Store assets.
    -- In Studio enable: Game Settings > Security > Allow Loading Third Party Assets.
    RequireCreatorStoreAssets = true,
    AssetLoadTimeoutSeconds = 45,
    ClientLoadTimeoutSeconds = 28,
    ClientPreloadBudget = 96,

    ProfileStoreName = "ShakeVM_Player_v2",
    TradeJournalStoreName = "ShakeVM_TradeJournal_v2",
    RareDropTopic = "ShakeVM_RareDrop_v2",
    HourlyMapPrefix = "ShakeVM_Hourly_v2_",

    StartingCoins = 125,
    ShakeCooldown = 0.78,
    ShakeDistance = 14,
    CollectDelay = 0.42,
    PendingDropLifetime = 30,
    AutosaveSeconds = 60,

    InventoryBaseCapacity = 100,
    ShowcaseSlots = 6,
    OutfitSlots = 3,

    -- Retention pacing. This is intentionally visible to the player rather than hidden/fake.
    LuckyMeterThreshold = 8,
    BeginnerLuckShakes = 30,
    BeginnerLuckMultiplier = 2.25,
    DiscoveryBonusFlat = 30,
    DiscoveryBonusMultiplier = 2.5,

    -- Truthful active-play rewards: fast shaking builds an Overdrive combo instead of fake near-misses.
    ShakeCombo = {
        WindowSeconds = 4.25,
        MaxCount = 30,
        MaxLuckBonus = 0.30,
        MaxMutationBonus = 0.15,
    },
    SessionGifts = {
        {Seconds=120, Coins=300, Shards=0},
        {Seconds=300, Coins=1_000, Shards=1},
        {Seconds=600, Coins=4_000, Shards=3},
        {Seconds=1200, Coins=15_000, Shards=7},
        {Seconds=1800, Coins=50_000, Shards=15},
    },

    FullVfxDistance = 55,
    ReducedVfxDistance = 135,
    MaxLocalParticles = 240,

    GlobalAnnouncementMinTier = "Secret",
    HourlyBoardSize = 10,
    HourlyBoardTTL = 7200,

    EventSlotSeconds = 300,

    UpgradeRules = {
        ShakePower = {BaseCost=30, Growth=1.43, Max=30},
        Luck = {BaseCost=75, Growth=1.55, Max=25},
        MutationLuck = {BaseCost=120, Growth=1.60, Max=20},
        Capacity = {BaseCost=80, Growth=1.48, Max=20},
        CollectionBonus = {BaseCost=200, Growth=1.62, Max=15},
    },

    CollectionMilestones = {
        {Count=5, Coins=250, Shards=0, Label="Starter Collector"},
        {Count=10, Coins=650, Shards=2, Label="Shelf Filler"},
        {Count=20, Coins=2_500, Shards=5, Label="Collector"},
        {Count=30, Coins=8_000, Shards=8, Label="Rare Hunter"},
        {Count=40, Coins=25_000, Shards=12, Label="Catalog Pro"},
        {Count=50, Coins=100_000, Shards=25, Label="Catalog Master"},
        {Count=60, Coins=500_000, Shards=60, Label="Vending Legend"},
    },

    MachineMasteryMilestones = {
        {Shakes=10, Coins=125, Shards=0},
        {Shakes=25, Coins=350, Shards=1},
        {Shakes=50, Coins=900, Shards=2},
        {Shakes=100, Coins=3_000, Shards=5},
        {Shakes=250, Coins=12_000, Shards=12},
    },

    Trading = {
        Enabled = true,
        MinShakes = 25,
        JoinCooldownSeconds = 45,
        RequestTimeoutSeconds = 20,
        FinalConfirmSeconds = 3,
        MaxOfferItems = 12,
        NonTradeableTiers = { Global = true },
    },

    Monetization = {
        Enabled = false,
        VIPGamePassId = 0,
        ExtraLoadoutGamePassId = 0,
        ExtraShowcaseGamePassId = 0,
        LuckDeveloperProductId = 0,
    },

    SoundIds = {
        Hum = "rbxassetid://171186876",
        Rattle = "rbxassetid://9116540638",
        Clunk = "rbxassetid://9116710986",
        Rare = "rbxassetid://9113155656",
    },
}

return Config

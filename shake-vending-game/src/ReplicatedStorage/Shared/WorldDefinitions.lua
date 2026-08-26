local Worlds = {
    Downtown = {
        Id = "Downtown",
        DisplayName = "Downtown",
        Subtitle = "The original vending district",
        Order = 1,
        Released = true,
        Machines = {"CornerStore","SugarRush","Energy","ToyCapsule","Luxury","Unknown"},
        CatalogTotal = 60,
        StampRequirements = {
            Discoveries = 38,
            TotalShakes = 180,
            MachineShakes = {
                CornerStore = 50,
                SugarRush = 25,
                Energy = 25,
            },
            HighestRarity = "Legendary",
        },
        StampReward = {
            Coins = 250_000,
            Shards = 25,
            Title = "DOWNTOWN COMPLETIONIST",
        },
        Accent = Color3.fromRGB(88, 190, 255),
        NextWorld = "SunsetBoardwalk",
    },

    -- These definitions intentionally exist before their content does. They let the passport,
    -- travel and progression code scale to real worlds without pretending placeholder machines
    -- are finished gameplay. Released=false means players can see the roadmap but cannot enter.
    SunsetBoardwalk = {
        Id = "SunsetBoardwalk",
        DisplayName = "Sunset Boardwalk",
        Subtitle = "Boardwalk snacks, prizes and strange seaside machines",
        Order = 2,
        Released = false,
        Machines = {},
        CatalogTotal = 0,
        Accent = Color3.fromRGB(255, 166, 92),
        NextWorld = "MetroArcade",
    },
    MetroArcade = {
        Id = "MetroArcade",
        DisplayName = "Metro Arcade",
        Subtitle = "Dense arcade blocks, capsule rows and night machines",
        Order = 3,
        Released = false,
        Machines = {},
        CatalogTotal = 0,
        Accent = Color3.fromRGB(175, 117, 255),
        NextWorld = "Skyport",
    },
    Skyport = {
        Id = "Skyport",
        DisplayName = "Skyport",
        Subtitle = "Travel machines, luggage curios and duty-free rarities",
        Order = 4,
        Released = false,
        Machines = {},
        CatalogTotal = 0,
        Accent = Color3.fromRGB(124, 220, 198),
    },
}

Worlds.Order = {"Downtown", "SunsetBoardwalk", "MetroArcade", "Skyport"}

local machineToWorld = {}
for worldId, world in pairs(Worlds) do
    if type(world) == "table" and world.Id then
        for _, machineId in ipairs(world.Machines or {}) do
            machineToWorld[machineId] = worldId
        end
    end
end

function Worlds.GetWorldForMachine(machineId)
    return machineToWorld[machineId]
end

function Worlds.Get(worldId)
    return Worlds[worldId]
end

return Worlds

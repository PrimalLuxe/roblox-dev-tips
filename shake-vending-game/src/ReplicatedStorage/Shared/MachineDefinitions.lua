local Machines = {
    CornerStore = {
        DisplayName = "Corner Store",
        WorldId = "Downtown",
        Color = Color3.fromRGB(67, 153, 235),
        Accent = Color3.fromRGB(173, 232, 255),
        UnlockCost = 0,
        AssetVariant = "VendingMachineModern",
        UnlockRequirements = {},
    },
    SugarRush = {
        DisplayName = "Sugar Rush",
        WorldId = "Downtown",
        Color = Color3.fromRGB(255, 109, 176),
        Accent = Color3.fromRGB(255, 226, 95),
        UnlockCost = 3_000,
        AssetVariant = "VendingMachineDetailed",
        UnlockRequirements = {
            PreviousMachine = "CornerStore",
            Discoveries = 5,
            TotalShakes = 12,
        },
    },
    Energy = {
        DisplayName = "Energy",
        WorldId = "Downtown",
        Color = Color3.fromRGB(46, 53, 61),
        Accent = Color3.fromRGB(85, 255, 124),
        UnlockCost = 10_000,
        AssetVariant = "VendingMachineModern",
        UnlockRequirements = {
            PreviousMachine = "SugarRush",
            Discoveries = 10,
            TotalShakes = 30,
        },
    },
    ToyCapsule = {
        DisplayName = "Toy Capsule",
        WorldId = "Downtown",
        Color = Color3.fromRGB(117, 82, 198),
        Accent = Color3.fromRGB(135, 218, 255),
        UnlockCost = 250_000,
        AssetVariant = "VendingMachineStudded",
        UnlockRequirements = {
            PreviousMachine = "Energy",
            Discoveries = 14,
            TotalShakes = 65,
            MachineShakes = {Energy = 20},
        },
    },
    Luxury = {
        DisplayName = "Luxury",
        WorldId = "Downtown",
        Color = Color3.fromRGB(31, 31, 36),
        Accent = Color3.fromRGB(255, 207, 76),
        UnlockCost = 2_500_000,
        AssetVariant = "VendingMachineDetailed",
        UnlockRequirements = {
            PreviousMachine = "ToyCapsule",
            Discoveries = 20,
            TotalShakes = 140,
            HighestRarity = "Epic",
            MachineShakes = {ToyCapsule = 30},
        },
    },
    Unknown = {
        DisplayName = "???",
        WorldId = "Downtown",
        Color = Color3.fromRGB(15, 13, 24),
        Accent = Color3.fromRGB(159, 80, 255),
        UnlockCost = 0,
        AssetVariant = "VendingMachineStudded",
        EventOnly = true,
        UnlockRequirements = {
            PreviousMachine = "Luxury",
            Discoveries = 30,
            TotalShakes = 200,
            HighestRarity = "Legendary",
        },
    },
}

Machines.Order = {"CornerStore","SugarRush","Energy","ToyCapsule","Luxury","Unknown"}
return Machines

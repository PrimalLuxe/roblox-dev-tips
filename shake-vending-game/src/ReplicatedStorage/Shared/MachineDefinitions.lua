local Machines = {
    CornerStore = {
        DisplayName = "Corner Store",
        Color = Color3.fromRGB(67, 153, 235),
        Accent = Color3.fromRGB(173, 232, 255),
        UnlockCost = 0,
        AssetVariant = "VendingMachineModern",
    },
    SugarRush = {
        DisplayName = "Sugar Rush",
        Color = Color3.fromRGB(255, 109, 176),
        Accent = Color3.fromRGB(255, 226, 95),
        UnlockCost = 3_000,
        AssetVariant = "VendingMachineDetailed",
    },
    Energy = {
        DisplayName = "Energy",
        Color = Color3.fromRGB(46, 53, 61),
        Accent = Color3.fromRGB(85, 255, 124),
        UnlockCost = 10_000,
        AssetVariant = "VendingMachineModern",
    },
    ToyCapsule = {
        DisplayName = "Toy Capsule",
        Color = Color3.fromRGB(117, 82, 198),
        Accent = Color3.fromRGB(135, 218, 255),
        UnlockCost = 250_000,
        AssetVariant = "VendingMachineStudded",
    },
    Luxury = {
        DisplayName = "Luxury",
        Color = Color3.fromRGB(31, 31, 36),
        Accent = Color3.fromRGB(255, 207, 76),
        UnlockCost = 2_500_000,
        AssetVariant = "VendingMachineDetailed",
    },
    Unknown = {
        DisplayName = "???",
        Color = Color3.fromRGB(15, 13, 24),
        Accent = Color3.fromRGB(159, 80, 255),
        UnlockCost = 25_000_000,
        AssetVariant = "VendingMachineStudded",
    },
}

Machines.Order = {"CornerStore","SugarRush","Energy","ToyCapsule","Luxury","Unknown"}
return Machines

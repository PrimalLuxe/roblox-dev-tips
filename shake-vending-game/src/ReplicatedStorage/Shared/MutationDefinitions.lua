-- Weight is relative. One mutation is selected after the base item roll.
local Mutations = {
    None = { Weight = 900000, Multiplier = 1, Color = nil, Material = nil, Effect = "None" },
    Shiny = { Weight = 45000, Multiplier = 1.5, Color = Color3.fromRGB(245,245,255), Material = Enum.Material.SmoothPlastic, Effect = "Sparkle" },
    Gold = { Weight = 25000, Multiplier = 3, Color = Color3.fromRGB(255,193,58), Material = Enum.Material.Metal, Effect = "Gold" },
    Frozen = { Weight = 12000, Multiplier = 5, Color = Color3.fromRGB(153,225,255), Material = Enum.Material.Glass, Effect = "Frozen" },
    Flaming = { Weight = 8000, Multiplier = 8, Color = Color3.fromRGB(255,98,45), Material = Enum.Material.Neon, Effect = "Flaming" },
    Toxic = { Weight = 5000, Multiplier = 12, Color = Color3.fromRGB(86,255,82), Material = Enum.Material.Neon, Effect = "Toxic" },
    Crystal = { Weight = 2800, Multiplier = 20, Color = Color3.fromRGB(141,238,255), Material = Enum.Material.Glass, Effect = "Crystal" },
    Rainbow = { Weight = 1000, Multiplier = 45, Color = Color3.fromRGB(255,255,255), Material = Enum.Material.Neon, Effect = "Rainbow" },
    Glitched = { Weight = 500, Multiplier = 90, Color = Color3.fromRGB(132,75,255), Material = Enum.Material.Neon, Effect = "Glitch" },
    Shadow = { Weight = 220, Multiplier = 175, Color = Color3.fromRGB(31,31,42), Material = Enum.Material.SmoothPlastic, Effect = "Shadow" },
    Cosmic = { Weight = 80, Multiplier = 450, Color = Color3.fromRGB(89,66,200), Material = Enum.Material.Neon, Effect = "Cosmic" },
    Heavenly = { Weight = 24, Multiplier = 1500, Color = Color3.fromRGB(255,247,193), Material = Enum.Material.Neon, Effect = "Heavenly" },
    Void = { Weight = 5, Multiplier = 8000, Color = Color3.fromRGB(34,7,66), Material = Enum.Material.Neon, Effect = "Void" },
}

local total = 0
for _, def in pairs(Mutations) do total += def.Weight end
Mutations.TotalWeight = total
return Mutations

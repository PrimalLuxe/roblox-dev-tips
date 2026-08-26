local Rarities = {
    Common = { Rank = 1, Color = Color3.fromRGB(190, 194, 202), Rays = 0, ParticleRate = 0, Reveal = 0.45, Scope = "None" },
    Uncommon = { Rank = 2, Color = Color3.fromRGB(91, 214, 122), Rays = 0, ParticleRate = 2, Reveal = 0.48, Scope = "None" },
    Rare = { Rank = 3, Color = Color3.fromRGB(74, 146, 255), Rays = 4, ParticleRate = 4, Reveal = 0.55, Scope = "None" },
    Epic = { Rank = 4, Color = Color3.fromRGB(182, 95, 255), Rays = 5, ParticleRate = 6, Reveal = 0.65, Scope = "None" },
    Legendary = { Rank = 5, Color = Color3.fromRGB(255, 184, 63), Rays = 6, ParticleRate = 8, Reveal = 0.85, Scope = "Local" },
    Mythic = { Rank = 6, Color = Color3.fromRGB(255, 74, 114), Rays = 8, ParticleRate = 10, Reveal = 1.05, Scope = "Nearby" },
    Divine = { Rank = 7, Color = Color3.fromRGB(255, 244, 160), Rays = 10, ParticleRate = 12, Reveal = 1.3, Scope = "Server" },
    Secret = { Rank = 8, Color = Color3.fromRGB(116, 255, 231), Rays = 12, ParticleRate = 15, Reveal = 1.9, Scope = "Server" },
    Global = { Rank = 9, Color = Color3.fromRGB(255, 93, 245), Rays = 16, ParticleRate = 20, Reveal = 2.35, Scope = "Global" },
}
function Rarities.Get(name) return Rarities[name] or Rarities.Common end
function Rarities.AtLeast(name, minimum) return Rarities.Get(name).Rank >= Rarities.Get(minimum).Rank end
local oddsThresholds={{Max=3,Name="Common"},{Max=10,Name="Uncommon"},{Max=50,Name="Rare"},{Max=250,Name="Epic"},{Max=1_000,Name="Legendary"},{Max=10_000,Name="Mythic"},{Max=100_000,Name="Divine"},{Max=2_000_000,Name="Secret"},{Max=math.huge,Name="Global"}}
function Rarities.FromOdds(oneIn) oneIn=math.max(1,tonumber(oneIn) or 1);for _,entry in ipairs(oddsThresholds) do if oneIn<=entry.Max then return entry.Name end end;return "Global" end
function Rarities.Max(a,b) return Rarities.Get(a).Rank>=Rarities.Get(b).Rank and a or b end
function Rarities.Effective(baseRarity,oneIn) return Rarities.Max(baseRarity or "Common",Rarities.FromOdds(oneIn)) end
return Rarities

local VFXManifest = {
    Quality = {
        Low={ParticleScale=0.20,RaysScale=0.35,Orbit=false,Lights=false,Secondary=false},
        Medium={ParticleScale=0.55,RaysScale=0.70,Orbit=true,Lights=true,Secondary=true},
        High={ParticleScale=1.00,RaysScale=1.00,Orbit=true,Lights=true,Secondary=true},
    },
    TierBudget = {
        Common={Particles=0,Rays=0,WorldDistance=0,Pulse=false},
        Uncommon={Particles=2,Rays=0,WorldDistance=0,Pulse=false},
        Rare={Particles=6,Rays=4,WorldDistance=45,Pulse=false},
        Epic={Particles=9,Rays=5,WorldDistance=55,Pulse=true},
        Legendary={Particles=13,Rays=6,WorldDistance=75,Pulse=true},
        Mythic={Particles=18,Rays=8,WorldDistance=95,Pulse=true},
        Divine={Particles=24,Rays=10,WorldDistance=120,Pulse=true},
        Secret={Particles=30,Rays=12,WorldDistance=150,Pulse=true},
        Global={Particles=36,Rays=16,WorldDistance=180,Pulse=true},
    },
    MutationFamilies = {
        None={Family="Rarity",Secondary="None",Light=0},
        Shiny={Family="Sparkle",Secondary="Glint",Light=0.35},
        Gold={Family="CoinBurst",Secondary="WarmGlow",Light=0.55},
        Frozen={Family="SnowMist",Secondary="IceLight",Light=0.45},
        Flaming={Family="EmberFlame",Secondary="HeatGlow",Light=0.75},
        Toxic={Family="ToxicBubbles",Secondary="Fume",Light=0.65},
        Crystal={Family="PrismShards",Secondary="GlassGlint",Light=0.60},
        Rainbow={Family="Spectrum",Secondary="Orbit",Light=0.70},
        Glitched={Family="GlitchBits",Secondary="Static",Light=0.70},
        Shadow={Family="ShadowSmoke",Secondary="DarkPulse",Light=0.10},
        Cosmic={Family="StarOrbit",Secondary="Nebula",Light=0.75},
        Heavenly={Family="Halo",Secondary="Ascend",Light=0.90},
        Void={Family="VoidCollapse",Secondary="DarkOrbit",Light=0.35},
    },
}

function VFXManifest.GetQuality(name)
    return VFXManifest.Quality[name] or VFXManifest.Quality.High
end

function VFXManifest.GetTier(name)
    return VFXManifest.TierBudget[name] or VFXManifest.TierBudget.Common
end

function VFXManifest.GetMutation(name)
    return VFXManifest.MutationFamilies[name] or VFXManifest.MutationFamilies.None
end

return VFXManifest

local VFXManifest = {
    Quality = {
        Low={ParticleScale=0.25, RaysScale=0.45, Orbit=false, Lights=false},
        Medium={ParticleScale=0.55, RaysScale=0.72, Orbit=true, Lights=true},
        High={ParticleScale=1.0, RaysScale=1.0, Orbit=true, Lights=true},
    },
    TierBudget = {
        Common={Particles=0,Rays=0,WorldDistance=0},
        Uncommon={Particles=3,Rays=0,WorldDistance=0},
        Rare={Particles=6,Rays=4,WorldDistance=45},
        Epic={Particles=9,Rays=5,WorldDistance=55},
        Legendary={Particles=13,Rays=6,WorldDistance=75},
        Mythic={Particles=18,Rays=8,WorldDistance=95},
        Divine={Particles=24,Rays=10,WorldDistance=120},
        Secret={Particles=30,Rays=12,WorldDistance=150},
        Global={Particles=36,Rays=16,WorldDistance=180},
    },
}

function VFXManifest.GetQuality(name)
    return VFXManifest.Quality[name] or VFXManifest.Quality.High
end

function VFXManifest.GetTier(name)
    return VFXManifest.TierBudget[name] or VFXManifest.TierBudget.Common
end

return VFXManifest

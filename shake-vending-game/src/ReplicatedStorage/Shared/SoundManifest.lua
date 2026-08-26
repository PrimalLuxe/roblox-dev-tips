local SoundManifest = {
    -- All IDs below were already present and loading in this project before this pass.
    -- Do not add unverified Creator Store/audio IDs here. Reusing a verified donor with
    -- different gain/pitch envelopes is preferable to inventing an asset reference.
    Machine = {
        Hum = {Id="rbxassetid://171186876", Volume=0.13, Group="Ambient", Looped=true, RollOffMaxDistance=30},
        Button = {Id="rbxassetid://9116540638", Volume=0.12, Group="SFX", PlaybackSpeed=1.28, Cooldown=0.05, RollOffMaxDistance=24},
        Click = {Id="rbxassetid://9116540638", Volume=0.18, Group="SFX", PlaybackSpeed=1.12, Cooldown=0.05, RollOffMaxDistance=28},
        Rattle = {Id="rbxassetid://9116540638", Volume=0.27, Group="SFX", PlaybackSpeed=1.04, Cooldown=0.08, RollOffMaxDistance=38},
        Clunk = {Id="rbxassetid://9116710986", Volume=0.48, Group="SFX", PlaybackSpeed=0.98, Cooldown=0.10, RollOffMaxDistance=42},
    },
    UI = {
        Hover = {Id="rbxassetid://9116540638", Volume=0.035, Group="UI", PlaybackSpeed=1.42, Cooldown=0.045, MaxInstances=2},
        Click = {Id="rbxassetid://9116540638", Volume=0.075, Group="UI", PlaybackSpeed=1.24, Cooldown=0.035, MaxInstances=3},
        Confirm = {Id="rbxassetid://9116710986", Volume=0.12, Group="UI", PlaybackSpeed=1.22, Cooldown=0.10, MaxInstances=2},
        Error = {Id="rbxassetid://9116710986", Volume=0.10, Group="UI", PlaybackSpeed=0.82, Cooldown=0.14, MaxInstances=1},
    },
    Economy = {
        Coin = {Id="rbxassetid://9113155656", Volume=0.09, Group="SFX", PlaybackSpeed=1.35, Cooldown=0.08, MaxInstances=2},
        Sell = {Id="rbxassetid://9116710986", Volume=0.17, Group="SFX", PlaybackSpeed=1.12, Cooldown=0.16, MaxInstances=2},
        Purchase = {Id="rbxassetid://9116710986", Volume=0.18, Group="SFX", PlaybackSpeed=0.92, Cooldown=0.16, MaxInstances=2},
        Unlock = {Id="rbxassetid://9113155656", Volume=0.18, Group="SFX", PlaybackSpeed=1.08, Cooldown=0.25, MaxInstances=2},
    },
    Collection = {
        Collect = {Id="rbxassetid://9113155656", Volume=0.10, Group="SFX", PlaybackSpeed=1.18, Cooldown=0.06, MaxInstances=3},
        Discovery = {Id="rbxassetid://9113155656", Volume=0.17, Group="RareReveal", PlaybackSpeed=1.03, Cooldown=0.15, MaxInstances=2, Duck=true},
        Milestone = {Id="rbxassetid://9113155656", Volume=0.22, Group="RareReveal", PlaybackSpeed=0.96, Cooldown=0.30, MaxInstances=2, Duck=true},
    },
    Engagement = {
        LuckyReady = {Id="rbxassetid://9113155656", Volume=0.17, Group="RareReveal", PlaybackSpeed=1.12, Cooldown=0.35, MaxInstances=1, Duck=true},
        Mastery = {Id="rbxassetid://9113155656", Volume=0.19, Group="RareReveal", PlaybackSpeed=1.00, Cooldown=0.35, MaxInstances=1, Duck=true},
        Gift = {Id="rbxassetid://9113155656", Volume=0.18, Group="RareReveal", PlaybackSpeed=1.20, Cooldown=0.35, MaxInstances=1, Duck=true},
    },
    Rarity = {
        Rare={Id="rbxassetid://9113155656",Volume=0.24,Group="RareReveal",PlaybackSpeed=1.08,Cooldown=0.20,MaxInstances=2,Duck=true},
        Epic={Id="rbxassetid://9113155656",Volume=0.28,Group="RareReveal",PlaybackSpeed=1.03,Cooldown=0.20,MaxInstances=2,Duck=true},
        Legendary={Id="rbxassetid://9113155656",Volume=0.34,Group="RareReveal",PlaybackSpeed=0.98,Cooldown=0.24,MaxInstances=2,Duck=true},
        Mythic={Id="rbxassetid://9113155656",Volume=0.39,Group="RareReveal",PlaybackSpeed=0.93,Cooldown=0.28,MaxInstances=2,Duck=true},
        Divine={Id="rbxassetid://9113155656",Volume=0.45,Group="RareReveal",PlaybackSpeed=0.88,Cooldown=0.32,MaxInstances=1,Duck=true},
        Secret={Id="rbxassetid://9113155656",Volume=0.51,Group="RareReveal",PlaybackSpeed=0.83,Cooldown=0.40,MaxInstances=1,Duck=true},
        Global={Id="rbxassetid://9113155656",Volume=0.58,Group="RareReveal",PlaybackSpeed=0.78,Cooldown=0.50,MaxInstances=1,Duck=true},
    },
    Mix = {
        Master = 1.00,
        SFX = 0.92,
        UI = 0.72,
        Ambient = 0.68,
        Music = 0.58,
        RareReveal = 0.96,
        Duck = {Music=0.30, Ambient=0.40, SFX=0.68, Attack=0.08, Hold=0.55, Release=0.34},
    },
}

function SoundManifest.Get(category,name)
    local bucket=SoundManifest[category]
    return type(bucket)=="table" and bucket[name] or nil
end

return SoundManifest

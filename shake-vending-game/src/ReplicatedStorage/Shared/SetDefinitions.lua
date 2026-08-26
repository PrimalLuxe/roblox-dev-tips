return {
    FrozenSet = {
        DisplayName = "Frozen Set",
        Requirements = {
            {BaseItemId="Cola",MutationId="Frozen"},{BaseItemId="Water",MutationId="Frozen"},{BaseItemId="CandyBottle",MutationId="Frozen"},{BaseItemId="RubberDuck",MutationId="Frozen"},{BaseItemId="CrownCan",MutationId="Frozen"},
        },
        Reward = {Id="FrozenWorld",Label="Frozen World Aura",Slot="Aura",BaseItemId="Water",MutationId="Frozen"},
    },
    GlitchSet = {
        DisplayName = "Glitch Set",
        Requirements = {
            {BaseItemId="ErrorCan",MutationId="Glitched"},{BaseItemId="StaticBottle",MutationId="Glitched"},{BaseItemId="CorruptedCola",MutationId="Glitched"},{BaseItemId="UnknownObject",MutationId="Glitched"},{BaseItemId="NullCapsule",MutationId="Glitched"},
        },
        Reward = {Id="ErrorField",Label="ERROR Glitch Aura",Slot="Aura",BaseItemId="ErrorCan",MutationId="Glitched"},
    },
    RoyalSet = {
        DisplayName = "Royal Set",
        Requirements = {{BaseItemId="CandyCrownCapsule"},{BaseItemId="GoldenToy"},{BaseItemId="CrownCan"},{BaseItemId="RoyalCandy"},{BaseItemId="EmperorCapsule"}},
        Reward = {Id="VendingKing",Label="VENDING KING",Slot="Title",BaseItemId="CrownCan",MutationId="Gold"},
    },
}

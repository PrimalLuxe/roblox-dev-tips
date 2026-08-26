# VISUAL ASSET AUDIT

This is the source-level 60/60 collectible mapping audit. It does **not** claim rendered Studio QA. Every row still requires Studio verification for scale, pivot, texture integrity, reveal framing, mutation readability and wearable fit.

| ID | Display | Machine | Donor | Family | Studio QA |
|---|---|---|---|---|---|
| Water | Water | CornerStore | WaterBottle | Bottle | REQUIRED |
| Cola | Cola | CornerStore | BloxyColaMesh | Can | REQUIRED |
| LemonSoda | Lemon Soda | CornerStore | SodaCan | Can | REQUIRED |
| OrangeSoda | Orange Soda | CornerStore | SodaCanMesh | Can | REQUIRED |
| Chips | Chips | CornerStore | PotatoChips | Bag | REQUIRED |
| Cookies | Cookies | CornerStore | CookieStack | Box | REQUIRED |
| Chocolate | Chocolate | CornerStore | Chocolate | Bar | REQUIRED |
| Gummies | Gummies | CornerStore | GummyBears | Bag | REQUIRED |
| Pretzels | Pretzels | CornerStore | ChipsPack | Bag | REQUIRED |
| MysteryCan | Mystery Can | CornerStore | SodaCan | Can | REQUIRED |
| CandyBottle | Candy Bottle | SugarRush | BottleCustom | Bottle | REQUIRED |
| GummyBears | Gummy Bears | SugarRush | GummyBears | Bag | REQUIRED |
| CandyBar | Candy Bar | SugarRush | Chocolate | Bar | REQUIRED |
| Lollipop | Lollipop | SugarRush | Lollipop | Lollipop | REQUIRED |
| CottonCandy | Cotton Candy | SugarRush | CandyPack | Ball | REQUIRED |
| BubbleGum | Bubble Gum | SugarRush | BubbleGumProp | Ball | REQUIRED |
| JellyBeans | Jelly Beans | SugarRush | CandyPack | Capsule | REQUIRED |
| SourCandy | Sour Candy | SugarRush | CandyPack | Box | REQUIRED |
| CandyCrownCapsule | Candy Crown Capsule | SugarRush | CrownProp | Capsule | REQUIRED |
| SecretSugarCube | Secret Sugar Cube | SugarRush | CandyPack | Cube | REQUIRED |
| PowerDrink | Power Drink | Energy | SodaCan | Can | REQUIRED |
| LightningDrink | Lightning Drink | Energy | DrinkBottle | Bottle | REQUIRED |
| TurboCan | Turbo Can | Energy | SodaCanMesh | Can | REQUIRED |
| HyperSoda | Hyper Soda | Energy | BloxyColaProp | Can | REQUIRED |
| SportsBottle | Sports Bottle | Energy | WaterBottle | Bottle | REQUIRED |
| NeonDrink | Neon Drink | Energy | Bottle | Bottle | REQUIRED |
| ShockCan | Shock Can | Energy | SodaCan | Can | REQUIRED |
| AtomicEnergy | Atomic Energy | Energy | SodaCan | Can | REQUIRED |
| ReactorCan | Reactor Can | Energy | SodaCanMesh | Can | REQUIRED |
| ForbiddenEnergy | Forbidden Energy | Energy | SodaCan | Can | REQUIRED |
| RubberDuck | Rubber Duck | ToyCapsule | RubberDuck | Duck | REQUIRED |
| TinyRobot | Tiny Robot | ToyCapsule | TinyRobot | Robot | REQUIRED |
| PlushRabbit | Plush Rabbit | ToyCapsule | BunnyPlush | Plush | REQUIRED |
| Slime | Slime | ToyCapsule | SlimeBlob | Ball | REQUIRED |
| Dice | Dice | ToyCapsule | DiceProp | Cube | REQUIRED |
| MiniUFO | Mini UFO | ToyCapsule | RobotToyAlt | UFO | REQUIRED |
| CrownCapsule | Crown Capsule | ToyCapsule | CrownProp | Capsule | REQUIRED |
| MysteryCreature | Mystery Creature | ToyCapsule | RobotToy | Robot | REQUIRED |
| GoldenToy | Golden Toy | ToyCapsule | RobotToyAlt | Robot | REQUIRED |
| UnknownCapsule | Unknown Capsule | ToyCapsule | GachaMachinePack | Capsule | REQUIRED |
| LuxuryWater | Luxury Water | Luxury | BottleCustom | Bottle | REQUIRED |
| DiamondSoda | Diamond Soda | Luxury | SodaCan | Can | REQUIRED |
| GoldenChocolate | Golden Chocolate | Luxury | Chocolate | Bar | REQUIRED |
| CrownCan | Crown Can | Luxury | CrownProp | Can | REQUIRED |
| CrystalBottle | Crystal Bottle | Luxury | BottleCustom | Bottle | REQUIRED |
| RoyalCandy | Royal Candy | Luxury | CandyPack | Box | REQUIRED |
| PlatinumSnack | Platinum Snack | Luxury | ChipsPack | Bag | REQUIRED |
| EmperorCapsule | Emperor Capsule | Luxury | CrownProp | Capsule | REQUIRED |
| CelestialDrink | Celestial Drink | Luxury | Bottle | Bottle | REQUIRED |
| MillionaireCan | Millionaire Can | Luxury | SodaCan | Can | REQUIRED |
| ErrorCan | Error Can | Unknown | SodaCan | Can | REQUIRED |
| MissingTextureSnack | Missing Texture Snack | Unknown | ChipsPack | Bag | REQUIRED |
| StaticBottle | Static Bottle | Unknown | Bottle | Bottle | REQUIRED |
| BlackCan | Black Can | Unknown | SodaCanMesh | Can | REQUIRED |
| NullCapsule | Null Capsule | Unknown | GachaMachinePack | Capsule | REQUIRED |
| CorruptedCola | Corrupted Cola | Unknown | BloxyColaMesh | Can | REQUIRED |
| UnknownObject | Unknown Object | Unknown | StoreItemsPack | Cube | REQUIRED |
| VoidContainer | Void Container | Unknown | BottleCustom | Bottle | REQUIRED |
| HeavenlyCan | Heavenly Can | Unknown | SodaCan | Can | REQUIRED |
| QuestionMark | ??? | Unknown | QuestionMarkProp | Capsule | REQUIRED |

**Items audited: 60 / 60**

## Automatic rejection criteria

Reject a donor during Studio QA if it is the wrong semantic category/silhouette, has broken textures/mesh/pivot, imports unsafe descendants that survive sanitation, clips catastrophically as a wearable, becomes unreadable under mutations, or cannot be framed cleanly in world/ViewportFrame presentation. Missing donors must remain omitted with diagnostics rather than replaced by generated fake collectible geometry.

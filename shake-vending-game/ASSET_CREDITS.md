# ASSET CREDITS

This ledger records the exact Creator Store IDs present in `AssetManifest.lua`. **No creator/title metadata is invented.** Where the current source does not contain independently verified creator/title metadata, that field remains pending for the Studio visual QA gate. Runtime import strips scripts, remotes, tools, prompts/detectors and other unsafe descendants before use.

| Key | Asset ID | Phase | Role | Source note / provenance status |
|---|---:|---|---|---|
| VendingMachine | `1924472602` | Critical | Machine | Verified scriptless vending-machine build |
| VendingMachineDetailed | `123896408090626` | Critical | Machine | Detailed food/drink vending donor; all 29 scripts/tools/audio stripped before use |
| VendingMachineStudded | `5854772913` | Warm | Machine | 1-stud old Roblox style vending machine; scripts stripped |
| VendingMachineModern | `73930515908550` | Warm | Machine | Modern free Bloxy Cola vending donor; compact mesh |
| HubShop | `140650365354389` | Critical | World | FREE Grow a Garden Shop v2 |
| CollectionShop | `110652161904837` | Warm | World | Grow a Garden cosmetics/crafting shop used as collection-gallery donor |
| GardenPlot | `132198808290621` | Warm | World | Highly rated Grow a Garden plot donor for studded hub detailing |
| LowPolyShop | `17380100820` | Warm | World | Free low-poly shop |
| LowPolyDecor | `16267075451` | Warm | World | Free low-poly asset pack |
| PineTree | `183435411` | Warm | World | Highly used free Quenty pine tree |
| Podium | `4180574986` | Critical | Podium | Free statue pedestal |
| SellATM | `3893560084` | Critical | World | Free Basic ATM |
| SimulatorUI | `6177977821` | Critical | UI | Free Simulator UI style donor; scripts stripped |
| SodaCan | `18238736152` | Critical | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| SodaCanMesh | `11962184173` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| BloxyColaMesh | `8761745867` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| BloxyColaProp | `5238761267` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| WaterBottle | `17473392905` | Critical | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| Bottle | `8752764216` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| BottleCustom | `87202443207548` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| DrinkBottle | `5127364594` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| PotatoChips | `11542524323` | Critical | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| ChipsPack | `15343999257` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| Chocolate | `5212600780` | Critical | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| GummyBears | `5670289254` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| Lollipop | `5053108042` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| CandyPack | `8800370694` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| RobotToy | `982342953` | Critical | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| RobotToyAlt | `974904281` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| TinyRobot | `981959327` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| RubberDuck | `112596010768171` | Background | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| StoreItemsPack | `404157586` | Warm | Item | No source note recorded; Creator Store metadata must be visually verified in Studio/browser before release. |
| CookieStack | `934871698` | Background | Item | Free low-triangle cookie stack donor |
| BunnyPlush | `9067952250` | Background | Item | Free bunny plush donor |
| SlimeBlob | `874582924` | Background | Item | Free rated slime donor |
| DiceProp | `4995709060` | Background | Item | Free compact dice donor |
| CrownProp | `959221624` | Background | Item | Free crown mesh donor |
| QuestionMarkProp | `4016842024` | Background | Item | Free question-mark prop donor |
| BubbleGumProp | `10831254538` | Background | Item | Free premium bubblegum donor |
| GachaMachinePack | `105994898400536` | Background | Item | Free gacha/capsule donor; scripts stripped and semantic submodel extraction only |

**Manifest donors recorded:** 40

## Release gate

- Open every significant donor in Creator Store/Studio and record title + creator before final public release.
- Confirm imported copies contain no executable or interaction-bearing third-party descendants.
- Reject semantically wrong, oversized, broken, or visually weak donors rather than relying on fallback geometry.

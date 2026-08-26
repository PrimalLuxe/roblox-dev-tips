# ASSET CREDITS

This ledger records the exact Creator Store IDs present in `AssetManifest.lua`. **No creator/title metadata is invented.** Where the current source does not contain independently verified creator/title metadata, that field remains pending for the Studio visual QA gate. Runtime import strips scripts, remotes, tools, prompts/detectors and other unsafe descendants before use. Donors are source material only; production systems may restyle, kitbash, resize, combine, or use them as chassis/props.

| Key | Asset ID | Phase | Role | Source note / provenance status |
|---|---:|---|---|---|
| VendingMachine | `1924472602` | Critical | Machine | Verified scriptless vending-machine build; chassis donor only |
| VendingMachineDetailed | `123896408090626` | Critical | Machine | Detailed food/drink vending donor; all 29 scripts/tools/audio stripped; chassis donor only |
| VendingMachineStudded | `5854772913` | Warm | Machine | 1-stud old Roblox style vending machine; scripts stripped; chassis donor only |
| VendingMachineModern | `73930515908550` | Warm | Machine | Modern free Bloxy Cola vending donor; compact mesh; chassis donor only |
| HubShop | `140650365354389` | Critical | World | FREE Grow a Garden Shop v2 |
| CollectionShop | `110652161904837` | Warm | World | Grow a Garden cosmetics/crafting shop used as collection-gallery donor |
| GardenPlot | `132198808290621` | Warm | World | Highly rated Grow a Garden plot donor for studded hub detailing |
| LowPolyShop | `17380100820` | Warm | World | Free low-poly shop |
| LowPolyDecor | `16267075451` | Warm | World | Free low-poly asset pack |
| PineTree | `183435411` | Warm | World | Highly used free Quenty pine tree |
| Podium | `4180574986` | Critical | Podium | Free statue pedestal |
| SellATM | `3893560084` | Critical | World | Free Basic ATM |
| SimulatorUI | `6177977821` | Critical | UI | Free Simulator UI donor; scripts stripped. No longer controls runtime palette/theme. |
| ArcadeCabinet | `15940632283` | Warm | World | Free scriptless arcade environment donor; sanitized, resized and used only as Toy Capsule district dressing |
| StreetBench | `342263157` | Warm | World | Free rated bench donor; sanitized/resized for Downtown street furniture |
| StreetLamp | `5131224078` | Warm | World | Free compact street-light donor; sanitized/resized for Downtown street furniture |
| TrashCan | `4860243220` | Warm | World | Free rated compact trash-can donor; sanitized/resized for Downtown street furniture |
| SodaCan | `18238736152` | Critical | Item | Creator Store metadata pending final visual verification. |
| SodaCanMesh | `11962184173` | Background | Item | Creator Store metadata pending final visual verification. |
| BloxyColaMesh | `8761745867` | Background | Item | Creator Store metadata pending final visual verification. |
| BloxyColaProp | `5238761267` | Background | Item | Creator Store metadata pending final visual verification. |
| WaterBottle | `17473392905` | Critical | Item | Creator Store metadata pending final visual verification. |
| Bottle | `8752764216` | Background | Item | Creator Store metadata pending final visual verification. |
| BottleCustom | `87202443207548` | Background | Item | Creator Store metadata pending final visual verification. |
| DrinkBottle | `5127364594` | Background | Item | Creator Store metadata pending final visual verification. |
| PotatoChips | `11542524323` | Critical | Item | Creator Store metadata pending final visual verification. |
| ChipsPack | `15343999257` | Background | Item | Creator Store metadata pending final visual verification. |
| Chocolate | `5212600780` | Critical | Item | Creator Store metadata pending final visual verification. |
| GummyBears | `5670289254` | Background | Item | Creator Store metadata pending final visual verification. |
| Lollipop | `5053108042` | Background | Item | Creator Store metadata pending final visual verification. |
| CandyPack | `8800370694` | Background | Item | Creator Store metadata pending final visual verification. |
| RobotToy | `982342953` | Critical | Item | Creator Store metadata pending final visual verification. |
| RobotToyAlt | `974904281` | Background | Item | Creator Store metadata pending final visual verification. |
| TinyRobot | `981959327` | Background | Item | Creator Store metadata pending final visual verification. |
| RubberDuck | `112596010768171` | Background | Item | Creator Store metadata pending final visual verification. |
| StoreItemsPack | `404157586` | Warm | Item | Creator Store metadata pending final visual verification. |
| CookieStack | `934871698` | Background | Item | Free low-triangle cookie stack donor |
| BunnyPlush | `9067952250` | Background | Item | Free bunny plush donor |
| SlimeBlob | `874582924` | Background | Item | Free rated slime donor |
| DiceProp | `4995709060` | Background | Item | Free compact dice donor |
| CrownProp | `959221624` | Background | Item | Free crown mesh donor |
| QuestionMarkProp | `4016842024` | Background | Item | Free question-mark prop donor |
| BubbleGumProp | `10831254538` | Background | Item | Free premium bubblegum donor |
| GachaMachinePack | `105994898400536` | Background | Item | Free gacha/capsule donor; scripts stripped and semantic submodel extraction only |

**Manifest donors recorded:** 44

## Machine donor treatment

The vending donors are explicitly **not** considered finished machines. `MachineArtDirector.lua` overlays an Olympus-authored front fascia with machine-specific marquee/silhouette details, display glass, semantic product rows generated from that machine's actual loot definitions, shelves, control screen, keypad, card reader, coin slot, dispensing tray, access panel, vents, feet, side trim and event indicator. This layer is attached to the sanitized donor chassis so the donor supplies useful modeled mass while the player-facing machine identity is ours.

## Release gate

- Open every significant donor in Creator Store/Studio and record title + creator before final public release.
- Confirm imported copies contain no executable or interaction-bearing third-party descendants.
- Reject semantically wrong, oversized, broken, or visually weak donors rather than relying on fallback geometry.
- Visually verify the complete Olympus kitbash from front, three-quarter and side views; replace any donor whose chassis still dominates the authored machine identity.

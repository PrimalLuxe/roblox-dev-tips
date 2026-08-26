# WORK CHECKPOINT — 2026-08-26

## Persistent target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- Source of truth: latest uploaded **Shake a Vending Machine — Front-Page Production Overhaul Master Prompt**.

## Runtime persistence status

The release-critical text runtime is mirrored into the persistent branch, including `UIController.lua` and `DropVisualController.lua`. `ClientBootstrap.client.lua` can resolve its UI, reveal, machine, trade, inspect, audio, onboarding, showcase and WorldLoop controller requirements from the branch instead of relying on an external baseline.

The branch also contains the AssetLoad, Inventory, Global, Roll, Engagement, Trading, Cosmetic and Showcase services plus the current DataService, RemoteService, SettingsService and UpgradeService implementations.

## Major production state

- Profile/data progression v5 with Vending Passport and 3-slot Hunt List.
- Downtown launch world, multi-goal machine unlocks and event-only Unknown machine.
- Server-authoritative Hunt/Passport, roll, inventory, upgrades, settings and trading actions.
- Truthful obtained-roll (`OneIn`) and natural-pool (`NaturalOneIn`) odds.
- Creator Store loading through `AssetService:LoadAssetAsync` with phased startup and donor sanitization.
- Missing Creator Store item donors warn and omit the visual; fake `MISSING_CREATOR_ASSET_*` geometry is removed.
- Protected mass selling, auto-lock, keep-one-each, favorites, shards, equipment and showcase references.
- Responsive HUD/collection UI with catalog search/sort, viewport inspection, sell confirmation, upgrades, global board, settings and gamepad Back.
- Wearable collectibles, auras, trails, titles, outfit slots, six editable showcase pedestals and rarest-item centerpiece.
- Journaled two-stage trading with revalidation, capacity checks, READY reset, CONFIRM countdown and interrupted-commit reconciliation.
- MemoryStore hourly rare board, MessagingService cross-server rare feed, restock events, cooperative Jammed progress, combo state and server-timed playtime gifts.
- DataStore autosave snapshot-rewind race fixed; centralized token-bucket remote limiting present.

## Presentation correction pass — current run

The branch previously still had two source-level presentation shortcuts that did not satisfy the master prompt even though the systems existed.

### Original UI identity

`UITheme.lua` no longer scans the free `SimulatorUI` donor at runtime and copies its darkest panel/accent/font. The runtime UI palette is now owned by ShakeVM: warm cream product-card surfaces, navy structure, vending blue, restrained gold, dark readable text, explicit success/warning/danger colors and consistent outline/shadow tokens.

`UIComponents.lua` now builds reusable tactile retail primitives rather than plain dark rectangles: physical shadow layers, outlined cream cards, top-edge button sheen, hover/press tween states, explicit gamepad selection treatment, section-label chips and a redesigned confirmation modal. This is a source-level component architecture improvement; it is not being presented as a Studio-verified final visual result.

### Distinct reveal / mutation language

`VFXManifest.lua` now defines separate mutation families for Shiny, Gold, Frozen, Flaming, Toxic, Crystal, Rainbow, Glitched, Shadow, Cosmic, Heavenly and Void instead of only tier particle counts.

`DropVisualController.lua` now consumes that manifest. Reveals use different Roblox effect classes/behaviors by mutation (sparkles, flame/embers, snow mist, toxic bubbles, smoke/collapse, glitch bits, spectrum/orbit/halo behavior), quality-scaled rarity rays, high-tier vertical discovery beams, mutation lights where appropriate, a cream physical rarity card, and a matching cream high-tier screen reveal. Common/remote effects remain bounded by existing quality and distance controls.

No external VFX texture or Creator Store asset IDs were invented in this pass. The implementation deliberately uses Roblox-native effect classes until a verified texture donor can be sourced and visually checked.

## Validation history

The last full repository static audit recorded before this presentation pass was:

```text
ShakeVM static audit
  items: 60 | 10 per machine across 6 machines
  mutations: 12 + None
  creator-store base assets: 40
  lua files: 46
PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.
```

A fresh full `tools/static_check.py` execution could **not** be run in this automation environment after the current commits because direct GitHub network access from the execution container is blocked. The changed files were persisted through the GitHub connector, and the branch was re-read through the connector, but this limitation means the previous PASS must not be represented as post-change certification. A fresh local/CI static run and Roblox Studio parse/run are required for this revision.

Fast-seller upper-bound loop simulation from the prior validated refactor:

| Machine | P10 | Median | P90 | Reach by 75m |
| --- | ---: | ---: | ---: | ---: |
| Sugar Rush | 1:53 | 2:48 | 3:25 | 100% |
| Energy | 3:27 | 4:44 | 5:39 | 100% |
| Toy Capsule | 10:40 | 13:44 | 15:36 | 100% |
| Luxury | 25:44 | 32:00 | 35:42 | 100% |

Median unique discoveries at 75 minutes: **31**.

## Production documentation persisted

- `FINAL_CHANGELOG.md`
- `REFERENCE_NOTES.md`
- `ASSET_CREDITS.md`
- `VISUAL_ASSET_AUDIT.md` — 60/60 source mappings; all rows still require Studio visual QA
- `MODEL_QA.md`
- `ECONOMY_AUDIT.md`
- `PERFORMANCE_AUDIT.md`
- `STUDIO_VISUAL_QA.md`
- `KNOWN_LIMITATIONS.md`
- `PLAY_IN_STUDIO.md`
- `LOOP_AUDIT.md`

`ASSET_CREDITS.md` preserves the 40 manifest IDs and leaves unverified Creator Store creator/title metadata pending instead of inventing it. `STUDIO_VISUAL_QA.md` deliberately marks all in-engine checks NOT RUN.

## Remaining blockers before final package

The branch is **not** visually release-certified. The next highest-impact unfinished requirement is the vending-machine/world art pass: the current `WorldBuilder` still treats the vending donor too much like the finished shell and relies mainly on recoloring/studs/highlight/billboard. It still needs a real kitbash layer with custom fascia, glass/product rows matching each loot family, control column/keypad/card reader, tray/access panel/vents/feet/marquee and stronger neighborhood dressing before the machine work should be considered master-prompt complete.

Roblox Studio/Luau runtime execution is also still required for Creator Store donor appearance/pivots/permissions, collisions/tray alignment, VFX readability, audio permissions/mix, mobile/gamepad layout on real emulation/devices, low-end performance profiling, published DataStore/MemoryStore/MessagingService behavior and two-player trade/disconnect reconciliation.

Final ZIP packaging must wait until those source and Studio gates are actually executed; do not label the current branch visually release-ready yet.

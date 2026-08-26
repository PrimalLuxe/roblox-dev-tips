# WORK CHECKPOINT — 2026-08-26

## Persistent target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- Source of truth: latest uploaded **Shake a Vending Machine — Front-Page Production Overhaul Master Prompt**.

## Runtime persistence status

The release-critical Rojo text source is persisted on the production branch. Client bootstrap resolves UI, reveal, machine, trade, inspection, audio, onboarding, showcase, world-loop, HUD art and collection-art controllers from source. Server bootstrap resolves the production data/progression/roll/inventory/cosmetic/showcase/trading/global/event/upgrade/world services.

## Implemented production systems

- Profile/data progression v5 with Vending Passport and 3-slot Hunt List.
- Downtown launch world, multi-goal machine unlocks and event-only Unknown machine.
- Server-authoritative Hunt/Passport, roll, inventory, upgrades, settings and trading actions.
- Truthful obtained-roll (`OneIn`) and natural-pool (`NaturalOneIn`) odds.
- Creator Store loading through `AssetService:LoadAssetAsync` with phased startup and donor sanitation.
- Missing Creator Store item donors warn/omit instead of spawning fake red placeholder geometry.
- Protected mass selling, auto-lock, keep-one-each, favorites, shards, equipment and showcase references.
- Responsive HUD/collection UI with catalog search/sort, viewport inspection, sell confirmation, upgrades, global board, settings and gamepad Back.
- Wearable collectibles, auras, trails, titles, outfit slots, six editable showcase pedestals and rarest-item centerpiece.
- Journaled two-stage trading with revalidation, capacity checks, READY reset, CONFIRM countdown and interrupted-commit reconciliation.
- MemoryStore hourly rare board, MessagingService cross-server rare feed, restock events, cooperative Jammed progress, combo state and server-timed playtime gifts.
- DataStore autosave snapshot-rewind race fixed; centralized token-bucket remote limiting present.

## Presentation correction state

### Original UI identity

`UITheme.lua` owns a warm cream/navy/vending-blue/restrained-gold retail palette rather than copying a free simulator donor at runtime. `UIComponents.lua` supplies reusable tactile cards/buttons, physical shadow layers, outlines, hover/press states, gamepad selection and confirmation-modal primitives.

`HudArtDirector.lua` and `CollectionArtDirector.lua` are both persisted. `ClientBootstrap.client.lua` explicitly applies both directors after `UI:Build`, so the authored HUD and collection cards/search/sort presentation are wired runtime systems rather than dead source.

### Reveal / mutation language

`VFXManifest.lua` defines distinct visual families for all 12 launch mutations. `DropVisualController.lua` consumes those definitions and keeps effects client-side/quality-bounded: rarity rays, high-tier discovery beam, differentiated mutation particles/lights, physical rarity card and high-tier screen treatment. No external VFX texture IDs were fabricated.

### Vending machine art — primary construction integration

`MachineArtDirector.lua` provides six machine families using the sanitized Creator Store vending donor as a chassis and adding an authored layer named `OlympusKitbash`:

- real glass display bay;
- three internal shelves;
- visible products generated from each machine's actual item definitions;
- display screen;
- keypad/buttons;
- card reader and coin slot;
- dispense tray;
- lower access panel and vents;
- feet/base hardware;
- marquee/top signage;
- subtle interior light;
- family-specific fascia/trim details for Corner Store, Sugar Rush, Energy, Toy Capsule, Luxury and Unknown.

Before this run the art layer was already applied by the secondary `WorldPolishService` pass, so it was not truly orphaned. The weakness was that `WorldBuilder` measured the donor shell and created root/collision/drop placement **before** that secondary art pass. `WorldBuilder.makeMachine` now requires and executes `MachineArtDirector.Apply(model,shell,machineId)` before final bounds, collision-hull and drop-spawn placement. `WorldPolishService` sees `ArtDirectionVersion == 2` and skips duplicate machine construction. This makes the authored fascia part of primary machine construction and keeps bounds/reveal placement deterministic.

### Physical machine interaction polish

`MachineInteractionController.lua` was upgraded from product-only jiggle to a staged, locally visual interaction driven by the authoritative `DropSpawned` event:

1. keypad acknowledgement and screen change;
2. slight forward compression/lean;
3. constrained spring rattle with product inertia;
4. subtle interior-light response;
5. short suspense settle;
6. CLUNK with tray kick rather than another full-machine shake;
7. clean restoration to the exact starting pivot/state.

Shake magnitude scales modestly with Overdrive/combo data when present and remains deliberately sub-stud. The controller uses `xpcall` plus a restoration path so an interrupted animation does not leave a machine, tray, lights or keypad in a mutated client state.

## QA tooling and CI added this run

`tools/presentation_check.py` now fails if authored presentation exists but is no longer wired into runtime. It checks WorldBuilder → MachineArtDirector integration, machine fascia/product/control/tray hardware markers, staged interaction markers, and authored collection UI bootstrap wiring.

The existing parsers in `tools/static_check.py` and `tools/loop_sim.py` were repaired for the current compact one-line `ItemDefinitions.lua` format. The assertions were not weakened: both tools still require exactly 60 launch items and 10 items for each of the six machines.

`.github/workflows/shake-vending-production-checks.yml` now runs on production-branch source changes with read-only repository permissions:

```bash
python tools/static_check.py
python tools/presentation_check.py
python tools/visual_quality_check.py
python tools/loop_sim.py
```

## Validation performed in this run

The production branch was inspected before changes at commit `a252ec23c70c5dec1aba988d2e244f65ff6bb98d`.

A direct local checkout from the execution container could not resolve `github.com`; that limitation was not treated as a pass. GitHub Actions was then added so the exact persisted branch could be checked independently.

The CI run for commit `8c993c6ffd0e36247891a7789022aa9393d53bc9` completed successfully across all four checks.

### Static structural audit — PASS

```text
ShakeVM static audit
  items: 60 | per machine: 10 each across CornerStore, SugarRush, Energy, ToyCapsule, Luxury, Unknown
  mutations: 12 + None
  creator-store base assets: 49
  lua files: 52
PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.
```

### Presentation persistence audit — PASS

```text
world art wiring: OK
machine authored fascia: OK
staged physical interaction: OK
authored collection UI wiring: OK
PASS: authored presentation systems are persisted and wired into runtime entry points.
```

### Visual-quality source guardrails — PASS

```text
PASS: authored machine kitbash, staged physical interaction, distinct Downtown districts,
HUD/collection hierarchy, safe donor extraction, UI identity, and reveal-language guardrails present.
```

### Progression loop simulation — PASS

1,000 deterministic-seed fast-seller upper-bound runs:

| Machine | P10 | Median | P90 | Reach by 75m |
| --- | ---: | ---: | ---: | ---: |
| Sugar Rush | 1:53 | 2:48 | 3:25 | 100% |
| Energy | 3:27 | 4:44 | 5:39 | 100% |
| Toy Capsule | 10:40 | 13:44 | 15:36 | 100% |
| Luxury | 25:44 | 32:00 | 35:42 | 100% |

Median unique discoveries at 75 minutes: **31**.

This is a static economy/progression simulation, not a Roblox Studio playtest.

## Production documentation persisted

- `FINAL_CHANGELOG.md`
- `REFERENCE_NOTES.md`
- `ASSET_CREDITS.md`
- `VISUAL_ASSET_AUDIT.md`
- `MODEL_QA.md`
- `ECONOMY_AUDIT.md`
- `PERFORMANCE_AUDIT.md`
- `STUDIO_VISUAL_QA.md`
- `KNOWN_LIMITATIONS.md`
- `PLAY_IN_STUDIO.md`
- `LOOP_AUDIT.md`

`ASSET_CREDITS.md` preserves manifest IDs while leaving unverified Creator Store creator/title metadata pending instead of inventing it. `STUDIO_VISUAL_QA.md` must continue to mark in-engine checks NOT RUN until they actually occur.

## Remaining blockers before final package

The source passes the current automated structural/presentation/economy suite, but it is **not visually release-certified**.

Highest remaining gates:

1. Roblox Studio visual QA of all six runtime-kitbashed vending machines: donor orientation, fascia alignment, glass/product clipping, tray/drop-spawn placement, collision hulls and pivots.
2. Studio visual QA of all 60 item donors in collection/reveal/showcase contexts; replace mismatched donors rather than accepting them because an ID loads.
3. Further world-art judgment in Studio. The six-district composition, district art director, premium donor facades and street decor exist, but the overall scene still needs real-camera comparison against the master prompt's front-page commercial-district bar.
4. Audio asset permissions/mix and reveal timing in a published experience.
5. Mobile/tablet/gamepad safe-area and focus QA on actual Studio emulation/devices.
6. Low-end performance profiling with 100+ inventory items, multiple players, effects and showcases.
7. Published DataStore/MemoryStore/MessagingService behavior and two-player trade/disconnect reconciliation.

Do not package or label `shake-vending-game-ULTIMATE.zip` as final until these gates are honestly cleared, or until a package is explicitly requested as a test build rather than a release-certified build.

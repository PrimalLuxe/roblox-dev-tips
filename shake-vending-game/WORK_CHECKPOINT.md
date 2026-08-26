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

`HudArtDirector.lua` and `CollectionArtDirector.lua` are both persisted. `ClientBootstrap.client.lua` now explicitly applies both directors after `UI:Build`, so the authored collection cards/search/sort presentation is not dead source.

### Reveal / mutation language

`VFXManifest.lua` defines distinct visual families for all 12 launch mutations. `DropVisualController.lua` consumes those definitions and keeps effects client-side/quality-bounded: rarity rays, high-tier discovery beam, differentiated mutation particles/lights, physical rarity card and high-tier screen treatment. No external VFX texture IDs were fabricated.

### Vending machine art — runtime wiring fixed

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

A persistence defect was found in this run: the art director existed but `WorldBuilder` never called it. `WorldBuilder.makeMachine` now requires and executes `MachineArtDirector.Apply(model,shell,machineId)` **before** final bounds, collision-hull and drop-spawn placement. This means the authored vending layer is now part of runtime construction instead of orphaned source.

### Physical machine interaction polish

`MachineInteractionController.lua` was upgraded from product-only jiggle to a staged, locally visual interaction driven by the authoritative `DropSpawned` event:

1. keypad acknowledgement and screen change;
2. slight forward compression/lean;
3. constrained spring rattle with product inertia;
4. subtle interior-light response;
5. short suspense settle;
6. CLUNK with tray kick rather than another full-machine shake;
7. clean restoration to the exact starting pivot/state.

Shake magnitude scales modestly with Overdrive/combo data when present and remains deliberately sub-stud. The controller uses `xpcall` + a restoration path so interrupted animation does not leave a machine, tray, lights or keypad in a mutated client state.

## QA tooling added this run

A new `tools/presentation_check.py` regression audit now fails if authored presentation exists but is no longer wired into runtime. It checks:

- `WorldBuilder` → `MachineArtDirector` wiring;
- expected machine fascia/product/control/tray hardware markers;
- staged machine-interaction markers;
- authored collection UI wiring from client bootstrap.

A repository workflow, `.github/workflows/shake-vending-production-checks.yml`, now defines production-branch CI for:

```bash
python tools/static_check.py
python tools/presentation_check.py
python tools/economy_sim.py
```

The workflow is intentionally read-only (`contents: read`), path-scoped and timeout-bounded.

## Validation performed in this run

The production branch was inspected before changes at commit `a252ec23c70c5dec1aba988d2e244f65ff6bb98d`.

Post-change source was persisted through GitHub commits and key files were re-read through the GitHub connector.

A direct local checkout was attempted to execute the full audit suite:

```text
git clone --depth 1 --branch shake-vending-production https://github.com/PrimalLuxe/roblox-dev-tips.git
fatal: unable to access ... Could not resolve host: github.com
```

Therefore a fresh full repository PASS was **not** fabricated. GitHub Actions history was queried after adding the workflow and returned zero runs at that moment, so CI completion is not being claimed either.

The prior recorded full static audit remains historical evidence only:

```text
ShakeVM static audit
  items: 60 | 10 per machine across 6 machines
  mutations: 12 + None
  creator-store base assets: 40
  lua files: 46
PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.
```

A fresh local/CI run is still required for the current revision.

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

The source is materially closer to the master prompt, but it is **not visually release-certified**.

Highest remaining gates:

1. Roblox Studio visual QA of all six runtime-kitbashed vending machines: donor orientation, fascia alignment, glass/product clipping, tray/drop-spawn placement, collision hulls and pivots.
2. Studio visual QA of all 60 item donors in collection/reveal/showcase contexts; replace mismatched donors rather than accepting them because an ID loads.
3. Further world art dressing. The six-district composition and donor facades exist, but paths/pads/sign anchors are still intentionally simple structural geometry and should be visually assessed against the master prompt's commercial-district bar.
4. Audio asset permissions/mix and reveal timing in a published experience.
5. Mobile/tablet/gamepad safe-area and focus QA on actual Studio emulation/devices.
6. Low-end performance profiling with 100+ inventory items, multiple players, effects and showcases.
7. Published DataStore/MemoryStore/MessagingService behavior and two-player trade/disconnect reconciliation.
8. Fresh execution of `static_check.py`, `presentation_check.py` and `economy_sim.py` on the exact current branch.

Do not package or label `shake-vending-game-ULTIMATE.zip` as final until these gates are honestly cleared, or until a package is explicitly requested as a test build rather than a release-certified build.

# WORK CHECKPOINT — 2026-08-26

## Persistent target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- Source of truth: latest uploaded **Shake a Vending Machine — Front-Page Production Overhaul Master Prompt**.

## Runtime persistence status

The release-critical text runtime is now mirrored into the persistent branch, including the two previously missing client boot dependencies: `UIController.lua` and `DropVisualController.lua`. `ClientBootstrap.client.lua` can now resolve its UI, reveal, machine, trade, inspect, audio, onboarding, showcase and WorldLoop controller requirements from the branch instead of relying on an external baseline.

This run also synchronized older branch copies of DataService, RemoteService, SettingsService and UpgradeService and persisted the previously absent AssetLoad, Inventory, Global, Roll, Engagement, Trading, Cosmetic and Showcase services.

## Major production state

- Profile/data progression v5 with Vending Passport and 3-slot Hunt List.
- Downtown launch world, multi-goal machine unlocks and event-only Unknown machine.
- Server-authoritative Hunt/Passport, roll, inventory, upgrades, settings and trading actions.
- Truthful obtained-roll (`OneIn`) and natural-pool (`NaturalOneIn`) odds.
- Creator Store loading through `AssetService:LoadAssetAsync` with phased startup and donor sanitization.
- Missing Creator Store item donors now warn and omit the visual; fake `MISSING_CREATOR_ASSET_*` geometry is removed.
- Protected mass selling, auto-lock, keep-one-each, favorites, shards, equipment and showcase references.
- Responsive HUD/collection UI with catalog search/sort, viewport inspection, sell confirmation, upgrades, global board, settings and gamepad Back.
- Local/world reward reveal controller with hover/touch/gamepad pickup, rarity billboards, highlights, particles, screen rarity reveal and distance-bounded world VFX.
- Wearable collectibles, auras, trails, titles, outfit slots, six editable showcase pedestals and rarest-item centerpiece.
- Journaled two-stage trading with revalidation, capacity checks, READY reset, CONFIRM countdown and interrupted-commit reconciliation.
- MemoryStore hourly rare board, MessagingService cross-server rare feed, restock events, cooperative Jammed progress, combo state and server-timed playtime gifts.
- DataStore autosave snapshot-rewind race fixed; centralized token-bucket remote limiting present.

## Validation actually run after the client refactor

```text
ShakeVM static audit
  items: 60 | 10 per machine across 6 machines
  mutations: 12 + None
  creator-store base assets: 40
  lua files: 46
PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.
```

`tools/static_check.py` verifies required bootstrap modules exist, WorldLoop is initialized, Creator Store procedural/fake-item regressions do not return, truthful odds fields remain, destructive bulk selling stays behind client confirmation, centralized remote limiting exists, onboarding completion persists, and gamepad/showcase/Jammed interaction markers remain.

Fast-seller upper-bound loop simulation after the refactor:

| Machine | P10 | Median | P90 | Reach by 75m |
| --- | ---: | ---: | ---: | ---: |
| Sugar Rush | 1:53 | 2:48 | 3:25 | 100% |
| Energy | 3:27 | 4:44 | 5:39 | 100% |
| Toy Capsule | 10:40 | 13:44 | 15:36 | 100% |
| Luxury | 25:44 | 32:00 | 35:42 | 100% |

Median unique discoveries at 75 minutes: **31**.

## Documentation persisted this run

- `FINAL_CHANGELOG.md`
- `MODEL_QA.md`
- `PERFORMANCE_AUDIT.md`
- `STUDIO_VISUAL_QA.md`
- `KNOWN_LIMITATIONS.md`
- `PLAY_IN_STUDIO.md`

`STUDIO_VISUAL_QA.md` deliberately marks all in-engine checks NOT RUN instead of inventing visual/device QA.

## Remaining blockers before final package

The runtime/source-persistence blocker is resolved, but the release is **not** fully certified. Roblox Studio/Luau runtime execution was unavailable in this run. Required in-engine checks still include Creator Store donor appearance/pivots/permissions, collisions/tray alignment, audio permissions/mix, mobile/gamepad layout on real emulation/devices, low-end performance profiling, published DataStore/MemoryStore/MessagingService behavior and two-player trade/disconnect reconciliation.

Final documentation/provenance files from the master prompt still need to be mirrored/refreshed on the branch where absent (`REFERENCE_NOTES.md`, `ASSET_CREDITS.md`, `VISUAL_ASSET_AUDIT.md`). Final ZIP packaging must wait until the Studio verification matrix is actually executed; do not label the current branch visually release-ready yet.

# WORK CHECKPOINT — 2026-08-26

## Persistent target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- Source of truth for current work: latest uploaded **Front-Page Production Overhaul Master Prompt**.

## Implemented and persisted

- Profile/data progression v5 with Vending Passport and 3-slot Hunt List.
- Downtown launch-world definitions and multi-goal machine unlock requirements.
- Event-only Unknown machine behavior and physical Passport kiosk entry point.
- Server-authoritative Hunt/Passport remotes and stamp validation.
- Creator Store asset loading through `AssetService:LoadAssetAsync`, donor sanitization, bounded startup phases, and loud failure diagnostics.
- `ItemVisualFactory` now uses sanitized donors and returns `nil` when no suitable donor exists; the old red-neon `MISSING_CREATOR_ASSET_*` fake collectible has been removed.
- Cosmetic/aura/trail wearables are nil-safe when an external donor is unavailable.
- Showcase service is persisted with six editable slots, rarest-item centerpiece, inspect plaques, and missing-donor safety.
- Inventory service is persisted with auto-lock, favorites/equipped/showcase protection, keep-one-each mass-sell behavior, duplicate selling, and shard conversion.
- Roll service is persisted with server authority plus both obtained-roll (`OneIn`) and natural-pool (`NaturalOneIn`) odds.
- Global service is persisted with MemoryStore hourly rare board and MessagingService rare-drop feed.
- Engagement service is persisted with combo state and server-timed playtime gifts.
- Trading service is persisted with join/playtime gates, capacity checks, revalidation, journaled transfer, confirmation reset, countdown, and reconciliation path.
- Client trade UX and player inspect controller are persisted.
- Existing branch already contains phased loading, audio/VFX manifests, onboarding, machine presentation, WorldLoopController, WorldBuilder, and Passport kiosk wiring.

## Static validation actually run

From the complete working tree:

```text
ShakeVM static audit
  items: 60 | 10 per machine across 6 machines
  mutations: 12 + None
  creator-store base assets: 40
  lua files: 46
PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.
```

The local regression gate also checks bootstrap-required module persistence, WorldLoop initialization, truthful odds fields, centralized remote throttling, destructive-sell confirmation routing, and prevents the removed `MISSING_CREATOR_ASSET_` placeholder from returning.

## Loop simulation actually run

Fast-seller upper-bound simulation:

| Machine | P10 | Median | P90 | Reach by 75m |
| --- | ---: | ---: | ---: | ---: |
| Sugar Rush | 1:53 | 2:48 | 3:25 | 100% |
| Energy | 3:27 | 4:44 | 5:39 | 100% |
| Toy Capsule | 10:40 | 13:44 | 15:36 | 100% |
| Luxury | 25:44 | 32:00 | 35:42 | 100% |

Median unique discoveries at 75 minutes: **31**.

## Persistence blocker still open

The tested working tree is **not yet fully mirrored into GitHub**. Two large release-critical client modules remain absent from the branch:

- `src/StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua` (~60 KB)
- `src/StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua` (~26 KB)

They exist in the tested working tree and contain the current collection/inventory UI and nil-safe reveal changes, but until they are persisted the branch is not a self-contained playable source checkout. Do not package a final release ZIP from the branch yet.

## Required next work

1. Persist `UIController.lua` and `DropVisualController.lua`, then run the bootstrap/source-persistence regression against a fresh branch checkout.
2. Persist the newest expanded `tools/static_check.py` guardrails if its branch copy is older.
3. Complete/update final documentation (`FINAL_CHANGELOG`, `MODEL_QA`, `PERFORMANCE_AUDIT`, `STUDIO_VISUAL_QA`, `KNOWN_LIMITATIONS`, `PLAY_IN_STUDIO`).
4. Perform final source audit and package `shake-vending-game-ULTIMATE.zip` only after the branch is self-contained.

## Honest limitation

Roblox Studio was not available in this run. No in-engine visual, collision, device, audio-permission, Creator Store donor-content, DataStore/MemoryStore/MessagingService, or multiplayer trade QA is claimed. Those remain **UNVERIFIED IN ENGINE** until run in Studio/published test servers.

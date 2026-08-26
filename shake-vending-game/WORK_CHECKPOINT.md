# WORK CHECKPOINT — 2026-08-26

## Persistent target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- Source of truth: latest uploaded **Shake a Vending Machine — Front-Page Production Overhaul Master Prompt**.

This pass inspected the persisted branch before editing. Starting HEAD was `fed40be47e78fee1c5f5dc93c420b772c3846d02` (`Checkpoint responsive accessibility and audit reconciliation pass`).

## Stable production systems already persisted

- 60 launch collectibles, 10 per each of six vending machines.
- 12 mutation families plus None.
- Server-authoritative roll/inventory/progression/upgrades/settings/trading.
- Vending Passport, Hunt List, Lucky Meter, mastery, playtime gifts and multi-goal machine unlocks.
- Protected selling, favorites, locking, keep-one-each, shards, equipment and showcase references.
- Six-slot showcase, wearable collectibles, auras/trails/titles/outfits.
- Journaled two-stage trading with READY reset, countdown/revalidation and interrupted-commit reconciliation.
- MemoryStore hourly rare board, MessagingService rare feed and timed/global event systems.
- Centralized token-bucket remote limiting and autosave snapshot-rewind protection.
- Creator Store donor loading/sanitation with no runtime third-party script execution.
- Authored pixel-retail HUD/collection art directors wired through `ClientBootstrap.client.lua`.
- Authored six-district Downtown composition with selected sanitized donor geometry where useful.
- Authored `OlympusKitbash` vending fascia layered onto the persisted machine shells.
- Staged physical vending interaction with keypad acknowledgement, constrained rattle, product inertia, suspense, CLUNK and tray kick.
- Distinct mutation/reveal VFX source language with quality/distance bounds.
- Categorized audio architecture with group mixing, positional cues, spam control and rarity ducking.
- Responsive safe-area layout, compact bottom navigation, gamepad focus recovery and reduced-motion integration.

## Work completed in this pass — collection performance architecture

### Virtualized collection previews

`CollectionArtDirector.lua` previously destroyed and recreated the complete visible-result set on every render, including one `ViewportFrame`, `WorldModel`, camera and cloned donor model for every discovered inventory/catalog item. That architecture scaled poorly for the master prompt's 100+ inventory requirement.

The collection grid now uses lightweight `VirtualSlot` layout frames for the complete result set while mounting heavy cards only inside the currently visible row window plus one overscan row.

Implemented:

- visible-window calculation from `CanvasPosition`, `AbsoluteSize`, cell size and padding;
- one-row overscan to prevent pop-in during normal scrolling;
- automatic unmount/destruction of offscreen heavy cards and their nested 3D preview resources;
- one deferred/coalesced mount refresh for rapid scroll events instead of rebuilding repeatedly inside the event burst;
- `CollectionRenderGeneration` protection so stale deferred work cannot remount a previous search/sort/profile snapshot;
- responsive column-count recalculation when the collection viewport size changes;
- `AutomaticCanvasSize` retention for scrolling behavior;
- existing authored rarity/card interaction, hunt behavior and item inspection retained inside the mounted cards.

This reduces live preview-model count from O(total matching inventory) to O(visible cards + overscan) while keeping lightweight slots for deterministic `UIGridLayout` ordering.

### Regression tooling

Added `tools/performance_check.py` and wired it into `.github/workflows/shake-vending-production-checks.yml`.

The gate verifies persisted virtualization state, lightweight slots, scroll-driven mounting, overscan, offscreen release, coalescing, viewport-resize refresh and stale-render protection. It also preserves the explicit boundary that static checks are not measured Studio/device profiling.

Updated `PERFORMANCE_AUDIT.md` to document the new architecture and the remaining 100+/250+/max-capacity MicroProfiler checks.

## CI status for this pass

The source implementation commit is `341a89b0a542955cb101d0d756cdfb48393c55dc`. Documentation followed on `855dec6986564d65aaf6b4b50ce3bd1ad2de77d9` and this checkpoint commit.

Production workflow run #41 was triggered by the implementation commit. Final release status for this run must be based on the newest exact-head workflow after documentation/checkpoint changes complete; do not reuse the previous run #40 as proof for these changes.

## Current structural counts

Latest previously-green structural CI verified:

```text
60 launch items
10 items per machine x 6
12 mutations + None
27 manifest Creator Store base assets
54 Lua source files
```

This pass adds one Python regression tool and does not change launch item or manifest counts.

## Remaining release blockers

The project is **not release-certified**. Source gates cannot replace the following in-engine/published checks:

1. Roblox Studio visual QA of all six vending shells + `OlympusKitbash` orientations, clipping, product rows, tray/drop placement, collision/pivots and scale.
2. Studio QA of all 60 collectible donors in reveal, catalog viewport, wearable and showcase contexts; replace visually poor/mismatched donors rather than accepting merely loadable assets.
3. Real player-camera world composition/readability review across Downtown, including spawn sightline, district differentiation, signage, density and global-board visibility.
4. Audio permission/listening pass: verify persisted IDs, replace provisional reused sounds with individually curated permitted free Creator Store audio, add/tune appropriate background music, and test mix on phone/headphones/desktop.
5. Studio emulator and physical-device checks for phone/tablet safe areas, touch targets, virtual-keyboard overlap, text truncation and modal ergonomics.
6. Full controller traversal through every menu, confirmation, trade state, collection grid and onboarding state to catch focus traps.
7. Low-end performance profiling, now specifically including rapid Collection scrolling at 100+, 250+ and maximum-capacity inventories and verification that live ViewportFrame/WorldModel counts remain bounded while offscreen cards are released.
8. Published DataStore/MemoryStore/MessagingService QA plus two-player trade/disconnect/rejoin reconciliation.

Do not label or package `shake-vending-game-ULTIMATE.zip` as a final release until those in-engine gates are honestly cleared. A test/review package may be produced separately if explicitly requested.

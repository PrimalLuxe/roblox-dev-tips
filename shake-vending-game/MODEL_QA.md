# Creator Store Model QA

## Pipeline policy

Creator Store content is used as donor geometry, not trusted runtime code. `AssetLoadService` loads manifest-approved asset IDs with `AssetService:LoadAssetAsync` and sanitizes loaded content before it is placed in `ReplicatedStorage.Assets.ImportedModels`.

Sanitization removes executable scripts/modules, remotes/bindables, tools, humanoids/animation controllers, sounds, click detectors, proximity prompts, body movers, joints, and constraints. Base parts are anchored and made non-colliding until a consuming world system deliberately creates predictable collision behavior.

`ItemVisualFactory` selects exact manifest donors first, then constrained family fallbacks. Pack-style donors use semantic candidate extraction. Missing donors now return `nil` and warn once; there is no generated red-neon missing-item cube.

## Source-level checks completed

- 60 launch collectible definitions map to manifest asset keys.
- Each of the six launch machines has 10 collectible definitions.
- 40 Creator Store manifest entries are present.
- Exact donor keys used by the launch catalog include dedicated cookie, plush, slime and dice donors.
- WorldBuilder uses Creator Store vending/shop/gallery/environment donors for visible architecture; generated geometry is limited to infrastructure such as paths, signage, collision hulls and setup diagnostics.
- Runtime source contains no `InsertService`, numeric `require`, `loadstring`, `HttpGet`, `GetObjects`, or direct runtime `LoadAsset` fallback paths.
- Showcase/cosmetic/reveal callers tolerate a missing donor without corrupting item ownership or economy state.

## Manual inspection still required

Asset IDs were not fabricated or re-labeled during this pass. However, source inspection cannot prove what a Creator Store asset currently renders as, whether it has changed upstream, whether its textures are moderated/available to the experience, or whether its pivot/orientation fits the game.

Before release, inspect every auto-loaded donor in Studio and record any rejected/replaced asset in `ASSET_CREDITS.md` / `VISUAL_ASSET_AUDIT.md`. Pay particular attention to vending machines, shop facades, podiums, UI donor packs, large multi-model packs, and every donor used as a wearable.

## Status

**SOURCE/MANIFEST INTEGRITY: PASS**  
**RUNTIME SANITATION PATH: IMPLEMENTED**  
**MANUAL STUDIO DONOR VISUAL INSPECTION: NOT RUN**

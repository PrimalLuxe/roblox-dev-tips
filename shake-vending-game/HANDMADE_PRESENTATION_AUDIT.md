# Handmade Presentation Audit

This checkpoint exists because the first Studio screenshots exposed a major quality failure that static feature counts did not detect. The visible game was a tiny slab, oversized BillboardGui signage, donor architecture, and generic rounded UI. Those presentation paths are now treated as regressions.

## Player-facing geometry

- `WorldBuilder.lua` constructs Downtown from authored Roblox parts: road grid, curbs, sidewalks, storefront masses, upper-floor windows, awnings/marquees, street lamps, planters, benches, central kiosks, rare board, background buildings, and a showcase promenade.
- No full Creator Store shop/building/bench/lamp/tree/ATM/podium/UI model is used by WorldBuilder.
- `MachineArtDirector.lua` constructs all six vending chassis from parts. There is no underlying Creator Store vending model.
- Machine product rows use small authored geometry derived from the item's `VisualFamily` and color so the merchandising window does not clone whole donor packs.
- `ShowcaseService.lua` constructs physical player booths/podiums and physical SurfaceGui plaques. It no longer uses a free podium or always-on-top BillboardGui labels.

## UI

- `UIComponents.lua` is square/pixel-authored: offset pixel shadows, hard 2–3 px borders, corner cuts, accent bars, and tactile pixel button presses.
- `HudArtDirector.lua` creates compact pixel counters, a pixel navigation rail, pixel modal frames, and a compact bottom objective strip.
- `CollectionArtDirector.lua` creates pixel-framed 3D item cards with rarity bands, state chips, search/sort support and five distinct sort modes.
- The deterministic Olympus loading intro uses direct wordmarks and a pixel shutter transition, eliminating the letter-order bug from the first Studio test.

## Creator Store boundary

`AssetManifest.lua` now contains collectible/item donors only. World, vending-machine, UI, podium, kiosk and street architecture donors were removed from the runtime manifest. Item donors remain sandboxed and sanitized because the 60 collectible visuals still need semantic Studio QA.

## Automated gate

The current source passes:

- `python tools/static_check.py`
- `python tools/presentation_check.py`
- `python tools/visual_quality_check.py`
- `python tools/loop_sim.py`

These checks prove source architecture and regression rules, not visual parity with any reference game. Studio screenshots remain the actual visual-quality gate.

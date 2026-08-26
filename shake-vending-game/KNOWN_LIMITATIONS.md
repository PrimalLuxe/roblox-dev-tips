# Known Limitations

## Not verified in Roblox Studio

This source has been structurally/static tested, but this production pass did **not** run Roblox Studio. The following remain unverified in-engine and must not be described as visually or operationally certified yet:

- exact Creator Store donor appearance, pivots, scaling, tray alignment, textures, and asset permissions;
- player collision around imported buildings and vending-machine collision hulls;
- mobile safe-area behavior on real phone/tablet aspect ratios;
- gamepad focus flow across every panel and confirmation modal;
- audio asset permission/volume balance and spatial mix;
- particle/beam density under real client performance conditions;
- DataStore, MemoryStore, MessagingService, and multi-server behavior in a published test environment;
- two-player and disconnect/rejoin trading reconciliation under live persistence;
- world walking distances and first-session pacing with human players.

## Launch-content boundaries

Downtown is the only launch world currently marked released. `SunsetBoardwalk`, `MetroArcade`, and `Skyport` are roadmap definitions only and are deliberately not exposed as finished travel destinations.

The Unknown vending machine is event-only. It is not a permanent coin door and is intended to be available only during qualifying events after progression requirements are met.

## Creator Store dependency

The game intentionally fails loudly when required Creator Store donors cannot be loaded. It does not replace missing items with fake generated collectible geometry. Studio testing requires **Game Settings → Security → Allow Loading Third Party Assets** when testing the runtime donor loader.

All donor assets are sanitized at runtime by removing executable scripts, remotes, tools, sounds, joints/constraints, prompts, and other unsafe/unwanted runtime objects before use. This reduces risk but does not replace visual/manual donor inspection in Studio.

## Performance boundary

The code includes distance-bounded world-drop VFX, effect-quality settings, reduced-effects mode, bounded startup loading, and centralized animation/update paths. These are structural safeguards, not measured device benchmarks. Real low-end mobile profiling remains required before release.

## Release packaging

Do not call the branch visually release-ready or produce the final `shake-vending-game-ULTIMATE.zip` until Studio visual/device/multiplayer QA is completed and recorded in `STUDIO_VISUAL_QA.md`.

# Shake a Vending Machine — Production Overhaul Changelog

## Core loop

- Reframed the launch experience as **Downtown / World 1** rather than a flat list of vending machines.
- Added multi-goal machine gates combining money, discoveries, total shakes, machine mastery and rarity milestones.
- Added persisted Vending Passport progression and a three-slot Hunt List.
- Made Unknown an event-only hunt machine rather than a permanent high-price door.
- Added future world definitions as unreleased roadmap entries only.

## Collection, economy and safety

- Preserved a 60-item launch catalog: 10 collectibles per machine across six machines.
- Added truthful obtained-roll odds (`OneIn`) and natural-pool odds (`NaturalOneIn`) to item instances.
- Added server-authoritative weighted item/mutation rolls, Lucky Meter, beginner luck, combo luck and event modifiers.
- Added inventory capacity, automatic Legendary+ locking, favorites, keep-one-each behavior and duplicate-to-shard conversion.
- Added protected bulk sale modes; locked, favorited, equipped and showcased items are not mass-sold.
- Routed physical sell stations through a client confirmation instead of performing destructive server actions immediately.
- Retuned normal Downtown progression with loop simulation so normal machine unlocks are not hard-gated by rare RNG.

## World and vending presentation

- Built a compact six-district Downtown commercial hub using sanitized Creator Store architecture donors for visible buildings/machines.
- Added district signage, paths, Passport kiosk, collection/showcase area and global rare board.
- Added predictable machine collision hulls and donor tray/output discovery for drop placement.
- Added machine shake response, local collectible reveal, hover pickup, billboard rarity/odds, highlights, particles and higher-rarity screen reveal.
- Added distance-bounded world rare-drop presentation and reduced-effects/effect-quality support.

## Creator Store safety

- Added phased runtime loading through `AssetService:LoadAssetAsync` with manifest-approved IDs.
- Sanitized donor models by removing scripts, modules, remotes/bindables, tools, humanoids, animation controllers, sounds, prompts/click detectors, body movers, joints and constraints.
- Added exact/family/semantic donor selection for collectibles.
- Removed generated `MISSING_CREATOR_ASSET_*` collectible geometry. A missing donor now warns once and omits that visual without altering ownership/economy data.

## UI, onboarding and controls

- Restored a self-contained responsive HUD and collection/catalog UI to the persistent GitHub branch.
- Added collection search, sorting, viewport previews, item inspection, obtained vs natural odds, sell confirmation, equip and showcase picking.
- Added goals, upgrades, playtime gift, global board and accessibility/settings surfaces.
- Added Vending Passport/Hunt loop UI through `WorldLoopController`.
- Added onboarding persistence/reset support.
- Added touch pickup, gamepad pickup, gamepad focus handling and Button B/Escape panel closing.

## Avatar and showcase

- Added collectible wearables for head/face/shoulder/back plus aura, trail, title/nameplate support.
- Added outfit-slot persistence/reapply behavior.
- Added six editable showcase pedestals, an automatic rarest-item centerpiece and inspect plaques.

## Trading and social systems

- Added playtime/join cooldown gates and per-player trading toggle.
- Added offer item validation, non-tradeable tier checks, capacity checks and offer-change READY reset.
- Added explicit READY → CONFIRM → countdown flow.
- Added journaled persistent trade execution with idempotent reconciliation after interrupted commits/rejoins.
- Added cross-server rare-drop messaging and hourly MemoryStore rarity board.

## Events and engagement

- Added Normal, Golden, Frozen, Lucky, Glitch, Blackout, Mystery and Jammed restock states.
- Added cooperative Jammed progress with a 500-shake server target and temporary burst reward state.
- Added combo/overdrive state and server-timed playtime gifts.

## Reliability and regression work

- Fixed the DataStore autosave snapshot-rewind race: a delayed save no longer replaces the newer live profile with an older persisted snapshot.
- Added centralized token-bucket remote limiting and applied guards across interaction services.
- Added bounded asset/client startup waits and clearer startup diagnostics.
- Expanded `tools/static_check.py` to verify source-persistence/bootstrap integrity, Creator Store guardrails, truthful odds, sell confirmation routing, rate limiting, onboarding persistence, Passport/Hunt boot wiring and interaction markers.
- Added `tools/loop_sim.py` for Downtown progression regression simulation.

## Verification boundary

Static/structural tests and progression simulations have been run. Roblox Studio visual/device/multiplayer/persistence QA has **not** been run in this production pass and is documented separately in `STUDIO_VISUAL_QA.md` and `KNOWN_LIMITATIONS.md`.

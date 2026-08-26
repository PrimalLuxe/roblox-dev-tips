# Play in Roblox Studio

## Project

The Rojo source root is `shake-vending-game` and the project file is `default.project.json`.

Before Play, enable **Game Settings → Security → Allow Loading Third Party Assets** if you are testing the runtime Creator Store donor loader. The game intentionally shows a setup diagnostic instead of substituting fake art when required donors cannot load.

## First boot checks

Open **View → Output** before Play. Treat the first server/client error as the primary failure; later errors may be downstream symptoms.

Expected successful startup includes server boot creating `ReplicatedStorage.Remotes`, loading/sanitizing critical Creator Store donors, building Downtown, and client bootstrap initializing UI, audio, reveals, machines, showcase, Passport/Hunts, trading and onboarding.

If Creator Store assets fail, verify the Studio security setting first. Do not replace manifest IDs with guessed assets.

## Fast smoke test

1. Spawn in Downtown and confirm the Corner Store machine is immediately usable.
2. Shake with keyboard prompt and collect the physical reward. Verify item name, rarity and odds are readable.
3. Open Collection and switch between Inventory/Catalog. Search and sort; inspect an owned item.
4. Confirm single-item selling prompts before destructive action and bulk selling protects locked/favorited/equipped/showcased items.
5. Track an undiscovered Catalog item and verify the Hunt List HUD updates.
6. Use the physical Passport kiosk and inspect Downtown requirements.
7. Buy an upgrade and confirm the HUD/profile updates.
8. Equip a collectible wearable and place an item in a showcase slot.
9. With two clients, test trade request → offer → READY → change offer reset → READY → CONFIRM → countdown → completion.
10. Exercise touch/gamepad emulation: Button A pickup and Button B close must work.

## Persistence test

By default Studio persistence is disabled through `Config.StudioUseDataStores=false`. To test real persistence, use a published test place and intentionally enable the required DataStore/API access settings. Verify rejoin retention for coins, inventory, collection, machine unlocks, Passport/Hunts, settings, outfits and trade journals.

Never test destructive persistence behavior against production player data.

## Cross-server test

Use two published test servers to verify:

- Secret/Global rare finds reach the cross-server feed through MessagingService;
- qualifying drops appear on the hourly MemoryStore board;
- Blackout/event timing is consistent enough for intended gameplay;
- trading remains local-player-to-player while ownership persistence survives rejoin.

## Device/performance test

Use Studio device emulation plus at least one real low-end mobile device before release. Check collection viewport memory, multiple showcase displays, Secret/Global reveal effects, six visible vending districts, touch target sizes and safe-area behavior.

Record observed results in `STUDIO_VISUAL_QA.md`. Do not mark an item PASS based only on static source review.

## Static checks

From `shake-vending-game`:

```bash
python tools/static_check.py
python tools/loop_sim.py
```

`static_check.py` is a structural/regression gate, not a Luau runtime or visual test. `loop_sim.py` is an upper-bound progression model with immediate selling and no walking/decision time.

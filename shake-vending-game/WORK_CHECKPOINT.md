# WORK CHECKPOINT — 2026-08-26

## Persistent source target

- Repository: `PrimalLuxe/roblox-dev-tips`
- Branch: `shake-vending-production`
- Folder: `shake-vending-game`
- This checkpoint is intended to replace the earlier partial-source mirror with the complete Rojo text source tree.

## Implemented in this production run

- fixed DataStore autosave snapshot rewind race;
- persisted comfort/onboarding/auto-protection settings;
- centralized SoundManifest/AudioController and VFXManifest;
- bounded client remote waits and phased Creator Store loading;
- exact obtained-roll odds + natural-pool odds tracking;
- centralized remote token-bucket validation;
- bulk-sell confirmations and physical sell-station confirmation path;
- auto-lock Legendary+ and keep-one-each safeguards;
- collection search + Rarity/Odds/Value/Newest/Name sorting;
- persisted first-session onboarding and reset path;
- gamepad B/Escape close behavior and gamepad focus handoff;
- Jammed machine 0/500 cooperative physical progress display;
- six-district vending plaza layout using donor architecture rather than generated fake buildings;
- six editable showcase pedestals + automatic rarest centerpiece + read-only item plaques + one centralized 20 Hz distance-bounded animation loop;
- 5,000-run static economy simulation and late-game retune;
- complete 60/60 source-level visual mapping audit and donor provenance ledger.

## Validation

Run:

```bash
python tools/static_check.py
python tools/economy_sim.py
```

Roblox Studio visual QA remains mandatory before calling the game visually release-ready.

## 2026-08-26 — World / Passport / Hunt loop pass

- Added `WorldDefinitions.lua`; Downtown is now launch World 1 with future destinations explicitly unreleased.
- Added multi-goal machine unlock requirements; progression is no longer coin-only.
- Unknown is event-only and remains unavailable outside qualifying restock events even after discovery.
- Added persisted Vending Passport state and 3-slot Hunt List to profile v5.
- Added server-authoritative Hunt/Passport remotes, passport stamping, and hunt auto-completion on discovery.
- Added Passport UI, HUD hunt target, catalog track/untrack interaction, machine requirement HUD/prompts, and physical Passport kiosk.
- Added `tools/loop_sim.py` and expanded static regression checks.
- 1,000-run fast-seller loop simulation after retune: Sugar 2:48 median, Energy 4:44, Toy 13:44, Luxury 32:00; 100% reached all normal machines inside 75 minutes.
- `python tools/static_check.py`: PASS.

# Shake a Vending Machine — GitHub Work Checkpoint

This folder is the persistent source-of-truth branch for the production overhaul.

- Branch: `shake-vending-production`
- Project: Shake a Vending Machine / Olympus Entertainment
- Baseline source: uploaded `shake-vending-game-FINAL(3).zip`
- `main` is intentionally untouched.
- `rojo.exe` is intentionally not committed; use a trusted local Rojo install instead of storing an executable in source control.

## Current checkpoint

- 60-item / 6-machine data model retained.
- 12 mutation families retained.
- Creator Store runtime sanitation retained and strengthened.
- Asset loading split into Critical / Warm / Background / Lazy phases.
- ReplicatedFirst Olympus loading system added.
- Returning-player intro / reduced-effects settings are server-persisted.
- Effect quality, reduced screen shake, SFX, and skip-long-reveal settings are server-persisted.
- Existing static structural audit passes after the changes.

Do not merge this branch into the unrelated historical web content on `main`; this branch is being used as isolated persistent storage until the project is moved to a dedicated repository.
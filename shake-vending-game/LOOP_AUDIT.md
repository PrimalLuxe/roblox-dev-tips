# GAME LOOP AUDIT — WORLD / PASSPORT / HUNT PASS

## Core loop implemented in source

The launch world is now **Downtown**, not the complete lifetime content of the game.

`SHAKE → PHYSICAL REVEAL → KEEP/SELL → CATALOG → HUNT → MULTI-GOAL MACHINE UNLOCK → PASSPORT → FUTURE WORLD`

### Downtown launch path

1. Corner Store — immediate starter machine.
2. Sugar Rush — requires money plus early catalog/shake progress.
3. Energy — requires previous-machine progress plus catalog/shakes.
4. Toy Capsule — requires catalog progress, total shakes and Energy-specific mastery shakes.
5. Luxury — requires catalog progress, Toy Capsule mastery, an Epic+ discovery and money.
6. Unknown — event-only. It never becomes a permanently available coin door; it requires a Blackout/Mystery-type event plus progression requirements.

## Vending Passport

Profiles now persist a Passport and Hunt List. Downtown can be stamped after meaningful world completion targets instead of a rebirth reset. The passport grants a reward/title while preserving the player's collection.

Future destination definitions exist as **Released=false** roadmap entries only. They are not presented as finished playable content:

- Sunset Boardwalk
- Metro Arcade
- Skyport

## Hunt List

Players can track up to 3 undiscovered base collectibles from Catalog mode. Tracked items appear on the HUD with their source machine and natural odds. A tracked item automatically clears when first discovered.

## Machine unlock philosophy

Coin-only doors were removed as the sole progression condition. Machine unlocks combine:

- previous machine access;
- base-catalog discoveries;
- total shakes;
- selected machine mastery shakes;
- a rarity milestone where appropriate;
- coins.

This keeps upgrades/economy relevant without allowing one lucky high-value sell to skip the actual collection loop.

## Static loop simulation

`tools/loop_sim.py` runs 1,000 seeded fast-seller simulations. It is intentionally an upper-bound model: immediate selling, no walking/decision time, and no Studio feel assumptions.

Current fast-seller medians:

| Machine | Median unlock |
|---|---:|
| Sugar Rush | 2:48 |
| Energy | 4:44 |
| Toy Capsule | 13:44 |
| Luxury | 32:00 |

All four normal progression unlocks were reached by 100% of the 1,000 simulated runs within 75 minutes after retuning the first catalog gates. Unknown is excluded because it is event-only.

The Passport deliberately takes longer than normal machine progression and requires returning to older machines to fill missing catalog slots; this is the directed collection/hunting layer rather than another coin wall.

## Remaining loop work

- Build the first post-Downtown world with its own machine/item set before enabling travel.
- Add travel transition/portal only when World 2 has real content.
- Studio-playtest first-session timing, walking distances, and actual discovery pacing.
- Add analytics events for machine unlock, hunt tracking/completion, passport stamping, and world travel before live scale tests.

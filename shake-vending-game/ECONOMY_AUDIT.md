# ECONOMY AUDIT

Static Monte Carlo; **not a Roblox Studio playtest**. It models current source weights, mutation value multipliers, the configured 0.78s base shake cooldown, immediate sale of every drop, and immediate purchase of the next machine when affordable. It does not model human hesitation, walking time, upgrade purchases, collection holding, event luck, Beginner Luck, Lucky Meter guarantees, or mastery rewards, so it is a fast-seller baseline rather than a retention claim.

- Runs: 5,000
- Starting coins: 125
- Base shake cadence: 0.78s

## Unlock-time distribution

| Machine | Cost | P10 | Median | P90 | Reach by 60m |
|---|---:|---:|---:|---:|---:|
| SugarRush | $3,000 | 1:48 | 2:49 | 3:25 | 100.0% |
| Energy | $10,000 | 3:23 | 4:42 | 5:35 | 100.0% |
| ToyCapsule | $250,000 | 10:29 | 13:42 | 15:38 | 100.0% |
| Luxury | $2,500,000 | 25:45 | 31:51 | 35:32 | 100.0% |
| Unknown | $25,000,000 | 40:59 | 54:34 | 59:09 | 16.8% |

## Expected raw sell value per pull

| Machine | Expected base value | Expected value incl. mutation multiplier |
|---|---:|---:|
| CornerStore | $11.09 | $16.90 |
| SugarRush | $55.45 | $84.48 |
| Energy | $277.26 | $422.42 |
| ToyCapsule | $1,330.85 | $2,027.63 |
| Luxury | $6,654.23 | $10,138.15 |
| Unknown | $33,271.13 | $50,690.74 |

Weighted expected mutation value multiplier: **1.5236×**.

## Interpretation

- These numbers are a regression baseline, not a promise of player behavior.
- Active sellers should always have a visible achievable next objective; collection-focused players will progress more slowly because they retain items.
- Studio playtests should validate travel time, UI friction, perceived reward frequency, and whether early upgrades materially alter these timings.
- If future balance changes alter item weights, values, mutation multipliers, machine costs, or shake cadence, rerun `python tools/economy_sim.py` and review this file before release.

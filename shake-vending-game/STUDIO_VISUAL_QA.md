# Studio Visual QA

**Status: UNVERIFIED IN ENGINE**

No Roblox Studio session was available during this production pass. This file is intentionally a verification record, not a fabricated pass report.

## Required Studio pass before release

| Area | Required verification | Status |
| --- | --- | --- |
| Startup | No first server/client error; Remotes and all boot modules initialize | NOT RUN |
| Creator Store | All critical donors load and sanitized clones preserve intended visuals | NOT RUN |
| Downtown | District facades, walks, signage, spawn, Passport kiosk and Global Board read correctly | NOT RUN |
| Machines | Six machine shells scale/orient correctly; collision hulls do not snag players | NOT RUN |
| Drop tray | Reveal origin visually aligns with each donor machine's tray/output | NOT RUN |
| Reveals | Common through Global drops have readable scale, billboard, highlight, particles and timing | NOT RUN |
| Mutations | All 12 mutations remain visually distinguishable on representative item families | NOT RUN |
| Missing donors | Missing donor produces diagnostic/omitted visual, not fake placeholder geometry | NOT RUN |
| Collection UI | Search, sorting, inventory/catalog switch, viewport items, item details and sell confirmation | NOT RUN |
| Passport/Hunts | Three-slot Hunt List, auto-complete, stamp requirements, physical kiosk | NOT RUN |
| Showcase | Six editable displays plus automatic rarest centerpiece and inspect plaques | NOT RUN |
| Avatar | Head/shoulder/back/aura/trail/title placement on R15 and acceptable R6 fallback behavior | NOT RUN |
| Trading | Request, offer edits, ready reset, confirm, countdown, completion, disconnect/rejoin recovery | NOT RUN |
| Events | Golden/Frozen/Lucky/Glitch/Blackout/Mystery/Jammed state and live Jammed progress | NOT RUN |
| Audio | Rattle/clunk/rarity/UI audio permission, balance and spatial behavior | NOT RUN |
| Mobile | Touch pickup, panel scaling, safe-area readability and no blocked controls | NOT RUN |
| Gamepad | Proximity prompts, Button A pickup, focus navigation and Button B close | NOT RUN |
| Accessibility | Reduced effects, reduced screen shake, skip long reveals, SFX/music toggles persist | NOT RUN |
| Performance | Low-end mobile and desktop MicroProfiler pass under multiple simultaneous drops | NOT RUN |
| Persistence | Published test with DataStore enabled; rejoin retains inventory/progression/settings | NOT RUN |
| Cross-server | MemoryStore hourly board and MessagingService rare feed in two published servers | NOT RUN |

## Acceptance rule

A row may only be changed to PASS after the behavior is observed in Studio or a published test server. Failures should include a concrete reproduction, device/test mode, and the commit SHA tested. Static checks are not substitutes for this file.

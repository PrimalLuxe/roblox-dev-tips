# Performance Audit

## Structural safeguards implemented

The current source is designed to avoid several common simulator-performance failures before device profiling begins.

| Area | Current safeguard |
| --- | --- |
| Creator Store loading | Critical/warm/background phases with bounded worker counts and startup timeout |
| World rare-drop VFX | Ignore non-local rare reveals outside `ReducedVfxDistance`; reduced presentation outside `FullVfxDistance` |
| Local VFX | Effect quality plus Reduced Effects setting; particle rate bounded by `MaxLocalParticles` |
| Collection UI | Virtualized scrolling grid: every result gets only a lightweight layout slot; heavy item cards, ViewportFrames, cameras and cloned item models are mounted only for the visible window plus one overscan row |
| Collection cleanup | Offscreen mounted cards are destroyed; scroll/resize work is deferred and coalesced; render generations prevent stale deferred work from remounting an older snapshot |
| Drop animation | One RenderStepped connection for the active local reward instead of one loop per effect object |
| Showcase | Server creates a bounded six-slot display plus one centerpiece per player |
| Remotes | Central token-bucket limiting prevents high-frequency UI/action spam from multiplying server work |
| Assets | Runtime clones are sanitized; scripts/tools/remotes from donor models do not execute |
| Trading | Maximum offered items is bounded and validation is performed before commit |
| Inventory | Capacity is bounded by progression; large inventories no longer imply one live 3D preview model per stored item while Collection is open |

## Collection virtualization pass — 2026-08-26

Collection previously rebuilt every heavy card and every discovered-item 3D preview on every sort, search and profile refresh. That made refresh cost scale directly with inventory size and kept all preview models resident while scrolling.

The replacement preserves UIGridLayout ordering through lightweight VirtualSlot frames, derives the visible row window from CanvasPosition and viewport size, and mounts only visible cards plus one overscan row. Cards leaving the window are destroyed, releasing their WorldModel, sanitized donor clone and Camera. Scroll events are coalesced through one deferred mount request, and a render-generation token rejects stale deferred work after a newer render.

This materially reduces live UI/model instance count for 100+ item inventories without reducing catalog content or preview quality.

## Static audit result

Production CI now includes `python tools/performance_check.py` in addition to the existing structural, presentation, visual, audio, accessibility and progression gates. The performance architecture gate verifies collection virtualization, offscreen release, deferred/coalesced scroll refresh and stale-render protection.

This is a source-level architecture audit; it is not a frame-time benchmark.

## Required measured profiling

Before release, profile in Studio/published test servers with MicroProfiler and Developer Console on at least one low-end mobile target and one desktop target. Record:

- client frame time while 6 machines are visible;
- client frame time during Secret/Global reveal VFX;
- memory after repeated collection panel opening/closing and 100+ inventory items;
- collection scroll frame time with 100+, 250+ and maximum-capacity inventories;
- live ViewportFrame/WorldModel count while rapidly scrolling and after closing Collection;
- server script time with 20+ concurrent players shaking;
- network receive/send rates during events and global announcements;
- instance counts for Downtown, showcases, active VFX and UI;
- asset load latency and failure behavior on a fresh client.

## Provisional performance risks

Imported Creator Store donors can contain unexpectedly high mesh/texture complexity even after sanitization. Source inspection cannot determine final triangle/texture cost. The six-district world still needs measured profiling and visual donor inspection.

Virtualization bounds simultaneous item preview models, but individual donor complexity still matters. Studio profiling should verify that the heaviest sanitized donor can enter and leave the visible window repeatedly without visible frame spikes or delayed cleanup.

Cross-server services are rate-limited by their use pattern but still need published-server testing for MemoryStore/MessagingService quotas and failure behavior.

## Release status

**STATIC PERFORMANCE ARCHITECTURE: PASS WHEN CI IS GREEN**  
**MEASURED STUDIO/DEVICE PERFORMANCE: NOT RUN**

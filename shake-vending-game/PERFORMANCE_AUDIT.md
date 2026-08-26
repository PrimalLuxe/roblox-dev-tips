# Performance Audit

## Structural safeguards implemented

The current source is designed to avoid several common simulator-performance failures before device profiling begins.

| Area | Current safeguard |
| --- | --- |
| Creator Store loading | Critical/warm/background phases with bounded worker counts and startup timeout |
| World rare-drop VFX | Ignore non-local rare reveals outside `ReducedVfxDistance`; reduced presentation outside `FullVfxDistance` |
| Local VFX | Effect quality plus Reduced Effects setting; particle rate bounded by `MaxLocalParticles` |
| UI | Collection uses one scrolling grid and on-demand viewport creation; no per-card RenderStepped coroutine |
| Drop animation | One `RenderStepped` connection for the active local reward instead of one loop per effect object |
| Showcase | Server creates a bounded six-slot display plus one centerpiece per player |
| Remotes | Central token-bucket limiting prevents high-frequency UI/action spam from multiplying server work |
| Assets | Runtime clones are sanitized; scripts/tools/remotes from donor models do not execute |
| Trading | Maximum offered items is bounded and validation is performed before commit |
| Inventory | Capacity is bounded by progression rather than unbounded client rendering |

## Static audit result

The complete current working tree passed `python tools/static_check.py` with 46 Lua source files, 60 launch items, 12 mutations plus None, and 40 Creator Store manifest entries. This verifies structural markers and known regression guards only; it is not a frame-time benchmark.

## Required measured profiling

Before release, profile in Studio/published test servers with MicroProfiler and Developer Console on at least one low-end mobile target and one desktop target. Record:

- client frame time while 6 machines are visible;
- client frame time during Secret/Global reveal VFX;
- memory after repeated collection panel opening/closing and 100+ inventory items;
- server script time with 20+ concurrent players shaking;
- network receive/send rates during events and global announcements;
- instance counts for Downtown, showcases, active VFX, and UI;
- asset load latency and failure behavior on a fresh client.

## Provisional performance risks

Imported Creator Store donors can contain unexpectedly high mesh/texture complexity even after sanitization. The code cannot determine visual triangle/texture cost from source text alone. The six-district world therefore still needs manual donor inspection and measured profiling.

Viewport previews clone sanitized item donors. Large inventories can still create a meaningful amount of UI/model memory while the collection panel is open. If profiling shows pressure on low-end devices, the next optimization should be card virtualization/pooling rather than reducing gameplay content.

Cross-server services are rate-limited by their use pattern but need published-server testing for MemoryStore/MessagingService quotas and error behavior.

## Release status

**STATIC SAFEGUARDS: PASS**  
**MEASURED STUDIO/DEVICE PERFORMANCE: NOT RUN**

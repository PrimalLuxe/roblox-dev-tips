# Persistent Work Checkpoints

These files preserve the exact production-overhaul delta even when a controller is too large to upload as a single connector write.

## 2026-08-26 checkpoint

Baseline: `shake-vending-game-FINAL(3).zip`

Patch parts, in byte order:

- `2026-08-26.patch.part00`
- `2026-08-26.patch.part01`
- `2026-08-26.patch.part02`
- `2026-08-26.patch.part03`
- `2026-08-26.patch.part04`
- `2026-08-26.patch.part05`
- `2026-08-26.patch.part06`

Expected reconstructed patch SHA-256:

`7b55a4c8a295da22f43f578499686e8d17675404124cb98b85ce7509e56e6b00`

The source checkpoint ZIP made from the working tree (excluding `rojo.exe`) had SHA-256:

`36cf7279304d6a565e61aaab6d3b9c4e6a1d2962723362e36bbdc2689aeac4f3`

### Reconstruct the patch without changing bytes

```python
from pathlib import Path
parts = [Path(f"2026-08-26.patch.part{i:02d}") for i in range(7)]
Path("2026-08-26.patch").write_bytes(b"".join(p.read_bytes() for p in parts))
```

Verify the SHA-256 before applying it.

The patch was generated with absolute sandbox paths. From the root of a fresh extraction of the baseline project, GNU `patch -p4 < 2026-08-26.patch` strips `/mnt/data/shake_vending_orig/shake-vending-game-FINAL/` and applies the changed/new files.

## Validation at checkpoint

`python3 tools/static_check.py` passed with:

- 60 items
- 10 items per each of 6 machines
- 12 mutations plus `None`
- 40 Creator Store base assets
- 38 Lua files after adding the new loading/settings modules
- referential integrity, feature markers, runtime asset safety, and lightweight structural checks passing

Roblox Studio was not available in the execution environment, so this is a static/structural checkpoint, not a claim of completed in-Studio visual QA.

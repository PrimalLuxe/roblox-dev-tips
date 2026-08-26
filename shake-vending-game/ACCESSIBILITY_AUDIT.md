# Mobile, Gamepad & Accessibility Audit

## Source-side implementation

`AccessibilityController.lua` now owns responsive presentation behavior after the authored HUD/catalog directors finish building the interface.

### Safe-area behavior

- `ShakeUI.IgnoreGuiInset` is overridden to `false` after construction.
- `ScreenInsets` uses `Enum.ScreenInsets.CoreUISafeInsets`.
- `ClipToDeviceSafeArea` is enabled.
- This keeps interactive HUD/navigation away from Roblox Core UI and device cutouts without changing the authored desktop composition at normal viewports.

### Compact/mobile layout

At viewports narrower than 760 px or shorter than 560 px:

- the four top counters reflow into a two-column / two-row HUD;
- the desktop left navigation rail becomes a bottom dock with up to four columns;
- the progression objective moves above that dock;
- modal `UIScale` is recalculated against the actual viewport and may reduce to 0.28 for the 920 px collection surface instead of being trapped at the legacy 0.52 minimum;
- desktop geometry is captured once and restored when the viewport grows again, preventing resize accumulation/drift.

The controller responds to camera/viewport replacement and resize rather than assuming the launch viewport is permanent.

### Gamepad

- GUI buttons and text boxes are explicitly selectable.
- Selection order is assigned for generated controls.
- A high-contrast gold selection image is installed through `PlayerGui.SelectionImageObject`.
- When gamepad input becomes active, the first actionable control in the visible top panel is selected.
- Existing `ButtonB` panel-close behavior remains in `UIController`.

### Reduced motion

The client bootstrap reads `GuiService.ReducedMotionEnabled`. When the platform preference is enabled, the effective client-only presentation settings force `ReducedEffects` and `ReducedScreenShake` on before reveal/audio presentation controllers consume them. This does not overwrite the saved profile setting; it is a local accessibility override.

## Regression coverage

`tools/mobile_accessibility_check.py` guards:

- Core UI safe-area configuration;
- compact HUD/navigation markers;
- progression-goal relocation;
- modal downscaling;
- desktop baseline restoration;
- selection image and selection order;
- gamepad focus;
- Button B support;
- platform reduced-motion wiring.

The production GitHub Actions workflow runs this audit alongside structural, presentation, visual-quality, audio, and economy/progression checks.

## Verification boundary

This is a source/structural audit only. It does **not** certify visual quality or touch ergonomics on real hardware.

Release QA still requires Roblox Studio device emulation and, ideally, physical-device checks at representative phone/tablet aspect ratios, plus controller navigation through every modal, confirmation path, collection grid, trading surface, and onboarding state. Text truncation, touch target comfort, safe-area appearance, virtual-keyboard overlap, controller focus loops and performance must be judged in-engine before release certification.

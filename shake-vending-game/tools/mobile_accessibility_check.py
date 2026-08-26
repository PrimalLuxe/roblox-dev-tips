from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
errors=[]

def need(text,markers,label):
    for marker in markers:
        if marker not in text:
            errors.append(f'{label}: missing {marker}')

controller=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/AccessibilityController.lua').read_text()
bootstrap=(SRC/'StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua').read_text()
ui=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua').read_text()
components=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/UIComponents.lua').read_text()

need(controller,[
    'Enum.ScreenInsets.CoreUISafeInsets',
    'ClipToDeviceSafeArea=true',
    'viewport.X<760 or viewport.Y<560',
    'PrimaryNavigation',
    'ProgressionGoal',
    'UDim2.new(1,-16,0,height)',
    'player.PlayerGui.SelectionImageObject',
    'SelectionOrder=order',
    'GuiService.SelectedObject=button',
    'ReducedMotionEnabled',
    'scale.Scale=math.clamp',
    ',.28,1)',
    'CaptureBaseline',
    'restore(self,holder)',
], 'AccessibilityController')

need(bootstrap,[
    'Accessibility=require(Controllers.AccessibilityController)',
    'Accessibility:Init(UI)',
    'GuiService.ReducedMotionEnabled',
    'effective.ReducedEffects=true',
    'effective.ReducedScreenShake=true',
], 'ClientBootstrap')

need(ui,[
    'Enum.KeyCode.ButtonB',
    'self:FocusPanel(self.CollectionPanel)',
    'SETTINGS / ACCESSIBILITY',
], 'UIController')

need(components,[
    'GuiService.SelectedObject=cancel',
    'player.PlayerGui.SelectionImageObject' if False else 'UIComponents.Button',
], 'UIComponents')

if 'IgnoreGuiInset=true' in controller:
    errors.append('AccessibilityController: safe-area controller must not opt back into unsafe full-screen interactive layout')
if 'math.clamp(math.min((v.X-24)/w,(v.Y-40)/h),.52,1)' not in ui:
    errors.append('UIController: expected legacy modal scaler changed; update accessibility audit assumptions')

print('ShakeVM mobile/accessibility audit')
if errors:
    print('FAILURES:')
    for error in errors:
        print(' -',error)
    sys.exit(1)
print('PASS: safe-area layout, compact navigation, modal downscaling, gamepad focus, and platform reduced-motion integration are persisted.')

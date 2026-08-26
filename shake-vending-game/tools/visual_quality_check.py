from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
def read(rel): return (SRC/rel).read_text()
art=read('ServerScriptService/Services/MachineArtDirector.lua')
world=read('ServerScriptService/Services/WorldBuilder.lua')
polish=read('ServerScriptService/Services/WorldPolishService.lua')
showcase=read('ServerScriptService/Services/ShowcaseService.lua')
motion=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua')
machine=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua')
hud=read('StarterPlayer/StarterPlayerScripts/Controllers/HudArtDirector.lua')
collection=read('StarterPlayer/StarterPlayerScripts/Controllers/CollectionArtDirector.lua')
components=read('StarterPlayer/StarterPlayerScripts/Controllers/UIComponents.lua')
accessibility=read('StarterPlayer/StarterPlayerScripts/Controllers/AccessibilityController.lua')
loading=read('ReplicatedFirst/Loading.client.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
theme=read('ReplicatedStorage/Shared/UITheme.lua')
drop=read('StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua')
factory=read('ReplicatedStorage/Shared/ItemVisualFactory.lua')
for marker in ['function MachineArtDirector.Apply','OlympusKitbash','BackCase','DisplayGlass','Shelf','MachineScreen','CardReader','CoinSlot','DispenseTray','AccessPanel','Vent','miniProduct']:
    assert marker in art, f'authored vending fascia marker missing: {marker}'
assert 'ItemVisualFactory' not in art and 'AssetVariant' not in art, 'vending fascia depends on item/runtime donor selection'
for machine_id in ['CornerStore','SugarRush','Energy','ToyCapsule','Luxury','Unknown']:
    assert machine_id in art and machine_id in world, f'machine/world identity missing: {machine_id}'
for marker in ['BUILDING_STYLES','RoadNorthSouth','RoadEastWest','CentralPlaza','storefront(hub','surfaceSign','lamp(hub','bench(hub','DowntownDirectory','PassportDirectory','GlobalBoard']:
    assert marker in world, f'authored Downtown composition missing: {marker}'
assert 'BillboardGui' not in world, 'world signage regressed to billboard spam'
for marker in ['sanitizeClone','d:IsA("BaseScript")','d:IsA("ModuleScript")','d:IsA("RemoteEvent")','d:IsA("RemoteFunction")','MachineArtDirector.Apply']:
    assert marker in world, f'curated donor sanitation/integration marker missing: {marker}'
assert 'fillFacades' not in polish and 'MachineArtDirector.Apply' not in polish, 'secondary competing vending/facade visual pass returned'
assert 'BillboardGui' not in showcase and 'importedPodium' not in showcase and 'HandBuiltShowcase' in showcase, 'showcase is not authored physical presentation'
assert 'MachineScreen' in machine and 'machineScreen(machine)' in machine and 'CHECK REQUIREMENTS' in machine, 'machine status is not using the physical control display'
assert 'UIListLayout' not in loading and 'olympus.Text="OLYMPUS"' in loading and 'E N T E R T A I N M E N T' in loading, 'loading logo can scramble or is not authored'
for marker in ['SHAKING','VENDING...','COLLECT!','Product_','PlayMachine("Rattle"','PlayMachine("Clunk"','ToObjectSpace']:
    assert marker in motion, f'mechanical interaction marker missing: {marker}'
for marker in ['PixelNavRail','VENDING MENU','COINS','CATALOG','NEXT OBJECTIVE']:
    assert marker in hud, f'pixel HUD marker missing: {marker}'
for marker in ['PixelCatalogSortBar','ItemCard_','PreviewWell','Rarity','Odds','Value','Newest','Name']:
    assert marker in collection, f'pixel collection marker missing: {marker}'
assert 'PixelBorder' in components and 'UICorner' not in components, 'shared UI primitives are not pixel-built'
for marker in ['CoreUISafeInsets','ClipToDeviceSafeArea=true','PrimaryNavigation','ProgressionGoal','SelectionImageObject','ReducedMotionEnabled']:
    assert marker in accessibility, f'accessibility/responsive presentation marker missing: {marker}'
assert 'HudArt:Apply(UI)' in client and 'CollectionArt:Apply(UI)' in client and 'Accessibility:Init(UI)' in client
assert 'SimulatorUI' not in theme and 'Pixel=3' in theme, 'runtime UI theme is not authored pixel identity'
assert ('addMutationLanguage' in drop and 'VFX.GetMutation' in drop) or 'RevealVFX' in drop
for marker in ['pack','bundle','partCount>18','bestScore<5']:
    assert marker in factory, f'pack donor safety marker missing: {marker}'
print('PASS: authored Downtown composition, curated donor sanitation, vending fascia, physical showcase, deterministic loading, pixel UI and responsive accessibility guardrails present.')

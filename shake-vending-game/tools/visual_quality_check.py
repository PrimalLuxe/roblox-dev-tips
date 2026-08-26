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
loading=read('ReplicatedFirst/Loading.client.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
theme=read('ReplicatedStorage/Shared/UITheme.lua')
drop=read('StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua')
factory=read('ReplicatedStorage/Shared/ItemVisualFactory.lua')
for marker in ['function MachineArtDirector.Build','HandBuiltMachine','OlympusKitbash','BackCase','MainCase','DisplayGlass','Shelf','MachineScreen','CardReader','CoinSlot','DispenseTray','AccessPanel','Vent','miniProduct']:
    assert marker in art, f'hand-built machine marker missing: {marker}'
assert 'ItemVisualFactory' not in art and 'AssetVariant' not in art, 'vending visuals still depend on donor chassis/items'
for machine_id in ['CornerStore','SugarRush','Energy','ToyCapsule','Luxury','Unknown']:
    assert machine_id in art and machine_id in world, f'machine/world identity missing: {machine_id}'
for marker in ['MainRoad','NorthSidewalk','SouthSidewalk','WestCrossStreet','EastCrossStreet','storefront(hub','upperWindow','streetLamp','planter','bench','backgroundBuilding','ShowcasePromenade']:
    assert marker in world, f'authored Downtown composition missing: {marker}'
assert 'BillboardGui' not in world, 'world signage regressed to billboard spam'
assert 'cloneWorldAsset' not in world and 'LowPolyShop' not in world and 'VendingMachineDetailed' not in world, 'visible world reverted to full donor models'
assert 'fillFacades' not in polish and 'MachineArtDirector.Apply' not in polish, 'secondary donor visual pass returned'
assert 'BillboardGui' not in showcase and 'importedPodium' not in showcase and 'HandBuiltShowcase' in showcase, 'showcase is not authored physical presentation'
assert 'MachineScreen' in machine and 'machineScreen(machine)' in machine, 'machine status is not using the physical control display'
assert 'UIListLayout' not in loading and 'olympus.Text="OLYMPUS"' in loading and 'E N T E R T A I N M E N T' in loading, 'loading logo can scramble or is not authored'
for marker in ['SHAKING','VENDING...','COLLECT!','Product_','PlayMachine("Rattle"','PlayMachine("Clunk"','ToObjectSpace']:
    assert marker in motion, f'mechanical interaction marker missing: {marker}'
for marker in ['PixelNavRail','VENDING MENU','COINS','CATALOG','NEXT OBJECTIVE']:
    assert marker in hud, f'pixel HUD marker missing: {marker}'
for marker in ['PixelCatalogSortBar','ItemCard_','PreviewWell','Rarity','Odds','Value','Newest','Name']:
    assert marker in collection, f'pixel collection marker missing: {marker}'
assert 'PixelBorder' in components and 'UICorner' not in components, 'shared UI primitives are not pixel-built'
assert 'HudArt:Apply(UI)' in client and 'CollectionArt:Apply(UI)' in client
assert 'SimulatorUI' not in theme and 'Pixel=3' in theme, 'runtime UI theme is not authored pixel identity'
assert ('addMutationLanguage' in drop and 'VFX.GetMutation' in drop) or 'RevealVFX' in drop
for marker in ['pack','bundle','partCount>18','bestScore<5']:
    assert marker in factory, f'pack donor safety marker missing: {marker}'
print('PASS: handmade Downtown, handmade vending chassis/product geometry, physical showcase, deterministic loading, and pixel UI guardrails present.')

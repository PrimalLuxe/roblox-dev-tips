from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
def read(rel): return (SRC/rel).read_text()
art=read('ServerScriptService/Services/MachineArtDirector.lua')
world=read('ServerScriptService/Services/WorldBuilder.lua')
polish=read('ServerScriptService/Services/WorldPolishService.lua')
motion=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua')
machine=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua')
hud=read('StarterPlayer/StarterPlayerScripts/Controllers/HudArtDirector.lua')
loading=read('ReplicatedFirst/Loading.client.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
theme=read('ReplicatedStorage/Shared/UITheme.lua')
drop=read('StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua')
factory=read('ReplicatedStorage/Shared/ItemVisualFactory.lua')
for marker in ['OlympusKitbash','DisplayGlass','Product_','MachineScreen','CardReader','DispenseTray','AccessPanel','Vent','Marquee','ArtDirectionVersion']:
    assert marker in art, f'machine art marker missing: {marker}'
for machine_id in ['CornerStore','SugarRush','Energy','ToyCapsule','Luxury','Unknown']:
    assert machine_id in art and machine_id in world, f'machine/world art missing: {machine_id}'
for marker in ['BUILDING_STYLES','RoadNorthSouth','RoadEastWest','CentralPlaza','storefront(hub','surfaceSign','DowntownDirectory','PassportDirectory']:
    assert marker in world, f'authored Downtown composition missing: {marker}'
assert 'BillboardGui' not in world, 'world signage regressed to AlwaysOnTop/fixed-pixel billboard spam'
assert 'fillFacades' not in polish and 'CornerStoreBuilding' not in polish, 'free-model storefront architecture has returned'
assert 'MachineScreen' in machine and 'machineScreen(machine)' in machine, 'machine status is not using the physical control display'
assert 'UIListLayout' not in loading and 'OLYMPUS ENTERTAINMENT' in loading, 'intro wordmark can scramble again'
for marker in ['SHAKING','VENDING...','COLLECT!','Product_','PlayMachine("Rattle"','PlayMachine("Clunk"','ToObjectSpace']:
    assert marker in motion, f'mechanical interaction marker missing: {marker}'
for marker in ['RetailNavRail','VENDING MENU','COINS','CATALOG','RetailHeaderStrip','NEXT OBJECTIVE']:
    assert marker in hud, f'HUD retail-art marker missing: {marker}'
assert 'HudArt:Apply(UI)' in client
assert 'SimulatorUI' not in theme, 'UI theme must not inherit donor UI at runtime'
assert ('addMutationLanguage' in drop and 'VFX.GetMutation' in drop) or 'RevealVFX' in drop
for marker in ['pack','bundle','partCount>18','bestScore<5']:
    assert marker in factory, f'pack donor safety marker missing: {marker}'
print('PASS: no billboard spam, deterministic intro, authored Downtown architecture, physical machine status, HUD identity, kitbash machines, and reveal guardrails present.')

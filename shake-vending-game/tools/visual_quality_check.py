from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
def read(rel): return (SRC/rel).read_text()
art=read('ServerScriptService/Services/MachineArtDirector.lua')
polish=read('ServerScriptService/Services/WorldPolishService.lua')
motion=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua')
boot=read('ServerScriptService/Bootstrap.server.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
manifest=read('ReplicatedStorage/Shared/AssetManifest.lua')
theme=read('ReplicatedStorage/Shared/UITheme.lua')
drop=read('StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua')
for marker in ['OlympusKitbash','DisplayGlass','Product_','MachineScreen','CardReader','DispenseTray','AccessPanel','Vent','Marquee','ArtDirectionVersion']:
    assert marker in art, f'machine art marker missing: {marker}'
for machine in ['CornerStore','SugarRush','Energy','ToyCapsule','Luxury','Unknown']:
    assert machine in art, f'machine-specific art style missing: {machine}'
for donor in ['ArcadeCabinet','StreetBench','StreetLamp','TrashCan']:
    assert donor in manifest and donor in polish, f'Downtown detail donor missing: {donor}'
assert 'MachineArtDirector.Apply' in polish and 'WorldPolishService:Init()' in boot
for marker in ['SHAKING','WAIT...','COLLECT!','Product_','PlayMachine("Rattle"','PlayMachine("Clunk"']:
    assert marker in motion, f'mechanical interaction marker missing: {marker}'
assert 'MachineInteraction:Init(events,Audio)' in client
assert 'SimulatorUI' not in theme, 'UI theme must not inherit donor UI at runtime'
compact=theme.replace(' ','')
assert ('248,244,232' in compact or '255,248,226' in compact), 'authored cream product-card palette missing'
assert ('addMutationLanguage' in drop and 'VFX.GetMutation' in drop) or 'RevealVFX' in drop, 'mutation-specific reveal language missing'
print('PASS: authored machine kitbash, layered interaction, Downtown dressing, UI identity, and reveal-language guardrails present.')

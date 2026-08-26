from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
errors=[]
def read(rel):
    p=SRC/rel
    if not p.exists(): errors.append(f'missing {rel}'); return ''
    return p.read_text()
world=read('ServerScriptService/Services/WorldBuilder.lua')
art=read('ServerScriptService/Services/MachineArtDirector.lua')
showcase=read('ServerScriptService/Services/ShowcaseService.lua')
components=read('StarterPlayer/StarterPlayerScripts/Controllers/UIComponents.lua')
hud=read('StarterPlayer/StarterPlayerScripts/Controllers/HudArtDirector.lua')
collection=read('StarterPlayer/StarterPlayerScripts/Controllers/CollectionArtDirector.lua')
loading=read('ReplicatedFirst/Loading.client.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
manifest=read('ReplicatedStorage/Shared/AssetManifest.lua')
checks={
 'hand-built world': all(x in world for x in ['HandBuiltWorld','MainRoad','storefront(hub','backgroundBuilding','ShowcasePromenade']),
 'no world billboards': 'BillboardGui' not in world,
 'no donor world/machines': all(x not in world for x in ['cloneWorldAsset','VendingMachineDetailed','LowPolyShop','HubShop']),
 'hand-built vending': all(x in art for x in ['function MachineArtDirector.Build','HandBuiltMachine','miniProduct','MachineScreen','DispenseTray']),
 'physical showcase': 'HandBuiltShowcase' in showcase and 'BillboardGui' not in showcase and 'importedPodium' not in showcase,
 'pixel components': 'PixelBorder' in components and 'UICorner' not in components,
 'pixel HUD': all(x in hud for x in ['PixelNavRail','VENDING MENU','NEXT OBJECTIVE']),
 'pixel catalog': all(x in collection for x in ['PixelCatalogSortBar','ItemCard_','PreviewWell']),
 'deterministic Olympus intro': 'olympus.Text="OLYMPUS"' in loading and 'E N T E R T A I N M E N T' in loading and 'UIListLayout' not in loading,
 'runtime art wiring': all(x in client for x in ['HudArt:Apply(UI)','CollectionArt:Apply(UI)','MachineInteraction:Init(events,Audio)']),
 'item-only Creator Store manifest': 'Role="World"' not in manifest and 'Role="Machine"' not in manifest and 'Role="UI"' not in manifest and 'Role="Podium"' not in manifest,
}
for name,ok in checks.items():
    print(f'{name}: {"OK" if ok else "FAIL"}')
    if not ok: errors.append(name)
if errors:
    print('FAILURES:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: player-facing world, vending chassis, showcase, loading, HUD and collection presentation are hand-authored/pixel-authored and runtime-wired.')

from pathlib import Path
import re, sys, collections
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
errors=[]
def err(s): errors.append(s)
def read(rel): return (SRC/rel).read_text()
item_text=read('ReplicatedStorage/Shared/ItemDefinitions.lua')
manifest_text=read('ReplicatedStorage/Shared/AssetManifest.lua')
machine_text=read('ReplicatedStorage/Shared/MachineDefinitions.lua')
rarity_text=read('ReplicatedStorage/Shared/RarityDefinitions.lua')
mutation_text=read('ReplicatedStorage/Shared/MutationDefinitions.lua')
remote_text=read('ReplicatedStorage/Shared/RemoteNames.lua')
profile_text=read('ReplicatedStorage/Shared/ProfileTemplate.lua')
world_defs=read('ReplicatedStorage/Shared/WorldDefinitions.lua')
blocks=re.findall(r'Items\.([A-Za-z0-9_]+)\s*=\s*\{([^{}]*)\}',item_text,re.S)
items=[]
for name,body in blocks:
    if name=='ByMachine': continue
    def field(k):
        m=re.search(rf'\b{k}\s*=\s*"([^"]+)"',body);return m.group(1) if m else None
    items.append((name,{k:field(k) for k in ['Id','Machine','Rarity','AssetKey','VisualFamily']}))
if len(items)!=60: err(f'expected 60 launch items, found {len(items)}')
ids=[d['Id'] for _,d in items]
if len(ids)!=len(set(ids)): err('duplicate item IDs')
machine_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{',machine_text,re.M))
rarity_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Rank',rarity_text,re.M))
asset_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Id\s*=',manifest_text,re.M))
counts=collections.Counter()
for name,d in items:
    if d['Id']!=name: err(f'{name}: Id mismatch')
    if d['Machine'] not in machine_ids: err(f'{name}: unknown machine {d["Machine"]}')
    if d['Rarity'] not in rarity_ids: err(f'{name}: unknown rarity {d["Rarity"]}')
    if d['AssetKey'] not in asset_ids: err(f'{name}: unknown asset {d["AssetKey"]}')
    if not d['VisualFamily']: err(f'{name}: missing VisualFamily')
    counts[d['Machine']]+=1
for m in machine_ids:
    if counts[m]!=10: err(f'{m}: expected 10 items, found {counts[m]}')
mutations=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Weight',mutation_text,re.M))
if len(mutations-{'None'})!=12: err('expected 12 mutations + None')
for marker in ['Downtown','SunsetBoardwalk']:
    if marker not in world_defs: err(f'world definition missing {marker}')
for marker in ['HuntList = {}','Passport = {','TutorialComplete']:
    if marker not in profile_text: err(f'profile missing {marker}')
if 'EventOnly = true' not in machine_text: err('Unknown machine is not event-only')
for marker in ['Discoveries=5','TotalShakes=12','HighestRarity="Epic"']:
    if marker not in machine_text.replace(' ',''): err(f'machine progression missing {marker}')
remote_names=set(re.findall(r'^\s{8}([A-Za-z0-9_]+)\s*=\s*"',remote_text,re.M))
for needed in ['HuntAction','PassportAction']:
    if needed not in remote_names: err(f'missing remote {needed}')
for f in SRC.rglob('*.lua'):
    text=f.read_text()
    for used in re.findall(r'(?:RemoteService\.Events|RemoteService\.Functions|remotes)\.([A-Za-z0-9_]+)',text):
        if used not in remote_names: err(f'{f.relative_to(ROOT)} uses undefined remote {used}')
    for bad in ['InsertService','LoadAsset(','loadstring','HttpGet(','GetObjects(']:
        if bad in text: err(f'{f.relative_to(ROOT)} contains forbidden runtime loader {bad}')
    if re.search(r'require\s*\(\s*\d+',text): err(f'{f.relative_to(ROOT)} requires numeric asset ID')
required=['ServerScriptService/Services/DataService.lua','ServerScriptService/Services/ProgressionService.lua','ServerScriptService/Services/MachineService.lua','ServerScriptService/Services/RollService.lua','ServerScriptService/Services/InventoryService.lua','ServerScriptService/Services/EventService.lua','ServerScriptService/Services/TradingService.lua','ServerScriptService/Services/WorldBuilder.lua','ServerScriptService/Services/WorldPolishService.lua','ServerScriptService/Services/MachineArtDirector.lua','StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua','StarterPlayer/StarterPlayerScripts/Controllers/HudArtDirector.lua','StarterPlayer/StarterPlayerScripts/Controllers/CollectionArtDirector.lua','StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua','StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua','StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua','StarterPlayer/StarterPlayerScripts/Controllers/WorldLoopController.lua','StarterPlayer/StarterPlayerScripts/Controllers/AudioController.lua','ReplicatedStorage/Shared/SoundManifest.lua','ReplicatedStorage/Shared/VFXManifest.lua','ReplicatedStorage/Shared/WorldDefinitions.lua','ReplicatedFirst/Loading.client.lua']
for rel in required:
    if not (SRC/rel).exists(): err(f'missing required module {rel}')
progression=read('ServerScriptService/Services/ProgressionService.lua')
for marker in ['function ProgressionService:SetHunt','function ProgressionService:TryStampWorld','GetMachineUnlockStates']:
    if marker not in progression: err(f'ProgressionService missing {marker}')
if 'CanUnlockMachine(profile,machineId)' not in read('ServerScriptService/Services/MachineService.lua'): err('MachineService bypasses unlock requirements')
if 'function RemoteService:Allow' not in read('ServerScriptService/Services/RemoteService.lua'): err('central remote rate limiter missing')
if 'self.Profiles[userId] = result' in read('ServerScriptService/Services/DataService.lua'): err('autosave can rewind live profile')
roll=read('ServerScriptService/Services/RollService.lua')
if 'NaturalOneIn=' not in roll or 'RollAdjusted=' not in roll: err('truthful roll odds fields missing')
if 'InventoryService:MassSell' in read('ServerScriptService/Services/WorldInteractionService.lua'): err('physical sell station bypasses confirmation')
world=read('ServerScriptService/Services/WorldBuilder.lua')
for marker in ['BUILDINGS','storefront(hub','MainRoad','WestCrossStreet','EastCrossStreet','DistrictDirectory','MachineArtDirector.Build','ShowcasePromenade']:
    if marker not in world: err(f'hand-authored Downtown marker missing: {marker}')
if 'BillboardGui' in world: err('WorldBuilder regressed to fixed-pixel BillboardGui signage')
if 'cloneWorldAsset' in world or 'VendingMachineDetailed' in world or 'LowPolyShop' in world: err('player-facing Downtown architecture/machines regressed to Creator Store donor construction')
art=read('ServerScriptService/Services/MachineArtDirector.lua')
for marker in ['function MachineArtDirector.Build','HandBuiltMachine','BackCase','DisplayGlass','Key"..idx','DispenseTray','miniProduct','CandyBulb','PowerFin','CapsuleGlobe','GoldInlay','Hazard']:
    if marker not in art: err(f'hand-built vending marker missing: {marker}')
if 'ItemVisualFactory' in art or 'AssetVariant' in art: err('vending machine art depends on external donor models')
polish=read('ServerScriptService/Services/WorldPolishService.lua')
if 'fillFacades' in polish or 'CornerStoreBuilding' in polish or 'MachineArtDirector.Apply' in polish: err('secondary donor/facade machine construction returned')
showcase=read('ServerScriptService/Services/ShowcaseService.lua')
if 'BillboardGui' in showcase or 'importedPodium' in showcase: err('showcase regressed to floating billboard/free podium presentation')
loading=read('ReplicatedFirst/Loading.client.lua')
if 'UIListLayout' in loading or 'olympus.Text="OLYMPUS"' not in loading or 'E N T E R T A I N M E N T' not in loading: err('Olympus intro is not deterministic')
components=read('StarterPlayer/StarterPlayerScripts/Controllers/UIComponents.lua')
if 'PixelBorder' not in components or 'UICorner' in components: err('common UI primitives are not pixel-authored')
machine_ui=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua')
if 'MachineScreen' not in machine_ui or 'JAMMED\n' not in machine_ui: err('physical machine-screen status missing')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
for marker in ['HudArt:Apply(UI)','CollectionArt:Apply(UI)','MachineInteraction:Init(events,Audio)','WorldLoop:Init(events,functions,UI)']:
    if marker not in client: err(f'client bootstrap missing {marker}')
def strip_lua(text):
    text=re.sub(r'--\[\[.*?\]\]',' ',text,flags=re.S);text=re.sub(r'\[\[.*?\]\]',' ',text,flags=re.S);text=re.sub(r'"(?:\\.|[^"\\])*"','""',text);text=re.sub(r"'(?:\\.|[^'\\])*'","''",text);text=re.sub(r'--[^\n]*',' ',text);return text
for f in SRC.rglob('*.lua'):
    clean=strip_lua(f.read_text());pairs={')':'(',']':'[','}':'{'};st=[]
    for ch in clean:
        if ch in '([{': st.append(ch)
        elif ch in ')]}':
            if not st or st[-1]!=pairs[ch]: err(f'{f.relative_to(ROOT)} bracket mismatch');break
            st.pop()
    if st: err(f'{f.relative_to(ROOT)} unclosed brackets')
print('ShakeVM static audit');print('  items:',len(items),' | per machine:',dict(sorted(counts.items())));print('  mutations:',len(mutations-{'None'}),' + None');print('  creator-store base assets:',len(asset_ids));print('  lua files:',len(list(SRC.rglob('*.lua'))))
if errors:
    print('FAILURES:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: data integrity, runtime safety, progression authority, and Studio-exposed presentation regressions are guarded.')

from pathlib import Path
import re, sys, collections
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'
errors=[]; warnings=[]

def err(s): errors.append(s)
def warn(s): warnings.append(s)

item_text=(SRC/'ReplicatedStorage/Shared/ItemDefinitions.lua').read_text()
manifest_text=(SRC/'ReplicatedStorage/Shared/AssetManifest.lua').read_text()
machine_text=(SRC/'ReplicatedStorage/Shared/MachineDefinitions.lua').read_text()
rarity_text=(SRC/'ReplicatedStorage/Shared/RarityDefinitions.lua').read_text()
mutation_text=(SRC/'ReplicatedStorage/Shared/MutationDefinitions.lua').read_text()
remote_text=(SRC/'ReplicatedStorage/Shared/RemoteNames.lua').read_text()
world_text=(SRC/'ReplicatedStorage/Shared/WorldDefinitions.lua').read_text() if (SRC/'ReplicatedStorage/Shared/WorldDefinitions.lua').exists() else ''
profile_text=(SRC/'ReplicatedStorage/Shared/ProfileTemplate.lua').read_text()

item_blocks=re.findall(r'Items\.([A-Za-z0-9_]+)\s*=\s*\{(.*?)\n\}',item_text,re.S)
items=[]
for name,body in item_blocks:
    if name=='ByMachine': continue
    def field(k):
        m=re.search(rf'\b{k}\s*=\s*"([^"]+)"',body); return m.group(1) if m else None
    items.append((name,{k:field(k) for k in ['Id','Machine','Rarity','AssetKey','VisualFamily','CosmeticSlot','Set']}))
if len(items)!=60: err(f'expected 60 launch items, found {len(items)}')
ids=[d['Id'] for _,d in items]
if len(set(ids))!=len(ids): err('duplicate item IDs')
machine_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{',machine_text,re.M))
rarity_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Rank',rarity_text,re.M))
asset_ids=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Id\s*=',manifest_text,re.M))
counts=collections.Counter()
for name,d in items:
    if d['Id']!=name: err(f'{name}: Id mismatch {d["Id"]}')
    if d['Machine'] not in machine_ids: err(f'{name}: unknown machine {d["Machine"]}')
    if d['Rarity'] not in rarity_ids: err(f'{name}: unknown rarity {d["Rarity"]}')
    if d['AssetKey'] not in asset_ids: err(f'{name}: unknown asset key {d["AssetKey"]}')
    if not d['VisualFamily']: err(f'{name}: missing visual family')
    counts[d['Machine']]+=1
for machine in machine_ids:
    if counts[machine]!=10: err(f'{machine}: expected 10 items, found {counts[machine]}')
mutation_names=set(re.findall(r'^\s{4}([A-Za-z0-9_]+)\s*=\s*\{\s*Weight',mutation_text,re.M))
if len(mutation_names-{'None'})!=12: err(f'expected 12 launch mutations + None, found {len(mutation_names-{"None"})}+None')

remote_names=set(re.findall(r'^\s{8}([A-Za-z0-9_]+)\s*=\s*"',remote_text,re.M))
for f in SRC.rglob('*.lua'):
    text=f.read_text()
    for used in re.findall(r'(?:RemoteService\.Events|RemoteService\.Functions|remotes)\.([A-Za-z0-9_]+)',text):
        if used not in remote_names: err(f'{f.relative_to(ROOT)} uses undefined remote {used}')

if 'Downtown' not in world_text or 'SunsetBoardwalk' not in world_text:
    err('world definitions missing Downtown launch world or future destination roadmap')
if 'HuntList = {}' not in profile_text or 'Passport = {' not in profile_text:
    err('profile template missing persisted Passport/HuntList progression')
if 'EventOnly = true' not in machine_text:
    err('Unknown/event machine is no longer marked event-only')
for marker in ['Discoveries = 5','TotalShakes = 12','HighestRarity = "Epic"']:
    if marker not in machine_text: err(f'multi-goal machine progression marker missing: {marker}')
for remote in ['HuntAction','PassportAction']:
    if remote not in remote_names: err(f'missing loop remote {remote}')
progression_text=(SRC/'ServerScriptService/Services/ProgressionService.lua').read_text()
for marker in ['function ProgressionService:SetHunt','function ProgressionService:TryStampWorld','GetMachineUnlockStates']:
    if marker not in progression_text: err(f'progression service missing loop feature {marker}')
machine_service_text=(SRC/'ServerScriptService/Services/MachineService.lua').read_text()
if 'CanUnlockMachine(profile,machineId)' not in machine_service_text:
    err('MachineService bypasses server-authoritative progression requirements')
loop_ui_text=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/WorldLoopController.lua').read_text()
for marker in ['function WorldLoopController:RenderPassport()','function WorldLoopController:RenderHunts()','HUNT LIST EMPTY']:
    if marker not in loop_ui_text: err(f'World loop UI missing feature {marker}')

for f in SRC.rglob('*.lua'):
    text=f.read_text()
    for bad in ['InsertService','LoadAsset(','loadstring','HttpGet(','GetObjects(']:
        if bad in text: err(f'runtime file {f.relative_to(ROOT)} contains forbidden pattern {bad}')
    if re.search(r'require\s*\(\s*\d+',text): err(f'runtime file {f.relative_to(ROOT)} requires numeric asset ID')

required=[
 'ServerScriptService/Services/DataService.lua','ServerScriptService/Services/ProgressionService.lua','ServerScriptService/Services/EngagementService.lua','ServerScriptService/Services/MachineService.lua','ServerScriptService/Services/RollService.lua',
 'ServerScriptService/Services/CollectionService.lua','ServerScriptService/Services/InventoryService.lua','ServerScriptService/Services/CosmeticService.lua',
 'ServerScriptService/Services/ShowcaseService.lua','ServerScriptService/Services/GlobalService.lua','ServerScriptService/Services/EventService.lua',
 'ServerScriptService/Services/TradingService.lua','ServerScriptService/Services/UpgradeService.lua','ServerScriptService/Services/WorldBuilder.lua',
 'StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua','StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua',
 'StarterPlayer/StarterPlayerScripts/Controllers/TradeController.lua','StarterPlayer/StarterPlayerScripts/Controllers/InspectController.lua',
 'StarterPlayer/StarterPlayerScripts/Controllers/AudioController.lua','StarterPlayer/StarterPlayerScripts/Controllers/OnboardingController.lua',
 'StarterPlayer/StarterPlayerScripts/Controllers/UIComponents.lua','StarterPlayer/StarterPlayerScripts/Controllers/ShowcaseController.lua','StarterPlayer/StarterPlayerScripts/Controllers/WorldLoopController.lua','ReplicatedStorage/Shared/SoundManifest.lua','ReplicatedStorage/Shared/VFXManifest.lua','ReplicatedStorage/Shared/WorldDefinitions.lua',
]
for rel in required:
    if not (SRC/rel).exists(): err(f'missing required module {rel}')

def strip_lua(text):
    text=re.sub(r'--\[\[.*?\]\]',' ',text,flags=re.S)
    text=re.sub(r'\[\[.*?\]\]',' ',text,flags=re.S)
    text=re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    text=re.sub(r"'(?:\\.|[^'\\])*'", "''", text)
    text=re.sub(r'--[^\n]*',' ',text)
    return text

for f in SRC.rglob('*.lua'):
    clean=strip_lua(f.read_text())
    toks=re.findall(r'\b(?:function|if|for|while|repeat|end|until)\b',clean)
    stack=[]
    for tok in toks:
        if tok in {'function','if','for','while','repeat'}:
            stack.append(tok)
        elif tok=='until':
            if not stack or stack[-1]!='repeat': err(f'{f.relative_to(ROOT)}: unmatched until'); break
            stack.pop()
        elif tok=='end':
            if not stack: err(f'{f.relative_to(ROOT)}: unmatched end'); break
            if stack[-1]=='repeat': err(f'{f.relative_to(ROOT)}: repeat closed by end'); break
            stack.pop()
    if stack: err(f'{f.relative_to(ROOT)}: unclosed blocks {stack[-5:]}')
    pairs={')':'(',']':'[','}':'{'}; st=[]
    for ch in clean:
        if ch in '([{': st.append(ch)
        elif ch in ')]}':
            if not st or st[-1]!=pairs[ch]: err(f'{f.relative_to(ROOT)}: bracket mismatch at {ch}'); break
            st.pop()
    if st: err(f'{f.relative_to(ROOT)}: unclosed brackets {st[-10:]}')

alltext='\n'.join(f.read_text() for f in SRC.rglob('*.lua'))
checks={
 'cursor attraction':'GetMouseLocation','hover rays':'RarityRays','viewport previews':'ViewportFrame','hourly board':'GetSortedMap','cross-server feed':'MessagingService','trade journal':'CommitRequested','trade confirmation reset':'ResetReady','showcases':'ShowcaseSlots','style shards':'ConvertToShards','upgrades':'UpgradeRules','event restocks':'ForcedMutation','outfit loadouts':'OutfitSlots','combined-odds rarity':'Rarities.Effective','visible rank goals':'RankGoals','mass sell modes':'MassSell','creator asset runtime':'LoadAssetAsync','lucky meter':'LuckyMeter','collection base catalog':'BaseCollection','session gift track':'SessionGifts','overdrive combo':'ShakeCombo','engagement remote':'ProgressionAction','premium rarity beam':'DiscoveryBeam','full-screen rarity reveal':'ShakeRarityReveal','creator exact cookie donor':'CookieStack','creator exact plush donor':'BunnyPlush','creator exact slime donor':'SlimeBlob','creator exact dice donor':'DiceProp',
}
for label,needle in checks.items():
    if needle not in alltext: err(f'missing expected feature marker: {label}')

visual_factory=(SRC/'ReplicatedStorage/Shared/ItemVisualFactory.lua').read_text()
world_builder=(SRC/'ServerScriptService/Services/WorldBuilder.lua').read_text()
if any(x in visual_factory for x in ['buildCan(', 'buildBottle(', 'buildBag(', 'buildRobot(', 'buildCapsule(']):
    err('ItemVisualFactory contains procedural item builders; Creator Store donor pipeline regressed')
if 'VendingMachineDetailed' not in world_builder: err('WorldBuilder is not using the detailed Creator Store vending donor')
if 'CollectionShop' not in world_builder or 'GardenPlot' not in world_builder: err('Creator Store collection/gallery environment assets are missing')
if 'ProgressionService' not in (SRC/'ServerScriptService/Bootstrap.server.lua').read_text(): err('rank-goal progression not wired into bootstrap')
asset_loader=(SRC/'ServerScriptService/Services/AssetLoadService.lua').read_text()
if re.search(r'AssetService\.AllowInsertFreeAssets\s*end',asset_loader):
    err('AssetLoadService tries to read protected AllowInsertFreeAssets instead of attempting sandboxed LoadAssetAsync')
showcase=(SRC/'ServerScriptService/Services/ShowcaseService.lua').read_text()
if 'MissingPodium' in showcase: err('ShowcaseService regressed to generated missing-podium geometry')
ui=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua').read_text()
if 'while vp.Parent and model.Parent' in ui: err('UI uses one RenderStepped coroutine per viewport card')
if 'hash%#candidates' in visual_factory: err('ItemVisualFactory still uses random pack extraction, which can produce mismatched collectibles')
if 'MISSING_CREATOR_ASSET_' in visual_factory or 'errorPlaceholder' in visual_factory:
    err('ItemVisualFactory regressed to generated missing-asset geometry')

data_service=(SRC/'ServerScriptService/Services/DataService.lua').read_text()
if 'self.Profiles[userId] = result' in data_service:
    err('autosave regression: SaveUserId can rewind live profile to an older persisted snapshot')
roll_service=(SRC/'ServerScriptService/Services/RollService.lua').read_text()
if 'NaturalOneIn=' not in roll_service or 'RollAdjusted=' not in roll_service:
    err('truthful odds regression: rolls do not preserve both conditional obtained odds and natural pool odds')
drop_controller=(SRC/'StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua').read_text()
if 'Config.SoundIds.Rare' in drop_controller:
    err('audio regression: reveal controller references legacy Config.SoundIds.Rare directly')
world_interaction=(SRC/'ServerScriptService/Services/WorldInteractionService.lua').read_text()
if 'InventoryService:MassSell' in world_interaction:
    err('destructive-action regression: physical sell station bypasses client confirmation')
remote_service=(SRC/'ServerScriptService/Services/RemoteService.lua').read_text()
if 'function RemoteService:Allow' not in remote_service:
    err('remote security regression: centralized token bucket guard is missing')
if 'TutorialComplete' not in profile_text:
    err('onboarding regression: tutorial completion is not persisted')

def require_targets(text, owner):
    for folder, module in re.findall(r'require\((Controllers|Services)\.([A-Za-z0-9_]+)\)', text):
        if folder == 'Controllers': target = SRC/'StarterPlayer/StarterPlayerScripts/Controllers'/(module+'.lua')
        else: target = SRC/'ServerScriptService/Services'/(module+'.lua')
        if not target.exists(): err(f'{owner}: requires missing persisted module {folder}.{module}')

require_targets((SRC/'StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua').read_text(), 'ClientBootstrap')
require_targets((SRC/'ServerScriptService/Bootstrap.server.lua').read_text(), 'Bootstrap.server')
required_runtime = [SRC/'ReplicatedStorage/Shared/ItemVisualFactory.lua',SRC/'StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua',SRC/'StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua',SRC/'StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua',SRC/'StarterPlayer/StarterPlayerScripts/Controllers/TradeController.lua',SRC/'StarterPlayer/StarterPlayerScripts/Controllers/InspectController.lua']
for target in required_runtime:
    if not target.exists(): err(f'missing release-critical persisted source: {target.relative_to(ROOT)}')

client_boot=(SRC/'StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua').read_text()
if 'WorldLoop:Init(events,functions,UI)' not in client_boot:
    err('world-loop regression: WorldLoopController exists but is not initialized by ClientBootstrap')

print('ShakeVM static audit')
print('  items:',len(items),' | per machine:',dict(sorted(counts.items())))
print('  mutations:',len(mutation_names-{'None'}),' + None')
print('  creator-store base assets:',len(asset_ids))
print('  lua files:',len(list(SRC.rglob('*.lua'))))
if warnings:
    print('WARNINGS:')
    for w in warnings: print(' -',w)
if errors:
    print('FAILURES:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: referential integrity, feature markers, runtime asset safety, and lightweight structural checks.')

assert "JAMMED • COMMUNITY" in (ROOT / "src/StarterPlayer/StarterPlayerScripts/Controllers/MachineController.lua").read_text(), "Jammed event has no live physical progress readout"
assert "ButtonB" in (ROOT / "src/StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua").read_text(), "Gamepad back navigation missing"
assert "ShowcaseBaseCFrame" in (ROOT / "src/ServerScriptService/Services/ShowcaseService.lua").read_text(), "Showcase animation contract missing"

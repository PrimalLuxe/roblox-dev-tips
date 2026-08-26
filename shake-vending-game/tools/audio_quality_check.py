from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src'

def read(rel):
    return (SRC/rel).read_text(encoding='utf-8')

manifest=read('ReplicatedStorage/Shared/SoundManifest.lua')
audio=read('StarterPlayer/StarterPlayerScripts/Controllers/AudioController.lua')
client=read('StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua')
motion=read('StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua')
drop=read('StarterPlayer/StarterPlayerScripts/Controllers/DropVisualController.lua')

for category in ['Machine = {','UI = {','Economy = {','Collection = {','Engagement = {','Rarity = {','Mix = {']:
    assert category in manifest, f'audio manifest category missing: {category}'
for group in ['SFX','UI','Ambient','Music','RareReveal']:
    assert f'group("{group}")' in audio, f'SoundGroup missing: {group}'
for marker in ['function AudioController:DuckFor','Cooldown','MaxInstances','ActiveCounts','function AudioController:BindGui','DescendantAdded','function AudioController:PlayCategory']:
    assert marker in audio or marker in manifest, f'audio production marker missing: {marker}'
assert 'Audio:BindGui(UI.Gui)' in client, 'global GUI audio feedback is not wired into the client bootstrap'
assert 'PlayMachine("Rattle"' in motion and 'PlayMachine("Clunk"' in motion, 'staged vending interaction lost positional audio cues'
assert 'PlayRarity(item.Rarity' in drop, 'rare reveal no longer drives rarity audio/ducking'
assert 'InsertService' not in manifest and 'LoadAsset' not in manifest, 'audio manifest must not dynamically import untrusted assets'

print('PASS: categorized audio manifest, bounded concurrency/cooldowns, SoundGroup mixing, rarity ducking, GUI feedback, and positional vending cues are wired.')

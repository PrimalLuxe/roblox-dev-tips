#!/usr/bin/env python3
"""Static progression-loop simulation for the Downtown launch world.

This is not a Roblox Studio playtest. It models authoritative base-item weights,
mutation sell multipliers, immediate sale, base-catalog discovery, shake gates,
machine-specific shake gates and rarity discovery gates. Event-only Unknown is
excluded from normal progression because it requires a live world event.
"""
from pathlib import Path
import random, re, statistics

ROOT=Path(__file__).resolve().parents[1]
items_text=(ROOT/'src/ReplicatedStorage/Shared/ItemDefinitions.lua').read_text()
mut_text=(ROOT/'src/ReplicatedStorage/Shared/MutationDefinitions.lua').read_text()
machine_text=(ROOT/'src/ReplicatedStorage/Shared/MachineDefinitions.lua').read_text()
rarity_text=(ROOT/'src/ReplicatedStorage/Shared/RarityDefinitions.lua').read_text()
config_text=(ROOT/'src/ReplicatedStorage/Shared/Config.lua').read_text()
profile_text=(ROOT/'src/ReplicatedStorage/Shared/ProfileTemplate.lua').read_text()

rank={name:int(r) for name,r in re.findall(r'(\w+)\s*=\s*\{\s*Rank\s*=\s*(\d+)',rarity_text)}
mult_block=re.search(r'local machineValueMultiplier\s*=\s*\{(.*?)\}',items_text,re.S).group(1)
mults={k:int(v.replace('_','')) for k,v in re.findall(r'(CornerStore|SugarRush|Energy|ToyCapsule|Luxury|Unknown)\s*=\s*([0-9_]+)',mult_block)}

items={}
for iid,b in re.findall(r'Items\.(\w+)\s*=\s*\{(.*?)\n\}',items_text,re.S):
    def sf(name,pat=r'([^,\n]+)'):
        m=re.search(rf'\b{name}\s*=\s*{pat}',b);return m.group(1).strip() if m else None
    machine=sf('Machine',r'"([^"]+)"')
    if not machine: continue
    items.setdefault(machine,[]).append({
        'id':iid,'weight':int((sf('Weight') or '0').replace('_','')),
        'value':int((sf('BaseValue') or '0').replace('_',''))*mults[machine],
        'rarity':sf('Rarity',r'"([^"]+)"') or 'Common',
    })

mut=[]
for name,b in re.findall(r'(\w+)\s*=\s*\{([^}]*)\}',mut_text):
    wm=re.search(r'Weight\s*=\s*([0-9_]+)',b);mm=re.search(r'Multiplier\s*=\s*([0-9_.]+)',b)
    if wm and mm: mut.append((int(wm.group(1).replace('_','')),float(mm.group(1))))
mut_total=sum(w for w,_ in mut)

blocks={}
lines=machine_text.splitlines()
current=None;buf=[]
for line in lines:
    m=re.match(r'^    (\w+) = \{$',line)
    if m:
        if current: blocks[current]='\n'.join(buf)
        current=m.group(1);buf=[line];continue
    if current:
        if re.match(r'^    },$',line):
            buf.append(line);blocks[current]='\n'.join(buf);current=None;buf=[]
        else: buf.append(line)

order=['CornerStore','SugarRush','Energy','ToyCapsule','Luxury']
requirements={}
for m in order:
    b=blocks[m]
    def num(key,default=0):
        mm=re.search(rf'\b{key}\s*=\s*([0-9_]+)',b);return int(mm.group(1).replace('_','')) if mm else default
    prev=re.search(r'PreviousMachine\s*=\s*"([^"]+)"',b)
    rarity=re.search(r'HighestRarity\s*=\s*"([^"]+)"',b)
    ms={k:int(v.replace('_','')) for k,v in re.findall(r'(CornerStore|SugarRush|Energy|ToyCapsule|Luxury)\s*=\s*([0-9_]+)',re.search(r'MachineShakes\s*=\s*\{([^}]*)\}',b,re.S).group(1))} if 'MachineShakes' in b else {}
    requirements[m]={'cost':num('UnlockCost'),'discoveries':num('Discoveries'),'total_shakes':num('TotalShakes'),'previous':prev.group(1) if prev else None,'rarity':rarity.group(1) if rarity else None,'machine_shakes':ms}

shake=float(re.search(r'ShakeCooldown\s*=\s*([0-9.]+)',config_text).group(1))
start=int(re.search(r'Coins\s*=\s*([0-9_]+)',profile_text).group(1).replace('_',''))

def weighted(pool):
    total=sum(x['weight'] for x in pool);r=random.randrange(total);acc=0
    for x in pool:
        acc+=x['weight']
        if r<acc:return x
    return pool[-1]

def mutation_mult():
    r=random.randrange(mut_total);acc=0
    for w,m in mut:
        acc+=w
        if r<acc:return m
    return 1

def can_unlock(req,coins,discovered,total_shakes,machine_shakes,unlocked,highest):
    if coins<req['cost'] or len(discovered)<req['discoveries'] or total_shakes<req['total_shakes']:return False
    if req['previous'] and req['previous'] not in unlocked:return False
    if req['rarity'] and highest<rank[req['rarity']]:return False
    return all(machine_shakes.get(k,0)>=v for k,v in req['machine_shakes'].items())

def run(max_minutes=75):
    coins=start;idx=0;unlocked={order[0]};discovered=set();machine_shakes={};total=0;t=0;highest=0;times={}
    while t<max_minutes*60:
        machine=order[idx];base=weighted(items[machine]);coins+=max(1,int(base['value']*mutation_mult()))
        discovered.add(base['id']);highest=max(highest,rank[base['rarity']]);total+=1;machine_shakes[machine]=machine_shakes.get(machine,0)+1;t+=shake
        while idx+1<len(order):
            nxt=order[idx+1];req=requirements[nxt]
            if not can_unlock(req,coins,discovered,total,machine_shakes,unlocked,highest):break
            coins-=req['cost'];idx+=1;unlocked.add(nxt);times[nxt]=t
    return times,len(discovered),coins

def fmt(sec):
    return 'not reached' if sec is None else f'{int(sec//60)}:{int(sec%60):02d}'

random.seed(20260826);N=1000
runs=[run() for _ in range(N)]
print('Downtown progression loop simulation (fast-seller upper bound)')
for m in order[1:]:
    vals=sorted(t[m] for t,_,_ in runs if m in t)
    if not vals:print(m,'not reached');continue
    q=lambda x: vals[min(len(vals)-1,int((len(vals)-1)*x))]
    print(f'{m:12s} P10={fmt(q(.10))} median={fmt(q(.50))} P90={fmt(q(.90))} reach75m={len(vals)/N:.1%}')
print('median discoveries at 75m:',statistics.median(d for _,d,_ in runs))

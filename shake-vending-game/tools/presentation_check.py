from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
errors = []

def require(rel, *markers):
    path = SRC / rel
    if not path.exists():
        errors.append(f"missing {rel}")
        return ""
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            errors.append(f"{rel}: missing marker {marker!r}")
    return text

world = require(
    "ServerScriptService/Services/WorldBuilder.lua",
    "MachineArtDirector = require(script.Parent.MachineArtDirector)",
    "MachineArtDirector.Apply(model,shell,machineId)",
    "VendingMachineDetailed",
    "DropSpawn",
    "CollisionHull",
)
art = require(
    "ServerScriptService/Services/MachineArtDirector.lua",
    'facade.Name="OlympusKitbash"',
    '"DisplayGlass"',
    '"Shelf"..row',
    '"MachineScreen"',
    '"CardReader"',
    '"CoinSlot"',
    '"DispenseTray"',
    '"AccessPanel"',
    '"Vent"..i',
    '"FootL"',
    '"Marquee"',
    '"Product_"..d.Id',
)
interaction = require(
    "StarterPlayer/StarterPlayerScripts/Controllers/MachineInteractionController.lua",
    "shell:PivotTo",
    "easeOutBack",
    "overdriveStrength",
    'setScreen(screen,"SHAKING',
    'setScreen(screen,"VENDING...',
    'self.Audio:PlayMachine("Clunk"',
    'art:FindFirstChild("DispenseTray")',
)
client = require(
    "StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua",
    "CollectionArtDirector",
    "CollectionArt:Apply(UI)",
    "MachineInteraction:Init(events,Audio)",
)
collection = require(
    "StarterPlayer/StarterPlayerScripts/Controllers/CollectionArtDirector.lua",
    "ViewportFrame",
    'local modes={"Rarity","Odds","Value","Newest","Name"}',
    'card.Name="ItemCard_"..it.BaseItemId',
)
hud = require(
    "StarterPlayer/StarterPlayerScripts/Controllers/HudArtDirector.lua",
    "HudArtDirector",
)

# Guard against known persistence failures from prior passes.
if "MachineArtDirector.Apply(model,shell,machineId)" not in world:
    errors.append("authored vending kitbash is not wired into runtime world construction")
if "DropSpawned.OnClientEvent" not in interaction:
    errors.append("machine interaction animation is not driven by authoritative drop events")
if "OlympusKitbash" not in art:
    errors.append("authored machine facade contract missing")

print("ShakeVM presentation persistence audit")
print("  world art wiring:", "OK" if "MachineArtDirector.Apply(model,shell,machineId)" in world else "FAIL")
print("  machine authored fascia:", "OK" if "OlympusKitbash" in art else "FAIL")
print("  staged physical interaction:", "OK" if "easeOutBack" in interaction and "DispenseTray" in interaction else "FAIL")
print("  authored collection UI wiring:", "OK" if "CollectionArt:Apply(UI)" in client else "FAIL")

if errors:
    print("FAILURES:")
    for error in errors:
        print(" -", error)
    sys.exit(1)

print("PASS: authored presentation systems are persisted and wired into runtime entry points.")

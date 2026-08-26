local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RemoteNames=require(ReplicatedStorage.Shared.RemoteNames)
local remotesFolder=ReplicatedStorage:WaitForChild("Remotes",20)
if not remotesFolder then error("[ShakeVM] Server did not create ReplicatedStorage.Remotes. Check the FIRST server error in Output.") end
local function requireRemote(className,name)
    local obj=remotesFolder:WaitForChild(name,12)
    if not obj or not obj:IsA(className) then error(string.format("[ShakeVM] Missing %s %s",className,name)) end
    return obj
end
local events={};for key,name in pairs(RemoteNames.Events)do events[key]=requireRemote("RemoteEvent",name)end
local functions={};for key,name in pairs(RemoteNames.Functions)do functions[key]=requireRemote("RemoteFunction",name)end
local Controllers=script.Parent:WaitForChild("Controllers")
local UI=require(Controllers.UIController);local Drop=require(Controllers.DropVisualController);local Machine=require(Controllers.MachineController);local Trade=require(Controllers.TradeController);local Inspect=require(Controllers.InspectController);local Audio=require(Controllers.AudioController);local Onboarding=require(Controllers.OnboardingController);local Showcase=require(Controllers.ShowcaseController);local MachineInteraction=require(Controllers.MachineInteractionController);local WorldLoop=require(Controllers.WorldLoopController)
Audio:Init();UI.Audio=Audio
UI:Build(events,functions)
Drop.Audio=Audio;Drop:Init(events);UI.OnSettingsChanged=function(settings)Audio:SetSettings(settings);Drop:SetSettings(settings)end
if UI.Snapshot and UI.Snapshot.Profile then UI:ApplyProfileSettings(UI.Snapshot.Profile) end
Machine.Audio=Audio;Machine:Init(events);MachineInteraction:Init(events,Audio);Showcase:Init();WorldLoop:Init(events,functions,UI);UI.OnSnapshotChanged=function(snapshot)Machine:SetSnapshot(snapshot);WorldLoop:RefreshHud()end;Machine:SetSnapshot(UI.Snapshot)
Trade:Init(events,UI);Inspect:Init(functions,UI,Drop);Onboarding:Init(events,UI)
print("[ShakeVM] Client ready — production systems initialized")

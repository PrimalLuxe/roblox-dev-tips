local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RemoteNames=require(ReplicatedStorage.Shared.RemoteNames)
local remotesFolder=ReplicatedStorage:WaitForChild("Remotes",20)
if not remotesFolder then error("[ShakeVM] Server did not create ReplicatedStorage.Remotes. Check the FIRST server error in Output.")end
local events={};for key,name in pairs(RemoteNames.Events)do events[key]=remotesFolder:WaitForChild(name)end
local functions={};for key,name in pairs(RemoteNames.Functions)do functions[key]=remotesFolder:WaitForChild(name)end
local Controllers=script.Parent:WaitForChild("Controllers")
local UI=require(Controllers.UIController);local Drop=require(Controllers.DropVisualController);local Machine=require(Controllers.MachineController);local Trade=require(Controllers.TradeController);local Inspect=require(Controllers.InspectController)

UI:Build(events,functions)
Drop:Init(events);UI.OnSettingsChanged=function(settings)Drop:SetSettings(settings)end
if UI.Snapshot and UI.Snapshot.Profile then UI:ApplyProfileSettings(UI.Snapshot.Profile) end
Machine:Init(events);UI.OnSnapshotChanged=function(snapshot)Machine:SetSnapshot(snapshot)end;Machine:SetSnapshot(UI.Snapshot)
Trade:Init(events,UI);Inspect:Init(functions,UI,Drop)
print("[ShakeVM] Client ready — Creator asset overhaul")

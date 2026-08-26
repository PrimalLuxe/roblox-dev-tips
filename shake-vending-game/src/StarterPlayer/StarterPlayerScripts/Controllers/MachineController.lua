local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Machines=require(ReplicatedStorage.Shared.MachineDefinitions)
local Config=require(ReplicatedStorage.Shared.Config)
local Util=require(ReplicatedStorage.Shared.Util)

local MachineController={Connections={},Snapshot=nil,Event=nil}
local eventColors={Golden=Color3.fromRGB(255,196,58),Frozen=Color3.fromRGB(144,226,255),Lucky=Color3.fromRGB(94,255,145),Glitch=Color3.fromRGB(165,77,255),Blackout=Color3.fromRGB(82,57,132),Mystery=Color3.fromRGB(235,235,255),Jammed=Color3.fromRGB(255,92,72)}

function MachineController:ConnectMachine(machine)
    if self.Connections[machine]then return end
    if self.Audio then self.Audio:EnsureMachineHum(machine) end
    local root=machine:FindFirstChild("Root");local prompt=root and root:FindFirstChild("ShakePrompt");if not prompt then return end
    self.Connections[machine]=prompt.Triggered:Connect(function()self.Remotes.ShakeMachine:FireServer(machine:GetAttribute("MachineId")or machine.Name)end)
end

function MachineController:SetSnapshot(snapshot)
    self.Snapshot=snapshot;self:UpdateDisplays(self.Event or (snapshot and snapshot.Event))
end

function MachineController:UpdateDisplays(event)
    self.Event=event
    local folder=Workspace:FindFirstChild("Machines");if not folder then return end
    local overlay=Lighting:FindFirstChild("ShakeEventColor")or Instance.new("ColorCorrectionEffect");overlay.Name="ShakeEventColor";overlay.Parent=Lighting;overlay.TintColor=Color3.new(1,1,1);overlay.Brightness=0;overlay.Contrast=0;overlay.Saturation=0
    if event and event.Id=="Blackout"then overlay.Brightness=-0.13;overlay.Contrast=0.1;overlay.TintColor=Color3.fromRGB(205,190,255)elseif event and event.Id=="Glitch"then overlay.Saturation=0.1;overlay.TintColor=Color3.fromRGB(239,218,255)end

    for _,machine in ipairs(folder:GetChildren())do
        local id=machine:GetAttribute("MachineId")or machine.Name;local def=Machines[id]
        local applies=event and event.Id~="Normal" and (event.Global or event.TargetMachine==id)
        local accent=applies and (eventColors[event.Id]or(def and def.Accent))or(def and def.Accent)
        local h=machine:FindFirstChild("Shell")and machine.Shell:FindFirstChild("MachineAccent")
        if h and h:IsA("Highlight")and accent then h.OutlineColor=accent end

        local root=machine:FindFirstChild("Root");local prompt=root and root:FindFirstChild("ShakePrompt")
        local gui=root and root:FindFirstChild("MachineBillboard");local frame=gui and gui:FindFirstChildOfClass("Frame");local subtitle=frame and frame:FindFirstChild("Subtitle")
        local unlocked=self.Snapshot and self.Snapshot.Profile.UnlockedMachines[id]
        local unlockState=self.Snapshot and self.Snapshot.MachineUnlocks and self.Snapshot.MachineUnlocks[id]
        local eventOnline=not def.EventOnly or (event and event.UnlockUnknown==true)
        if subtitle and def then
            if applies then
                if event.Jammed then
                    subtitle.Text=string.format("JAMMED • COMMUNITY %d/%d",event.JamCount or 0,event.JamTarget or 500)
                else
                    subtitle.Text=(event.Hidden and"??? RESTOCK"or event.Display)
                end
            elseif def.EventOnly and not eventOnline then
                subtitle.Text="OFFLINE • ACTIVATES DURING BLACKOUT / MYSTERY"
            elseif unlocked or (def.UnlockCost==0 and not def.EventOnly) then
                local shakes=self.Snapshot and self.Snapshot.Profile.Progression and self.Snapshot.Profile.Progression.MachineShakes[id] or 0
                local nextMilestone
                for _,m in ipairs(Config.MachineMasteryMilestones) do if shakes<m.Shakes then nextMilestone=m;break end end
                subtitle.Text=nextMilestone and string.format("SHAKE • MASTERY %d/%d",shakes,nextMilestone.Shakes) or "MASTERY COMPLETE • HUNT RARES"
            else
                local firstMissing
                for _,req in ipairs(unlockState and unlockState.Requirements or {}) do if not req.Met then firstMissing=req;break end end
                if firstMissing then
                    subtitle.Text=string.format("LOCKED • %s %s/%s",string.upper(firstMissing.Label),Util.FormatInteger(firstMissing.Current),Util.FormatInteger(firstMissing.Target))
                else
                    subtitle.Text="READY • $"..Util.FormatInteger(def.UnlockCost or 0)
                end
            end
            subtitle.TextColor3=accent or def.Accent
        end
        if prompt and def then
            prompt.ObjectText=applies and (def.DisplayName.." • "..(event.Hidden and"???"or event.Display))or def.DisplayName
            if def.EventOnly and not eventOnline then prompt.ActionText="OFFLINE"
            elseif unlocked or (def.UnlockCost==0 and not def.EventOnly) then prompt.ActionText="SHAKE"
            elseif unlockState and unlockState.Met and unlockState.HasCoins then prompt.ActionText="UNLOCK + SHAKE"
            else prompt.ActionText="CHECK REQUIREMENTS" end
        end
    end
end

function MachineController:Init(remotes)
    self.Remotes=remotes;local folder=Workspace:WaitForChild("Machines")
    for _,m in ipairs(folder:GetChildren())do self:ConnectMachine(m)end;folder.ChildAdded:Connect(function(m)task.wait();self:ConnectMachine(m)end)
    remotes.EventChanged.OnClientEvent:Connect(function(event)self:UpdateDisplays(event)end)
end
return MachineController

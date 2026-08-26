local RunService=game:GetService("RunService")
local MachineInteractionController={Audio=nil,Busy={}}

local function artRoot(machine)local shell=machine and machine:FindFirstChild("Shell");return shell and shell:FindFirstChild("OlympusKitbash")end
local function products(art)
    local out={};if not art then return out end
    for _,child in ipairs(art:GetChildren())do if child:IsA("Model")and child.Name:sub(1,8)=="Product_"then table.insert(out,child)end end;return out
end
local function setScreen(screen,value,color)
    if not screen then return end;screen.Color=color or screen.Color
    local gui=screen:FindFirstChild("ArtLabel");local frame=gui and gui:FindFirstChildOfClass("Frame");local label=frame and frame:FindFirstChildOfClass("TextLabel");if label then label.Text=value end
end
local function pulseKey(key,on)if not key then return end;key.Color=on and Color3.fromRGB(255,215,76)or Color3.fromRGB(232,234,229);key.Material=on and Enum.Material.Neon or Enum.Material.SmoothPlastic end

function MachineInteractionController:Animate(machine)
    if not machine or self.Busy[machine]then return end
    local art=artRoot(machine);local root=machine:FindFirstChild("Root");if not art or not root then return end;self.Busy[machine]=true
    local rows=products(art);local originals={};for _,m in ipairs(rows)do originals[m]=m:GetPivot()end
    local screen=art:FindFirstChild("MachineScreen");local key=art:FindFirstChild("Key5");local old=screen and screen.Color
    if self.Audio then self.Audio:PlayMachine("Rattle",root,{Volume=.34,PlaybackSpeed=1.02})end
    setScreen(screen,"SHAKING\n•••",Color3.fromRGB(255,210,75));pulseKey(key,true)
    local started=os.clock();local duration=.34
    while machine.Parent and os.clock()-started<duration do
        local t=(os.clock()-started)/duration;local envelope=1-t
        for i,m in ipairs(rows)do if m.Parent then local base=originals[m];local phase=t*math.pi*11+i*.73;local x=math.sin(phase)*.045*envelope;local y=math.abs(math.cos(phase*.82))*.035*envelope;local rz=math.sin(phase*1.17)*math.rad(2.2)*envelope;m:PivotTo(base*CFrame.new(x,y,0)*CFrame.Angles(0,0,rz))end end
        RunService.RenderStepped:Wait()
    end
    for m,cf in pairs(originals)do if m.Parent then m:PivotTo(cf)end end;pulseKey(key,false);setScreen(screen,"WAIT...",Color3.fromRGB(112,221,236));task.wait(.10)
    if self.Audio then self.Audio:PlayMachine("Clunk",root,{Volume=.55,PlaybackSpeed=.97})end
    setScreen(screen,"COLLECT!",Color3.fromRGB(105,225,145));task.wait(.16)
    if screen and screen.Parent then screen.Color=old or Color3.fromRGB(92,201,228);setScreen(screen,"READY\nSHAKE",screen.Color)end
    self.Busy[machine]=nil
end
function MachineInteractionController:Init(events,audio)
    self.Audio=audio
    events.DropSpawned.OnClientEvent:Connect(function(payload)local folder=workspace:FindFirstChild("Machines");local machine=folder and payload and folder:FindFirstChild(payload.MachineId);if machine then task.spawn(function()self:Animate(machine)end)end end)
end
return MachineInteractionController

local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local MachineArtDirector=require(script.Parent.MachineArtDirector)
local WorldPolishService={}

local function polishMachine(machine)
    local shell=machine:FindFirstChild("Shell");if not shell or not shell:IsA("Model")then return end
    if machine:GetAttribute("ArtDirectionVersion")~=2 then
        local id=machine:GetAttribute("MachineId")or machine.Name
        local ok,art=pcall(function()return MachineArtDirector.Apply(machine,shell,id)end)
        if not ok then warn("[ShakeVM] delayed machine art failed",id,art)end
    end
    local hl=shell:FindFirstChild("MachineAccent");if hl and hl:IsA("Highlight")then hl.OutlineTransparency=.92 end
end

function WorldPolishService:Init()
    -- WorldBuilder owns the authored architecture. Do not clone full Creator Store shops/facades
    -- over it: the first Studio visual test showed those donors as mismatched roofs and loose props.
    local bloom=Lighting:FindFirstChild("ShakeBloom");if bloom and bloom:IsA("BloomEffect")then bloom.Intensity=.06;bloom.Threshold=1.65 end
    local machines=Workspace:FindFirstChild("Machines");if machines then
        for _,m in ipairs(machines:GetChildren())do polishMachine(m)end
        machines.ChildAdded:Connect(function(m)task.defer(function()polishMachine(m)end)end)
    end
end
return WorldPolishService

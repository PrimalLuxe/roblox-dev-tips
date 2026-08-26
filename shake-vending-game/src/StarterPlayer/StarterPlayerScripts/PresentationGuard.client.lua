local Players=game:GetService("Players")
local player=Players.LocalPlayer

local function enforceGui(obj)
    if obj:IsA("UICorner")then
        task.defer(function()if obj.Parent then obj:Destroy()end end)
    end
end
local function enforceWorld(obj)
    if not obj:IsA("BillboardGui")then return end
    if obj.Name=="MachineBillboard"then
        task.defer(function()if obj.Parent then obj:Destroy()end end)
    elseif obj.Name=="RarityRays"then
        obj.Size=UDim2.fromOffset(205,66)
        obj.StudsOffset=Vector3.new(0,1.75,0)
        obj.AlwaysOnTop=false
        obj.MaxDistance=18
        for _,d in ipairs(obj:GetDescendants())do enforceGui(d)end
        obj.DescendantAdded:Connect(enforceGui)
    end
end

local gui=player:WaitForChild("PlayerGui")
for _,d in ipairs(gui:GetDescendants())do enforceGui(d)end
gui.DescendantAdded:Connect(enforceGui)
for _,d in ipairs(workspace:GetDescendants())do enforceWorld(d)end
workspace.DescendantAdded:Connect(enforceWorld)

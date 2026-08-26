local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")

local ShowcaseController={Tracked=setmetatable({}, {__mode="k"}),Accumulator=0}

function ShowcaseController:Rescan()
    local folder=Workspace:FindFirstChild("PlayerShowcases")
    if not folder then return end
    for _,model in ipairs(folder:GetDescendants()) do
        if model:IsA("Model") and model.Name=="DisplayedItem" and not self.Tracked[model] then
            self.Tracked[model]={Base=model:GetPivot(),Phase=math.random()*math.pi*2}
        end
    end
end

function ShowcaseController:Init()
    self:Rescan()
    RunService.Heartbeat:Connect(function(dt)
        self.Accumulator+=dt
        if self.Accumulator<1/20 then return end
        self.Accumulator=0
        self:Rescan()
        local camera=Workspace.CurrentCamera
        if not camera then return end
        local now=os.clock()
        for model,state in pairs(self.Tracked) do
            if not model.Parent then
                self.Tracked[model]=nil
            else
                local base=model:GetAttribute("ShowcaseBaseCFrame") or state.Base
                state.Base=base
                local distance=(camera.CFrame.Position-base.Position).Magnitude
                if distance<=85 then
                    local bob=math.sin(now*1.7+state.Phase)*0.08
                    local yaw=(now*0.32+state.Phase)%(math.pi*2)
                    model:PivotTo(base*CFrame.new(0,bob,0)*CFrame.Angles(0,yaw,0))
                end
            end
        end
    end)
end

return ShowcaseController

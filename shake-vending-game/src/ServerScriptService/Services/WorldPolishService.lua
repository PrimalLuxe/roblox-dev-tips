local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local WorldPolishService={}

function WorldPolishService:Init()
    -- WorldBuilder and MachineArtDirector now own all visible architecture and vending geometry.
    -- This service is deliberately limited to non-destructive runtime polish; it must never clone
    -- full Creator Store buildings or replace authored machine shells.
    local bloom=Lighting:FindFirstChild("ShakeBloom")
    if bloom and bloom:IsA("BloomEffect")then bloom.Intensity=.045;bloom.Threshold=1.8 end
    local hub=Workspace:FindFirstChild("ShakeHub")
    if hub then hub:SetAttribute("VisualPolishVersion",4)end
end

return WorldPolishService

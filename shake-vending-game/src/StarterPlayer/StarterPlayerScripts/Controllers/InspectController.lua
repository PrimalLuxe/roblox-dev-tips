local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local mouse=player:GetMouse()

local InspectController={}

function InspectController:Init(functions,ui,dropController)
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        if dropController.Active and dropController.Active.Hover then return end
        local target=mouse.Target;if not target then return end
        local model=target:FindFirstAncestorOfClass("Model");if not model then return end
        local targetPlayer=Players:GetPlayerFromCharacter(model);if not targetPlayer or targetPlayer==player then return end
        local ok,summary=pcall(function()return functions.GetPlayerSummary:InvokeServer(targetPlayer.UserId)end)
        if ok and summary then ui:ShowInspect(summary) end
    end)
end

return InspectController

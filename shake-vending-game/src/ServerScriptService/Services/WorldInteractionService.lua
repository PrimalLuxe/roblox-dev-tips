local Workspace=game:GetService("Workspace")
local WorldInteractionService={}

local function firstPart(root)
    if root:IsA("BasePart")then return root end
    return root:FindFirstChildWhichIsA("BasePart",true)
end

function WorldInteractionService:Init(RemoteService,InventoryService)
    local hub=Workspace:FindFirstChild("ShakeHub");if not hub then return end
    local sell=hub:FindFirstChild("SellStation")
    local sp=sell and firstPart(sell)
    if sp then
        local common=Instance.new("ProximityPrompt");common.Name="SellCommonsPrompt";common.ActionText="OPEN SELL MENU";common.ObjectText="SAFE SELL STATION";common.KeyboardKeyCode=Enum.KeyCode.E;common.HoldDuration=0.08;common.MaxActivationDistance=10;common.RequiresLineOfSight=false;common.Parent=sp
        common.Triggered:Connect(function(player)RemoteService.Events.OpenPanel:FireClient(player,{Panel="Sell",Mode="commons"})end)
        local dup=Instance.new("ProximityPrompt");dup.Name="SellDuplicatesPrompt";dup.ActionText="SELL DUPLICATES";dup.ObjectText="REVIEW FIRST";dup.KeyboardKeyCode=Enum.KeyCode.Q;dup.HoldDuration=0.08;dup.MaxActivationDistance=10;dup.RequiresLineOfSight=false;dup.Parent=sp
        dup.Triggered:Connect(function(player)RemoteService.Events.OpenPanel:FireClient(player,{Panel="Sell",Mode="duplicates"})end)
    end
    local upgrade=hub:FindFirstChild("UpgradeKiosk");local up=upgrade and firstPart(upgrade)
    if up then
        local pr=Instance.new("ProximityPrompt");pr.Name="UpgradePrompt";pr.ActionText="UPGRADES";pr.ObjectText="POWER SHOP";pr.KeyboardKeyCode=Enum.KeyCode.E;pr.HoldDuration=0.05;pr.MaxActivationDistance=10;pr.RequiresLineOfSight=false;pr.Parent=up
        pr.Triggered:Connect(function(player)RemoteService.Events.OpenPanel:FireClient(player,{Panel="Upgrades"})end)
    end
    local passport=hub:FindFirstChild("PassportKiosk");local pp=passport and firstPart(passport)
    if pp then
        local pr=Instance.new("ProximityPrompt");pr.Name="PassportPrompt";pr.ActionText="OPEN PASSPORT";pr.ObjectText="VENDING PASSPORT";pr.KeyboardKeyCode=Enum.KeyCode.E;pr.GamepadKeyCode=Enum.KeyCode.ButtonY;pr.HoldDuration=0.05;pr.MaxActivationDistance=10;pr.RequiresLineOfSight=false;pr.Parent=pp
        pr.Triggered:Connect(function(player)RemoteService.Events.OpenPanel:FireClient(player,{Panel="Passport"})end)
    end
end
return WorldInteractionService

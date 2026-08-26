local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local OnboardingController={Stage=0,Complete=false}

local function highlightMachine(on)
    local machines=workspace:FindFirstChild("Machines");local machine=machines and machines:FindFirstChild("CornerStore");if not machine then return end
    local h=machine:FindFirstChild("TutorialHighlight")
    if on and not h then h=Instance.new("Highlight");h.Name="TutorialHighlight";h.FillTransparency=0.88;h.OutlineTransparency=0.05;h.OutlineColor=Color3.fromRGB(255,218,76);h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=machine elseif not on and h then h:Destroy() end
end

function OnboardingController:SetText(text)
    if not self.Label then return end
    self.Label.Text=text;self.Frame.Position=UDim2.new(0.5,0,0,-70);TweenService:Create(self.Frame,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,0,0,26)}):Play()
end

function OnboardingController:Finish()
    if self.Complete then return end;self.Complete=true;highlightMachine(false);self.SettingsAction:FireServer("tutorial_complete",true);self:SetText("TUTORIAL COMPLETE • HUNT RARES, BUILD YOUR CATALOG, FLEX YOUR BEST DROPS")
    task.delay(3,function()if self.Frame and self.Frame.Parent then TweenService:Create(self.Frame,TweenInfo.new(0.2),{Position=UDim2.new(0.5,0,0,-70)}):Play()end end)
end

function OnboardingController:Init(remotes,ui)
    self.SettingsAction=remotes.SettingsAction
    local profile=ui.Snapshot and ui.Snapshot.Profile;local settings=profile and profile.Settings or {}
    if settings.TutorialComplete==true or player:GetAttribute("ShakeVM_TutorialComplete")==true then self.Complete=true;return end
    local frame=Instance.new("Frame");frame.Name="Onboarding";frame.AnchorPoint=Vector2.new(0.5,0);frame.Position=UDim2.new(0.5,0,0,-70);frame.Size=UDim2.fromOffset(560,54);frame.BackgroundColor3=Color3.fromRGB(248,244,225);frame.BorderSizePixel=0;frame.ZIndex=150;frame.Parent=ui.Gui;self.Frame=frame
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,14);c.Parent=frame;local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(31,45,66);s.Thickness=2;s.Parent=frame
    local label=Instance.new("TextLabel");label.Size=UDim2.new(1,-24,1,0);label.Position=UDim2.fromOffset(12,0);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBlack;label.TextSize=18;label.TextColor3=Color3.fromRGB(31,45,66);label.TextXAlignment=Enum.TextXAlignment.Center;label.ZIndex=151;label.Parent=frame;self.Label=label
    self.Stage=1;highlightMachine(true);self:SetText("SHAKE THE CORNER STORE MACHINE")
    remotes.DropSpawned.OnClientEvent:Connect(function(payload)if self.Complete or payload.OwnerUserId~=player.UserId then return end;if self.Stage==1 then self.Stage=2;highlightMachine(false);self:SetText("COLLECT IT • CLICK / TAP THE HOVERING ITEM")end end)
    remotes.Toast.OnClientEvent:Connect(function(data)if self.Complete or self.Stage~=2 or type(data)~="table" then return end;local text=tostring(data.Text or "");if data.Kind=="Collect" or text:find("CATALOG",1,true) or text:find("NEW VARIANT",1,true) then self.Stage=3;self:SetText("SELL OR KEEP • OPEN COLLECTION TO SEE YOUR CATALOG") end end)
    ui.OnCollectionOpened=function()if not self.Complete and self.Stage>=3 then self:Finish()end end
end

return OnboardingController

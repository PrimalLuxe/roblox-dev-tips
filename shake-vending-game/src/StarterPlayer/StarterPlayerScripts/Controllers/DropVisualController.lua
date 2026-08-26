local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local Config=require(ReplicatedStorage.Shared.Config)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Mutations=require(ReplicatedStorage.Shared.MutationDefinitions)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util=require(ReplicatedStorage.Shared.Util)

local DropVisualController={Active=nil,EffectQuality="High",ReducedEffects=false,ReducedScreenShake=false,SkipLong=false,PointerPosition=nil,Audio=nil}

local function primary(model)
    if not model then return nil end
    if model.PrimaryPart then return model.PrimaryPart end
    local p=model:FindFirstChildWhichIsA("BasePart",true)
    if p then model.PrimaryPart=p end
    return p
end

local function rankOf(item)return Rarities.Get(item.Rarity).Rank end
local function distanceTo(pos)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return root and (root.Position-pos).Magnitude or math.huge
end

local function billboard(part,item)
    local def=Items[item.BaseItemId];local rarity=Rarities.Get(item.Rarity)
    local gui=Instance.new("BillboardGui");gui.Name="RarityRays";gui.Size=UDim2.fromOffset(280,98);gui.StudsOffset=Vector3.new(0,2.1,0);gui.AlwaysOnTop=true;gui.Adornee=part;gui.Parent=part
    local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(27,31,40);frame.BackgroundTransparency=0.10;frame.BorderSizePixel=0;frame.Parent=gui
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,13);c.Parent=frame
    local st=Instance.new("UIStroke");st.Color=rarity.Color;st.Thickness=1.5;st.Transparency=0.18;st.Parent=frame
    local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Position=UDim2.fromOffset(8,6);name.Size=UDim2.new(1,-16,0,38);name.Text=(item.MutationId~="None" and item.MutationId.." " or "")..(def and def.Name or item.BaseItemId);name.TextColor3=Color3.new(1,1,1);name.TextStrokeTransparency=0.55;name.Font=Enum.Font.GothamBlack;name.TextScaled=true;name.Parent=frame
    local tier=Instance.new("TextLabel");tier.BackgroundTransparency=1;tier.Position=UDim2.fromOffset(8,46);tier.Size=UDim2.new(1,-16,0,22);tier.Text=item.Rarity:upper();tier.TextColor3=rarity.Color;tier.Font=Enum.Font.GothamBlack;tier.TextScaled=true;tier.Parent=frame
    local odds=Instance.new("TextLabel");odds.BackgroundTransparency=1;odds.Position=UDim2.fromOffset(8,70);odds.Size=UDim2.new(1,-16,0,18);odds.Text="1 IN "..Util.FormatInteger(item.OneIn or 1);odds.TextColor3=Color3.fromRGB(220,225,235);odds.Font=Enum.Font.GothamBold;odds.TextScaled=true;odds.Parent=frame
    return gui
end

local function highlight(model,item)
    local h=Instance.new("Highlight");h.FillTransparency=0.83;h.OutlineTransparency=0.08;h.FillColor=Rarities.Get(item.Rarity).Color;h.OutlineColor=Rarities.Get(item.Rarity).Color;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model;return h
end

local function particles(part,item,quality,reduced)
    if reduced or quality=="Low" or not part then return end
    local rank=rankOf(item);if rank<3 and item.MutationId=="None" then return end
    local a=Instance.new("Attachment");a.Name="RewardVFX";a.Parent=part
    if rank>=7 then local beam=Instance.new("Beam");beam.Name="DiscoveryBeam";beam.Attachment0=a;beam.Attachment1=a;beam.Width0=0.12;beam.Width1=0;beam.Transparency=NumberSequence.new(0.55);beam.Color=ColorSequence.new(Rarities.Get(item.Rarity).Color);beam.Parent=a end
    local e=Instance.new("ParticleEmitter");e.Rate=math.min(Config.MaxLocalParticles,quality=="High" and 10+rank*3 or 6+rank*2);e.Lifetime=NumberRange.new(0.5,1.25);e.Speed=NumberRange.new(0.35,1.25);e.SpreadAngle=Vector2.new(180,180);e.LightEmission=0.82;e.Rotation=NumberRange.new(0,360);e.RotSpeed=NumberRange.new(-100,100);e.Color=ColorSequence.new((Mutations[item.MutationId] and Mutations[item.MutationId].Color) or Rarities.Get(item.Rarity).Color);e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.22),NumberSequenceKeypoint.new(0.65,0.12),NumberSequenceKeypoint.new(1,0)});e.Parent=a
end

local function rewardPulse(item)
    local rank=rankOf(item);if rank<5 then return end
    if DropVisualController.Audio then DropVisualController.Audio:PlayRarity(item.Rarity,camera) end
    if DropVisualController.ReducedEffects then return end
    local gui=Instance.new("ScreenGui");gui.Name="ShakeRarityReveal";gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=120;gui.Parent=player.PlayerGui
    local flash=Instance.new("Frame");flash.Size=UDim2.fromScale(1,1);flash.BackgroundColor3=Rarities.Get(item.Rarity).Color;flash.BackgroundTransparency=0.92;flash.BorderSizePixel=0;flash.Parent=gui
    local text=Instance.new("TextLabel");text.AnchorPoint=Vector2.new(0.5,0.5);text.Position=UDim2.fromScale(0.5,0.32);text.Size=UDim2.fromOffset(650,95);text.BackgroundTransparency=1;text.Text=(rank>=8 and "INCREDIBLE FIND" or "RARE FIND").."  •  1 / "..Util.FormatInteger(item.OneIn or 1);text.TextColor3=Rarities.Get(item.Rarity).Color;text.TextStrokeTransparency=0.22;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=gui
    local scale=Instance.new("UIScale");scale.Scale=0.72;scale.Parent=text
    TweenService:Create(scale,TweenInfo.new(0.20,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play();TweenService:Create(flash,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play()
    task.delay(DropVisualController.SkipLong and 0.45 or 1.15,function()if gui.Parent then gui:Destroy()end end)
end

local function animateMachine(machine)
    if not machine then return end
    local shell=machine:FindFirstChild("Shell");if not shell or not shell:IsA("Model") then return end
    local original=shell:GetPivot();local start=os.clock();local duration=0.32
    while shell.Parent and os.clock()-start<duration do
        local t=(os.clock()-start)/duration;local mag=(1-t)*0.10;local angle=math.sin(t*math.pi*8)*mag;shell:PivotTo(original*CFrame.Angles(0,0,angle));RunService.RenderStepped:Wait()
    end
    if shell.Parent then shell:PivotTo(original)end
end

function DropVisualController:SetSettings(settings,legacySkipLong)
    if type(settings)=="table" then
        self.EffectQuality=settings.EffectQuality or self.EffectQuality;self.SkipLong=settings.SkipLongReveals==true;self.ReducedEffects=settings.ReducedEffects==true;self.ReducedScreenShake=settings.ReducedScreenShake==true
    else self.EffectQuality=settings or self.EffectQuality;self.SkipLong=legacySkipLong==true end
end

function DropVisualController:CreateOwn(payload)
    if self.Active and self.Active.Model and self.Active.Model.Parent then self.Active.Model:Destroy() end
    self.Active=nil
    local item=payload.Item;local machine=workspace:FindFirstChild("Machines") and workspace.Machines:FindFirstChild(payload.MachineId)
    if not item or not machine then return end
    task.spawn(function()animateMachine(machine)end)
    local model=Factory.Create(item.BaseItemId,item.MutationId);if not model then return end
    model.Name="LocalReward";model.Parent=workspace
    local p=primary(model);if not p then model:Destroy();return end
    pcall(function()model:ScaleTo(rankOf(item)>=8 and 1.10 or 0.88)end)
    local spawn=machine:FindFirstChild("DropSpawn");if not spawn then model:Destroy();return end
    local base=spawn.CFrame*CFrame.new(0,0.55,0);model:PivotTo(base*CFrame.new(0,1.0,0));highlight(model,item);particles(p,item,self.EffectQuality,self.ReducedEffects);billboard(p,item);rewardPulse(item)
    self.Active={Model=model,Primary=p,BaseCFrame=base,Token=payload.Token,Item=item,Start=os.clock(),CollectEnabled=false,Collecting=false,Hover=false}
    task.delay(payload.AvailableAfter or Config.CollectDelay,function()if self.Active and self.Active.Model==model then self.Active.CollectEnabled=true end end)
end

function DropVisualController:RenderActive()
    local a=self.Active;if not a or not a.Model or not a.Model.Parent then return end
    local screen,onScreen=camera:WorldToViewportPoint(a.Primary.Position);local pointer=self.PointerPosition or UserInputService:GetMouseLocation();a.Hover=onScreen and (Vector2.new(screen.X,screen.Y)-pointer).Magnitude<=125
    local t=os.clock()-a.Start;local bob=math.sin(t*2.8)*0.10;local scale=a.Hover and 1.10 or 1
    a.Model:PivotTo(a.BaseCFrame*CFrame.new(0,bob,0)*CFrame.Angles(0,t*0.55,0));pcall(function()a.Model:ScaleTo((rankOf(a.Item)>=8 and 1.10 or 0.88)*scale)end)
end

function DropVisualController:TryCollect(pointerPosition,force)
    local a=self.Active;if not a or not a.CollectEnabled or a.Collecting then return false end
    local hover=a.Hover
    if pointerPosition then local s,on=camera:WorldToViewportPoint(a.Primary.Position);hover=on and (Vector2.new(s.X,s.Y)-pointerPosition).Magnitude<=130 end
    if not hover and not force then return false end
    a.Collecting=true;self.Remotes.CollectDrop:FireServer(a.Token)
    local model=a.Model;local start=model:GetPivot();local begin=os.clock()
    while model.Parent and os.clock()-begin<0.20 do local t=(os.clock()-begin)/0.20;model:PivotTo(start:Lerp(camera.CFrame*CFrame.new(2.5,-1.5,-5),t*t));RunService.RenderStepped:Wait()end
    if model.Parent then model:Destroy()end;if self.Active==a then self.Active=nil end;return true
end

function DropVisualController:ShowWorld(payload)
    if not payload or payload.OwnerUserId==player.UserId then return end
    local item=payload.Item;local machine=workspace:FindFirstChild("Machines") and workspace.Machines:FindFirstChild(payload.MachineId);if not item or not machine then return end
    if rankOf(item)<5 then return end
    local spawn=machine:FindFirstChild("DropSpawn");if not spawn or distanceTo(spawn.Position)>Config.ReducedVfxDistance then return end
    local model=Factory.Create(item.BaseItemId,item.MutationId);if not model then return end
    model.Name="WorldRareDrop";model.Parent=workspace;local p=primary(model);if not p then model:Destroy();return end
    pcall(function()model:ScaleTo(distanceTo(spawn.Position)<=Config.FullVfxDistance and 0.72 or 0.50)end);model:PivotTo(spawn.CFrame*CFrame.new(0,0.7,0));highlight(model,item)
    if distanceTo(spawn.Position)<=Config.FullVfxDistance then particles(p,item,self.EffectQuality,self.ReducedEffects);billboard(p,item)end
    task.delay(2.4,function()if model.Parent then model:Destroy()end end)
end

function DropVisualController:Init(remotes)
    self.Remotes=remotes
    remotes.DropSpawned.OnClientEvent:Connect(function(payload)task.spawn(function()self:CreateOwn(payload)end)end)
    remotes.WorldDrop.OnClientEvent:Connect(function(payload)task.spawn(function()self:ShowWorld(payload)end)end)
    RunService.RenderStepped:Connect(function()self:RenderActive()end)
    UserInputService.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch then self.PointerPosition=Vector2.new(input.Position.X,input.Position.Y)end end)
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.UserInputType==Enum.UserInputType.Touch then self.PointerPosition=Vector2.new(input.Position.X,input.Position.Y);self:TryCollect(self.PointerPosition,false)
        elseif input.UserInputType==Enum.UserInputType.MouseButton1 then self:TryCollect(UserInputService:GetMouseLocation(),false)
        elseif input.KeyCode==Enum.KeyCode.ButtonA then self:TryCollect(nil,true)end
    end)
end

return DropVisualController

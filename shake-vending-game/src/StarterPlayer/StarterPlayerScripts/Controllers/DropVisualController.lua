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
local VFX=require(ReplicatedStorage.Shared.VFXManifest)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util=require(ReplicatedStorage.Shared.Util)

local DropVisualController={Active=nil,EffectQuality="High",ReducedEffects=false,ReducedScreenShake=false,SkipLong=false,PointerPosition=nil,Audio=nil}

local function primary(model)
    if not model then return nil end
    if model.PrimaryPart then return model.PrimaryPart end
    local p=model:FindFirstChildWhichIsA("BasePart",true);if p then model.PrimaryPart=p end;return p
end
local function rankOf(item)return Rarities.Get(item.Rarity).Rank end
local function distanceTo(pos)local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");return root and(root.Position-pos).Magnitude or math.huge end
local function attachment(part,name)local a=Instance.new("Attachment");a.Name=name;a.Parent=part;return a end
local function colorOf(item)return(Mutations[item.MutationId]and Mutations[item.MutationId].Color)or Rarities.Get(item.Rarity).Color end

local function billboard(part,item)
    local def=Items[item.BaseItemId];local rarity=Rarities.Get(item.Rarity)
    local gui=Instance.new("BillboardGui");gui.Name="RarityRays";gui.Size=UDim2.fromOffset(300,106);gui.StudsOffset=Vector3.new(0,2.25,0);gui.AlwaysOnTop=true;gui.Adornee=part;gui.Parent=part
    local shadow=Instance.new("Frame");shadow.Position=UDim2.fromOffset(0,5);shadow.Size=UDim2.fromScale(1,1);shadow.BackgroundColor3=Color3.fromRGB(24,35,46);shadow.BackgroundTransparency=.55;shadow.BorderSizePixel=0;shadow.Parent=gui;local sc=Instance.new("UICorner");sc.CornerRadius=UDim.new(0,14);sc.Parent=shadow
    local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(255,248,226);frame.BackgroundTransparency=.03;frame.BorderSizePixel=0;frame.Parent=gui
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,14);c.Parent=frame
    local st=Instance.new("UIStroke");st.Color=rarity.Color;st.Thickness=3;st.Transparency=.05;st.Parent=frame
    local stripe=Instance.new("Frame");stripe.Size=UDim2.new(0,8,1,-14);stripe.Position=UDim2.fromOffset(7,7);stripe.BackgroundColor3=rarity.Color;stripe.BorderSizePixel=0;stripe.Parent=frame;local cc=Instance.new("UICorner");cc.CornerRadius=UDim.new(0,5);cc.Parent=stripe
    local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Position=UDim2.fromOffset(24,8);name.Size=UDim2.new(1,-34,0,40);name.Text=(item.MutationId~="None"and item.MutationId.." "or"")..(def and def.Name or item.BaseItemId);name.TextColor3=Color3.fromRGB(31,49,70);name.Font=Enum.Font.GothamBlack;name.TextScaled=true;name.Parent=frame
    local tier=Instance.new("TextLabel");tier.BackgroundTransparency=1;tier.Position=UDim2.fromOffset(24,50);tier.Size=UDim2.new(.52,-24,0,22);tier.Text=item.Rarity:upper();tier.TextColor3=rarity.Color;tier.Font=Enum.Font.GothamBlack;tier.TextScaled=true;tier.TextXAlignment=Enum.TextXAlignment.Left;tier.Parent=frame
    local odds=tier:Clone();odds.Position=UDim2.new(.52,0,0,50);odds.Size=UDim2.new(.48,-12,0,22);odds.Text="1 IN "..Util.FormatInteger(item.OneIn or 1);odds.TextColor3=Color3.fromRGB(75,89,101);odds.TextXAlignment=Enum.TextXAlignment.Right;odds.Parent=frame
    local hint=Instance.new("TextLabel");hint.BackgroundTransparency=1;hint.Position=UDim2.fromOffset(24,76);hint.Size=UDim2.new(1,-36,0,20);hint.Text="CLICK / TAP TO COLLECT";hint.TextColor3=Color3.fromRGB(99,112,124);hint.Font=Enum.Font.GothamBold;hint.TextSize=10;hint.Parent=frame
    return gui
end

local function highlight(model,item)local h=Instance.new("Highlight");h.FillTransparency=.86;h.OutlineTransparency=.05;h.FillColor=colorOf(item);h.OutlineColor=Rarities.Get(item.Rarity).Color;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model;return h end

local function emitter(a,rate,speed,life,size,color)
    local e=Instance.new("ParticleEmitter");e.Rate=rate;e.Lifetime=life;e.Speed=speed;e.SpreadAngle=Vector2.new(180,180);e.LightEmission=.78;e.Rotation=NumberRange.new(0,360);e.RotSpeed=NumberRange.new(-120,120);e.Color=ColorSequence.new(color);e.Size=size;e.Parent=a;return e
end

local function addRarityRays(part,item,q,tier)
    if tier.Rays<=0 or q.RaysScale<=0 then return end
    local a=attachment(part,"RarityRayCore")
    local count=math.max(2,math.floor(tier.Rays*q.RaysScale))
    for i=1,count do
        local ray=Instance.new("ParticleEmitter");ray.Rate=0;ray.Lifetime=NumberRange.new(.32,.48);ray.Speed=NumberRange.new(2.2,3.8);ray.SpreadAngle=Vector2.new(16,180);ray.LightEmission=1;ray.Color=ColorSequence.new(Rarities.Get(item.Rarity).Color);ray.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.45,.035),NumberSequenceKeypoint.new(1,0)});ray.Parent=a;ray:Emit(1)
    end
end

local function addMutationLanguage(part,item,q,tier)
    if DropVisualController.ReducedEffects or DropVisualController.EffectQuality=="Low" then return end
    local spec=VFX.GetMutation(item.MutationId);local c=colorOf(item);local a=attachment(part,"Mutation_"..spec.Family);local budget=math.max(1,math.floor(tier.Particles*q.ParticleScale))
    if spec.Family=="Sparkle" then
        local s=Instance.new("Sparkles");s.SparkleColor=c;s.Parent=part
    elseif spec.Family=="EmberFlame" then
        local fire=Instance.new("Fire");fire.Color=c;fire.SecondaryColor=Color3.fromRGB(255,204,86);fire.Heat=4;fire.Size=2.2;fire.Parent=part
        emitter(a,math.max(3,budget),NumberRange.new(.4,1.4),NumberRange.new(.35,.8),NumberSequence.new({NumberSequenceKeypoint.new(0,.16),NumberSequenceKeypoint.new(1,0)}),c).Acceleration=Vector3.new(0,2.6,0)
    elseif spec.Family=="SnowMist" then
        local e=emitter(a,math.max(3,budget),NumberRange.new(.15,.55),NumberRange.new(.8,1.5),NumberSequence.new({NumberSequenceKeypoint.new(0,.13),NumberSequenceKeypoint.new(.7,.09),NumberSequenceKeypoint.new(1,0)}),c);e.Acceleration=Vector3.new(0,-.7,0);e.Drag=1.2
    elseif spec.Family=="ToxicBubbles" then
        local e=emitter(a,math.max(3,budget),NumberRange.new(.25,.8),NumberRange.new(.65,1.25),NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.55,.21),NumberSequenceKeypoint.new(1,0)}),c);e.Acceleration=Vector3.new(0,1.8,0)
    elseif spec.Family=="ShadowSmoke" or spec.Family=="VoidCollapse" then
        local smoke=Instance.new("Smoke");smoke.Color=c;smoke.Opacity=.22;smoke.RiseVelocity=spec.Family=="VoidCollapse"and -.6 or .35;smoke.Size=2;smoke.Parent=part
    elseif spec.Family=="GlitchBits" then
        local e=emitter(a,math.max(4,budget),NumberRange.new(.8,2.1),NumberRange.new(.18,.4),NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.8,.12),NumberSequenceKeypoint.new(1,0)}),c);e.SpreadAngle=Vector2.new(8,180);e.RotSpeed=NumberRange.new(0,0)
    elseif spec.Family=="StarOrbit" or spec.Family=="Spectrum" or spec.Family=="Halo" then
        local e=emitter(a,math.max(3,budget),NumberRange.new(.12,.42),NumberRange.new(.65,1.15),NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.5,.18),NumberSequenceKeypoint.new(1,0)}),c);e.Acceleration=Vector3.new(0,.7,0)
    else
        emitter(a,math.max(2,budget),NumberRange.new(.25,1.0),NumberRange.new(.45,1.0),NumberSequence.new({NumberSequenceKeypoint.new(0,.17),NumberSequenceKeypoint.new(.65,.10),NumberSequenceKeypoint.new(1,0)}),c)
    end
    if q.Lights and spec.Light>0 then local l=Instance.new("PointLight");l.Name="MutationGlow";l.Color=c;l.Brightness=spec.Light*2;l.Range=5+rankOf(item)*.45;l.Shadows=false;l.Parent=part end
end

local function particles(part,item,quality,reduced)
    if reduced or not part then return end
    local q=VFX.GetQuality(quality);local tier=VFX.GetTier(item.Rarity);local rank=rankOf(item)
    if rank>=3 then
        local a=attachment(part,"RewardVFX")
        local rate=math.min(Config.MaxLocalParticles,math.max(2,math.floor(tier.Particles*q.ParticleScale)))
        if rate>0 then emitter(a,rate,NumberRange.new(.3,1.15),NumberRange.new(.5,1.15),NumberSequence.new({NumberSequenceKeypoint.new(0,.20),NumberSequenceKeypoint.new(.65,.11),NumberSequenceKeypoint.new(1,0)}),Rarities.Get(item.Rarity).Color)end
    end
    addRarityRays(part,item,q,tier);addMutationLanguage(part,item,q,tier)
    if rank>=7 then
        local top=attachment(part,"DiscoveryBeamTop");top.Position=Vector3.new(0,14,0);local base=attachment(part,"DiscoveryBeamBase")
        local beam=Instance.new("Beam");beam.Name="DiscoveryBeam";beam.Attachment0=base;beam.Attachment1=top;beam.Width0=.28;beam.Width1=.04;beam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(1,.85)});beam.Color=ColorSequence.new(Rarities.Get(item.Rarity).Color);beam.LightEmission=1;beam.Parent=base
    end
end

local function rewardPulse(item)
    local rank=rankOf(item);if rank<5 then return end
    if DropVisualController.Audio then DropVisualController.Audio:PlayRarity(item.Rarity,camera)end
    if DropVisualController.ReducedEffects then return end
    local gui=Instance.new("ScreenGui");gui.Name="ShakeRarityReveal";gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=120;gui.Parent=player.PlayerGui
    local flash=Instance.new("Frame");flash.Size=UDim2.fromScale(1,1);flash.BackgroundColor3=Rarities.Get(item.Rarity).Color;flash.BackgroundTransparency=.93;flash.BorderSizePixel=0;flash.Parent=gui
    local plate=Instance.new("Frame");plate.AnchorPoint=Vector2.new(.5,.5);plate.Position=UDim2.fromScale(.5,.30);plate.Size=UDim2.fromOffset(680,104);plate.BackgroundColor3=Color3.fromRGB(255,248,226);plate.BackgroundTransparency=.04;plate.BorderSizePixel=0;plate.Parent=gui;local pc=Instance.new("UICorner");pc.CornerRadius=UDim.new(0,18);pc.Parent=plate;local ps=Instance.new("UIStroke");ps.Color=Rarities.Get(item.Rarity).Color;ps.Thickness=4;ps.Parent=plate
    local text=Instance.new("TextLabel");text.Size=UDim2.new(1,-30,1,-20);text.Position=UDim2.fromOffset(15,10);text.BackgroundTransparency=1;text.Text=(rank>=8 and"INCREDIBLE FIND"or"RARE FIND").."  •  1 / "..Util.FormatInteger(item.OneIn or 1);text.TextColor3=Rarities.Get(item.Rarity).Color;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=plate
    local scale=Instance.new("UIScale");scale.Scale=.72;scale.Parent=plate;TweenService:Create(scale,TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play();TweenService:Create(flash,TweenInfo.new(.38),{BackgroundTransparency=1}):Play()
    task.delay(DropVisualController.SkipLong and .45 or 1.15,function()if gui.Parent then gui:Destroy()end end)
end

local function animateMachine(machine)
    if not machine then return end;local shell=machine:FindFirstChild("Shell");if not shell or not shell:IsA("Model")then return end
    local original=shell:GetPivot();local start=os.clock();local duration=.32
    while shell.Parent and os.clock()-start<duration do local t=(os.clock()-start)/duration;local mag=(1-t)*.10;local angle=math.sin(t*math.pi*8)*mag;shell:PivotTo(original*CFrame.Angles(0,0,angle));RunService.RenderStepped:Wait()end
    if shell.Parent then shell:PivotTo(original)end
end

function DropVisualController:SetSettings(settings,legacySkipLong)
    if type(settings)=="table"then self.EffectQuality=settings.EffectQuality or self.EffectQuality;self.SkipLong=settings.SkipLongReveals==true;self.ReducedEffects=settings.ReducedEffects==true;self.ReducedScreenShake=settings.ReducedScreenShake==true else self.EffectQuality=settings or self.EffectQuality;self.SkipLong=legacySkipLong==true end
end
function DropVisualController:CreateOwn(payload)
    if self.Active and self.Active.Model and self.Active.Model.Parent then self.Active.Model:Destroy()end;self.Active=nil
    local item=payload.Item;local machine=workspace:FindFirstChild("Machines")and workspace.Machines:FindFirstChild(payload.MachineId);if not item or not machine then return end
    task.spawn(function()animateMachine(machine)end)
    local model=Factory.Create(item.BaseItemId,item.MutationId);if not model then return end;model.Name="LocalReward";model.Parent=workspace
    local p=primary(model);if not p then model:Destroy();return end;pcall(function()model:ScaleTo(rankOf(item)>=8 and 1.10 or .88)end)
    local spawn=machine:FindFirstChild("DropSpawn");if not spawn then model:Destroy();return end
    local base=spawn.CFrame*CFrame.new(0,.55,0);model:PivotTo(base*CFrame.new(0,1,0));highlight(model,item);particles(p,item,self.EffectQuality,self.ReducedEffects);billboard(p,item);rewardPulse(item)
    self.Active={Model=model,Primary=p,BaseCFrame=base,Token=payload.Token,Item=item,Start=os.clock(),CollectEnabled=false,Collecting=false,Hover=false}
    task.delay(payload.AvailableAfter or Config.CollectDelay,function()if self.Active and self.Active.Model==model then self.Active.CollectEnabled=true end end)
end
function DropVisualController:RenderActive()
    local a=self.Active;if not a or not a.Model or not a.Model.Parent then return end
    local screen,onScreen=camera:WorldToViewportPoint(a.Primary.Position);local pointer=self.PointerPosition or UserInputService:GetMouseLocation();a.Hover=onScreen and(Vector2.new(screen.X,screen.Y)-pointer).Magnitude<=125
    local t=os.clock()-a.Start;local bob=math.sin(t*2.8)*.10;local scale=a.Hover and 1.10 or 1;a.Model:PivotTo(a.BaseCFrame*CFrame.new(0,bob,0)*CFrame.Angles(0,t*.55,0));pcall(function()a.Model:ScaleTo((rankOf(a.Item)>=8 and 1.10 or .88)*scale)end)
end
function DropVisualController:TryCollect(pointerPosition,force)
    local a=self.Active;if not a or not a.CollectEnabled or a.Collecting then return false end;local hover=a.Hover
    if pointerPosition then local s,on=camera:WorldToViewportPoint(a.Primary.Position);hover=on and(Vector2.new(s.X,s.Y)-pointerPosition).Magnitude<=130 end;if not hover and not force then return false end
    a.Collecting=true;self.Remotes.CollectDrop:FireServer(a.Token);local model=a.Model;local start=model:GetPivot();local begin=os.clock()
    while model.Parent and os.clock()-begin<.20 do local t=(os.clock()-begin)/.20;model:PivotTo(start:Lerp(camera.CFrame*CFrame.new(2.5,-1.5,-5),t*t));RunService.RenderStepped:Wait()end
    if model.Parent then model:Destroy()end;if self.Active==a then self.Active=nil end;return true
end
function DropVisualController:ShowWorld(payload)
    if not payload or payload.OwnerUserId==player.UserId then return end;local item=payload.Item;local machine=workspace:FindFirstChild("Machines")and workspace.Machines:FindFirstChild(payload.MachineId);if not item or not machine or rankOf(item)<5 then return end
    local spawn=machine:FindFirstChild("DropSpawn");if not spawn or distanceTo(spawn.Position)>Config.ReducedVfxDistance then return end
    local model=Factory.Create(item.BaseItemId,item.MutationId);if not model then return end;model.Name="WorldRareDrop";model.Parent=workspace;local p=primary(model);if not p then model:Destroy();return end
    pcall(function()model:ScaleTo(distanceTo(spawn.Position)<=Config.FullVfxDistance and .72 or .50)end);model:PivotTo(spawn.CFrame*CFrame.new(0,.7,0));highlight(model,item)
    if distanceTo(spawn.Position)<=Config.FullVfxDistance then particles(p,item,self.EffectQuality,self.ReducedEffects);billboard(p,item)end;task.delay(2.4,function()if model.Parent then model:Destroy()end end)
end
function DropVisualController:Init(remotes)
    self.Remotes=remotes;remotes.DropSpawned.OnClientEvent:Connect(function(payload)task.spawn(function()self:CreateOwn(payload)end)end);remotes.WorldDrop.OnClientEvent:Connect(function(payload)task.spawn(function()self:ShowWorld(payload)end)end)
    RunService.RenderStepped:Connect(function()self:RenderActive()end)
    UserInputService.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch then self.PointerPosition=Vector2.new(input.Position.X,input.Position.Y)end end)
    UserInputService.InputBegan:Connect(function(input,gp)if gp then return end;if input.UserInputType==Enum.UserInputType.Touch then self.PointerPosition=Vector2.new(input.Position.X,input.Position.Y);self:TryCollect(self.PointerPosition,false)elseif input.UserInputType==Enum.UserInputType.MouseButton1 then self:TryCollect(UserInputService:GetMouseLocation(),false)elseif input.KeyCode==Enum.KeyCode.ButtonA then self:TryCollect(nil,true)end end)
end
return DropVisualController

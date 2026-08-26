local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Manifest=require(ReplicatedStorage.Shared.SoundManifest)
local AudioController={Enabled=true,MusicEnabled=true,Loops={},LastPlayed={},ActiveCounts={},GuiConnections={},DuckGeneration=0}

local function group(name)
    local g=SoundService:FindFirstChild("ShakeVM_"..name)
    if not g then g=Instance.new("SoundGroup");g.Name="ShakeVM_"..name;g.Parent=SoundService end
    return g
end

local function keyFor(def)
    return tostring(def.Group or "SFX")..":"..tostring(def.Id)..":"..tostring(def.PlaybackSpeed or 1)
end

function AudioController:_baseVolume(name)
    local mix=Manifest.Mix or {}
    local volume=tonumber(mix[name]) or 1
    if name=="Music" then return self.MusicEnabled and volume or 0 end
    return self.Enabled and volume or 0
end

function AudioController:_applyMix(duration)
    if not self.Groups then return end
    for name,g in pairs(self.Groups)do
        local target=self:_baseVolume(name)
        if duration and duration>0 then TweenService:Create(g,TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Volume=target}):Play()else g.Volume=target end
    end
end

function AudioController:Init()
    self.Groups={SFX=group("SFX"),UI=group("UI"),Ambient=group("Ambient"),Music=group("Music"),RareReveal=group("RareReveal")}
    self:_applyMix()
end

function AudioController:SetSettings(settings)
    settings=settings or {}
    self.Enabled=settings.SFXEnabled~=false
    self.MusicEnabled=settings.MusicEnabled~=false
    self:_applyMix(.12)
end

function AudioController:DuckFor(seconds)
    if not self.Groups or not self.Enabled then return end
    local mix=Manifest.Mix and Manifest.Mix.Duck or {}
    self.DuckGeneration+=1
    local generation=self.DuckGeneration
    local attack=tonumber(mix.Attack) or .08
    local hold=tonumber(seconds) or tonumber(mix.Hold) or .55
    local release=tonumber(mix.Release) or .34
    for _,name in ipairs({"Music","Ambient","SFX"})do
        local g=self.Groups[name]
        if g then
            local scale=tonumber(mix[name]) or 1
            TweenService:Create(g,TweenInfo.new(attack,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Volume=self:_baseVolume(name)*scale}):Play()
        end
    end
    task.delay(attack+hold,function()
        if generation~=self.DuckGeneration then return end
        for _,name in ipairs({"Music","Ambient","SFX"})do
            local g=self.Groups[name]
            if g then TweenService:Create(g,TweenInfo.new(release,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Volume=self:_baseVolume(name)}):Play()end
        end
    end)
end

function AudioController:Play(def,parent,overrides)
    if not def or not def.Id or def.Id=="" then return nil end
    local groupName=def.Group or "SFX"
    if groupName=="Music" then if not self.MusicEnabled then return nil end elseif not self.Enabled then return nil end
    local now=os.clock()
    local key=keyFor(def)
    local cooldown=tonumber(def.Cooldown) or 0
    if cooldown>0 and now-(self.LastPlayed[key] or -math.huge)<cooldown then return nil end
    local maxInstances=math.max(1,tonumber(def.MaxInstances) or 6)
    if (self.ActiveCounts[key] or 0)>=maxInstances then return nil end
    self.LastPlayed[key]=now
    self.ActiveCounts[key]=(self.ActiveCounts[key] or 0)+1

    parent=parent or SoundService
    local s=Instance.new("Sound")
    s.SoundId=def.Id
    s.Volume=(overrides and overrides.Volume) or def.Volume or 0.35
    s.PlaybackSpeed=(overrides and overrides.PlaybackSpeed) or def.PlaybackSpeed or 1
    s.Looped=false
    s.SoundGroup=self.Groups and self.Groups[groupName] or nil
    if parent:IsA("BasePart") or parent:IsA("Attachment") then
        s.RollOffMode=Enum.RollOffMode.InverseTapered
        s.RollOffMinDistance=math.min(8,def.RollOffMaxDistance or 55)
        s.RollOffMaxDistance=def.RollOffMaxDistance or 55
    end
    s.Parent=parent
    local released=false
    local function release()
        if released then return end
        released=true
        self.ActiveCounts[key]=math.max(0,(self.ActiveCounts[key] or 1)-1)
    end
    s.Ended:Connect(release)
    s.AncestryChanged:Connect(function(_,newParent)if newParent==nil then release()end end)
    if def.Duck then self:DuckFor((overrides and overrides.DuckHold) or nil)end
    s:Play()
    Debris:AddItem(s,math.max(5,(s.TimeLength>0 and s.TimeLength+1 or 5)))
    return s
end

function AudioController:PlayCategory(category,name,parent,overrides)
    return self:Play(Manifest.Get(category,name),parent,overrides)
end

function AudioController:PlayMachine(name,parent,overrides)
    return self:PlayCategory("Machine",name,parent,overrides)
end

function AudioController:PlayUI(name,overrides)
    return self:PlayCategory("UI",name,SoundService,overrides)
end

function AudioController:PlayRarity(rarity,parent)
    return self:PlayCategory("Rarity",rarity,parent)
end

function AudioController:EnsureMachineHum(machine)
    local root=machine and machine:FindFirstChild("Root");if not root then return end
    local key=machine:GetDebugId()
    local existing=self.Loops[key]
    if existing and existing.Parent then return existing end
    local def=Manifest.Machine.Hum;if not def or not def.Id then return end
    local s=Instance.new("Sound")
    s.Name="MachineHum";s.SoundId=def.Id;s.Volume=def.Volume or 0.13;s.Looped=true
    s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMinDistance=5;s.RollOffMaxDistance=def.RollOffMaxDistance or 30
    s.SoundGroup=self.Groups and self.Groups.Ambient or nil;s.Parent=root;s:Play();self.Loops[key]=s
    machine.AncestryChanged:Connect(function(_,newParent)
        if newParent==nil then
            if self.Loops[key]==s then self.Loops[key]=nil end
            if s.Parent then s:Destroy()end
        end
    end)
    return s
end

function AudioController:BindGui(root)
    if not root then return end
    local function bind(button)
        if not button:IsA("GuiButton") or button:GetAttribute("ShakeAudioBound") then return end
        button:SetAttribute("ShakeAudioBound",true)
        table.insert(self.GuiConnections,button.MouseEnter:Connect(function()
            if button.Visible and button.Active and not button:GetAttribute("SilentAudio") then self:PlayUI("Hover")end
        end))
        table.insert(self.GuiConnections,button.Activated:Connect(function()
            if not button:GetAttribute("SilentAudio") then self:PlayUI("Click")end
        end))
    end
    for _,d in ipairs(root:GetDescendants())do bind(d)end
    table.insert(self.GuiConnections,root.DescendantAdded:Connect(function(d)task.defer(function()if d.Parent then bind(d)end end)end))
end

return AudioController

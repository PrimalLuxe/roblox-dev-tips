local SoundService=game:GetService("SoundService")
local Debris=game:GetService("Debris")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Manifest=require(ReplicatedStorage.Shared.SoundManifest)
local AudioController={Enabled=true,MusicEnabled=true,Loops={}}

local function group(name)
    local g=SoundService:FindFirstChild("ShakeVM_"..name)
    if not g then g=Instance.new("SoundGroup");g.Name="ShakeVM_"..name;g.Parent=SoundService end
    return g
end

function AudioController:Init()
    self.Groups={SFX=group("SFX"),UI=group("UI"),Ambient=group("Ambient"),Music=group("Music"),RareReveal=group("RareReveal")}
end

function AudioController:SetSettings(settings)
    settings=settings or {}
    self.Enabled=settings.SFXEnabled~=false
    self.MusicEnabled=settings.MusicEnabled~=false
    if self.Groups then
        self.Groups.SFX.Volume=self.Enabled and 1 or 0
        self.Groups.UI.Volume=self.Enabled and 1 or 0
        self.Groups.Ambient.Volume=self.Enabled and 1 or 0
        self.Groups.RareReveal.Volume=self.Enabled and 1 or 0
        self.Groups.Music.Volume=self.MusicEnabled and 1 or 0
    end
end

function AudioController:Play(def,parent,overrides)
    if not self.Enabled or not def or not def.Id or def.Id=="" then return nil end
    parent=parent or SoundService
    local s=Instance.new("Sound")
    s.SoundId=def.Id;s.Volume=(overrides and overrides.Volume) or def.Volume or 0.35
    s.PlaybackSpeed=(overrides and overrides.PlaybackSpeed) or def.PlaybackSpeed or 1
    s.Looped=false;s.SoundGroup=self.Groups and self.Groups[def.Group or "SFX"] or nil
    if parent:IsA("BasePart") or parent:IsA("Attachment") then s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMaxDistance=def.RollOffMaxDistance or 55 end
    s.Parent=parent;s:Play();Debris:AddItem(s,math.max(5,s.TimeLength+1));return s
end

function AudioController:PlayMachine(name,parent,overrides)
    return self:Play(Manifest.Machine[name],parent,overrides)
end

function AudioController:PlayRarity(rarity,parent)
    return self:Play(Manifest.Rarity[rarity],parent)
end

function AudioController:EnsureMachineHum(machine)
    local root=machine and machine:FindFirstChild("Root");if not root then return end
    local key=machine:GetDebugId()
    local existing=self.Loops[key]
    if existing and existing.Parent then return existing end
    local def=Manifest.Machine.Hum;if not def or not def.Id then return end
    local s=Instance.new("Sound");s.Name="MachineHum";s.SoundId=def.Id;s.Volume=def.Volume or 0.14;s.Looped=true;s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMaxDistance=def.RollOffMaxDistance or 34;s.SoundGroup=self.Groups and self.Groups.Ambient or nil;s.Parent=root;s:Play();self.Loops[key]=s;return s
end

return AudioController

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
ReplicatedFirst:RemoveDefaultLoadingScreen()

local MAX_WAIT = 28
local MAX_PRELOAD = 96
local STARTED = os.clock()

local gui = Instance.new("ScreenGui")
gui.Name = "OlympusLoading"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.Parent = player:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1,1)
root.BackgroundColor3 = Color3.fromRGB(8,11,16)
root.BorderSizePixel = 0
root.Parent = gui

local vignette = Instance.new("UIGradient")
vignette.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8,11,16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(17,23,31)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,11,16)),
})
vignette.Rotation = 90
vignette.Parent = root

-- One deterministic wordmark replaces the previous per-letter layout, which visibly scrambled the studio name in Studio.
local wordmark = Instance.new("TextLabel")
wordmark.AnchorPoint = Vector2.new(0.5,0.5)
wordmark.Position = UDim2.fromScale(0.5,0.44)
wordmark.Size = UDim2.new(0.82,0,0,92)
wordmark.BackgroundTransparency = 1
wordmark.Text = "OLYMPUS ENTERTAINMENT"
wordmark.TextColor3 = Color3.fromRGB(246,248,251)
wordmark.Font = Enum.Font.GothamBlack
wordmark.TextScaled = true
wordmark.TextTransparency = 1
wordmark.TextStrokeTransparency = 1
wordmark.Parent = root
local wordConstraint = Instance.new("UITextSizeConstraint")
wordConstraint.MinTextSize = 24
wordConstraint.MaxTextSize = 54
wordConstraint.Parent = wordmark
local wordScale = Instance.new("UIScale")
wordScale.Scale = 0.92
wordScale.Parent = wordmark

local studio = Instance.new("TextLabel")
studio.AnchorPoint = Vector2.new(0.5,0)
studio.Position = UDim2.new(0.5,0,0.44,49)
studio.Size = UDim2.fromOffset(260,24)
studio.BackgroundTransparency = 1
studio.Text = "PRESENTS"
studio.TextColor3 = Color3.fromRGB(224,181,66)
studio.Font = Enum.Font.GothamBold
studio.TextSize = 12
studio.TextTransparency = 1
studio.TextXAlignment = Enum.TextXAlignment.Center
studio.Parent = root

local divider = Instance.new("Frame")
divider.AnchorPoint = Vector2.new(0.5,0.5)
divider.Position = UDim2.new(0.5,0,0.44,82)
divider.Size = UDim2.fromOffset(0,2)
divider.BackgroundColor3 = Color3.fromRGB(224,181,66)
divider.BorderSizePixel = 0
divider.Parent = root

local status = Instance.new("TextLabel")
status.AnchorPoint = Vector2.new(0.5,1)
status.Position = UDim2.new(0.5,0,1,-46)
status.Size = UDim2.fromOffset(430,24)
status.BackgroundTransparency = 1
status.Text = "STARTING SERVER"
status.TextColor3 = Color3.fromRGB(150,164,181)
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Center
status.Parent = root

local track = Instance.new("Frame")
track.AnchorPoint = Vector2.new(0.5,1)
track.Position = UDim2.new(0.5,0,1,-27)
track.Size = UDim2.fromOffset(340,4)
track.BackgroundColor3 = Color3.fromRGB(40,48,59)
track.BorderSizePixel = 0
track.Parent = root
local tc = Instance.new("UICorner");tc.CornerRadius=UDim.new(1,0);tc.Parent=track
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0,1)
fill.BackgroundColor3 = Color3.fromRGB(224,181,66)
fill.BorderSizePixel = 0
fill.Parent = track
local fc = Instance.new("UICorner");fc.CornerRadius=UDim.new(1,0);fc.Parent=fill

local function setProgress(done,total,label)
    local ratio = total > 0 and math.clamp(done/total,0,1) or 0
    TweenService:Create(fill,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{Size=UDim2.fromScale(ratio,1)}):Play()
    status.Text = string.format("%s  %d%%",label or "LOADING WORLD",math.floor(ratio*100+0.5))
end

local profileWaitDeadline=os.clock()+2.5
while player:GetAttribute("ShakeVM_IntroSeen")==nil and os.clock()<profileWaitDeadline do
    status.Text="LOADING PLAYER PROFILE"
    RunService.Heartbeat:Wait()
end
local introSeen=player:GetAttribute("ShakeVM_IntroSeen")==true
local reducedEffects=player:GetAttribute("ShakeVM_ReducedEffects")==true

wordmark.TextTransparency=1
studio.TextTransparency=1
TweenService:Create(wordmark,TweenInfo.new(introSeen and 0.12 or 0.32,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{TextTransparency=0}):Play()
TweenService:Create(wordScale,TweenInfo.new(introSeen and 0.12 or 0.42,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
TweenService:Create(divider,TweenInfo.new(introSeen and 0.12 or 0.34,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(220,2)}):Play()
task.delay(introSeen and 0.02 or 0.18,function()
    if studio.Parent then TweenService:Create(studio,TweenInfo.new(0.22),{TextTransparency=0}):Play() end
end)

local function collectContentIds()
    local ids,seen={},{}
    local function add(id)
        if type(id)~="string"or id==""or seen[id]then return end
        if not string.find(id,"rbxasset",1,true)and not string.find(id,"http",1,true)then return end
        seen[id]=true;table.insert(ids,id)
    end
    local function scan(rootObj)
        for _,d in ipairs(rootObj:GetDescendants())do
            if d:IsA("MeshPart")then add(d.TextureID)
            elseif d:IsA("Decal")or d:IsA("Texture")then add(d.Texture)
            elseif d:IsA("ImageLabel")or d:IsA("ImageButton")then add(d.Image)
            elseif d:IsA("ParticleEmitter")or d:IsA("Beam")or d:IsA("Trail")then add(d.Texture)
            elseif d:IsA("Sound")then add(d.SoundId)end
            if #ids>=MAX_PRELOAD then return end
        end
    end
    local assets=ReplicatedStorage:FindFirstChild("Assets");if assets then scan(assets)end
    local hub=workspace:FindFirstChild("ShakeHub");if hub and #ids<MAX_PRELOAD then scan(hub)end
    return ids
end

while os.clock()-STARTED<MAX_WAIT do
    local characterReady=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local serverReady=ReplicatedStorage:GetAttribute("ShakeVM_ServerBootReady")==true
    if characterReady and serverReady then break end
    local elapsed=os.clock()-STARTED
    fill.Size=UDim2.fromScale(math.clamp(elapsed/10,0,.35),1)
    status.Text=serverReady and "PREPARING PLAYER"or"BUILDING DOWNTOWN"
    RunService.Heartbeat:Wait()
end

local ids=collectContentIds()
if #ids>0 then
    local completed,nextIndex=0,1
    for _=1,math.min(6,#ids)do
        task.spawn(function()
            while true do
                local i=nextIndex;nextIndex+=1;local id=ids[i];if not id then break end
                pcall(function()ContentProvider:PreloadAsync({id})end);completed+=1
            end
        end)
    end
    while completed<#ids and os.clock()-STARTED<MAX_WAIT do setProgress(completed,#ids,"LOADING DOWNTOWN");RunService.Heartbeat:Wait()end
    setProgress(completed,#ids,completed>=#ids and"READY"or"CONTINUING IN BACKGROUND")
else setProgress(1,1,"READY")end

introSeen=player:GetAttribute("ShakeVM_IntroSeen")==true
reducedEffects=player:GetAttribute("ShakeVM_ReducedEffects")==true
task.wait((introSeen or reducedEffects)and .05 or .16)

local flash=Instance.new("Frame")
flash.Size=UDim2.fromScale(1,1);flash.BackgroundColor3=Color3.fromRGB(248,246,235);flash.BackgroundTransparency=1;flash.BorderSizePixel=0;flash.Parent=root
if not introSeen and not reducedEffects then
    TweenService:Create(flash,TweenInfo.new(.06),{BackgroundTransparency=.18}):Play();task.wait(.065)
end
TweenService:Create(root,TweenInfo.new((introSeen or reducedEffects)and .16 or .30,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
for _,d in ipairs(root:GetDescendants())do
    if d:IsA("TextLabel")then TweenService:Create(d,TweenInfo.new(.20),{TextTransparency=1}):Play()
    elseif d:IsA("Frame")and d~=root then TweenService:Create(d,TweenInfo.new(.20),{BackgroundTransparency=1}):Play()end
end
task.wait((introSeen or reducedEffects)and .18 or .32);gui:Destroy()

local remotes=ReplicatedStorage:FindFirstChild("Remotes")
local settings=remotes and remotes:FindFirstChild("SettingsAction")
if settings and settings:IsA("RemoteEvent")and not introSeen then settings:FireServer("intro_seen",true)end

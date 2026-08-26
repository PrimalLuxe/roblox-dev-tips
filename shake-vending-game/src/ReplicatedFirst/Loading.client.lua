local ReplicatedFirst=game:GetService("ReplicatedFirst")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local ContentProvider=game:GetService("ContentProvider")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
ReplicatedFirst:RemoveDefaultLoadingScreen()

local MAX_WAIT=28
local MAX_PRELOAD=96
local STARTED=os.clock()

local gui=Instance.new("ScreenGui");gui.Name="OlympusLoading";gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=10000;gui.Parent=player:WaitForChild("PlayerGui")
local root=Instance.new("Frame");root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=Color3.fromRGB(10,15,20);root.BorderSizePixel=0;root.Parent=gui

for i=0,90 do
    local line=Instance.new("Frame");line.Size=UDim2.new(1,0,0,1);line.Position=UDim2.new(0,0,0,i*12);line.BackgroundColor3=Color3.fromRGB(255,255,255);line.BackgroundTransparency=.975;line.BorderSizePixel=0;line.Parent=root
end
local function bracket(xScale,xOffset,yScale,yOffset,xDir,yDir)
    local h=Instance.new("Frame");h.Size=UDim2.fromOffset(52,4);h.AnchorPoint=Vector2.new(xDir<0 and 1 or 0,yDir<0 and 1 or 0);h.Position=UDim2.new(xScale,xOffset,yScale,yOffset);h.BackgroundColor3=Color3.fromRGB(213,165,47);h.BorderSizePixel=0;h.Parent=root
    local v=Instance.new("Frame");v.Size=UDim2.fromOffset(4,52);v.AnchorPoint=h.AnchorPoint;v.Position=h.Position;v.BackgroundColor3=Color3.fromRGB(213,165,47);v.BorderSizePixel=0;v.Parent=root
end
bracket(.5,-340,.5,-116,1,1);bracket(.5,340,.5,-116,-1,1);bracket(.5,-340,.5,104,1,-1);bracket(.5,340,.5,104,-1,-1)

local olympus=Instance.new("TextLabel");olympus.AnchorPoint=Vector2.new(.5,.5);olympus.Position=UDim2.fromScale(.5,.42);olympus.Size=UDim2.fromOffset(660,90);olympus.BackgroundTransparency=1;olympus.Text="OLYMPUS";olympus.TextColor3=Color3.fromRGB(247,244,231);olympus.Font=Enum.Font.GothamBlack;olympus.TextSize=72;olympus.TextTransparency=1;olympus.Parent=root
local entertainment=Instance.new("TextLabel");entertainment.AnchorPoint=Vector2.new(.5,.5);entertainment.Position=UDim2.fromScale(.5,.51);entertainment.Size=UDim2.fromOffset(520,38);entertainment.BackgroundTransparency=1;entertainment.Text="E N T E R T A I N M E N T";entertainment.TextColor3=Color3.fromRGB(213,165,47);entertainment.Font=Enum.Font.GothamBold;entertainment.TextSize=18;entertainment.TextTransparency=1;entertainment.Parent=root
local rule=Instance.new("Frame");rule.AnchorPoint=Vector2.new(.5,.5);rule.Position=UDim2.fromScale(.5,.475);rule.Size=UDim2.fromOffset(0,4);rule.BackgroundColor3=Color3.fromRGB(49,134,211);rule.BorderSizePixel=0;rule.Parent=root

local status=Instance.new("TextLabel");status.AnchorPoint=Vector2.new(.5,1);status.Position=UDim2.new(.5,0,1,-44);status.Size=UDim2.fromOffset(450,24);status.BackgroundTransparency=1;status.Text="STARTING SERVER";status.TextColor3=Color3.fromRGB(145,158,168);status.Font=Enum.Font.GothamBlack;status.TextSize=10;status.Parent=root
local track=Instance.new("Frame");track.AnchorPoint=Vector2.new(.5,1);track.Position=UDim2.new(.5,0,1,-25);track.Size=UDim2.fromOffset(360,9);track.BackgroundColor3=Color3.fromRGB(24,34,43);track.BorderSizePixel=0;track.Parent=root
local fill=Instance.new("Frame");fill.Size=UDim2.fromScale(0,1);fill.BackgroundColor3=Color3.fromRGB(213,165,47);fill.BorderSizePixel=0;fill.Parent=track
for i=1,17 do local tick=Instance.new("Frame");tick.Size=UDim2.fromOffset(2,9);tick.Position=UDim2.new(i/18,-1,0,0);tick.BackgroundColor3=Color3.fromRGB(10,15,20);tick.BorderSizePixel=0;tick.ZIndex=2;tick.Parent=track end

local function setProgress(done,total,label)
    local ratio=total>0 and math.clamp(done/total,0,1)or 0
    TweenService:Create(fill,TweenInfo.new(.10,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(ratio,1)}):Play()
    status.Text=string.format("%s   %02d%%",label or"LOADING WORLD",math.floor(ratio*100+.5))
end

local profileDeadline=os.clock()+2.5
while player:GetAttribute("ShakeVM_IntroSeen")==nil and os.clock()<profileDeadline do status.Text="LOADING PLAYER PROFILE";RunService.Heartbeat:Wait()end
local introSeen=player:GetAttribute("ShakeVM_IntroSeen")==true
local reduced=player:GetAttribute("ShakeVM_ReducedEffects")==true

olympus.Position=UDim2.fromScale(.5,.40)
TweenService:Create(olympus,TweenInfo.new(introSeen and .12 or .28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{TextTransparency=0,Position=UDim2.fromScale(.5,.42)}):Play()
task.delay(introSeen and .03 or .10,function()
    if entertainment.Parent then TweenService:Create(entertainment,TweenInfo.new(introSeen and .12 or .25),{TextTransparency=0}):Play();TweenService:Create(rule,TweenInfo.new(introSeen and .15 or .34,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(520,4)}):Play()end
end)

local function collectContentIds()
    local ids,seen={},{}
    local function add(id)
        if type(id)~="string"or id==""or seen[id]then return end
        if not id:find("rbxasset",1,true)and not id:find("http",1,true)then return end
        seen[id]=true;table.insert(ids,id)
    end
    local function scan(obj)
        for _,d in ipairs(obj:GetDescendants())do
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
    local charReady=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local serverReady=ReplicatedStorage:GetAttribute("ShakeVM_ServerBootReady")==true
    if charReady and serverReady then break end
    local elapsed=os.clock()-STARTED;fill.Size=UDim2.fromScale(math.clamp(elapsed/12,0,.30),1);status.Text=serverReady and"PREPARING PLAYER"or"BUILDING DOWNTOWN";RunService.Heartbeat:Wait()
end

local ids=collectContentIds()
if #ids>0 then
    local complete,nextIndex=0,1
    for _=1,math.min(6,#ids)do task.spawn(function()
        while true do local i=nextIndex;nextIndex+=1;local id=ids[i];if not id then break end;pcall(function()ContentProvider:PreloadAsync({id})end);complete+=1 end
    end)end
    while complete<#ids and os.clock()-STARTED<MAX_WAIT do setProgress(complete,#ids,"LOADING ASSETS");RunService.Heartbeat:Wait()end
    setProgress(complete,#ids,complete>=#ids and"READY"or"STREAMING")
else setProgress(1,1,"READY")end

task.wait((introSeen or reduced)and .06 or .20)
local shutters={}
for i=1,14 do
    local f=Instance.new("Frame");f.Size=UDim2.new(1/14+.002,0,1,0);f.Position=UDim2.new((i-1)/14,0,i%2==0 and-1 or 1,0);f.BackgroundColor3=i%2==0 and Color3.fromRGB(49,134,211)or Color3.fromRGB(213,165,47);f.BorderSizePixel=0;f.ZIndex=50;f.Parent=root;table.insert(shutters,f)
    TweenService:Create(f,TweenInfo.new((introSeen or reduced)and .12 or .24,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new((i-1)/14,0,0,0)}):Play()
end
task.wait((introSeen or reduced)and .13 or .25)
for _,f in ipairs(shutters)do TweenService:Create(f,TweenInfo.new(.15,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()end
TweenService:Create(root,TweenInfo.new(.16),{BackgroundTransparency=1}):Play()
for _,d in ipairs(root:GetDescendants())do if d:IsA("TextLabel")then TweenService:Create(d,TweenInfo.new(.12),{TextTransparency=1}):Play()elseif d:IsA("Frame")and d~=root then TweenService:Create(d,TweenInfo.new(.12),{BackgroundTransparency=1}):Play()end end
task.wait(.18);gui:Destroy()

local remotes=ReplicatedStorage:FindFirstChild("Remotes");local settings=remotes and remotes:FindFirstChild("SettingsAction")
if settings and settings:IsA("RemoteEvent")and not introSeen then settings:FireServer("intro_seen",true)end

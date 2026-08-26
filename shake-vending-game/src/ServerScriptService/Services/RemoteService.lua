local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RemoteNames = require(ReplicatedStorage.Shared.RemoteNames)
local RemoteService = { Events = {}, Functions = {}, Buckets = {} }
function RemoteService:Allow(player,key,rate,burst)
    if not player or not player.Parent then return false end
    rate=rate or 4;burst=burst or math.max(2,rate)
    local uid=player.UserId;local now=os.clock();local user=self.Buckets[uid]
    if not user then user={};self.Buckets[uid]=user end
    local b=user[key]
    if not b then b={Tokens=burst,At=now};user[key]=b end
    local elapsed=math.max(0,now-b.At);b.At=now;b.Tokens=math.min(burst,b.Tokens+elapsed*rate)
    if b.Tokens<1 then return false end
    b.Tokens-=1;return true
end
function RemoteService:Init()
    local folder=ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder");folder.Name="Remotes";folder.Parent=ReplicatedStorage
    for key,name in pairs(RemoteNames.Events) do local remote=folder:FindFirstChild(name) or Instance.new("RemoteEvent");remote.Name=name;remote.Parent=folder;self.Events[key]=remote end
    for key,name in pairs(RemoteNames.Functions) do local remote=folder:FindFirstChild(name) or Instance.new("RemoteFunction");remote.Name=name;remote.Parent=folder;self.Functions[key]=remote end
    if not self.CleanupConnection then self.CleanupConnection=Players.PlayerRemoving:Connect(function(player)self.Buckets[player.UserId]=nil end) end
end
return RemoteService

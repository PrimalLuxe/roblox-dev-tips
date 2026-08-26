local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Config=require(ReplicatedStorage.Shared.Config)
local Machines=require(ReplicatedStorage.Shared.MachineDefinitions)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Util=require(ReplicatedStorage.Shared.Util)

local MachineService={Pending={},Cooldowns={}}

local function getRoot(player)local c=player.Character;return c and c:FindFirstChild("HumanoidRootPart")end

function MachineService:FindMachine(id)
    local f=Workspace:FindFirstChild("Machines");local m=f and f:FindFirstChild(id)
    if m and m:GetAttribute("MachineId")==id then return m end
end

function MachineService:CanUse(player,machine)
    local root=getRoot(player);if not root then return false,"NoCharacter" end
    local mr=machine:FindFirstChild("Root");if not mr or (root.Position-mr.Position).Magnitude>Config.ShakeDistance then return false,"TooFar" end
    local now=os.clock();if (self.Cooldowns[player.UserId] or 0)>now then return false,"Cooldown" end
    local pending=self.Pending[player.UserId];if pending and pending.ExpiresAt>now then return false,"Collect your current drop first" end
    return true
end

function MachineService:EnsureUnlocked(player,machineId)
    local profile=self.DataService:GetProfile(player);if not profile then return false,"ProfileNotLoaded" end
    local def=Machines[machineId];if not def then return false,"UnknownMachine" end

    -- Event machines remain event machines forever. Discovering Unknown records it in the
    -- passport/profile, but does not turn the maintenance-room machine into an always-on door.
    if def.EventOnly then
        local event=self.EventService:GetCurrent()
        if not (event and event.UnlockUnknown) then return false,"UNKNOWN MACHINE OFFLINE • wait for a Blackout / Mystery event" end
        local requirementsMet,reason=self.ProgressionService:CanUnlockMachine(profile,machineId)
        if not requirementsMet then return false,reason end
        if not profile.UnlockedMachines[machineId] then
            profile.UnlockedMachines[machineId]=true
            self.RemoteService.Events.Toast:FireClient(player,{Text="SECRET MACHINE DISCOVERED — ???",Kind="New"})
        end
        return true
    end

    if profile.UnlockedMachines[machineId] then return true end
    local requirementsMet,reason=self.ProgressionService:CanUnlockMachine(profile,machineId)
    if not requirementsMet then return false,reason end
    if profile.Coins<(def.UnlockCost or 0) then return false,"Need $"..Util.FormatInteger(def.UnlockCost or 0) end
    profile.Coins-=def.UnlockCost or 0;profile.UnlockedMachines[machineId]=true
    self.RemoteService.Events.Toast:FireClient(player,{Text="NEW MACHINE UNLOCKED — "..def.DisplayName,Kind="New"})
    return true
end

function MachineService:ApplyMastery(player,machineId)
    local profile=self.DataService:GetProfile(player);if not profile then return end
    local prog=profile.Progression;prog.MachineShakes[machineId]=(prog.MachineShakes[machineId] or 0)+1
    prog.MachineMilestones[machineId]=prog.MachineMilestones[machineId] or {}
    local shakes=prog.MachineShakes[machineId]
    for _,m in ipairs(Config.MachineMasteryMilestones) do
        local key=tostring(m.Shakes)
        if shakes>=m.Shakes and not prog.MachineMilestones[machineId][key] then
            prog.MachineMilestones[machineId][key]=true;profile.Coins+=(m.Coins or 0);profile.StyleShards+=(m.Shards or 0)
            self.RemoteService.Events.Toast:FireClient(player,{Text=Machines[machineId].DisplayName.." MASTERY "..m.Shakes.."! +"..m.Coins.." coins"..((m.Shards or 0)>0 and (" +"..m.Shards.." shards") or ""),Kind="New"})
        end
    end
end

function MachineService:Shake(player,machineId)
    if type(machineId)~="string" then return end
    local machine=self:FindMachine(machineId);if not machine then return end
    local ok,reason=self:CanUse(player,machine);if not ok then if reason~="Cooldown" then self.RemoteService.Events.Toast:FireClient(player,{Text=reason,Kind="Warn"}) end;return end
    local unlocked,msg=self:EnsureUnlocked(player,machineId);if not unlocked then self.RemoteService.Events.Toast:FireClient(player,{Text=msg,Kind="Warn"});return end

    local engagement=self.EngagementService and self.EngagementService:RegisterShake(player) or nil
    local result,err=self.RollService:Roll(player,machineId,engagement);if not result then self.RemoteService.Events.Toast:FireClient(player,{Text=err,Kind="Error"});return end
    local now=os.clock();local profile=self.DataService:GetProfile(player);local power=math.max(1,profile.Upgrades.ShakePower or 1)
    local speed=1+math.min(2.5,(power-1)*0.085);local shakeDuration=math.max(0.18,0.56/speed);local collectDelay=math.max(0.18,Config.CollectDelay/speed)
    self.Cooldowns[player.UserId]=now+math.max(0.28,Config.ShakeCooldown/speed)
    local token=Util.Guid();self.Pending[player.UserId]={Token=token,Item=result,MachineId=machineId,AvailableAt=now+collectDelay,ExpiresAt=now+Config.PendingDropLifetime}
    profile.Statistics.Shakes+=1;self:ApplyMastery(player,machineId)
    if self.ProgressionService then task.defer(function() self.ProgressionService:Check(player) end) end

    if result.LuckyGuarantee then self.RemoteService.Events.Toast:FireClient(player,{Text="LUCKY METER! Guaranteed Rare+ pull",Kind="New"}) end

    local jam=self.EventService:RegisterShake(machineId)
    if jam then
        -- Publish cooperative progress at a bounded cadence so the physical machine UI can
        -- update without turning every shake into a global remote broadcast.
        if jam.Triggered or jam.Count%10==0 or jam.Count==1 then
            self.RemoteService.Events.EventChanged:FireAllClients(self.EventService:GetCurrent())
        end
        if jam.Triggered then self.RemoteService.Events.Toast:FireAllClients({Text="JAM BROKEN! 60 seconds of boosted luck!",Kind="Global"})
        elseif jam.Count%50==0 then self.RemoteService.Events.Toast:FireAllClients({Text="Jammed machine: "..jam.Count.." / 500 shakes",Kind="Info"}) end
    end

    local payload={Token=token,OwnerUserId=player.UserId,MachineId=machineId,Item=result,AvailableAfter=collectDelay,ShakeDuration=shakeDuration,LuckyGuarantee=result.LuckyGuarantee,Combo=engagement}
    self.RemoteService.Events.DropSpawned:FireClient(player,payload)
    if self.EngagementService then self.EngagementService:PushState(player) end
    if engagement and (engagement.Count==10 or engagement.Count==20 or engagement.Count==30) then
        self.RemoteService.Events.Toast:FireClient(player,{Text=string.format("OVERDRIVE x%d • +%d%% luck",engagement.Count,math.floor((engagement.LuckMultiplier-1)*100+0.5)),Kind="New"})
    end
    task.delay(math.max(0.12,shakeDuration*0.72),function()if player.Parent then self.RemoteService.Events.WorldDrop:FireAllClients({OwnerUserId=player.UserId,MachineId=machineId,Item=result})end end)
end

function MachineService:Collect(player,token)
    if type(token)~="string" then return end
    local pending=self.Pending[player.UserId];if not pending or pending.Token~=token then return end
    local now=os.clock();if now<pending.AvailableAt or now>pending.ExpiresAt then return end
    local ok,metaOrReason=self.InventoryService:Add(player,pending.Item)
    if not ok then self.RemoteService.Events.Toast:FireClient(player,{Text=metaOrReason,Kind="Warn"});return end
    self.Pending[player.UserId]=nil
    local meta=metaOrReason or {}
    local prefix=meta.FirstBase and "NEW CATALOG! " or (meta.FirstVariant and "NEW VARIANT! " or "+ ")
    self.RemoteService.Events.Toast:FireClient(player,{Text=prefix..Items[pending.Item.BaseItemId].Name,Kind=(meta.FirstBase or meta.FirstVariant) and "New" or "Collect"})
    self.GlobalService:OnCollected(player,pending.Item)
end

function MachineService:Init(RemoteService,DataService,RollService,InventoryService,GlobalService,EventService,ProgressionService,EngagementService)
    self.RemoteService=RemoteService;self.DataService=DataService;self.RollService=RollService;self.InventoryService=InventoryService;self.GlobalService=GlobalService;self.EventService=EventService;self.ProgressionService=ProgressionService;self.EngagementService=EngagementService
    RemoteService.Events.ShakeMachine.OnServerEvent:Connect(function(p,id)if RemoteService:Allow(p,"shake",4,6) then self:Shake(p,id) end end)
    RemoteService.Events.CollectDrop.OnServerEvent:Connect(function(p,token)if RemoteService:Allow(p,"collect",6,8) then self:Collect(p,token) end end)
    Players.PlayerRemoving:Connect(function(p)self.Pending[p.UserId]=nil;self.Cooldowns[p.UserId]=nil end)
end
return MachineService

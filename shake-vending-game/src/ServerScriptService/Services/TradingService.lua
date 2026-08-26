local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.Config)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Util=require(ReplicatedStorage.Shared.Util)

local TradingService={Sessions={},PendingRequests={}}

local function inventoryCapacity(profile)
    return Config.InventoryBaseCapacity+math.max(0,((profile.Upgrades and profile.Upgrades.Capacity) or 1)-1)*25
end

local function other(session,userId)
    return session.A==userId and session.B or session.A
end

function TradingService:BuildState(session)
    local details={A={},B={}}
    for side,userId in pairs({A=session.A,B=session.B}) do
        local profile=self.DataService:GetProfile(userId)
        if profile then
            for _,instanceId in ipairs(session.Offers[side]) do
                local _,item=Util.FindInventoryIndex(profile,instanceId)
                if item then table.insert(details[side],Util.DeepCopy(item)) end
            end
        end
    end
    return {
        Id=session.Id,A=session.A,B=session.B,
        Offers={A=Util.DeepCopy(session.Offers.A),B=Util.DeepCopy(session.Offers.B)},
        OfferDetails=details,
        Ready={A=session.Ready.A,B=session.Ready.B},
        Confirm={A=session.Confirm.A,B=session.Confirm.B},
        Phase=session.Phase,
    }
end

function TradingService:Send(session)
    local payload=self:BuildState(session)
    local a=Players:GetPlayerByUserId(session.A); local b=Players:GetPlayerByUserId(session.B)
    if a then self.RemoteService.Events.TradeState:FireClient(a,payload) end
    if b then self.RemoteService.Events.TradeState:FireClient(b,payload) end
end

function TradingService:GetSessionFor(userId)
    for _,s in pairs(self.Sessions) do if s.A==userId or s.B==userId then return s end end
end

function TradingService:Request(player,targetUserId)
    if not Config.Trading.Enabled or type(targetUserId)~="number" or targetUserId==player.UserId then return end
    local target=Players:GetPlayerByUserId(targetUserId); if not target then return end
    if self:GetSessionFor(player.UserId) or self:GetSessionFor(targetUserId) then return end
    local p1=self.DataService:GetProfile(player); local p2=self.DataService:GetProfile(target)
    if not p1 or not p2 or not p1.TradeSettings.Enabled or not p2.TradeSettings.Enabled then return end
    if p1.Statistics.Shakes<Config.Trading.MinShakes or p2.Statistics.Shakes<Config.Trading.MinShakes then
        self.RemoteService.Events.Toast:FireClient(player,{Text="Both players need more playtime before trading.",Kind="Warn"}); return
    end
    if self.DataService:GetJoinAge(player.UserId)<Config.Trading.JoinCooldownSeconds or self.DataService:GetJoinAge(targetUserId)<Config.Trading.JoinCooldownSeconds then
        self.RemoteService.Events.Toast:FireClient(player,{Text="Trading unlocks shortly after joining.",Kind="Warn"}); return
    end
    self.PendingRequests[targetUserId]={From=player.UserId,Expires=os.clock()+Config.Trading.RequestTimeoutSeconds}
    self.RemoteService.Events.TradeState:FireClient(target,{Phase="Request",From=player.UserId,FromName=player.DisplayName})
    self.RemoteService.Events.Toast:FireClient(player,{Text="Trade request sent.",Kind="Info"})
end

function TradingService:AcceptRequest(player,fromUserId)
    local req=self.PendingRequests[player.UserId]
    if not req or req.From~=fromUserId or req.Expires<os.clock() then return end
    self.PendingRequests[player.UserId]=nil
    if self:GetSessionFor(player.UserId) or self:GetSessionFor(fromUserId) then return end
    local s={Id=Util.Guid(),A=fromUserId,B=player.UserId,Offers={A={},B={}},Ready={A=false,B=false},Confirm={A=false,B=false},Phase="Offer"}
    self.Sessions[s.Id]=s; self:Send(s)
end

function TradingService:Side(session,userId)
    return session.A==userId and "A" or session.B==userId and "B" or nil
end

function TradingService:ResetReady(session)
    session.Ready.A=false; session.Ready.B=false; session.Confirm.A=false; session.Confirm.B=false; session.Phase="Offer"
end

function TradingService:ValidOfferItem(player,instanceId)
    local profile=self.DataService:GetProfile(player); if not profile then return nil end
    local _,item=Util.FindInventoryIndex(profile,instanceId)
    if not item or item.Locked then return nil end
    if Config.Trading.NonTradeableTiers[item.Rarity] then return nil end
    return item
end

function TradingService:AddOffer(player,session,instanceId)
    local side=self:Side(session,player.UserId); if not side then return end
    local item=self:ValidOfferItem(player,instanceId); if not item then return end
    local offer=session.Offers[side]
    if #offer>=Config.Trading.MaxOfferItems or table.find(offer,instanceId) then return end
    table.insert(offer,instanceId); self:ResetReady(session); self:Send(session)
end

function TradingService:RemoveOffer(player,session,instanceId)
    local side=self:Side(session,player.UserId); if not side then return end
    Util.ArrayRemoveValue(session.Offers[side],instanceId); self:ResetReady(session); self:Send(session)
end

function TradingService:ValidateAll(session)
    local function collect(userId,ids)
        local player=Players:GetPlayerByUserId(userId); if not player then return nil,"PlayerMissing" end
        local out={}
        for _,id in ipairs(ids) do
            local item=self:ValidOfferItem(player,id); if not item then return nil,"OfferedItemUnavailable" end
            table.insert(out,Util.DeepCopy(item))
        end
        return out
    end
    local aItems,aErr=collect(session.A,session.Offers.A);if not aItems then return nil,nil,aErr end
    local bItems,bErr=collect(session.B,session.Offers.B);if not bItems then return nil,nil,bErr end
    local aProfile=self.DataService:GetProfile(session.A);local bProfile=self.DataService:GetProfile(session.B)
    if not aProfile or not bProfile then return nil,nil,"ProfileMissing" end
    local aAfter=#aProfile.Inventory-#aItems+#bItems
    local bAfter=#bProfile.Inventory-#bItems+#aItems
    if aAfter>inventoryCapacity(aProfile) then return nil,nil,"First player inventory would be full" end
    if bAfter>inventoryCapacity(bProfile) then return nil,nil,"Second player inventory would be full" end
    return aItems,bItems,nil
end

function TradingService:RefreshParticipants(session)
    for _,uid in ipairs({session.A,session.B}) do
        local player=Players:GetPlayerByUserId(uid)
        if player then
            if self.CosmeticService then self.CosmeticService:Reapply(player) end
            if self.ShowcaseService then self.ShowcaseService:Refresh(player) end
        end
    end
end

function TradingService:Finalize(session)
    local aItems,bItems,validationError=self:ValidateAll(session)
    if not aItems or not bItems then self:Cancel(session,"Trade stopped safely: "..tostring(validationError or "item unavailable")); return end
    local journal={
        Id=session.Id,State="Prepared",CreatedAt=os.time(),
        A={UserId=session.A,ItemIds=Util.DeepCopy(session.Offers.A),Items=aItems},
        B={UserId=session.B,ItemIds=Util.DeepCopy(session.Offers.B),Items=bItems},
    }
    session.Phase="Committing"; self:Send(session)
    local ok,reason=self.DataService:ExecuteJournaledTrade(journal)
    if ok then
        local a=Players:GetPlayerByUserId(session.A); local b=Players:GetPlayerByUserId(session.B)
        if a then self.RemoteService.Events.Toast:FireClient(a,{Text="Trade complete!",Kind="Success"}) end
        if b then self.RemoteService.Events.Toast:FireClient(b,{Text="Trade complete!",Kind="Success"}) end
        self:RefreshParticipants(session)
        self.Sessions[session.Id]=nil
    elseif reason=="TradePendingReconciliation" then
        self.Sessions[session.Id]=nil
        for _,uid in ipairs({session.A,session.B}) do local p=Players:GetPlayerByUserId(uid); if p then self.RemoteService.Events.Toast:FireClient(p,{Text="Trade is safely syncing. Do not retry the same items.",Kind="Warn"}) end end
        task.spawn(function()
            for _=1,4 do
                task.wait(3)
                local j=self.DataService:GetTradeJournal(journal.Id); if not j then continue end
                local aOk=self.DataService:ApplyTradeToUser(j.A.UserId,j.Id,j)
                local bOk=self.DataService:ApplyTradeToUser(j.B.UserId,j.Id,j)
                if aOk and bOk then self.DataService:UpdateTradeJournal(j.Id,function(x)x.State="Committed";x.CommittedAt=os.time();return x end); self:RefreshParticipants(session); break end
            end
        end)
    else
        self:Cancel(session,"Trade failed safely: "..tostring(reason))
    end
end

function TradingService:Cancel(session,reason)
    self.Sessions[session.Id]=nil
    for _,uid in ipairs({session.A,session.B}) do
        local p=Players:GetPlayerByUserId(uid)
        if p then self.RemoteService.Events.TradeState:FireClient(p,{Phase="Closed",Reason=reason or "Cancelled"}) end
    end
end

function TradingService:Action(player,action,data)
    if action=="accept_request" then self:AcceptRequest(player,tonumber(data)); return end
    if action=="decline_request" then self.PendingRequests[player.UserId]=nil; return end
    local session=self:GetSessionFor(player.UserId); if not session then return end
    local side=self:Side(session,player.UserId)
    if action=="cancel" then self:Cancel(session,"Cancelled"); return end
    if action=="add" then self:AddOffer(player,session,tostring(data)); return end
    if action=="remove" then self:RemoveOffer(player,session,tostring(data)); return end
    if action=="ready" then
        session.Ready[side]=not session.Ready[side]; session.Confirm.A=false;session.Confirm.B=false
        if session.Ready.A and session.Ready.B then session.Phase="Confirm" end
        self:Send(session); return
    end
    if action=="confirm" and session.Phase=="Confirm" and session.Ready.A and session.Ready.B then
        session.Confirm[side]=true; self:Send(session)
        if session.Confirm.A and session.Confirm.B then
            session.Phase="Countdown"; self:Send(session)
            local id=session.Id
            task.delay(Config.Trading.FinalConfirmSeconds,function()
                local current=self.Sessions[id]
                if current and current.Phase=="Countdown" and current.Confirm.A and current.Confirm.B then self:Finalize(current) end
            end)
        end
    end
end

function TradingService:CancelForUser(userId, reason)
    local session = self:GetSessionFor(userId)
    if session then self:Cancel(session, reason or "Cancelled") end
    self.PendingRequests[userId] = nil
end

function TradingService:Init(RemoteService,DataService,CosmeticService,ShowcaseService)
    self.RemoteService=RemoteService; self.DataService=DataService; self.CosmeticService=CosmeticService; self.ShowcaseService=ShowcaseService
    RemoteService.Events.RequestTrade.OnServerEvent:Connect(function(p,target) if RemoteService:Allow(p,"trade_request",2,4) then self:Request(p,target) end end)
    RemoteService.Events.TradeAction.OnServerEvent:Connect(function(p,action,data) if RemoteService:Allow(p,"trade_action",6,10) and type(action)=="string" then self:Action(p,action,data) end end)
    Players.PlayerRemoving:Connect(function(p) local s=self:GetSessionFor(p.UserId); if s then self:Cancel(s,"Player left") end; self.PendingRequests[p.UserId]=nil end)
end

return TradingService

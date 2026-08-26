local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local EventService = { JamCounts = {}, BurstUntil = 0 }

local machineOrder={"CornerStore","SugarRush","Energy","ToyCapsule","Luxury","Unknown"}
local events = {
    { Id="Normal", Display="Normal Restock", Luck=1, Mutation=1, Global=true },
    { Id="Golden", Display="GOLDEN RESTOCK", Luck=1.05, Mutation=2.3, ForcedMutation="Gold" },
    { Id="Frozen", Display="FROZEN RESTOCK", Luck=1.08, Mutation=2.0, ForcedMutation="Frozen" },
    { Id="Lucky", Display="LUCKY MACHINE", Luck=1.65, Mutation=1.35 },
    { Id="Glitch", Display="BROKEN MACHINE", Luck=1.15, Mutation=2.5, ForcedMutation="Glitched" },
    { Id="Blackout", Display="BLACKOUT", Luck=1.25, Mutation=2.0, UnlockUnknown=true, Global=true },
    { Id="Mystery", Display="MYSTERY RESTOCK", Luck=1.35, Mutation=1.8, Hidden=true },
    { Id="Jammed", Display="JAMMED MACHINE", Luck=1.0, Mutation=1.0, Jammed=true },
}

local function slot()
    return math.floor(os.time() / Config.EventSlotSeconds)
end

local function chooseForSlot(s)
    local x = (s * 1103515245 + 12345) % 2147483647
    local roll = x % 100
    if roll < 44 then return events[1],x end
    local index = 2 + (x % (#events - 1))
    return events[index],x
end

function EventService:GetCurrent()
    local s = slot()
    local e,x = chooseForSlot(s)
    local burst=os.clock()<self.BurstUntil
    local target=nil
    if not e.Global then target=machineOrder[(math.floor(x/97)%#machineOrder)+1] end
    return {
        Id=e.Id, Display=e.Display,
        Luck=e.Luck * (burst and 2.5 or 1), Mutation=e.Mutation * (burst and 2.0 or 1),
        ForcedMutation=e.ForcedMutation, UnlockUnknown=e.UnlockUnknown, Hidden=e.Hidden, Jammed=e.Jammed,
        Global=e.Global==true, TargetMachine=target, Burst=burst,
        JamCount=e.Jammed and (self.JamCounts[s] or 0) or nil, JamTarget=e.Jammed and 500 or nil,
        Slot=s, EndsAt=(s+1)*Config.EventSlotSeconds,
    }
end

function EventService:AppliesTo(event,machineId)
    return event and (event.Global or event.TargetMachine==machineId)
end

function EventService:RegisterShake(machineId)
    local current=self:GetCurrent()
    if not current.Jammed or current.TargetMachine~=machineId then return nil end
    local count=(self.JamCounts[current.Slot] or 0)+1;self.JamCounts[current.Slot]=count
    if count==500 then self.BurstUntil=os.clock()+60; return {Count=count,Triggered=true,TargetMachine=machineId} end
    return {Count=count,Triggered=false,TargetMachine=machineId}
end

function EventService:Init(RemoteService)
    self.RemoteService = RemoteService
    local last
    task.spawn(function()
        while true do
            local current = self:GetCurrent()
            if current.Slot ~= last then
                last = current.Slot
                for oldSlot in pairs(self.JamCounts) do if oldSlot < current.Slot-3 then self.JamCounts[oldSlot]=nil end end
                RemoteService.Events.EventChanged:FireAllClients(current)
            end
            task.wait(2)
        end
    end)
end

return EventService

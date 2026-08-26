local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Items = require(ReplicatedStorage.Shared.ItemDefinitions)
local Machines = require(ReplicatedStorage.Shared.MachineDefinitions)
local Rarities = require(ReplicatedStorage.Shared.RarityDefinitions)
local Theme = require(ReplicatedStorage.Shared.UITheme).Get()
local Util = require(ReplicatedStorage.Shared.Util)

local WorldLoopController = {Mode = "Passport", Panel = nil}

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Accent
    s.Thickness = thickness or 1.2
    s.Transparency = transparency or 0.25
    s.Parent = obj
end

local function label(parent, text, size, pos, font, textSize, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Size = size
    l.Position = pos or UDim2.new()
    l.Font = font or Theme.Font
    l.TextSize = textSize or 14
    l.TextColor3 = color or Theme.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, text, size, pos, accent)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Size = size
    b.Position = pos or UDim2.new()
    b.BackgroundColor3 = Theme.Button
    b.TextColor3 = Theme.Text
    b.Font = Theme.Font
    b.TextSize = 13
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Selectable = true
    b.Parent = parent
    round(b, 9)
    stroke(b, accent or Theme.Accent, 1.2, 0.3)
    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(scale,TweenInfo.new(0.08),{Scale=1.035}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(scale,TweenInfo.new(0.10),{Scale=1}):Play() end)
    b.MouseButton1Down:Connect(function() TweenService:Create(scale,TweenInfo.new(0.05),{Scale=0.95}):Play() end)
    b.MouseButton1Up:Connect(function() TweenService:Create(scale,TweenInfo.new(0.08),{Scale=1.035}):Play() end)
    return b
end

local function compact(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.1fB",n/1e9) end
    if n >= 1e6 then return string.format("%.1fM",n/1e6) end
    if n >= 1e3 then return string.format("%.1fK",n/1e3) end
    return tostring(math.floor(n))
end

local function clearContent(content)
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end
end

local function isTracked(profile, itemId)
    local list = profile and profile.Progression and profile.Progression.HuntList or {}
    return table.find(list,itemId) ~= nil
end

function WorldLoopController:Fetch()
    local snapshot = self.UI:Fetch()
    self:RefreshHud()
    return snapshot
end

function WorldLoopController:RefreshHud()
    local snapshot = self.UI and self.UI.Snapshot
    if not snapshot or not snapshot.Profile then return end
    local profile = snapshot.Profile
    local nextId, nextDef
    for _, id in ipairs(Machines.Order) do
        local def = Machines[id]
        if def and not def.EventOnly and not profile.UnlockedMachines[id] then nextId,nextDef=id,def;break end
    end

    if self.UI.GoalText and self.UI.GoalFill then
        if nextDef then
            local state = snapshot.MachineUnlocks and snapshot.MachineUnlocks[nextId]
            local firstMissing
            local met, total = 0, 0
            for _, req in ipairs(state and state.Requirements or {}) do
                total += 1
                if req.Met then met += 1 elseif not firstMissing then firstMissing = req end end
            local reqRatio = total > 0 and met/total or 1
            local coinRatio = nextDef.UnlockCost > 0 and math.clamp((profile.Coins or 0)/nextDef.UnlockCost,0,1) or 1
            local missing = firstMissing and string.format(" • %s %s/%s",string.upper(firstMissing.Label),compact(firstMissing.Current),compact(firstMissing.Target)) or ""
            self.UI.GoalText.Text = string.format("NEXT: %s%s • $%s/$%s",string.upper(nextDef.DisplayName),missing,compact(profile.Coins),compact(nextDef.UnlockCost))
            self.UI.GoalFill.Size = UDim2.fromScale(math.min(reqRatio,coinRatio),1)
        else
            self.UI.GoalText.Text = "DOWNTOWN ROUTE COMPLETE • STAMP PASSPORT • HUNT EVENT MACHINE ???"
            self.UI.GoalFill.Size = UDim2.fromScale(1,1)
        end
    end

    local hunts = snapshot.PassportState and snapshot.PassportState.Hunts or {}
    if self.HuntHud then
        if #hunts > 0 then
            local h = hunts[1]
            self.HuntHud.Text = string.format("HUNT  %s  •  %s  •  1/%s%s",string.upper(h.Name),string.upper(h.MachineName),compact(h.OneIn or 1),#hunts>1 and ("  +"..(#hunts-1).." MORE") or "")
            self.HuntHud.TextColor3 = Rarities.Get(h.Rarity).Color
        else
            self.HuntHud.Text = "HUNT LIST EMPTY • TRACK 3 UNKNOWN ITEMS"
            self.HuntHud.TextColor3 = Color3.fromRGB(255,215,82)
        end
    end
end

function WorldLoopController:Close()
    if self.Panel then self.Panel.Visible = false end
    GuiService.SelectedObject = nil
end

function WorldLoopController:Show(mode)
    self.Mode = mode or self.Mode
    self:Fetch()
    self.Panel.Visible = true
    self.Panel.Position = UDim2.new(0.5,0,0.5,14)
    TweenService:Create(self.Panel,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.fromScale(0.5,0.5)}):Play()
    self:Render()
    task.defer(function() if self.CloseButton and self.Panel.Visible then GuiService.SelectedObject=self.CloseButton end end)
end

function WorldLoopController:RenderPassport()
    local snapshot = self.UI.Snapshot
    local state = snapshot and snapshot.PassportState
    clearContent(self.Content)
    if not state then label(self.Content,"Passport unavailable",UDim2.new(1,-20,0,30),UDim2.fromOffset(10,10),Enum.Font.GothamBold,14,Theme.Muted);return end
    label(self.Content,"WORLD 1 • DOWNTOWN",UDim2.new(1,-20,0,30),UDim2.fromOffset(10,4),Enum.Font.GothamBlack,18,Color3.fromRGB(255,215,82))
    label(self.Content,"Collect → master → stamp. Future worlds add new machines and catalogs; no rebirth reset.",UDim2.new(1,-20,0,38),UDim2.fromOffset(10,32),Enum.Font.GothamBold,11,Theme.Muted).TextWrapped=true

    local y = 80
    for _, world in ipairs(state.Worlds or {}) do
        local rowHeight = world.Released and 100 or 64
        local row = Instance.new("Frame")
        row.Position = UDim2.fromOffset(10,y)
        row.Size = UDim2.new(1,-20,0,rowHeight)
        row.BackgroundColor3 = Theme.Panel2
        row.BorderSizePixel = 0
        row.Parent = self.Content
        round(row,11);stroke(row,world.Stamped and Color3.fromRGB(255,215,82) or Theme.Accent,1.2,0.3)
        label(row,string.upper(world.DisplayName),UDim2.fromOffset(270,24),UDim2.fromOffset(12,7),Enum.Font.GothamBlack,15,world.Stamped and Color3.fromRGB(255,215,82) or Theme.Text)
        if world.Released then
            label(row,string.format("CATALOG %d/%d",world.Discovered or 0,world.CatalogTotal or 0),UDim2.fromOffset(180,20),UDim2.fromOffset(12,31),Enum.Font.GothamBold,11,Theme.Accent)
            local done=0;local missing={}
            for _, req in ipairs(world.Requirements or {}) do
                if req.Met then done+=1 else table.insert(missing,req.Label.." "..compact(req.Current).."/"..compact(req.Target)) end
            end
            local status = world.Stamped and "STAMPED ✓" or string.format("%d/%d TASKS",done,#(world.Requirements or {}))
            local stamp = button(row,status,UDim2.fromOffset(145,34),UDim2.new(1,-157,0,9),world.CanStamp and Color3.fromRGB(89,228,148) or Theme.Accent)
            if world.CanStamp then
                stamp.Text="STAMP PASSPORT"
                stamp.MouseButton1Click:Connect(function()
                    self.Events.PassportAction:FireServer("stamp",world.Id)
                    task.delay(0.20,function()self:Show("Passport")end)
                end)
            else stamp.Active=false end
            local detail = #missing>0 and table.concat(missing," • ") or (world.Stamped and "Completed. Keep your collection forever." or "Ready to stamp.")
            local d = label(row,detail,UDim2.new(1,-24,0,39),UDim2.fromOffset(12,55),Enum.Font.GothamBold,9,Theme.Muted);d.TextWrapped=true
        else
            local d=label(row,"FUTURE DESTINATION • "..(world.Subtitle or ""),UDim2.new(1,-150,0,25),UDim2.fromOffset(12,32),Enum.Font.GothamBold,10,Theme.Muted);d.TextTruncate=Enum.TextTruncate.AtEnd
            local locked=button(row,"LOCKED",UDim2.fromOffset(110,32),UDim2.new(1,-122,0,15),Theme.Muted);locked.Active=false
        end
        y += rowHeight + 8
    end
    self.Content.CanvasSize=UDim2.fromOffset(0,y+10)
end

function WorldLoopController:RenderHunts()
    local snapshot = self.UI.Snapshot
    local profile = snapshot and snapshot.Profile
    local state = snapshot and snapshot.PassportState
    clearContent(self.Content)
    if not profile or not state then return end
    local hunts = state.Hunts or {}
    label(self.Content,"HUNT LIST  "..#hunts.." / "..tostring(state.HuntSlots or 3),UDim2.new(1,-20,0,30),UDim2.fromOffset(10,4),Enum.Font.GothamBlack,18,Color3.fromRGB(255,215,82))
    label(self.Content,"Pin an undiscovered item. The HUD keeps its machine + natural odds visible until you find it.",UDim2.new(1,-20,0,36),UDim2.fromOffset(10,34),Enum.Font.GothamBold,11,Theme.Muted).TextWrapped=true

    local y=78
    if #hunts>0 then
        for _,h in ipairs(hunts) do
            local row=Instance.new("Frame");row.Position=UDim2.fromOffset(10,y);row.Size=UDim2.new(1,-20,0,50);row.BackgroundColor3=Theme.Panel2;row.BorderSizePixel=0;row.Parent=self.Content;round(row,9);stroke(row,Rarities.Get(h.Rarity).Color,1.2,0.3)
            label(row,string.format("%s • %s • 1/%s",h.Name,h.MachineName,compact(h.OneIn or 1)),UDim2.new(1,-105,1,0),UDim2.fromOffset(10,0),Enum.Font.GothamBold,11,Rarities.Get(h.Rarity).Color)
            local un=button(row,"UNTRACK",UDim2.fromOffset(90,30),UDim2.new(1,-100,0,10),Color3.fromRGB(255,105,115));un.MouseButton1Click:Connect(function()self.Events.HuntAction:FireServer(h.BaseItemId,false);task.delay(0.18,function()self:Show("Hunts")end)end)
            y+=58
        end
    else
        label(self.Content,"No hunts pinned yet.",UDim2.new(1,-20,0,28),UDim2.fromOffset(10,y),Enum.Font.GothamBold,12,Theme.Muted);y+=38
    end

    label(self.Content,"UNDISCOVERED CATALOG",UDim2.new(1,-20,0,28),UDim2.fromOffset(10,y),Enum.Font.GothamBlack,13,Theme.Accent);y+=32
    local catalog={}
    for id,def in pairs(Items) do
        if type(def)=="table" and def.Id and not (profile.BaseCollection and profile.BaseCollection[id]) then table.insert(catalog,{Id=id,Def=def}) end
    end
    table.sort(catalog,function(a,b)
        local ar,br=Rarities.Get(a.Def.Rarity).Rank,Rarities.Get(b.Def.Rarity).Rank
        if ar==br then return (a.Def.BaseOneIn or 1)<(b.Def.BaseOneIn or 1) end
        return ar<br
    end)
    for _,entry in ipairs(catalog) do
        local def=entry.Def;local tracked=isTracked(profile,entry.Id);local rarity=Rarities.Get(def.Rarity)
        local row=Instance.new("Frame");row.Position=UDim2.fromOffset(10,y);row.Size=UDim2.new(1,-20,0,44);row.BackgroundColor3=Theme.Panel2;row.BorderSizePixel=0;row.Parent=self.Content;round(row,8)
        label(row,string.format("%s • %s • %s • 1/%s",def.Name,Machines[def.Machine].DisplayName,def.Rarity,compact(def.BaseOneIn or 1)),UDim2.new(1,-105,1,0),UDim2.fromOffset(10,0),Enum.Font.GothamBold,10,rarity.Color)
        local b=button(row,tracked and "TRACKED" or "TRACK",UDim2.fromOffset(88,28),UDim2.new(1,-98,0,8),tracked and Color3.fromRGB(255,215,82) or Theme.Accent)
        b.MouseButton1Click:Connect(function()
            self.Events.HuntAction:FireServer(entry.Id,not tracked)
            task.delay(0.18,function()self:Show("Hunts")end)
        end)
        y+=50
    end
    self.Content.CanvasSize=UDim2.fromOffset(0,y+12)
end

function WorldLoopController:Render()
    if self.Mode=="Hunts" then self:RenderHunts() else self:RenderPassport() end
    self.PassportTab.BackgroundColor3=self.Mode=="Passport" and Theme.Accent or Theme.Button
    self.HuntTab.BackgroundColor3=self.Mode=="Hunts" and Theme.Accent or Theme.Button
end

function WorldLoopController:Init(events, functions, UI)
    self.Events=events;self.Functions=functions;self.UI=UI
    local gui=UI.Gui

    local open=button(gui,"✦  PASSPORT",UDim2.fromOffset(150,42),UDim2.new(0,14,0.14,0),Color3.fromRGB(255,215,82))
    open.ZIndex=12;open.MouseButton1Click:Connect(function()self:Show("Passport")end)
    self.HuntHud=label(gui,"HUNT LIST EMPTY • TRACK 3 UNKNOWN ITEMS",UDim2.fromOffset(620,22),UDim2.new(0.5,-310,0,165),Enum.Font.GothamBlack,10,Color3.fromRGB(255,215,82));self.HuntHud.TextXAlignment=Enum.TextXAlignment.Center;self.HuntHud.ZIndex=12

    local panel=Instance.new("Frame");panel.Name="WorldLoopPanel";panel.AnchorPoint=Vector2.new(0.5,0.5);panel.Position=UDim2.fromScale(0.5,0.5);panel.Size=UDim2.fromOffset(760,650);panel.BackgroundColor3=Theme.Panel;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=70;panel.Parent=gui;round(panel,14);stroke(panel,Color3.fromRGB(255,215,82),1.6,0.2);self.Panel=panel
    label(panel,"VENDING PASSPORT",UDim2.new(1,-170,0,42),UDim2.fromOffset(22,10),Enum.Font.GothamBlack,22,Theme.Text).ZIndex=72
    self.CloseButton=button(panel,"×",UDim2.fromOffset(40,40),UDim2.new(1,-52,0,9),Color3.fromRGB(255,105,115));self.CloseButton.ZIndex=73;self.CloseButton.MouseButton1Click:Connect(function()self:Close()end)
    self.PassportTab=button(panel,"PASSPORT",UDim2.fromOffset(145,34),UDim2.fromOffset(22,58),Color3.fromRGB(255,215,82));self.PassportTab.ZIndex=72;self.PassportTab.MouseButton1Click:Connect(function()self.Mode="Passport";self:Render()end)
    self.HuntTab=button(panel,"HUNT LIST",UDim2.fromOffset(145,34),UDim2.fromOffset(175,58),Theme.Accent);self.HuntTab.ZIndex=72;self.HuntTab.MouseButton1Click:Connect(function()self.Mode="Hunts";self:Render()end)
    local content=Instance.new("ScrollingFrame");content.Name="Content";content.Position=UDim2.fromOffset(16,101);content.Size=UDim2.new(1,-32,1,-117);content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=6;content.ScrollBarImageColor3=Theme.Accent;content.CanvasSize=UDim2.new();content.ZIndex=71;content.Parent=panel;self.Content=content

    events.OpenPanel.OnClientEvent:Connect(function(data)if type(data)=="table" and data.Panel=="Passport" then self:Show("Passport")end end)
    UserInputService.InputBegan:Connect(function(input,processed)if not processed and panel.Visible and (input.KeyCode==Enum.KeyCode.ButtonB or input.KeyCode==Enum.KeyCode.Escape) then self:Close() end end)

    local baseUpdate=UI.UpdateHud
    UI.UpdateHud=function(controller,...)
        local result=baseUpdate(controller,...)
        self:RefreshHud()
        return result
    end
    self:RefreshHud()
end

return WorldLoopController

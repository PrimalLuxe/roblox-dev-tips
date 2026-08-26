local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Util=require(ReplicatedStorage.Shared.Util)
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()

local player=Players.LocalPlayer
local TradeController={Panel=nil,State=nil}

local function round(x,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=x end
local function stroke(x,color,t,trans)local s=Instance.new("UIStroke");s.Color=color or Theme.Accent;s.Thickness=t or 1.2;s.Transparency=trans or 0.3;s.Parent=x end
local function gradient(x,c1,c2)local g=Instance.new("UIGradient");g.Color=ColorSequence.new(c1,c2);g.Rotation=90;g.Parent=x end
local function txt(parent,text,pos,size,color,font,textSize)
    local l=Instance.new("TextLabel");l.Text=text;l.Position=pos;l.Size=size;l.BackgroundTransparency=1;l.TextColor3=color or Theme.Text;l.Font=font or Enum.Font.GothamBold;l.TextSize=textSize or 14;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function btn(parent,text,pos,size,accent)
    local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=Theme.Button;b.TextColor3=Theme.Text;b.Font=Enum.Font.GothamBlack;b.TextSize=14;b.AutoButtonColor=true;b.BorderSizePixel=0;b.Parent=parent;round(b,10);stroke(b,accent or Theme.Accent,1.4,0.2);return b
end

function TradeController:DestroyPanel()
    if self.Panel then self.Panel:Destroy();self.Panel=nil end
end

function TradeController:BasePanel(name,size)
    self:DestroyPanel()
    local p=Instance.new("Frame");p.Name=name;p.Size=size;p.AnchorPoint=Vector2.new(0.5,0.5);p.Position=UDim2.fromScale(0.5,0.5);p.BackgroundColor3=Theme.Panel;p.BorderSizePixel=0;p.ZIndex=60;p.Parent=self.UI.Gui;round(p,16);stroke(p,Theme.Accent,1.8,0.18);gradient(p,Theme.Panel2,Theme.Panel);self.Panel=p
    return p
end

function TradeController:ShowRequest(state)
    local p=self:BasePanel("TradeRequest",UDim2.fromOffset(470,210))
    local title=txt(p,"TRADE REQUEST",UDim2.fromOffset(24,18),UDim2.fromOffset(420,32),Theme.Accent,Enum.Font.GothamBlack,22);title.TextXAlignment=Enum.TextXAlignment.Center
    local who=txt(p,(state.FromName or "A player").." wants to trade with you.",UDim2.fromOffset(30,67),UDim2.fromOffset(410,44),Theme.Text,Enum.Font.GothamBold,16);who.TextWrapped=true;who.TextXAlignment=Enum.TextXAlignment.Center
    local yes=btn(p,"ACCEPT",UDim2.fromOffset(36,136),UDim2.fromOffset(185,46),Color3.fromRGB(82,231,143));yes.MouseButton1Click:Connect(function()self.Remotes.TradeAction:FireServer("accept_request",state.From)end)
    local no=btn(p,"DECLINE",UDim2.fromOffset(249,136),UDim2.fromOffset(185,46),Color3.fromRGB(255,91,111));no.MouseButton1Click:Connect(function()self.Remotes.TradeAction:FireServer("decline_request",state.From);self:DestroyPanel()end)
end

local function offerSummary(items)
    local total=0;local rare=0
    for _,item in ipairs(items or {}) do total+=item.Value or 0;if Rarities.Get(item.Rarity).Rank>=7 then rare+=1 end end
    return #items,total,rare
end

local function addItemRow(parent,item,y,own,removeCallback)
    local def=Items[item.BaseItemId];local rarity=Rarities.Get(item.Rarity)
    local row=Instance.new("TextButton");row.Text="";row.Position=UDim2.fromOffset(8,y);row.Size=UDim2.new(1,-16,0,43);row.BackgroundColor3=Theme.Panel;row.BorderSizePixel=0;row.AutoButtonColor=own;row.Parent=parent;round(row,8);stroke(row,rarity.Color,1.3,0.22)
    local display=(item.MutationId~="None" and item.MutationId.." " or "")..(def and def.Name or item.BaseItemId)
    local name=txt(row,display,UDim2.fromOffset(9,3),UDim2.new(1,-18,0,20),rarity.Color,Enum.Font.GothamBlack,12);name.TextTruncate=Enum.TextTruncate.AtEnd
    local detail=txt(row,"1/"..Util.FormatInteger(item.OneIn or 1).."   •   $"..Util.FormatInteger(item.Value or 0)..(item.Locked and "   •   LOCKED" or ""),UDim2.fromOffset(9,22),UDim2.new(1,-18,0,17),Theme.Muted,Enum.Font.GothamBold,10);detail.TextTruncate=Enum.TextTruncate.AtEnd
    if rarity.Rank>=8 then
        local badge=txt(row,"HIGH VALUE",UDim2.fromOffset(-94,3),UDim2.fromOffset(88,18),Color3.fromRGB(255,215,82),Enum.Font.GothamBlack,9);badge.AnchorPoint=Vector2.new(1,0);badge.Position=UDim2.new(1,-6,0,3);badge.TextXAlignment=Enum.TextXAlignment.Right
    end
    if own then row.MouseButton1Click:Connect(function()removeCallback(item.InstanceId)end)end
end

function TradeController:Render(state)
    self.State=state
    if state.Phase=="Request" then self:ShowRequest(state);return end
    if state.Phase=="Closed" then self.UI.TradeActive=false;self:DestroyPanel();self.UI:Toast({Text=state.Reason or "Trade closed",Kind="Info"});return end
    self.UI.TradeActive=true
    if not self.Panel or self.Panel.Name~="TradePanel" then self:BasePanel("TradePanel",UDim2.fromOffset(850,610)) end
    local p=self.Panel
    for _,c in ipairs(p:GetChildren()) do if not (c:IsA("UICorner") or c:IsA("UIStroke") or c:IsA("UIGradient")) then c:Destroy() end end

    local side=state.A==player.UserId and "A" or "B";local otherSide=side=="A" and "B" or "A";local otherId=state[otherSide]
    local otherPlayer=Players:GetPlayerByUserId(otherId)
    local title=txt(p,"TRADE WITH "..string.upper(otherPlayer and otherPlayer.DisplayName or "PLAYER"),UDim2.fromOffset(24,14),UDim2.new(1,-48,0,38),Theme.Text,Enum.Font.GothamBlack,22);title.TextXAlignment=Enum.TextXAlignment.Center
    local notice=txt(p,"Any offer change instantly resets both READY and CONFIRM states.",UDim2.fromOffset(24,50),UDim2.new(1,-48,0,25),Theme.Muted,Enum.Font.GothamBold,12);notice.TextXAlignment=Enum.TextXAlignment.Center

    local mine=(state.OfferDetails and state.OfferDetails[side]) or {};local theirs=(state.OfferDetails and state.OfferDetails[otherSide]) or {}
    local mineCount,mineValue,mineRare=offerSummary(mine);local theirCount,theirValue,theirRare=offerSummary(theirs)
    local function sideBox(x,header,items,count,value,rare,own)
        local box=Instance.new("Frame");box.Position=UDim2.fromOffset(x,92);box.Size=UDim2.fromOffset(390,360);box.BackgroundColor3=Theme.Panel2;box.BorderSizePixel=0;box.Parent=p;round(box,12);stroke(box,own and Theme.Accent or Color3.fromRGB(255,190,87),1.5,0.3)
        txt(box,header,UDim2.fromOffset(14,10),UDim2.fromOffset(210,28),own and Theme.Accent or Color3.fromRGB(255,190,87),Enum.Font.GothamBlack,16)
        local stats=txt(box,string.format("%d items • $%s%s",count,Util.FormatInteger(value),rare>0 and (" • "..rare.." high-value") or ""),UDim2.fromOffset(14,38),UDim2.new(1,-28,0,22),Theme.Muted,Enum.Font.GothamBold,11);stats.TextXAlignment=Enum.TextXAlignment.Left
        local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(8,68);scroll.Size=UDim2.new(1,-16,1,-76);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=5;scroll.ScrollBarImageColor3=own and Theme.Accent or Color3.fromRGB(255,190,87);scroll.CanvasSize=UDim2.fromOffset(0,#items*48);scroll.Parent=box
        local y=0;for _,item in ipairs(items) do addItemRow(scroll,item,y,own,function(id)self.Remotes.TradeAction:FireServer("remove",id)end);y+=48 end
        if #items==0 then local empty=txt(scroll,own and "Open COLLECTION → inspect an item → ADD TO TRADE" or "No items offered yet",UDim2.fromOffset(12,20),UDim2.new(1,-24,0,50),Theme.Muted,Enum.Font.GothamBold,12);empty.TextWrapped=true;empty.TextXAlignment=Enum.TextXAlignment.Center end
    end
    sideBox(24,"YOUR OFFER",mine,mineCount,mineValue,mineRare,true)
    sideBox(436,"THEIR OFFER",theirs,theirCount,theirValue,theirRare,false)

    local mineReady=state.Ready[side];local theirReady=state.Ready[otherSide]
    txt(p,(mineReady and "✓ YOU READY" or "○ YOU NOT READY").."        "..(theirReady and "✓ THEY READY" or "○ THEY NOT READY"),UDim2.fromOffset(35,466),UDim2.new(1,-70,0,25),mineReady and theirReady and Color3.fromRGB(84,235,145) or Theme.Muted,Enum.Font.GothamBlack,13).TextXAlignment=Enum.TextXAlignment.Center
    local ready=btn(p,mineReady and "UNREADY" or "READY",UDim2.fromOffset(28,510),UDim2.fromOffset(190,50),Color3.fromRGB(82,231,143));ready.MouseButton1Click:Connect(function()self.Remotes.TradeAction:FireServer("ready")end)
    if state.Phase=="Confirm" or state.Phase=="Countdown" then
        local confirm=btn(p,state.Confirm[side] and "✓ CONFIRMED" or "CONFIRM TRADE",UDim2.fromOffset(230,510),UDim2.fromOffset(250,50),Color3.fromRGB(255,206,83));confirm.MouseButton1Click:Connect(function()self.Remotes.TradeAction:FireServer("confirm")end)
    end
    local cancel=btn(p,"CANCEL",UDim2.new(1,-218,0,510),UDim2.fromOffset(190,50),Color3.fromRGB(255,91,111));cancel.MouseButton1Click:Connect(function()self.Remotes.TradeAction:FireServer("cancel")end)
    if state.Phase=="Countdown" then
        local warning=txt(p,"FINALIZING • OFFERS LOCKED • SERVER REVALIDATING OWNERSHIP",UDim2.fromOffset(120,570),UDim2.new(1,-240,0,26),Color3.fromRGB(255,111,111),Enum.Font.GothamBlack,12);warning.TextXAlignment=Enum.TextXAlignment.Center
    end
end

function TradeController:Init(remotes,ui)
    self.Remotes=remotes;self.UI=ui
    remotes.TradeState.OnClientEvent:Connect(function(state)self:Render(state)end)
end

return TradeController

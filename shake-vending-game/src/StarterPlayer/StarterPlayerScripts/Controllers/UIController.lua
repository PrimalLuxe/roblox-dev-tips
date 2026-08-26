local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")

local player=Players.LocalPlayer
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Machines=require(ReplicatedStorage.Shared.MachineDefinitions)
local Config=require(ReplicatedStorage.Shared.Config)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Util=require(ReplicatedStorage.Shared.Util)
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents=require(script.Parent.UIComponents)

local UIController={Snapshot=nil,TradeActive=false,Filters={Search="",Sort="Rarity"},Panels={},CollectionMode="Inventory",ShowcasePickSlot=nil}

local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=o end
local function stroke(o,color)local s=Instance.new("UIStroke");s.Thickness=1.25;s.Color=color or Theme.Accent;s.Transparency=0.28;s.Parent=o end
local function text(parent,value,pos,size,color,font,n)
    local x=Instance.new("TextLabel");x.BackgroundTransparency=1;x.Text=value;x.Position=pos or UDim2.new();x.Size=size or UDim2.fromScale(1,1);x.TextColor3=color or Theme.Text;x.Font=font or Enum.Font.GothamBold;x.TextSize=n or 14;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=parent;return x
end
local function button(parent,value,pos,size,color)return UIComponents.Button(parent,value,size or UDim2.fromOffset(140,40),pos or UDim2.new(),color or Theme.Accent)end
local function compact(n)n=tonumber(n)or 0;if n>=1e9 then return string.format("%.1fB",n/1e9)elseif n>=1e6 then return string.format("%.1fM",n/1e6)elseif n>=1e3 then return string.format("%.1fK",n/1e3)end;return tostring(math.floor(n))end
local function count(t)local n=0;for _,v in pairs(t or {})do if v then n+=1 end end;return n end
local function cap(p)return Config.InventoryBaseCapacity+math.max(0,((p.Upgrades and p.Upgrades.Capacity)or 1)-1)*25 end
local function clear(frame)
    for _,c in ipairs(frame:GetChildren())do if not(c:IsA("UIListLayout")or c:IsA("UIGridLayout")or c:IsA("UIPadding")or c:IsA("UICorner")or c:IsA("UIStroke"))then c:Destroy()end end
end
local function modal(gui,name,w,h)
    local p=Instance.new("Frame");p.Name=name;p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.5);p.Size=UDim2.fromOffset(w,h);p.BackgroundColor3=Theme.Panel;p.BorderSizePixel=0;p.Visible=false;p.ZIndex=30;p.Parent=gui;round(p,16);stroke(p)
    local sc=Instance.new("UIScale");sc.Parent=p
    local function fit()local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(w,h);sc.Scale=math.clamp(math.min((v.X-24)/w,(v.Y-40)/h),.52,1)end;fit();if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)end
    return p
end
local function closeButton(self,p)local b=button(p,"×",UDim2.new(1,-52,0,10),UDim2.fromOffset(40,40),Color3.fromRGB(255,95,105));b.ZIndex=35;b.MouseButton1Click:Connect(function()p.Visible=false;self.ShowcasePickSlot=nil;self:UpdateModalBlur()end)end
local function viewport(parent,item)
    local vp=Instance.new("ViewportFrame");vp.Size=UDim2.fromScale(1,1);vp.BackgroundTransparency=1;vp.Ambient=Color3.fromRGB(190,195,210);vp.LightColor=Color3.new(1,1,1);vp.Parent=parent
    local world=Instance.new("WorldModel");world.Parent=vp;local model=Factory.Create(item.BaseItemId,item.MutationId or "None")
    if model then Factory.PrepareForViewport(model);model.Parent=world;pcall(function()model:ScaleTo(.9)end)end
    local cam=Instance.new("Camera");cam.CFrame=CFrame.new(3,1.8,4.5)*CFrame.Angles(math.rad(-7),math.rad(32),0);cam.Focus=CFrame.new();cam.Parent=vp;vp.CurrentCamera=cam
end

function UIController:ApplyProfileSettings(profile)
    local s=profile and profile.Settings or {};self.EffectQuality=s.EffectQuality or "High";self.SkipLong=s.SkipLongReveals==true;self.ReducedEffects=s.ReducedEffects==true;self.ReducedScreenShake=s.ReducedScreenShake==true;self.SFXEnabled=s.SFXEnabled~=false;self.MusicEnabled=s.MusicEnabled~=false
    if self.OnSettingsChanged then self.OnSettingsChanged(s)end
end
function UIController:PushSetting(action,value)self.Events.SettingsAction:FireServer(action,value);task.delay(.15,function()self:Fetch();self:ApplyProfileSettings(self.Snapshot.Profile)end)end
function UIController:Fetch()
    local ok,s=pcall(function()return self.Functions.GetSnapshot:InvokeServer()end);if ok and type(s)=="table" then self.Snapshot=s;if self.OnSnapshotChanged then self.OnSnapshotChanged(s)end end;return self.Snapshot
end
function UIController:GetNextMachine()
    local p=self.Snapshot and self.Snapshot.Profile;if not p then return nil end
    for _,id in ipairs(Machines.Order)do local d=Machines[id];if not d.EventOnly and not p.UnlockedMachines[id]then return id,d end end
end
function UIController:UpdateHud()
    local p=self.Snapshot and self.Snapshot.Profile;if not p then return end
    self.Coins.Text="$"..compact(p.Coins);self.Shards.Text="◆ "..compact(p.StyleShards);self.Inventory.Text=string.format("%d/%d ITEMS",#(p.Inventory or {}),cap(p));self.Catalog.Text=string.format("%d/60 CATALOG",count(p.BaseCollection))
end
function UIController:Toast(data)
    local t=Instance.new("TextLabel");t.AnchorPoint=Vector2.new(.5,0);t.Position=UDim2.new(.5,0,0,78);t.Size=UDim2.fromOffset(470,44);t.BackgroundColor3=Theme.Panel;t.BackgroundTransparency=.08;t.Text=data.Text or "";t.TextColor3=data.Kind=="Warn" and Color3.fromRGB(255,173,96)or data.Kind=="Success"and Color3.fromRGB(105,239,157)or Theme.Text;t.Font=Enum.Font.GothamBlack;t.TextSize=14;t.ZIndex=180;t.Parent=self.Gui;round(t,12);stroke(t,t.TextColor3);task.delay(2.7,function()if t.Parent then t:Destroy()end end)
end
function UIController:UpdateModalBlur()end
function UIController:CloseTopPanel()for i=#self.Panels,1,-1 do local p=self.Panels[i];if p.Visible then p.Visible=false;self:UpdateModalBlur();return true end end;return false end
function UIController:FocusPanel(p)task.defer(function()local b=p:FindFirstChildWhichIsA("GuiButton",true);if b then GuiService.SelectedObject=b end end)end
function UIController:ClosePanels(except)for _,p in ipairs(self.Panels)do if p~=except then p.Visible=false end end end

function UIController:OpenCollection(mode)
    self:Fetch();self.CollectionMode=mode or self.CollectionMode;self:ClosePanels(self.CollectionPanel);self.CollectionPanel.Visible=true;self:RenderCollection();self:FocusPanel(self.CollectionPanel);if self.OnCollectionOpened then self.OnCollectionOpened()end
end
function UIController:RenderCollection()
    local p=self.Snapshot and self.Snapshot.Profile;if not p then return end;clear(self.CollectionList)
    local rows={};local q=(self.SearchBox.Text or ""):lower()
    if self.CollectionMode=="Catalog" then
        for id,d in pairs(Items)do if type(d)=="table" and d.Id and (q==""or d.Name:lower():find(q,1,true))then table.insert(rows,{BaseItemId=id,MutationId="None",Rarity=d.Rarity,OneIn=d.BaseOneIn or 1,Value=d.BaseValue or 0,Catalog=true,Discovered=p.BaseCollection[id]==true})end end
    else
        for _,it in ipairs(p.Inventory or {})do local d=Items[it.BaseItemId];local hay=((d and d.Name or it.BaseItemId).." "..it.Rarity.." "..it.MutationId.." "..(it.ObtainedMachine or "")):lower();if q==""or hay:find(q,1,true)then table.insert(rows,it)end end
    end
    table.sort(rows,function(a,b)if self.Filters.Sort=="Value"then return(a.Value or 0)>(b.Value or 0)elseif self.Filters.Sort=="Name"then return(Items[a.BaseItemId].Name)<(Items[b.BaseItemId].Name)elseif self.Filters.Sort=="Newest"then return(a.ObtainedAt or 0)>(b.ObtainedAt or 0)else return(a.OneIn or 1)>(b.OneIn or 1)end end)
    self.CollectionCount.Text=tostring(#rows).." shown"
    for _,it in ipairs(rows)do
        local d=Items[it.BaseItemId];local card=Instance.new("TextButton");card.Text="";card.Size=UDim2.fromOffset(145,182);card.BackgroundColor3=Theme.Panel2;card.BorderSizePixel=0;card.Parent=self.CollectionList;round(card,11);stroke(card,Rarities.Get(it.Rarity).Color)
        local preview=Instance.new("Frame");preview.Size=UDim2.new(1,-10,0,105);preview.Position=UDim2.fromOffset(5,5);preview.BackgroundTransparency=1;preview.Parent=card;if it.Discovered~=false then viewport(preview,it)end
        local n=text(card,it.Discovered==false and "???"or d.Name,UDim2.fromOffset(7,112),UDim2.new(1,-14,0,24),Rarities.Get(it.Rarity).Color,Enum.Font.GothamBlack,11);n.TextTruncate=Enum.TextTruncate.AtEnd
        text(card,it.Rarity.." • 1/"..compact(it.OneIn),UDim2.fromOffset(7,139),UDim2.new(1,-14,0,18),Theme.Muted,Enum.Font.GothamBold,9)
        text(card,it.Catalog and(it.Discovered and"DISCOVERED"or"TRACK / HUNT")or("$"..compact(it.Value)),UDim2.fromOffset(7,159),UDim2.new(1,-14,0,17),Theme.Text,Enum.Font.GothamBold,9)
        card.MouseButton1Click:Connect(function()if it.Catalog then self.Events.HuntAction:FireServer(it.BaseItemId,true)else self:ShowItem(it)end end)
    end
end
function UIController:ShowItem(item)
    local p=self.ItemPanel;clear(p);p.Visible=true;closeButton(self,p);local d=Items[item.BaseItemId];local r=Rarities.Get(item.Rarity);text(p,(item.MutationId~="None"and item.MutationId.." "or"")..d.Name,UDim2.fromOffset(24,20),UDim2.new(1,-90,0,40),r.Color,Enum.Font.GothamBlack,22)
    local v=Instance.new("Frame");v.Position=UDim2.fromOffset(28,75);v.Size=UDim2.fromOffset(280,280);v.BackgroundColor3=Theme.Panel2;v.BorderSizePixel=0;v.Parent=p;round(v,14);viewport(v,item)
    text(p,"RARITY  "..item.Rarity.."\nOBTAINED ODDS  1 / "..Util.FormatInteger(item.OneIn or 1).."\nNATURAL ODDS  1 / "..Util.FormatInteger(item.NaturalOneIn or item.OneIn or 1).."\nVALUE  $"..compact(item.Value).."\nMACHINE  "..tostring(item.ObtainedMachine or "Unknown"),UDim2.fromOffset(335,88),UDim2.fromOffset(380,190),Theme.Text,Enum.Font.GothamBold,14).TextWrapped=true
    local y=380;local fav=button(p,"☆ FAVORITE",UDim2.fromOffset(25,y),UDim2.fromOffset(130,42),Color3.fromRGB(255,215,82));fav.MouseButton1Click:Connect(function()self.Events.InventoryAction:FireServer("favorite",item.InstanceId)end)
    local lock=button(p,"LOCK / UNLOCK",UDim2.fromOffset(166,y),UDim2.fromOffset(140,42));lock.MouseButton1Click:Connect(function()self.Events.InventoryAction:FireServer("lock",item.InstanceId)end)
    local sell=button(p,"SELL $"..compact(item.Value),UDim2.fromOffset(317,y),UDim2.fromOffset(130,42),Color3.fromRGB(91,230,144));sell.MouseButton1Click:Connect(function()UIComponents.Confirm(self.Gui,"SELL ITEM","Sell this exact item? Locked, favorited, equipped and showcased items are protected.","SELL",function()self.Events.InventoryAction:FireServer("sell",item.InstanceId);p.Visible=false;task.delay(.2,function()self:OpenCollection("Inventory")end)end)end)
    local equip=button(p,"EQUIP",UDim2.fromOffset(458,y),UDim2.fromOffset(120,42));equip.MouseButton1Click:Connect(function()self.Events.EquipCosmetic:FireServer(item.InstanceId,d.CosmeticSlot)end)
    if self.ShowcasePickSlot then local s=button(p,"SHOWCASE #"..self.ShowcasePickSlot,UDim2.fromOffset(589,y),UDim2.fromOffset(140,42),Color3.fromRGB(255,204,86));s.MouseButton1Click:Connect(function()self.Events.SetShowcase:FireServer(self.ShowcasePickSlot,item.InstanceId);self.ShowcasePickSlot=nil;p.Visible=false end)end
end
function UIController:ConfirmMassSell(mode,labelText)
    local p=self.Snapshot.Profile;local n,v=0,0;for _,it in ipairs(p.Inventory or {})do if not it.Locked and not p.Favorites[it.InstanceId]then local rank=Rarities.Get(it.Rarity).Rank;if(mode=="commons"and rank<=2)or(mode=="safe"and rank<=4)or mode=="duplicates"then n+=1;v+=it.Value or 0 end end end
    UIComponents.Confirm(self.Gui,"CONFIRM BULK SALE",string.format("%s can sell up to %d eligible items for about $%s. Locked, favorited, equipped and showcased items stay protected.",labelText,n,compact(v)),"SELL "..n,function()self.Events.InventoryAction:FireServer("mass_"..mode);task.delay(.25,function()self:Fetch();self:RenderCollection();self:UpdateHud()end)end)
end

local function simpleList(self,p,title,lines)
    clear(p);closeButton(self,p);text(p,title,UDim2.fromOffset(22,14),UDim2.new(1,-80,0,40),Theme.Text,Enum.Font.GothamBlack,22);local body=text(p,table.concat(lines,"\n"),UDim2.fromOffset(24,65),UDim2.new(1,-48,1,-90),Theme.Text,Enum.Font.GothamBold,14);body.TextWrapped=true;body.TextYAlignment=Enum.TextYAlignment.Top;p.Visible=true;self:FocusPanel(p)
end
function UIController:OpenDrip()local p=self.Snapshot.Profile;simpleList(self,self.DripPanel,"DRIP / AVATAR",{"Equip collectibles from Collection.","Saved outfits: "..tostring(#(p.OutfitSlots or {})),"Auras and trails are cosmetic only."})end
function UIController:OpenUpgrades()self:Fetch();local p=self.UpgradePanel;clear(p);closeButton(self,p);text(p,"UPGRADES",UDim2.fromOffset(22,14),UDim2.new(1,-80,0,40),Theme.Text,Enum.Font.GothamBlack,22);local y=70;for _,name in ipairs({"ShakePower","Luck","MutationLuck","Capacity","CollectionBonus"})do local lv=self.Snapshot.Profile.Upgrades[name]or 1;local b=button(p,name:upper().."  Lv."..lv,UDim2.fromOffset(24,y),UDim2.fromOffset(320,44));b.MouseButton1Click:Connect(function()self.Events.UpgradeAction:FireServer(name);task.delay(.2,function()self:OpenUpgrades();self:UpdateHud()end)end);y+=55 end;p.Visible=true;self:FocusPanel(p)end
function UIController:OpenGoals()self:Fetch();local pr=self.Snapshot.Profile.Progression;local lines={"RANK "..tostring(pr.Rank or 1),"SHAKES  "..compact(self.Snapshot.Profile.Statistics.Shakes or 0),"LUCKY METER  "..tostring(pr.LuckyMeter or 0).."/"..Config.LuckyMeterThreshold,"Open the Vending Passport for world goals and hunts."};simpleList(self,self.GoalsPanel,"GOALS",lines)end
function UIController:OpenGifts()self.Events.ProgressionAction:FireServer("request_engagement");simpleList(self,self.GiftsPanel,"PLAYTIME GIFTS",{"Stay and shake to unlock timed rewards.","Rewards are timed on the server.","Ready gifts can be claimed when their state arrives."})end
function UIController:OpenBoard()local ok,rows=pcall(function()return self.Functions.GetHourlyBoard:InvokeServer()end);local lines={};if ok then for i,r in ipairs(rows)do table.insert(lines,string.format("#%d  %s  •  %s  •  1/%s",i,r.DisplayName or r.PlayerName or"Player",r.ItemName or r.BaseItemId,compact(r.OneIn)))end end;if #lines==0 then lines={"No qualifying rare finds this hour yet."}end;simpleList(self,self.BoardPanel,"GLOBAL RAREST THIS HOUR",lines)end
function UIController:OpenSettings()
    self:Fetch();local p=self.SettingsPanel;clear(p);closeButton(self,p);text(p,"SETTINGS / ACCESSIBILITY",UDim2.fromOffset(22,14),UDim2.new(1,-80,0,40),Theme.Text,Enum.Font.GothamBlack,21);local s=self.Snapshot.Profile.Settings;local opts={{"REDUCED EFFECTS","reduced_effects",not s.ReducedEffects},{"REDUCED SCREEN SHAKE","reduced_screen_shake",not s.ReducedScreenShake},{"SKIP LONG REVEALS","skip_long_reveals",not s.SkipLongReveals},{"SFX","sfx_enabled",s.SFXEnabled==false},{"MUSIC","music_enabled",s.MusicEnabled==false},{"AUTO-LOCK LEGENDARY+","auto_lock_legendary",s.AutoLockLegendary==false},{"KEEP ONE EACH","keep_one_each",s.KeepOneEach==false}};local y=70;for _,o in ipairs(opts)do local b=button(p,o[1],UDim2.fromOffset(24,y),UDim2.fromOffset(340,40));b.MouseButton1Click:Connect(function()self:PushSetting(o[2],o[3]);task.delay(.2,function()self:OpenSettings()end)end);y+=48 end;p.Visible=true;self:FocusPanel(p)
end
function UIController:ShowGlobal(data)self:Toast({Text=(data.DisplayName or"PLAYER").." FOUND "..(data.ItemName or data.BaseItemId).." • 1/"..compact(data.OneIn),Kind="New"})end
function UIController:ShowInspect(s)local r=s.Rarest;simpleList(self,self.InspectPanel,"PLAYER COLLECTION",{"Catalog: "..tostring(s.CollectionCount or 0).."/60","Collection score: "..compact(s.CollectionScore),r and("Rarest: "..r.BaseItemId.." • 1/"..compact(r.OneIn))or"Rarest: none yet"})end

function UIController:Build(remotes,functions)
    self.Events=remotes;self.Functions=functions
    local gui=Instance.new("ScreenGui");gui.Name="ShakeUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=20;gui.Parent=player.PlayerGui;self.Gui=gui
    local top=Instance.new("Frame");top.AnchorPoint=Vector2.new(.5,0);top.Position=UDim2.new(.5,0,0,14);top.Size=UDim2.fromOffset(650,52);top.BackgroundColor3=Theme.Panel;top.BorderSizePixel=0;top.Parent=gui;round(top,14);stroke(top)
    self.Coins=text(top,"$0",UDim2.fromOffset(18,5),UDim2.fromOffset(150,42),Color3.fromRGB(108,239,153),Enum.Font.GothamBlack,18);self.Shards=text(top,"◆ 0",UDim2.fromOffset(170,5),UDim2.fromOffset(120,42),Color3.fromRGB(196,125,255),Enum.Font.GothamBlack,16);self.Inventory=text(top,"0/0 ITEMS",UDim2.fromOffset(300,5),UDim2.fromOffset(150,42),Theme.Text,Enum.Font.GothamBlack,14);self.Catalog=text(top,"0/60 CATALOG",UDim2.fromOffset(465,5),UDim2.fromOffset(170,42),Color3.fromRGB(255,213,86),Enum.Font.GothamBlack,14)
    local side=Instance.new("Frame");side.Position=UDim2.new(0,12,.22,0);side.Size=UDim2.fromOffset(156,390);side.BackgroundTransparency=1;side.Parent=gui;local actions={{"COLLECTION",function()self:OpenCollection("Inventory")end},{"GOALS",function()self:OpenGoals()end},{"UPGRADES",function()self:OpenUpgrades()end},{"DRIP",function()self:OpenDrip()end},{"GIFTS",function()self:OpenGifts()end},{"GLOBAL",function()self:OpenBoard()end},{"SETTINGS",function()self:OpenSettings()end}};local y=0;for _,a in ipairs(actions)do local b=button(side,a[1],UDim2.fromOffset(0,y),UDim2.fromOffset(148,44));b.MouseButton1Click:Connect(a[2]);y+=50 end
    local goal=Instance.new("Frame");goal.AnchorPoint=Vector2.new(.5,1);goal.Position=UDim2.new(.5,0,1,-16);goal.Size=UDim2.fromOffset(620,50);goal.BackgroundColor3=Theme.Panel;goal.BorderSizePixel=0;goal.Parent=gui;round(goal,13);stroke(goal);self.GoalText=text(goal,"NEXT MACHINE",UDim2.fromOffset(10,3),UDim2.new(1,-20,0,26),Theme.Text,Enum.Font.GothamBlack,13);self.GoalText.TextXAlignment=Enum.TextXAlignment.Center;local track=Instance.new("Frame");track.Position=UDim2.fromOffset(10,33);track.Size=UDim2.new(1,-20,0,10);track.BackgroundColor3=Color3.fromRGB(48,54,66);track.BorderSizePixel=0;track.Parent=goal;round(track,5);self.GoalFill=Instance.new("Frame");self.GoalFill.Size=UDim2.fromScale(0,1);self.GoalFill.BackgroundColor3=Theme.Accent;self.GoalFill.BorderSizePixel=0;self.GoalFill.Parent=track;round(self.GoalFill,5)
    self.CollectionPanel=modal(gui,"Collection",920,650);self.ItemPanel=modal(gui,"Item",760,500);self.GoalsPanel=modal(gui,"Goals",600,430);self.UpgradePanel=modal(gui,"Upgrades",500,420);self.DripPanel=modal(gui,"Drip",500,330);self.GiftsPanel=modal(gui,"Gifts",500,330);self.BoardPanel=modal(gui,"Board",650,500);self.SettingsPanel=modal(gui,"Settings",430,470);self.InspectPanel=modal(gui,"Inspect",460,300);self.Panels={self.CollectionPanel,self.ItemPanel,self.GoalsPanel,self.UpgradePanel,self.DripPanel,self.GiftsPanel,self.BoardPanel,self.SettingsPanel,self.InspectPanel};for _,p in ipairs(self.Panels)do closeButton(self,p)end
    text(self.CollectionPanel,"COLLECTION",UDim2.fromOffset(22,10),UDim2.fromOffset(220,40),Theme.Text,Enum.Font.GothamBlack,22);local mode=button(self.CollectionPanel,"INVENTORY / CATALOG",UDim2.fromOffset(24,56),UDim2.fromOffset(175,36));mode.MouseButton1Click:Connect(function()self.CollectionMode=self.CollectionMode=="Inventory"and"Catalog"or"Inventory";self:RenderCollection()end);self.CollectionCount=text(self.CollectionPanel,"0 shown",UDim2.fromOffset(210,58),UDim2.fromOffset(100,30),Theme.Muted)
    self.SearchBox=Instance.new("TextBox");self.SearchBox.PlaceholderText="Search collection...";self.SearchBox.ClearTextOnFocus=false;self.SearchBox.Position=UDim2.fromOffset(320,56);self.SearchBox.Size=UDim2.fromOffset(300,36);self.SearchBox.BackgroundColor3=Theme.Panel2;self.SearchBox.TextColor3=Theme.Text;self.SearchBox.PlaceholderColor3=Theme.Muted;self.SearchBox.Font=Enum.Font.GothamBold;self.SearchBox.TextSize=13;self.SearchBox.BorderSizePixel=0;self.SearchBox.Parent=self.CollectionPanel;round(self.SearchBox,9);self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()self:RenderCollection()end)
    local sort=button(self.CollectionPanel,"SORT",UDim2.fromOffset(630,56),UDim2.fromOffset(90,36));sort.MouseButton1Click:Connect(function()local v={"Rarity","Value","Newest","Name"};local i=table.find(v,self.Filters.Sort)or 1;self.Filters.Sort=v[i%#v+1];sort.Text=self.Filters.Sort;self:RenderCollection()end)
    local sell=button(self.CollectionPanel,"SELL COMMONS",UDim2.fromOffset(24,100),UDim2.fromOffset(140,34),Color3.fromRGB(91,230,144));sell.MouseButton1Click:Connect(function()self:ConfirmMassSell("commons","SELL COMMONS")end);local dup=button(self.CollectionPanel,"SELL DUPES",UDim2.fromOffset(174,100),UDim2.fromOffset(130,34),Color3.fromRGB(91,230,144));dup.MouseButton1Click:Connect(function()self:ConfirmMassSell("duplicates","SELL DUPLICATES")end);local safe=button(self.CollectionPanel,"SELL SAFE",UDim2.fromOffset(314,100),UDim2.fromOffset(120,34),Color3.fromRGB(255,171,81));safe.MouseButton1Click:Connect(function()self:ConfirmMassSell("safe","SELL SAFE")end)
    self.CollectionList=Instance.new("ScrollingFrame");self.CollectionList.Position=UDim2.fromOffset(18,145);self.CollectionList.Size=UDim2.new(1,-36,1,-165);self.CollectionList.BackgroundTransparency=1;self.CollectionList.BorderSizePixel=0;self.CollectionList.AutomaticCanvasSize=Enum.AutomaticSize.Y;self.CollectionList.CanvasSize=UDim2.new();self.CollectionList.ScrollBarThickness=6;self.CollectionList.Parent=self.CollectionPanel;local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(145,182);grid.CellPadding=UDim2.fromOffset(10,10);grid.Parent=self.CollectionList
    remotes.Toast.OnClientEvent:Connect(function(d)self:Toast(d)end);remotes.RareGlobal.OnClientEvent:Connect(function(d)self:ShowGlobal(d)end);remotes.OpenPanel.OnClientEvent:Connect(function(d)if d.Panel=="ShowcasePicker"then self.ShowcasePickSlot=d.Slot;self:OpenCollection("Inventory")elseif d.Panel=="Upgrades"then self:OpenUpgrades()elseif d.Panel=="Sell"then self:OpenCollection("Inventory");task.delay(.1,function()self:ConfirmMassSell(d.Mode or"commons","SELL")end)end end)
    UserInputService.InputBegan:Connect(function(input,gp)if gp and input.KeyCode~=Enum.KeyCode.ButtonB then return end;if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then self:CloseTopPanel()end end)
    self:Fetch();if self.Snapshot and self.Snapshot.Profile then self:ApplyProfileSettings(self.Snapshot.Profile)end;self:UpdateHud()
end
return UIController

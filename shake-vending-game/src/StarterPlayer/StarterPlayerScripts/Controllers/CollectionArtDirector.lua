local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents=require(script.Parent.UIComponents)

local CollectionArtDirector={}
local CELL_SIZE=Vector2.new(166,208)
local CELL_PADDING=Vector2.new(12,12)
local OVERSCAN_ROWS=1

local function label(parent,value,pos,size,color,font,textSize)
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=value;t.TextColor3=color or Theme.Text;t.Font=font or Enum.Font.GothamBold;t.TextSize=textSize or 10;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t
end
local function compact(n)n=tonumber(n)or 0;if n>=1e9 then return string.format("%.1fB",n/1e9)elseif n>=1e6 then return string.format("%.1fM",n/1e6)elseif n>=1e3 then return string.format("%.1fK",n/1e3)end;return tostring(math.floor(n))end
local function clear(frame)for _,c in ipairs(frame:GetChildren())do if not(c:IsA("UIGridLayout")or c:IsA("UIListLayout")or c:IsA("UIPadding"))then c:Destroy()end end end
local function contains(t,value)for _,v in pairs(t or{})do if v==value then return true end end;return false end
local function isEquipped(profile,id)for _,v in pairs(profile.Equipped or{})do if v==id then return true end end;return false end
local function isShowcased(profile,id)return contains(profile.Showcase,id)end

local function viewport(parent,item)
    local vp=Instance.new("ViewportFrame");vp.Name="ProductPreview";vp.Size=UDim2.fromScale(1,1);vp.BackgroundTransparency=1;vp.Ambient=Color3.fromRGB(186,190,186);vp.LightColor=Color3.fromRGB(255,247,219);vp.LightDirection=Vector3.new(-1,-.7,-1);vp.Parent=parent
    local world=Instance.new("WorldModel");world.Parent=vp;local model=Factory.Create(item.BaseItemId,item.MutationId or"None")
    if model then Factory.PrepareForViewport(model);model.Parent=world;pcall(function()model:ScaleTo(.82)end)end
    local cam=Instance.new("Camera");cam.CFrame=CFrame.new(3.05,1.55,4.55)*CFrame.Angles(math.rad(-6),math.rad(32),0);cam.Focus=CFrame.new();cam.Parent=vp;vp.CurrentCamera=cam
end
local function chip(card,value,slot,color)
    local w=math.max(30,#value*5+12);local x=7+slot
    local sh=Instance.new("Frame");sh.Position=UDim2.new(1,-x-w+2,0,11);sh.Size=UDim2.fromOffset(w,17);sh.BackgroundColor3=Theme.Shadow;sh.BackgroundTransparency=.20;sh.BorderSizePixel=0;sh.ZIndex=7;sh.Parent=card
    local b=Instance.new("TextLabel");b.Position=UDim2.new(1,-x-w,0,9);b.Size=UDim2.fromOffset(w,17);b.BackgroundColor3=color;b.BorderSizePixel=0;b.Text=value;b.TextColor3=Theme.ButtonText;b.Font=Enum.Font.GothamBlack;b.TextSize=8;b.ZIndex=8;b.Parent=card;UIComponents.PixelBorder(b,Theme.Outline,2,10)
    return w+5
end
local function sortRows(ui,rows)
    table.sort(rows,function(a,b)
        if ui.Filters.Sort=="Value"then return(a.Value or 0)>(b.Value or 0)
        elseif ui.Filters.Sort=="Odds"then return(a.OneIn or 1)>(b.OneIn or 1)
        elseif ui.Filters.Sort=="Name"then return(Items[a.BaseItemId].Name)<(Items[b.BaseItemId].Name)
        elseif ui.Filters.Sort=="Newest"then return(a.ObtainedAt or 0)>(b.ObtainedAt or 0)
        else local ar=Rarities.Get(a.Rarity).Rank;local br=Rarities.Get(b.Rarity).Rank;if ar==br then return(a.OneIn or 1)>(b.OneIn or 1)end;return ar>br end
    end)
end

local function renderCard(ui,profile,it,parent)
    local def=Items[it.BaseItemId];if not def then return nil end
    local rarity=Rarities.Get(it.Rarity);local discovered=it.Discovered~=false
    local card=Instance.new("TextButton");card.Name="ItemCard_"..it.BaseItemId;card.Text="";card.AutoButtonColor=false;card.Size=UDim2.fromScale(1,1);card.BackgroundColor3=Theme.Panel2;card.BorderSizePixel=0;card.Parent=parent;UIComponents.PixelBorder(card,Theme.Outline,3,6)
    local shadow=Instance.new("Frame");shadow.Name="PixelDepth";shadow.Position=UDim2.fromOffset(5,5);shadow.Size=UDim2.new(1,0,1,0);shadow.BackgroundColor3=Theme.Shadow;shadow.BackgroundTransparency=.26;shadow.BorderSizePixel=0;shadow.ZIndex=-1;shadow.Parent=card
    local rarityBand=Instance.new("Frame");rarityBand.Size=UDim2.new(1,-10,0,7);rarityBand.Position=UDim2.fromOffset(5,5);rarityBand.BackgroundColor3=rarity.Color;rarityBand.BorderSizePixel=0;rarityBand.Parent=card
    local notch=Instance.new("Frame");notch.Size=UDim2.fromOffset(14,7);notch.Position=UDim2.new(1,-19,0,5);notch.BackgroundColor3=Theme.Accent2;notch.BorderSizePixel=0;notch.Parent=card

    local preview=Instance.new("Frame");preview.Name="PreviewWell";preview.Position=UDim2.fromOffset(7,17);preview.Size=UDim2.new(1,-14,0,116);preview.BackgroundColor3=rarity.Color:Lerp(Theme.Panel2,.91);preview.BorderSizePixel=0;preview.Parent=card;UIComponents.PixelBorder(preview,rarity.Color,2,4)
    for i=0,4 do local px=Instance.new("Frame");px.Size=UDim2.fromOffset(3,3);px.Position=UDim2.fromOffset(7+i*7,7);px.BackgroundColor3=i%2==0 and rarity.Color or Theme.Outline;px.BackgroundTransparency=.22;px.BorderSizePixel=0;px.ZIndex=2;px.Parent=preview end
    if discovered then viewport(preview,it)else
        local q=label(preview,"?",UDim2.fromScale(.25,.08),UDim2.fromScale(.5,.65),rarity.Color,Enum.Font.GothamBlack,54);q.TextXAlignment=Enum.TextXAlignment.Center
        local hint=label(preview,"UNKNOWN PRODUCT",UDim2.new(0,8,1,-24),UDim2.new(1,-16,0,16),Theme.Muted,Enum.Font.GothamBlack,8);hint.TextXAlignment=Enum.TextXAlignment.Center
    end

    local slot=0
    if it.Catalog and not discovered then slot+=chip(card,contains(profile.HuntList,it.BaseItemId)and"TRACK"or"HUNT",slot,Theme.Accent)
    elseif not it.Catalog then
        if isShowcased(profile,it.InstanceId)then slot+=chip(card,"SHOW",slot,Theme.Accent2)end
        if isEquipped(profile,it.InstanceId)then slot+=chip(card,"EQ",slot,Theme.Accent)end
        if profile.Favorites and profile.Favorites[it.InstanceId]then slot+=chip(card,"★",slot,Color3.fromRGB(197,148,43))end
        if it.Locked then slot+=chip(card,"LOCK",slot,Color3.fromRGB(81,88,93))end
    end

    local name=label(card,discovered and def.Name or"UNDISCOVERED",UDim2.fromOffset(9,140),UDim2.new(1,-18,0,22),Theme.Text,Enum.Font.GothamBlack,10);name.TextTruncate=Enum.TextTruncate.AtEnd
    local stat=label(card,string.upper(it.Rarity).."   1/"..compact(it.OneIn),UDim2.fromOffset(9,163),UDim2.new(1,-18,0,17),rarity.Color,Enum.Font.GothamBlack,8);stat.TextTruncate=Enum.TextTruncate.AtEnd
    local footer=it.Catalog and(discovered and("CATALOG  •  "..string.upper(def.Machine))or("TRACK  •  "..string.upper(def.Machine)))or("$"..compact(it.Value).."  •  "..string.upper(it.ObtainedMachine or def.Machine))
    local f=label(card,footer,UDim2.fromOffset(9,184),UDim2.new(1,-18,0,16),Theme.Muted,Enum.Font.GothamBold,8);f.TextTruncate=Enum.TextTruncate.AtEnd
    if it.MutationId and it.MutationId~="None"then local mut=Instance.new("Frame");mut.Size=UDim2.new(1,-10,0,4);mut.Position=UDim2.new(0,5,1,-9);mut.BackgroundColor3=rarity.Color:Lerp(Theme.Accent2,.38);mut.BorderSizePixel=0;mut.Parent=card end

    local scale=Instance.new("UIScale");scale.Parent=card
    card.MouseEnter:Connect(function()TweenService:Create(scale,TweenInfo.new(.08,Enum.EasingStyle.Quad),{Scale=1.025}):Play();rarityBand.Size=UDim2.new(1,-10,0,10)end)
    card.MouseLeave:Connect(function()TweenService:Create(scale,TweenInfo.new(.09),{Scale=1}):Play();rarityBand.Size=UDim2.new(1,-10,0,7)end)
    card.MouseButton1Down:Connect(function()scale.Scale=.98 end);card.MouseButton1Up:Connect(function()scale.Scale=1.01 end)
    card.MouseButton1Click:Connect(function()
        if it.Catalog then ui.Events.HuntAction:FireServer(it.BaseItemId,true);task.delay(.18,function()ui:Fetch();ui:RenderCollection()end)
        else ui:ShowItem(it)end
    end)
    return card
end

local function getColumnCount(list)
    local width=list.AbsoluteSize.X
    if width<=0 then return 1 end
    return math.max(1,math.floor((width+CELL_PADDING.X)/(CELL_SIZE.X+CELL_PADDING.X)))
end

local function mountVisible(ui)
    local state=ui.CollectionVirtualState
    if not state or state.Generation~=ui.CollectionRenderGeneration then return end
    local list=ui.CollectionList
    local columns=getColumnCount(list)
    local stride=CELL_SIZE.Y+CELL_PADDING.Y
    local top=math.max(0,list.CanvasPosition.Y)
    local height=math.max(CELL_SIZE.Y,list.AbsoluteSize.Y)
    local firstRow=math.max(0,math.floor(top/stride)-OVERSCAN_ROWS)
    local lastRow=math.ceil((top+height)/stride)+OVERSCAN_ROWS
    local firstIndex=firstRow*columns+1
    local lastIndex=math.min(#state.Rows,(lastRow+1)*columns)
    for index,slot in ipairs(state.Slots)do
        local shouldMount=index>=firstIndex and index<=lastIndex
        local card=slot:FindFirstChild("MountedCard")
        if shouldMount and not card then
            local mounted=renderCard(ui,state.Profile,state.Rows[index],slot)
            if mounted then mounted.Name="MountedCard" end
        elseif not shouldMount and card then
            card:Destroy()
        end
    end
    state.FirstVisible=firstIndex
    state.LastVisible=lastIndex
end

local function scheduleMount(ui)
    local state=ui.CollectionVirtualState
    if not state or state.MountQueued then return end
    state.MountQueued=true
    task.defer(function()
        local current=ui.CollectionVirtualState
        if current~=state then return end
        current.MountQueued=false
        mountVisible(ui)
    end)
end

local function buildVirtualSlots(ui,profile,rows)
    ui.CollectionRenderGeneration=(ui.CollectionRenderGeneration or 0)+1
    local generation=ui.CollectionRenderGeneration
    clear(ui.CollectionList)
    local slots=table.create(#rows)
    for index=1,#rows do
        local slot=Instance.new("Frame")
        slot.Name="VirtualSlot"
        slot.BackgroundTransparency=1
        slot.BorderSizePixel=0
        slot.LayoutOrder=index
        slot.Size=UDim2.fromOffset(CELL_SIZE.X,CELL_SIZE.Y)
        slot.Parent=ui.CollectionList
        slots[index]=slot
    end
    ui.CollectionVirtualState={Rows=rows,Slots=slots,Profile=profile,Generation=generation,MountQueued=false,FirstVisible=0,LastVisible=0}
    ui.CollectionList.AutomaticCanvasSize=Enum.AutomaticSize.Y
    if not ui.CollectionVirtualConnections then
        ui.CollectionVirtualConnections={
            ui.CollectionList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()scheduleMount(ui)end),
            ui.CollectionList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()scheduleMount(ui)end),
        }
    end
    scheduleMount(ui)
end

local function addSortBar(ui)
    if ui.CollectionPanel:FindFirstChild("PixelCatalogSortBar")then return end
    for _,d in ipairs(ui.CollectionPanel:GetChildren())do if d:IsA("TextButton")and(d.Text=="SORT"or d.Text=="Rarity"or d.Text=="Odds"or d.Text=="Value"or d.Text=="Newest"or d.Text=="Name")then d.Visible=false end end
    local bar=Instance.new("Frame");bar.Name="PixelCatalogSortBar";bar.Position=UDim2.fromOffset(442,99);bar.Size=UDim2.fromOffset(456,36);bar.BackgroundTransparency=1;bar.Parent=ui.CollectionPanel
    local modes={"Rarity","Odds","Value","Newest","Name"}
    for i,mode in ipairs(modes)do
        local b=UIComponents.Button(bar,string.upper(mode),UDim2.fromOffset(84,32),UDim2.fromOffset((i-1)*91,1),mode=="Odds"and Theme.Accent2 or Theme.Accent);b.TextSize=9
        b.MouseButton1Click:Connect(function()ui.Filters.Sort=mode;ui:RenderCollection()end)
    end
    for _,d in ipairs(ui.CollectionPanel:GetChildren())do if d:IsA("TextButton")and(d.Text=="SELL COMMONS"or d.Text=="SELL DUPES"or d.Text=="SELL SAFE")then d.Parent.Position=UDim2.new(d.Parent.Position.X.Scale,d.Parent.Position.X.Offset,0,141)end end
    ui.CollectionList.Position=UDim2.fromOffset(18,184);ui.CollectionList.Size=UDim2.new(1,-36,1,-204)
    local grid=ui.CollectionList:FindFirstChildOfClass("UIGridLayout");if grid then grid.CellSize=UDim2.fromOffset(CELL_SIZE.X,CELL_SIZE.Y);grid.CellPadding=UDim2.fromOffset(CELL_PADDING.X,CELL_PADDING.Y);grid.SortOrder=Enum.SortOrder.LayoutOrder end
end

function CollectionArtDirector:Apply(ui)
    if not ui or not ui.CollectionPanel or ui.CollectionPanel:GetAttribute("PixelCollectionDirected")then return end
    ui.CollectionPanel:SetAttribute("PixelCollectionDirected",true);addSortBar(ui)
    ui.RenderCollection=function(self)
        local profile=self.Snapshot and self.Snapshot.Profile;if not profile then return end
        local q=(self.SearchBox.Text or""):lower();local rows={}
        if self.CollectionMode=="Catalog"then
            for id,d in pairs(Items)do if type(d)=="table"and d.Id and(q==""or d.Name:lower():find(q,1,true))then table.insert(rows,{BaseItemId=id,MutationId="None",Rarity=d.Rarity,OneIn=d.BaseOneIn or 1,Value=d.BaseValue or 0,Catalog=true,Discovered=profile.BaseCollection[id]==true})end end
        else
            for _,it in ipairs(profile.Inventory or{})do local d=Items[it.BaseItemId];local hay=((d and d.Name or it.BaseItemId).." "..tostring(it.Rarity).." "..tostring(it.MutationId).." "..tostring(it.ObtainedMachine or"")):lower();if q==""or hay:find(q,1,true)then table.insert(rows,it)end end
        end
        sortRows(self,rows);self.CollectionCount.Text=string.format("%d SHOWN  •  %s",#rows,string.upper(self.Filters.Sort));buildVirtualSlots(self,profile,rows)
    end
end
return CollectionArtDirector

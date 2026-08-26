local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Shared.ItemDefinitions)
local Rarities=require(ReplicatedStorage.Shared.RarityDefinitions)
local Factory=require(ReplicatedStorage.Shared.ItemVisualFactory)
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents=require(script.Parent.UIComponents)
local CollectionArtDirector={}

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,color,thick,trans)local s=Instance.new("UIStroke");s.Color=color or Theme.Outline;s.Thickness=thick or 1.5;s.Transparency=trans or .15;s.Parent=o;return s end
local function label(parent,value,pos,size,color,font,textSize)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=value;t.TextColor3=color or Theme.Text;t.Font=font or Enum.Font.GothamBold;t.TextSize=textSize or 11;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t
end
local function compact(n)n=tonumber(n)or 0;if n>=1e9 then return string.format("%.1fB",n/1e9)elseif n>=1e6 then return string.format("%.1fM",n/1e6)elseif n>=1e3 then return string.format("%.1fK",n/1e3)end;return tostring(math.floor(n))end
local function clear(frame)for _,c in ipairs(frame:GetChildren())do if not(c:IsA("UIGridLayout")or c:IsA("UIListLayout")or c:IsA("UIPadding"))then c:Destroy()end end end
local function viewport(parent,item)
 local vp=Instance.new("ViewportFrame");vp.Name="ProductPreview";vp.Size=UDim2.fromScale(1,1);vp.BackgroundTransparency=1;vp.Ambient=Color3.fromRGB(205,207,200);vp.LightColor=Color3.fromRGB(255,248,226);vp.LightDirection=Vector3.new(-1,-.7,-1);vp.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=vp;local model=Factory.Create(item.BaseItemId,item.MutationId or"None")
 if model then Factory.PrepareForViewport(model);model.Parent=world;pcall(function()model:ScaleTo(.82)end)end
 local cam=Instance.new("Camera");cam.CFrame=CFrame.new(3.1,1.65,4.7)*CFrame.Angles(math.rad(-6),math.rad(32),0);cam.Focus=CFrame.new();cam.Parent=vp;vp.CurrentCamera=cam
end
local function contains(t,value)for _,v in pairs(t or{})do if v==value then return true end end;return false end
local function chip(card,value,x,color)
 local width=math.max(30,#value*5.8+13);local b=Instance.new("TextLabel");b.AnchorPoint=Vector2.new(1,0);b.Position=UDim2.new(1,-7-x,0,9);b.Size=UDim2.fromOffset(width,18);b.BackgroundColor3=color;b.BorderSizePixel=0;b.Text=value;b.TextColor3=Color3.fromRGB(255,252,239);b.Font=Enum.Font.GothamBlack;b.TextSize=8;b.ZIndex=8;b.Parent=card;corner(b,6);return width+4
end
local function isEquipped(profile,id)for _,v in pairs(profile.Equipped or{})do if v==id then return true end end;return false end
local function isShowcased(profile,id)return contains(profile.Showcase,id)end

local function sortRows(ui,rows)
 table.sort(rows,function(a,b)
  if ui.Filters.Sort=="Value"then return(a.Value or 0)>(b.Value or 0)
  elseif ui.Filters.Sort=="Odds"then return(a.OneIn or 1)>(b.OneIn or 1)
  elseif ui.Filters.Sort=="Name"then return(Items[a.BaseItemId].Name)<(Items[b.BaseItemId].Name)
  elseif ui.Filters.Sort=="Newest"then return(a.ObtainedAt or 0)>(b.ObtainedAt or 0)
  else local ar=Rarities.Get(a.Rarity).Rank;local br=Rarities.Get(b.Rarity).Rank;if ar==br then return(a.OneIn or 1)>(b.OneIn or 1)end;return ar>br end
 end)
end
local function renderCard(ui,profile,it)
 local def=Items[it.BaseItemId];if not def then return end;local rarity=Rarities.Get(it.Rarity);local discovered=it.Discovered~=false
 local card=Instance.new("TextButton");card.Name="ItemCard_"..it.BaseItemId;card.Text="";card.AutoButtonColor=false;card.BackgroundColor3=Color3.fromRGB(255,250,235);card.BorderSizePixel=0;card.Parent=ui.CollectionList;corner(card,13);local outline=stroke(card,rarity.Color,2.4,.05)
 local shadow=Instance.new("Frame");shadow.Name="CardDepth";shadow.Size=UDim2.new(1,-8,1,-8);shadow.Position=UDim2.fromOffset(4,7);shadow.BackgroundColor3=Theme.Shadow;shadow.BackgroundTransparency=.82;shadow.BorderSizePixel=0;shadow.ZIndex=0;shadow.Parent=card;corner(shadow,12)
 local band=Instance.new("Frame");band.Size=UDim2.new(1,-10,0,7);band.Position=UDim2.fromOffset(5,5);band.BackgroundColor3=rarity.Color;band.BorderSizePixel=0;band.ZIndex=2;band.Parent=card;corner(band,4)
 local preview=Instance.new("Frame");preview.Name="PreviewWell";preview.Position=UDim2.fromOffset(7,15);preview.Size=UDim2.new(1,-14,0,116);preview.BackgroundColor3=rarity.Color:Lerp(Color3.fromRGB(255,250,235),.90);preview.BorderSizePixel=0;preview.ZIndex=1;preview.Parent=card;corner(preview,10);stroke(preview,rarity.Color,1,.72)
 if discovered then viewport(preview,it)else local q=label(preview,"?",UDim2.fromScale(.25,.05),UDim2.fromScale(.5,.8),rarity.Color,Enum.Font.GothamBlack,58);q.TextXAlignment=Enum.TextXAlignment.Center;local hint=label(preview,"UNKNOWN PRODUCT",UDim2.new(0,8,1,-25),UDim2.new(1,-16,0,18),Theme.Muted,Enum.Font.GothamBlack,8);hint.TextXAlignment=Enum.TextXAlignment.Center end
 local x=0
 if it.Catalog then if not discovered then x+=chip(card,contains(profile.HuntList,it.BaseItemId)and"TRACKING"or"HUNT",x,Theme.Accent)end
 else
  if isShowcased(profile,it.InstanceId)then x+=chip(card,"SHOW",x,Theme.Accent2)end
  if isEquipped(profile,it.InstanceId)then x+=chip(card,"EQ",x,Theme.Accent)end
  if profile.Favorites and profile.Favorites[it.InstanceId]then x+=chip(card,"★",x,Color3.fromRGB(209,157,46))end
  if it.Locked then x+=chip(card,"LOCK",x,Color3.fromRGB(86,94,103))end
 end
 if it.MutationId and it.MutationId~="None"then chip(card,string.upper(it.MutationId),0,rarity.Color:Lerp(Color3.fromRGB(31,49,70),.35))end
 local name=label(card,discovered and def.Name or"UNDISCOVERED",UDim2.fromOffset(9,137),UDim2.new(1,-18,0,23),Theme.Text,Enum.Font.GothamBlack,10);name.TextTruncate=Enum.TextTruncate.AtEnd
 label(card,string.upper(it.Rarity).."  •  1/"..compact(it.OneIn),UDim2.fromOffset(9,159),UDim2.new(1,-18,0,17),rarity.Color,Enum.Font.GothamBlack,8)
 local footer=it.Catalog and(discovered and("CATALOG • "..string.upper(def.Machine))or("TRACK • "..string.upper(def.Machine)))or("$"..compact(it.Value).." • "..string.upper(it.ObtainedMachine or def.Machine))
 local f=label(card,footer,UDim2.fromOffset(9,180),UDim2.new(1,-18,0,16),Theme.Muted,Enum.Font.GothamBold,8);f.TextTruncate=Enum.TextTruncate.AtEnd
 local scale=Instance.new("UIScale");scale.Parent=card
 card.MouseEnter:Connect(function()TweenService:Create(scale,TweenInfo.new(.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.035}):Play();outline.Thickness=3.2;outline.Transparency=0 end)
 card.MouseLeave:Connect(function()TweenService:Create(scale,TweenInfo.new(.12),{Scale=1}):Play();outline.Thickness=2.4;outline.Transparency=.05 end)
 card.MouseButton1Down:Connect(function()TweenService:Create(scale,TweenInfo.new(.05),{Scale=.97}):Play()end)
 card.MouseButton1Up:Connect(function()TweenService:Create(scale,TweenInfo.new(.08,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.02}):Play()end)
 card.MouseButton1Click:Connect(function()if it.Catalog then ui.Events.HuntAction:FireServer(it.BaseItemId,true);task.delay(.18,function()ui:Fetch();ui:RenderCollection()end)else ui:ShowItem(it)end end)
end

local function addSortBar(ui)
 if ui.CollectionPanel:FindFirstChild("CatalogSortBar")then return end
 local oldSort
 for _,d in ipairs(ui.CollectionPanel:GetChildren())do if d:IsA("TextButton")and(d.Text=="SORT"or d.Text=="Rarity"or d.Text=="Odds"or d.Text=="Value"or d.Text=="Newest"or d.Text=="Name")then oldSort=d;break end end
 if oldSort then oldSort.Visible=false end
 local bar=Instance.new("Frame");bar.Name="CatalogSortBar";bar.Position=UDim2.fromOffset(455,98);bar.Size=UDim2.fromOffset(440,36);bar.BackgroundTransparency=1;bar.Parent=ui.CollectionPanel
 local modes={"Rarity","Odds","Value","Newest","Name"};for i,mode in ipairs(modes)do local b=UIComponents.Button(bar,string.upper(mode),UDim2.fromOffset(82,32),UDim2.fromOffset((i-1)*88,2),mode=="Odds"and Theme.Accent2 or Theme.Button);b.TextSize=10;b.MouseButton1Click:Connect(function()ui.Filters.Sort=mode;ui:RenderCollection()end)end
 for _,d in ipairs(ui.CollectionPanel:GetChildren())do if d:IsA("TextButton")and(d.Text=="SELL COMMONS"or d.Text=="SELL DUPES"or d.Text=="SELL SAFE")then d.Position=UDim2.new(d.Position.X.Scale,d.Position.X.Offset,0,140)end end
 ui.CollectionList.Position=UDim2.fromOffset(18,184);ui.CollectionList.Size=UDim2.new(1,-36,1,-204)
 local grid=ui.CollectionList:FindFirstChildOfClass("UIGridLayout");if grid then grid.CellSize=UDim2.fromOffset(164,204);grid.CellPadding=UDim2.fromOffset(11,11)end
end

function CollectionArtDirector:Apply(ui)
 if not ui or not ui.CollectionPanel or ui.CollectionPanel:GetAttribute("CollectionArtDirected")then return end;ui.CollectionPanel:SetAttribute("CollectionArtDirected",true);addSortBar(ui)
 ui.RenderCollection=function(self)
  local profile=self.Snapshot and self.Snapshot.Profile;if not profile then return end;clear(self.CollectionList);local q=(self.SearchBox.Text or""):lower();local rows={}
  if self.CollectionMode=="Catalog"then for id,d in pairs(Items)do if type(d)=="table"and d.Id and(q==""or d.Name:lower():find(q,1,true))then table.insert(rows,{BaseItemId=id,MutationId="None",Rarity=d.Rarity,OneIn=d.BaseOneIn or 1,Value=d.BaseValue or 0,Catalog=true,Discovered=profile.BaseCollection[id]==true})end end
  else for _,it in ipairs(profile.Inventory or{})do local d=Items[it.BaseItemId];local hay=((d and d.Name or it.BaseItemId).." "..tostring(it.Rarity).." "..tostring(it.MutationId).." "..tostring(it.ObtainedMachine or"")):lower();if q==""or hay:find(q,1,true)then table.insert(rows,it)end end end
  sortRows(self,rows);self.CollectionCount.Text=string.format("%d SHOWN • %s",#rows,string.upper(self.Filters.Sort));for _,it in ipairs(rows)do renderCard(self,profile,it)end
 end
end
return CollectionArtDirector

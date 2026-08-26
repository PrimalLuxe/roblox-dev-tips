local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local HudArtDirector={}
local function corner(o,r)local c=o:FindFirstChildOfClass("UICorner")or Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=o end
local function stroke(o,color,thick,trans)local s=o:FindFirstChildOfClass("UIStroke")or Instance.new("UIStroke");s.Color=color or Theme.Outline;s.Thickness=thick or 1.5;s.Transparency=trans or .2;s.Parent=o;return s end
local function label(parent,value,pos,size,color,font,textSize)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=value;t.TextColor3=color;t.Font=font or Enum.Font.GothamBold;t.TextSize=textSize or 11;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t end
local function pulseOnChange(t)local scale=Instance.new("UIScale");scale.Parent=t;t:GetPropertyChangedSignal("Text"):Connect(function()scale.Scale=.96;TweenService:Create(scale,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.07}):Play();task.delay(.18,function()if scale.Parent then TweenService:Create(scale,TweenInfo.new(.12),{Scale=1}):Play()end end)end)end
local function segment(top,x,w,title,value,accent)
 local card=Instance.new("Frame");card.Name=title.."Segment";card.Position=UDim2.fromOffset(x,7);card.Size=UDim2.fromOffset(w,54);card.BackgroundColor3=Color3.fromRGB(255,252,242);card.BorderSizePixel=0;card.Parent=top;corner(card,11);stroke(card,Theme.Outline,1,.68)
 local bar=Instance.new("Frame");bar.Size=UDim2.new(0,5,1,-12);bar.Position=UDim2.fromOffset(6,6);bar.BackgroundColor3=accent;bar.BorderSizePixel=0;bar.Parent=card;corner(bar,3);label(card,title,UDim2.fromOffset(18,5),UDim2.new(1,-24,0,15),Theme.Muted,Enum.Font.GothamBold,9)
 value.Parent=card;value.Position=UDim2.fromOffset(18,18);value.Size=UDim2.new(1,-24,0,30);value.TextXAlignment=Enum.TextXAlignment.Left;value.TextColor3=Theme.Text;value.TextSize=15;pulseOnChange(value)
end
local function styleNav(gui)
 local wanted={COLLECTION=true,GOALS=true,UPGRADES=true,DRIP=true,GIFTS=true,GLOBAL=true,SETTINGS=true};local buttons={}
 for _,d in ipairs(gui:GetDescendants())do if d:IsA("TextButton")and wanted[d.Text]then table.insert(buttons,d)end end;if #buttons==0 then return end
 table.sort(buttons,function(a,b)return a.AbsolutePosition.Y<b.AbsolutePosition.Y end);local parent=buttons[1].Parent;parent.Size=UDim2.fromOffset(172,408)
 local rail=Instance.new("Frame");rail.Name="RetailNavRail";rail.Position=UDim2.fromOffset(-6,-40);rail.Size=UDim2.fromOffset(170,430);rail.BackgroundColor3=Color3.fromRGB(255,248,226);rail.BorderSizePixel=0;rail.ZIndex=0;rail.Parent=parent;corner(rail,16);stroke(rail,Theme.Outline,2,.35)
 local tape=Instance.new("Frame");tape.Size=UDim2.new(1,-12,0,7);tape.Position=UDim2.fromOffset(6,6);tape.BackgroundColor3=Theme.Accent2;tape.BorderSizePixel=0;tape.Parent=rail;corner(tape,4);label(rail,"VENDING MENU",UDim2.fromOffset(14,15),UDim2.new(1,-28,0,24),Theme.Text,Enum.Font.GothamBlack,12)
 local numbers={"01","02","03","04","05","06","07"};for i,b in ipairs(buttons)do b.Position=UDim2.fromOffset(5,(i-1)*50);b.Size=UDim2.fromOffset(152,44);b.TextXAlignment=Enum.TextXAlignment.Left;b.Text="    "..b.Text;local tag=label(b,numbers[i],UDim2.fromOffset(9,0),UDim2.fromOffset(28,44),Color3.fromRGB(255,222,116),Enum.Font.GothamBlack,9);tag.ZIndex=b.ZIndex+1;local stripe=Instance.new("Frame");stripe.Name="NavStripe";stripe.Position=UDim2.fromOffset(0,7);stripe.Size=UDim2.fromOffset(4,30);stripe.BackgroundColor3=i==1 and Theme.Accent2 or Theme.Accent;stripe.BorderSizePixel=0;stripe.Parent=b;corner(stripe,2)end
end
local function stylePanels(ui)
 for _,panel in ipairs(ui.Panels or{})do panel.BackgroundColor3=Color3.fromRGB(255,248,226);corner(panel,18);stroke(panel,Theme.Outline,2,.25);local grad=Instance.new("UIGradient");grad.Name="RetailPanelGradient";grad.Color=ColorSequence.new(Color3.fromRGB(255,252,242),Color3.fromRGB(239,231,204));grad.Rotation=90;grad.Parent=panel;local strip=Instance.new("Frame");strip.Name="RetailHeaderStrip";strip.Size=UDim2.new(1,-24,0,7);strip.Position=UDim2.fromOffset(12,8);strip.BackgroundColor3=Theme.Accent2;strip.BorderSizePixel=0;strip.Parent=panel;corner(strip,4)end
end
function HudArtDirector:Apply(ui)
 if not ui or not ui.Gui or ui.Gui:FindFirstChild("HudArtDirected")then return end;local marker=Instance.new("Folder");marker.Name="HudArtDirected";marker.Parent=ui.Gui
 local top=ui.Coins and ui.Coins.Parent;if top then top.Size=UDim2.fromOffset(700,70);top.BackgroundColor3=Color3.fromRGB(244,235,207);corner(top,16);stroke(top,Theme.Outline,2,.28);for _,v in ipairs({ui.Coins,ui.Shards,ui.Inventory,ui.Catalog})do if v then v.Parent=nil end end;segment(top,8,162,"COINS",ui.Coins,Color3.fromRGB(66,166,102));segment(top,178,144,"STYLE",ui.Shards,Color3.fromRGB(157,103,210));segment(top,330,170,"BAG",ui.Inventory,Theme.Accent);segment(top,508,184,"CATALOG",ui.Catalog,Theme.Accent2)end
 styleNav(ui.Gui);stylePanels(ui);local goal=ui.GoalText and ui.GoalText.Parent;if goal then goal.Size=UDim2.fromOffset(660,62);goal.BackgroundColor3=Color3.fromRGB(255,248,226);corner(goal,15);stroke(goal,Theme.Outline,2,.35);label(goal,"NEXT OBJECTIVE",UDim2.fromOffset(14,5),UDim2.fromOffset(120,14),Theme.Muted,Enum.Font.GothamBlack,9);ui.GoalText.Position=UDim2.fromOffset(12,16);ui.GoalText.Size=UDim2.new(1,-24,0,26)end
end
return HudArtDirector

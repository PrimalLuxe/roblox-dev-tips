local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents=require(script.Parent.UIComponents)

local HudArtDirector={}

local function removeRounded(root)
    for _,d in ipairs(root:GetDescendants())do if d:IsA("UICorner")or d:IsA("UIGradient")then d:Destroy()end end
end
local function label(parent,value,pos,size,color,font,textSize)
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=value;t.TextColor3=color or Theme.Text;t.Font=font or Enum.Font.GothamBold;t.TextSize=textSize or 10;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t
end
local function pixelCard(parent,name,pos,size,accent)
    local sh=Instance.new("Frame");sh.Name=name.."Shadow";sh.Position=pos+UDim2.fromOffset(4,4);sh.Size=size;sh.BackgroundColor3=Theme.Shadow;sh.BackgroundTransparency=.28;sh.BorderSizePixel=0;sh.Parent=parent
    local f=Instance.new("Frame");f.Name=name;f.Position=pos;f.Size=size;f.BackgroundColor3=Theme.Panel;f.BorderSizePixel=0;f.Parent=parent;UIComponents.PixelBorder(f,Theme.Outline,3,f.ZIndex+2)
    local bar=Instance.new("Frame");bar.Size=UDim2.new(0,6,1,-12);bar.Position=UDim2.fromOffset(7,6);bar.BackgroundColor3=accent;bar.BorderSizePixel=0;bar.Parent=f
    return f
end
local function pulse(textObj)
    local scale=Instance.new("UIScale");scale.Parent=textObj
    textObj:GetPropertyChangedSignal("Text"):Connect(function()
        scale.Scale=1.08;TweenService:Create(scale,TweenInfo.new(.12,Enum.EasingStyle.Quad),{Scale=1}):Play()
    end)
end
local function counter(parent,x,w,title,value,accent)
    local card=pixelCard(parent,title.."Counter",UDim2.fromOffset(x,0),UDim2.fromOffset(w,50),accent)
    label(card,title,UDim2.fromOffset(20,5),UDim2.new(1,-26,0,13),Theme.Muted,Enum.Font.GothamBlack,8)
    value.Parent=card;value.Position=UDim2.fromOffset(20,17);value.Size=UDim2.new(1,-26,0,27);value.TextXAlignment=Enum.TextXAlignment.Left;value.TextColor3=Theme.Text;value.TextSize=14;value.Font=Enum.Font.GothamBlack;pulse(value)
    return card
end
local function styleNav(gui)
    local wanted={COLLECTION=true,GOALS=true,UPGRADES=true,DRIP=true,GIFTS=true,GLOBAL=true,SETTINGS=true}
    local buttons={}
    for _,d in ipairs(gui:GetDescendants())do if d:IsA("TextButton")and wanted[(d.Text or""):gsub("^%s+","")]then table.insert(buttons,d)end end
    if #buttons==0 then return end
    table.sort(buttons,function(a,b)return a.AbsolutePosition.Y<b.AbsolutePosition.Y end)
    local parent=buttons[1].Parent.Parent or buttons[1].Parent
    local rail=Instance.new("Frame");rail.Name="PixelNavRail";rail.Position=UDim2.fromOffset(16,92);rail.Size=UDim2.fromOffset(154,348);rail.BackgroundColor3=Theme.Panel;rail.BorderSizePixel=0;rail.Parent=gui;UIComponents.PixelBorder(rail,Theme.Outline,3,rail.ZIndex+2)
    local shadow=Instance.new("Frame");shadow.Name="NavShadow";shadow.Position=rail.Position+UDim2.fromOffset(5,5);shadow.Size=rail.Size;shadow.BackgroundColor3=Theme.Shadow;shadow.BackgroundTransparency=.28;shadow.BorderSizePixel=0;shadow.ZIndex=rail.ZIndex-1;shadow.Parent=gui
    local cap=Instance.new("Frame");cap.Size=UDim2.new(1,-12,0,7);cap.Position=UDim2.fromOffset(6,6);cap.BackgroundColor3=Theme.Accent;cap.BorderSizePixel=0;cap.Parent=rail
    label(rail,"VENDING MENU",UDim2.fromOffset(12,16),UDim2.new(1,-24,0,20),Theme.Text,Enum.Font.GothamBlack,10)
    for i,b in ipairs(buttons)do
        local holder=b.Parent
        holder.Parent=rail;holder.Position=UDim2.fromOffset(8,41+(i-1)*42);holder.Size=UDim2.fromOffset(138,36)
        b.Text=(string.format("%02d  ",i))..(b.Text:gsub("^%s+",""));b.TextXAlignment=Enum.TextXAlignment.Left;b.TextSize=10
        local accent=b:FindFirstChild("PixelAccent");if accent then accent.BackgroundColor3=i==1 and Theme.Accent2 or Theme.Accent end
    end
    if parent and parent:IsA("Frame")then parent.Visible=false end
end
local function stylePanels(ui)
    for _,panel in ipairs(ui.Panels or{})do
        panel.BackgroundColor3=Theme.Panel;panel.BorderSizePixel=0
        UIComponents.PixelBorder(panel,Theme.Outline,3,panel.ZIndex+2)
        local shadow=Instance.new("Frame");shadow.Name="ModalPixelShadow";shadow.AnchorPoint=panel.AnchorPoint;shadow.Position=panel.Position+UDim2.fromOffset(6,6);shadow.Size=panel.Size;shadow.BackgroundColor3=Theme.Shadow;shadow.BackgroundTransparency=.30;shadow.BorderSizePixel=0;shadow.ZIndex=panel.ZIndex-1;shadow.Parent=panel.Parent
        panel:GetPropertyChangedSignal("Visible"):Connect(function()shadow.Visible=panel.Visible end);shadow.Visible=panel.Visible
        local band=Instance.new("Frame");band.Name="PixelPanelBand";band.Size=UDim2.new(1,-16,0,7);band.Position=UDim2.fromOffset(8,8);band.BackgroundColor3=Theme.Accent2;band.BorderSizePixel=0;band.ZIndex=panel.ZIndex+3;band.Parent=panel
        for x=0,4 do local px=Instance.new("Frame");px.Size=UDim2.fromOffset(4,4);px.Position=UDim2.new(1,-22-x*6,0,18);px.BackgroundColor3=x%2==0 and Theme.Accent or Theme.Outline;px.BorderSizePixel=0;px.ZIndex=panel.ZIndex+3;px.Parent=panel end
    end
end
function HudArtDirector:Apply(ui)
    if not ui or not ui.Gui or ui.Gui:GetAttribute("PixelHudDirected")then return end
    ui.Gui:SetAttribute("PixelHudDirected",true);removeRounded(ui.Gui)

    local oldTop=ui.Coins and ui.Coins.Parent
    if oldTop then
        oldTop.BackgroundTransparency=1;oldTop.Position=UDim2.fromOffset(18,18);oldTop.Size=UDim2.fromOffset(620,50)
        for _,v in ipairs({ui.Coins,ui.Shards,ui.Inventory,ui.Catalog})do if v then v.Parent=nil end end
        counter(oldTop,0,146,"COINS",ui.Coins,Color3.fromRGB(66,160,99))
        counter(oldTop,154,132,"STYLE",ui.Shards,Color3.fromRGB(157,103,210))
        counter(oldTop,294,146,"BAG",ui.Inventory,Theme.Accent)
        counter(oldTop,448,168,"CATALOG",ui.Catalog,Theme.Accent2)
    end

    styleNav(ui.Gui);stylePanels(ui)
    local goal=ui.GoalText and ui.GoalText.Parent
    if goal then
        goal.AnchorPoint=Vector2.new(.5,1);goal.Position=UDim2.new(.5,0,1,-18);goal.Size=UDim2.fromOffset(560,58);goal.BackgroundColor3=Theme.Panel;goal.BorderSizePixel=0;removeRounded(goal);UIComponents.PixelBorder(goal,Theme.Outline,3,goal.ZIndex+2)
        local shadow=Instance.new("Frame");shadow.Name="ObjectiveShadow";shadow.AnchorPoint=goal.AnchorPoint;shadow.Position=goal.Position+UDim2.fromOffset(5,5);shadow.Size=goal.Size;shadow.BackgroundColor3=Theme.Shadow;shadow.BackgroundTransparency=.28;shadow.BorderSizePixel=0;shadow.ZIndex=goal.ZIndex-1;shadow.Parent=goal.Parent
        label(goal,"NEXT OBJECTIVE",UDim2.fromOffset(14,7),UDim2.fromOffset(110,12),Theme.Muted,Enum.Font.GothamBlack,8)
        ui.GoalText.Position=UDim2.fromOffset(14,18);ui.GoalText.Size=UDim2.new(1,-28,0,21);ui.GoalText.TextSize=11;ui.GoalText.TextXAlignment=Enum.TextXAlignment.Left
        local track=ui.GoalFill and ui.GoalFill.Parent;if track then track.Position=UDim2.fromOffset(14,43);track.Size=UDim2.new(1,-28,0,7);track.BackgroundColor3=Theme.Outline;removeRounded(track);ui.GoalFill.BackgroundColor3=Theme.Accent2;removeRounded(ui.GoalFill)end
    end
end
return HudArtDirector

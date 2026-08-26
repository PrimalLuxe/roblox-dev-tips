local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()

local UIComponents={}

local function pixelBorder(obj,color,thickness,z)
    thickness=thickness or 3;color=color or Theme.Outline
    local group=Instance.new("Folder");group.Name="PixelBorder";group.Parent=obj
    local function edge(name,size,pos)
        local f=Instance.new("Frame");f.Name=name;f.Size=size;f.Position=pos;f.BackgroundColor3=color;f.BorderSizePixel=0;f.ZIndex=z or(obj.ZIndex+2);f.Parent=obj;return f
    end
    edge("Top",UDim2.new(1,0,0,thickness),UDim2.new())
    edge("Bottom",UDim2.new(1,0,0,thickness),UDim2.new(0,0,1,-thickness))
    edge("Left",UDim2.new(0,thickness,1,0),UDim2.new())
    edge("Right",UDim2.new(0,thickness,1,0),UDim2.new(1,-thickness,0,0))
    local cut=math.max(2,thickness)
    for _,p in ipairs({{0,0},{1,-cut}})do
        local a=Instance.new("Frame");a.Size=UDim2.fromOffset(cut,cut);a.Position=UDim2.new(p[1],p[2],0,0);a.BackgroundColor3=obj.BackgroundColor3;a.BorderSizePixel=0;a.ZIndex=(z or obj.ZIndex+3);a.Parent=obj
        local b=a:Clone();b.Position=UDim2.new(p[1],p[2],1,-cut);b.Parent=obj
    end
    return group
end

local function pixelShadow(parent,size,pos,z)
    local sh=Instance.new("Frame");sh.Name="PixelShadow";sh.Size=size;sh.Position=(pos or UDim2.new())+UDim2.fromOffset(5,5);sh.BackgroundColor3=Theme.Shadow;sh.BackgroundTransparency=.28;sh.BorderSizePixel=0;sh.ZIndex=z or 0;sh.Parent=parent
    return sh
end

local function scanlines(obj,spacing,alpha)
    spacing=spacing or 7
    local folder=Instance.new("Folder");folder.Name="PixelScanlines";folder.Parent=obj
    for y=spacing,1200,spacing do
        local l=Instance.new("Frame");l.Size=UDim2.new(1,0,0,1);l.Position=UDim2.fromOffset(0,y);l.BackgroundColor3=Theme.Outline;l.BackgroundTransparency=alpha or .92;l.BorderSizePixel=0;l.ZIndex=obj.ZIndex+1;l.Parent=obj
        if y>obj.AbsoluteSize.Y+spacing and obj.AbsoluteSize.Y>0 then break end
    end
end

function UIComponents.Panel(parent,size,pos)
    local wrap=Instance.new("Frame");wrap.Name="PixelPanel";wrap.Size=size;wrap.Position=pos or UDim2.new();wrap.BackgroundTransparency=1;wrap.Parent=parent
    pixelShadow(wrap,UDim2.fromScale(1,1),UDim2.new(),wrap.ZIndex)
    local panel=Instance.new("Frame");panel.Name="Surface";panel.Size=UDim2.fromScale(1,1);panel.BackgroundColor3=Theme.Panel;panel.BorderSizePixel=0;panel.ZIndex=wrap.ZIndex+2;panel.Parent=wrap
    pixelBorder(panel,Theme.Outline,3,panel.ZIndex+2)
    local header=Instance.new("Frame");header.Name="PixelHeaderBand";header.Size=UDim2.new(1,-12,0,6);header.Position=UDim2.fromOffset(6,6);header.BackgroundColor3=Theme.Accent;header.BorderSizePixel=0;header.ZIndex=panel.ZIndex+3;header.Parent=panel
    local tick=Instance.new("Frame");tick.Name="HeaderTick";tick.Size=UDim2.fromOffset(18,6);tick.Position=UDim2.new(1,-24,0,6);tick.BackgroundColor3=Theme.Accent2;tick.BorderSizePixel=0;tick.ZIndex=header.ZIndex+1;tick.Parent=panel
    return wrap,panel
end

function UIComponents.Button(parent,textValue,size,pos,accent)
    accent=accent or Theme.Accent
    local holder=Instance.new("Frame");holder.Name="PixelButtonHolder";holder.Size=size;holder.Position=pos or UDim2.new();holder.BackgroundTransparency=1;holder.Parent=parent
    local shadow=pixelShadow(holder,UDim2.fromScale(1,1),UDim2.new(),holder.ZIndex)
    local b=Instance.new("TextButton");b.Name="Button";b.AutoButtonColor=false;b.Text=textValue;b.Size=UDim2.fromScale(1,1);b.BackgroundColor3=Theme.Button;b.TextColor3=Theme.ButtonText;b.Font=Enum.Font.GothamBlack;b.TextSize=13;b.BorderSizePixel=0;b.ZIndex=holder.ZIndex+3;b.Parent=holder
    pixelBorder(b,Theme.Outline,3,b.ZIndex+2)
    local edge=Instance.new("Frame");edge.Name="PixelAccent";edge.Size=UDim2.new(0,5,1,-10);edge.Position=UDim2.fromOffset(6,5);edge.BackgroundColor3=accent;edge.BorderSizePixel=0;edge.ZIndex=b.ZIndex+1;edge.Parent=b
    local top=Instance.new("Frame");top.Name="PixelHighlight";top.Size=UDim2.new(1,-22,0,2);top.Position=UDim2.fromOffset(11,5);top.BackgroundColor3=Color3.fromRGB(255,255,255);top.BackgroundTransparency=.72;top.BorderSizePixel=0;top.ZIndex=b.ZIndex+1;top.Parent=b
    local scale=Instance.new("UIScale");scale.Parent=holder
    local function tweenScale(v,t)TweenService:Create(scale,TweenInfo.new(t or .07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=v}):Play()end
    b.MouseEnter:Connect(function()b.BackgroundColor3=Theme.ButtonHover;edge.Size=UDim2.new(0,8,1,-10);tweenScale(1.018,.07)end)
    b.MouseLeave:Connect(function()b.BackgroundColor3=Theme.Button;edge.Size=UDim2.new(0,5,1,-10);tweenScale(1,.08)end)
    b.MouseButton1Down:Connect(function()holder.Position=(pos or UDim2.new())+UDim2.fromOffset(2,2);shadow.Position=UDim2.fromOffset(3,3);tweenScale(.985,.04)end)
    b.MouseButton1Up:Connect(function()holder.Position=pos or UDim2.new();shadow.Position=UDim2.fromOffset(5,5);tweenScale(1.006,.05)end)
    return b
end

function UIComponents.Badge(parent,textValue,accent,pos)
    local badge=Instance.new("TextLabel");badge.AutomaticSize=Enum.AutomaticSize.X;badge.Size=UDim2.fromOffset(0,22);badge.Position=pos or UDim2.new();badge.BackgroundColor3=accent or Theme.Accent;badge.TextColor3=Theme.ButtonText;badge.Text=textValue;badge.Font=Enum.Font.GothamBlack;badge.TextSize=9;badge.BorderSizePixel=0;badge.Parent=parent
    pixelBorder(badge,Theme.Outline,2,badge.ZIndex+2)
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.Parent=badge
    return badge
end

function UIComponents.Confirm(parent,title,body,confirmText,onConfirm)
    local cover=Instance.new("Frame");cover.Name="ConfirmationModal";cover.Size=UDim2.fromScale(1,1);cover.BackgroundColor3=Color3.fromRGB(11,18,24);cover.BackgroundTransparency=.24;cover.BorderSizePixel=0;cover.ZIndex=200;cover.Parent=parent
    local holder,box=UIComponents.Panel(cover,UDim2.fromOffset(500,254),UDim2.fromScale(.5,.5));holder.AnchorPoint=Vector2.new(.5,.5);holder.ZIndex=201;box.ZIndex=202
    local warning=Instance.new("Frame");warning.Size=UDim2.new(1,-30,0,8);warning.Position=UDim2.fromOffset(15,20);warning.BackgroundColor3=Theme.Accent2;warning.BorderSizePixel=0;warning.ZIndex=204;warning.Parent=box
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(24,36);t.Size=UDim2.new(1,-48,0,38);t.Text=title;t.Font=Enum.Font.GothamBlack;t.TextSize=20;t.TextColor3=Theme.Text;t.TextXAlignment=Enum.TextXAlignment.Left;t.ZIndex=204;t.Parent=box
    local d=t:Clone();d.Position=UDim2.fromOffset(24,80);d.Size=UDim2.new(1,-48,0,82);d.Text=body;d.TextWrapped=true;d.Font=Enum.Font.GothamMedium;d.TextSize=14;d.TextColor3=Theme.Muted;d.TextYAlignment=Enum.TextYAlignment.Top;d.Parent=box
    local cancel=UIComponents.Button(box,"CANCEL",UDim2.fromOffset(196,44),UDim2.new(0,24,1,-64),Theme.Muted);cancel.ZIndex=205
    local confirm=UIComponents.Button(box,confirmText or"CONFIRM",UDim2.fromOffset(230,44),UDim2.new(1,-254,1,-64),Color3.fromRGB(214,132,49));confirm.ZIndex=205
    local previous=GuiService.SelectedObject
    local function dismiss()if cover.Parent then cover:Destroy()end;GuiService.SelectedObject=previous end
    cancel.MouseButton1Click:Connect(dismiss);confirm.MouseButton1Click:Connect(function()dismiss();onConfirm()end)
    task.defer(function()if cover.Parent then GuiService.SelectedObject=cancel end end)
    return cover
end

UIComponents.PixelBorder=pixelBorder
UIComponents.PixelShadow=pixelShadow
UIComponents.Scanlines=scanlines
return UIComponents

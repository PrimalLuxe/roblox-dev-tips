local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents={}

local function round(obj,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or Theme.Radius or 12);c.Parent=obj;return c end
local function stroke(obj,color,trans,thickness)local s=Instance.new("UIStroke");s.Thickness=thickness or 1.5;s.Color=color or Theme.Outline;s.Transparency=trans or 0.18;s.Parent=obj;return s end
local function shadow(parent,size,pos,radius,z)
    local s=Instance.new("Frame");s.Name="PhysicalShadow";s.Size=size;s.Position=pos+UDim2.fromOffset(0,4);s.BackgroundColor3=Theme.Shadow;s.BackgroundTransparency=0.70;s.BorderSizePixel=0;s.ZIndex=(z or 1)-1;s.Parent=parent;round(s,radius);return s
end

function UIComponents.Card(parent,size,pos,z)
    shadow(parent,size,pos,Theme.Radius,z or 1)
    local card=Instance.new("Frame");card.Size=size;card.Position=pos;card.BackgroundColor3=Theme.Panel;card.BorderSizePixel=0;card.ZIndex=z or 1;card.Parent=parent;round(card,Theme.Radius);stroke(card,Theme.Outline,0.50,1)
    return card
end

function UIComponents.Button(parent,text,size,pos,accent)
    local base=accent or Theme.Button
    shadow(parent,size,pos or UDim2.new(),10,2)
    local b=Instance.new("TextButton");b.AutoButtonColor=false;b.Text=text;b.Size=size;b.Position=pos or UDim2.new();b.BackgroundColor3=base;b.TextColor3=Theme.TextOnDark;b.Font=Theme.Font;b.TextSize=15;b.TextStrokeTransparency=0.88;b.BorderSizePixel=0;b.ZIndex=2;b.Parent=parent;round(b,10)
    local outline=stroke(b,Theme.Outline,0.15,1.5)
    local top=Instance.new("Frame");top.Name="TopSheen";top.BackgroundColor3=Color3.new(1,1,1);top.BackgroundTransparency=0.88;top.BorderSizePixel=0;top.Size=UDim2.new(1,-8,0,2);top.Position=UDim2.fromOffset(4,3);top.ZIndex=b.ZIndex+1;top.Parent=b;round(top,2)
    local scale=Instance.new("UIScale");scale.Parent=b
    local function tweenScale(v,t)TweenService:Create(scale,TweenInfo.new(t or 0.09,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=v}):Play()end
    b.MouseEnter:Connect(function()
        tweenScale(1.035)
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=base:Lerp(Color3.new(1,1,1),0.10)}):Play()
        outline.Transparency=0.02
    end)
    b.MouseLeave:Connect(function()
        tweenScale(1)
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=base}):Play()
        outline.Transparency=0.15
    end)
    b.MouseButton1Down:Connect(function()tweenScale(0.94,0.05);b.BackgroundColor3=base:Lerp(Color3.new(0,0,0),0.12)end)
    b.MouseButton1Up:Connect(function()tweenScale(1.02,0.08);b.BackgroundColor3=base:Lerp(Color3.new(1,1,1),0.06)end)
    b.SelectionGained:Connect(function()outline.Thickness=3;outline.Transparency=0 end)
    b.SelectionLost:Connect(function()outline.Thickness=1.5;outline.Transparency=0.15 end)
    return b
end

function UIComponents.SectionLabel(parent,value,pos,size,accent)
    local chip=Instance.new("Frame");chip.Position=pos;chip.Size=size;chip.BackgroundColor3=accent or Theme.Accent2;chip.BorderSizePixel=0;chip.Parent=parent;round(chip,8);stroke(chip,Theme.Outline,0.50,1)
    local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Size=UDim2.new(1,-16,1,0);l.Position=UDim2.fromOffset(8,0);l.Text=value;l.TextColor3=Theme.Text;l.TextXAlignment=Enum.TextXAlignment.Left;l.Font=Theme.HeadingFont;l.TextSize=12;l.Parent=chip
    return chip
end

function UIComponents.Confirm(parent,title,body,confirmText,onConfirm)
    local cover=Instance.new("Frame");cover.Name="ConfirmationModal";cover.Size=UDim2.fromScale(1,1);cover.BackgroundColor3=Color3.fromRGB(20,32,44);cover.BackgroundTransparency=0.34;cover.ZIndex=200;cover.Parent=parent
    local box=UIComponents.Card(cover,UDim2.fromOffset(460,230),UDim2.new(0.5,-230,0.5,-115),201);box.ZIndex=201
    local band=Instance.new("Frame");band.Size=UDim2.new(1,0,0,8);band.BackgroundColor3=Theme.Accent2;band.BorderSizePixel=0;band.ZIndex=202;band.Parent=box;local bandCorner=Instance.new("UICorner");bandCorner.CornerRadius=UDim.new(0,Theme.Radius);bandCorner.Parent=band
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(24,24);t.Size=UDim2.new(1,-48,0,34);t.Text=title;t.Font=Theme.HeadingFont;t.TextSize=22;t.TextColor3=Theme.Text;t.TextXAlignment=Enum.TextXAlignment.Left;t.ZIndex=202;t.Parent=box
    local d=t:Clone();d.Position=UDim2.fromOffset(24,68);d.Size=UDim2.new(1,-48,0,76);d.Text=body;d.TextWrapped=true;d.Font=Enum.Font.GothamMedium;d.TextSize=15;d.TextColor3=Theme.Muted;d.TextYAlignment=Enum.TextYAlignment.Top;d.Parent=box
    local cancel=UIComponents.Button(box,"CANCEL",UDim2.fromOffset(180,44),UDim2.new(0,24,1,-64),Color3.fromRGB(112,123,132));cancel.ZIndex=203
    local confirm=UIComponents.Button(box,confirmText or "CONFIRM",UDim2.fromOffset(220,44),UDim2.new(1,-244,1,-64),Theme.Warning);confirm.ZIndex=203
    local previous=GuiService.SelectedObject
    local function dismiss()if cover.Parent then cover:Destroy()end;GuiService.SelectedObject=previous end
    cancel.MouseButton1Click:Connect(dismiss);confirm.MouseButton1Click:Connect(function()dismiss();onConfirm()end)
    task.defer(function()if cover.Parent then GuiService.SelectedObject=cancel end end)
    return cover
end

return UIComponents

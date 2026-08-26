local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
local Theme=require(ReplicatedStorage.Shared.UITheme).Get()
local UIComponents={}

local function round(obj,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=obj;return c end
local function stroke(obj,color,trans)local s=Instance.new("UIStroke");s.Thickness=1.4;s.Color=color or Theme.Accent;s.Transparency=trans or 0.28;s.Parent=obj;return s end

function UIComponents.Button(parent,text,size,pos,accent)
    local b=Instance.new("TextButton");b.AutoButtonColor=false;b.Text=text;b.Size=size;b.Position=pos or UDim2.new();b.BackgroundColor3=Theme.Button;b.TextColor3=Theme.Text;b.Font=Theme.Font;b.TextSize=15;b.BorderSizePixel=0;b.Parent=parent;round(b,10);stroke(b,accent)
    local scale=Instance.new("UIScale");scale.Parent=b
    local function to(v,t)TweenService:Create(scale,TweenInfo.new(t or 0.09,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=v}):Play()end
    b.MouseEnter:Connect(function()to(1.035)end);b.MouseLeave:Connect(function()to(1)end);b.MouseButton1Down:Connect(function()to(0.94,0.05)end);b.MouseButton1Up:Connect(function()to(1.02,0.08)end)
    return b
end

function UIComponents.Confirm(parent,title,body,confirmText,onConfirm)
    local cover=Instance.new("Frame");cover.Name="ConfirmationModal";cover.Size=UDim2.fromScale(1,1);cover.BackgroundColor3=Color3.new(0,0,0);cover.BackgroundTransparency=0.38;cover.ZIndex=200;cover.Parent=parent
    local box=Instance.new("Frame");box.AnchorPoint=Vector2.new(0.5,0.5);box.Position=UDim2.fromScale(0.5,0.5);box.Size=UDim2.fromOffset(460,230);box.BackgroundColor3=Theme.Panel;box.BorderSizePixel=0;box.ZIndex=201;box.Parent=cover;round(box,16);stroke(box,Theme.Accent,0.12)
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(24,20);t.Size=UDim2.new(1,-48,0,38);t.Text=title;t.Font=Enum.Font.GothamBlack;t.TextSize=22;t.TextColor3=Theme.Text;t.TextXAlignment=Enum.TextXAlignment.Left;t.ZIndex=202;t.Parent=box
    local d=t:Clone();d.Position=UDim2.fromOffset(24,68);d.Size=UDim2.new(1,-48,0,76);d.Text=body;d.TextWrapped=true;d.Font=Enum.Font.GothamMedium;d.TextSize=15;d.TextColor3=Theme.Muted;d.TextYAlignment=Enum.TextYAlignment.Top;d.Parent=box
    local cancel=UIComponents.Button(box,"CANCEL",UDim2.fromOffset(180,44),UDim2.new(0,24,1,-64),Theme.Muted);cancel.ZIndex=203
    local confirm=UIComponents.Button(box,confirmText or "CONFIRM",UDim2.fromOffset(220,44),UDim2.new(1,-244,1,-64),Color3.fromRGB(255,170,72));confirm.ZIndex=203
    local previous=GuiService.SelectedObject
    local function dismiss()if cover.Parent then cover:Destroy()end;GuiService.SelectedObject=previous end
    cancel.MouseButton1Click:Connect(dismiss);confirm.MouseButton1Click:Connect(function()dismiss();onConfirm()end)
    task.defer(function()if cover.Parent then GuiService.SelectedObject=cancel end end)
    return cover
end

return UIComponents

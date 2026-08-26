local Players=game:GetService("Players")
local GuiService=game:GetService("GuiService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local AccessibilityController={Connections={}}

local function disconnectAll(self)
    for _,connection in ipairs(self.Connections)do
        connection:Disconnect()
    end
    table.clear(self.Connections)
end

local function directFrames(gui)
    local frames={}
    for _,child in ipairs(gui:GetChildren())do
        if child:IsA("Frame")then table.insert(frames,child)end
    end
    return frames
end

local function findShell(gui,kind)
    for _,frame in ipairs(directFrames(gui))do
        if kind=="top" and frame.AnchorPoint==Vector2.new(.5,0) and frame.Position.Y.Scale==0 and frame.Position.Y.Offset>=0 and frame.Size.X.Offset>=600 and frame.Size.Y.Offset<=80 then
            return frame
        elseif kind=="side" and frame.BackgroundTransparency==1 and frame.Size.X.Offset>=140 and frame.Size.Y.Offset>=300 then
            return frame
        elseif kind=="goal" and frame.AnchorPoint==Vector2.new(.5,1) and frame.Position.Y.Scale==1 and frame.Size.X.Offset>=580 then
            return frame
        end
    end
end

local function navButtons(side)
    local buttons={}
    if not side then return buttons end
    for _,child in ipairs(side:GetChildren())do
        if child:IsA("Frame") and child:FindFirstChildWhichIsA("GuiButton",true)then
            table.insert(buttons,child)
        end
    end
    table.sort(buttons,function(a,b)
        if a.Position.Y.Offset==b.Position.Y.Offset then return a.Position.X.Offset<b.Position.X.Offset end
        return a.Position.Y.Offset<b.Position.Y.Offset
    end)
    return buttons
end

local function ensureSelectionImage()
    local existing=player.PlayerGui:FindFirstChild("ShakeSelectionImage")
    if existing then player.PlayerGui.SelectionImageObject=existing;return existing end
    local image=Instance.new("Frame")
    image.Name="ShakeSelectionImage"
    image.Size=UDim2.new(1,8,1,8)
    image.Position=UDim2.fromOffset(-4,-4)
    image.BackgroundTransparency=1
    image.BorderSizePixel=0
    local stroke=Instance.new("UIStroke")
    stroke.Name="FocusStroke"
    stroke.Color=Color3.fromRGB(255,208,71)
    stroke.Thickness=3
    stroke.Transparency=.05
    stroke.Parent=image
    image.Parent=player.PlayerGui
    player.PlayerGui.SelectionImageObject=image
    return image
end

local function makeSelectable(root)
    local order=1
    for _,desc in ipairs(root:GetDescendants())do
        if desc:IsA("GuiButton")then
            desc.Selectable=true
            desc.SelectionOrder=order
            order+=1
        elseif desc:IsA("TextBox")then
            desc.Selectable=true
            desc.SelectionOrder=order
            order+=1
        end
    end
end

local function setHudTextSize(top,mobile)
    if not top then return end
    for _,child in ipairs(top:GetChildren())do
        if child:IsA("TextLabel")then
            child.TextSize=mobile and math.max(12,math.min(child.TextSize,14)) or child:GetAttribute("DesktopTextSize") or child.TextSize
            if not child:GetAttribute("DesktopTextSize")then child:SetAttribute("DesktopTextSize",child.TextSize)end
        end
    end
end

function AccessibilityController:ApplyLayout()
    local gui=self.Gui
    if not gui or not gui.Parent then return end
    local camera=workspace.CurrentCamera
    local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
    local mobile=UserInputService.TouchEnabled and (viewport.X<900 or viewport.Y<620)
    local compact=viewport.X<760 or viewport.Y<560

    gui.IgnoreGuiInset=false
    gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    gui.ClipToDeviceSafeArea=true

    local top=self.Top or findShell(gui,"top")
    local side=self.Side or findShell(gui,"side")
    local goal=self.Goal or findShell(gui,"goal")
    self.Top,self.Side,self.Goal=top,side,goal

    if top then
        top.Name="TopHUD"
        if compact then
            top.Size=UDim2.new(1,-20,0,72)
            top.Position=UDim2.new(.5,0,0,8)
            local labels={}
            for _,child in ipairs(top:GetChildren())do if child:IsA("TextLabel")then table.insert(labels,child)end end
            table.sort(labels,function(a,b)return a.Position.X.Offset<b.Position.X.Offset end)
            for i,label in ipairs(labels)do
                local column=(i-1)%2
                local row=math.floor((i-1)/2)
                label.Position=UDim2.new(column*.5,10,row*.5,2)
                label.Size=UDim2.new(.5,-20,.5,-4)
                label.TextXAlignment=column==0 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
            end
        else
            top.Size=UDim2.fromOffset(650,52)
            top.Position=UDim2.new(.5,0,0,14)
        end
        setHudTextSize(top,compact)
    end

    local buttons=navButtons(side)
    if side then
        side.Name="PrimaryNavigation"
        if compact then
            local columns=math.min(4,math.max(1,#buttons))
            local rows=math.ceil(#buttons/columns)
            local height=rows*48+4
            side.AnchorPoint=Vector2.new(.5,1)
            side.Position=UDim2.new(.5,0,1,-8)
            side.Size=UDim2.new(1,-16,0,height)
            local gap=5
            for i,holder in ipairs(buttons)do
                local col=(i-1)%columns
                local row=math.floor((i-1)/columns)
                holder.Position=UDim2.new(col/columns,col==0 and 0 or gap/2,0,row*48)
                holder.Size=UDim2.new(1/columns,-gap,0,43)
            end
        else
            side.AnchorPoint=Vector2.new(0,0)
            side.Position=UDim2.new(0,12,.22,0)
            side.Size=UDim2.fromOffset(156,390)
            for i,holder in ipairs(buttons)do
                holder.Position=UDim2.fromOffset(0,(i-1)*50)
                holder.Size=UDim2.fromOffset(148,44)
            end
        end
    end

    if goal then
        goal.Name="ProgressionGoal"
        if compact then
            local navHeight=side and side.Size.Y.Offset or 100
            goal.Position=UDim2.new(.5,0,1,-(navHeight+18))
            goal.Size=UDim2.new(1,-20,0,48)
        else
            goal.Position=UDim2.new(.5,0,1,-16)
            goal.Size=UDim2.fromOffset(620,50)
        end
    end

    for _,panel in ipairs(self.UI.Panels or {})do
        local scale=panel:FindFirstChildWhichIsA("UIScale")
        if scale then
            local w=math.max(1,panel.Size.X.Offset)
            local h=math.max(1,panel.Size.Y.Offset)
            local xMargin=compact and 20 or 36
            local yMargin=compact and 24 or 48
            scale.Scale=math.clamp(math.min((viewport.X-xMargin)/w,(viewport.Y-yMargin)/h),.28,1)
        end
    end

    makeSelectable(gui)
end

function AccessibilityController:FocusVisiblePanel()
    if not UserInputService.GamepadEnabled then return end
    for i=#(self.UI.Panels or {}),1,-1 do
        local panel=self.UI.Panels[i]
        if panel.Visible then
            local button=panel:FindFirstChildWhichIsA("GuiButton",true)
            if button then GuiService.SelectedObject=button end
            return
        end
    end
end

function AccessibilityController:Init(ui)
    disconnectAll(self)
    self.UI=ui
    self.Gui=ui.Gui
    if not self.Gui then return end
    ensureSelectionImage()
    self:ApplyLayout()

    local function bindCamera(camera)
        if not camera then return end
        table.insert(self.Connections,camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()self:ApplyLayout()end))
    end
    bindCamera(workspace.CurrentCamera)
    table.insert(self.Connections,workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()bindCamera(workspace.CurrentCamera);self:ApplyLayout()end))
    table.insert(self.Connections,UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()self:ApplyLayout()end))
    table.insert(self.Connections,UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(function()if UserInputService.GamepadEnabled then self:FocusVisiblePanel()end end))
    table.insert(self.Connections,self.Gui.DescendantAdded:Connect(function(desc)
        if desc:IsA("GuiButton")or desc:IsA("TextBox")then desc.Selectable=true end
    end))
    table.insert(self.Connections,GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
        local profile=self.UI.Snapshot and self.UI.Snapshot.Profile
        if profile then self.UI:ApplyProfileSettings(profile)end
    end))
end

return AccessibilityController

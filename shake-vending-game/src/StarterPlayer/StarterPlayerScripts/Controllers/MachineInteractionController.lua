local RunService=game:GetService("RunService")
local MachineInteractionController={Audio=nil,Busy={}}

local function artRoot(machine)
    local shell=machine and machine:FindFirstChild("Shell")
    return shell and shell:FindFirstChild("OlympusKitbash")
end

local function products(art)
    local out={}
    if not art then return out end
    for _,child in ipairs(art:GetChildren())do
        if child:IsA("Model")and child.Name:sub(1,8)=="Product_"then table.insert(out,child)end
    end
    return out
end

local function setScreen(screen,value,color)
    if not screen then return end
    if color then screen.Color=color end
    local gui=screen:FindFirstChild("ArtLabel")
    local frame=gui and gui:FindFirstChildOfClass("Frame")
    local label=frame and frame:FindFirstChildOfClass("TextLabel")
    if label then label.Text=value end
end

local function pulseKey(key,on)
    if not key then return end
    key.Color=on and Color3.fromRGB(255,215,76)or Color3.fromRGB(232,234,229)
    key.Material=on and Enum.Material.Neon or Enum.Material.SmoothPlastic
end

local function easeOutBack(t)
    local c1=1.70158
    local c3=c1+1
    return 1+c3*(t-1)^3+c1*(t-1)^2
end

local function easeInOutSine(t)
    return -(math.cos(math.pi*t)-1)/2
end

local function overdriveStrength(payload)
    local combo=payload and tonumber(payload.ShakeCombo or payload.Combo or payload.Overdrive)or 0
    return math.clamp(combo/30,0,1)
end

function MachineInteractionController:Animate(machine,payload)
    if not machine or self.Busy[machine]then return end
    local art=artRoot(machine)
    local root=machine:FindFirstChild("Root")
    local shell=machine:FindFirstChild("Shell")
    if not art or not root or not shell then return end

    self.Busy[machine]=true
    local shellStart=shell:GetPivot()
    local rows=products(art)
    local productOffsets={}
    for _,m in ipairs(rows)do productOffsets[m]=shellStart:ToObjectSpace(m:GetPivot())end

    local screen=art:FindFirstChild("MachineScreen")
    local key=art:FindFirstChild("Key5")
    local tray=art:FindFirstChild("DispenseTray")
    local light=art:FindFirstChild("InteriorLight")
    local eventLight=art:FindFirstChild("EventLight")
    local trayOffset=tray and shellStart:ToObjectSpace(tray.CFrame)
    local lightColor=light and light.Color
    local eventColor=eventLight and eventLight.Color
    local screenColor=screen and screen.Color
    local strain=overdriveStrength(payload)

    local function restore()
        if shell.Parent then shell:PivotTo(shellStart)end
        for m,rel in pairs(productOffsets)do
            if m.Parent then m:PivotTo(shellStart*rel)end
        end
        if tray and tray.Parent and trayOffset then tray.CFrame=shellStart*trayOffset end
        if light and light.Parent and lightColor then light.Color=lightColor end
        if eventLight and eventLight.Parent and eventColor then eventLight.Color=eventColor end
        pulseKey(key,false)
        if screen and screen.Parent then
            screen.Color=screenColor or Color3.fromRGB(92,201,228)
            setScreen(screen,"READY\nSHAKE",screen.Color)
        end
        self.Busy[machine]=nil
    end

    local ok,err=xpcall(function()
        pulseKey(key,true)
        setScreen(screen,"SHAKE\nLOCKED",Color3.fromRGB(255,210,75))
        if eventLight then eventLight.Color=Color3.fromRGB(255,205,72)end
        if self.Audio then self.Audio:PlayMachine("Rattle",root,{Volume=.30+.10*strain,PlaybackSpeed=1.04+.05*strain})end

        -- Stage 1: fast input acknowledgement and slight forward compression.
        local t0=os.clock()
        local duration=.10
        while machine.Parent and os.clock()-t0<duration do
            local t=math.clamp((os.clock()-t0)/duration,0,1)
            local e=easeOutBack(t)
            local pitch=math.rad(-1.4-1.0*strain)*e
            local sink=(-.025-.025*strain)*e
            shell:PivotTo(shellStart*CFrame.new(0,sink,.025*e)*CFrame.Angles(pitch,0,0))
            RunService.RenderStepped:Wait()
        end

        -- Stage 2: constrained spring rattle. Magnitude rises with Overdrive but remains sub-stud.
        setScreen(screen,"SHAKING\n•••",Color3.fromRGB(255,210,75))
        t0=os.clock();duration=.38+.06*strain
        while machine.Parent and os.clock()-t0<duration do
            local t=math.clamp((os.clock()-t0)/duration,0,1)
            local decay=(1-t)^1.6
            local phase=t*math.pi*(12+5*strain)
            local lateral=math.sin(phase)*(.028+.035*strain)*decay
            local yaw=math.sin(phase*.83)*math.rad(.7+1.0*strain)*decay
            local pitch=math.rad(-1.4)*(1-t)+math.cos(phase*.57)*math.rad(.35+.35*strain)*decay
            local base=shellStart*CFrame.new(lateral,-.025*(1-t),.025*(1-t))*CFrame.Angles(pitch,yaw,0)
            shell:PivotTo(base)
            for i,m in ipairs(rows)do
                if m.Parent then
                    local rel=productOffsets[m]
                    local productPhase=phase+i*.81
                    local x=math.sin(productPhase)*(.045+.028*strain)*decay
                    local y=math.abs(math.cos(productPhase*.78))*(.035+.018*strain)*decay
                    local rz=math.sin(productPhase*1.11)*math.rad(2.0+1.0*strain)*decay
                    m:PivotTo(base*rel*CFrame.new(x,y,0)*CFrame.Angles(0,0,rz))
                end
            end
            if light then
                local flicker=.90+.10*math.abs(math.sin(phase*.36))
                light.Color=(lightColor or Color3.fromRGB(255,244,212)):Lerp(Color3.fromRGB(255,220,120),1-flicker)
            end
            RunService.RenderStepped:Wait()
        end

        -- Stage 3: settle and deliberately hold a short suspense beat.
        shell:PivotTo(shellStart)
        for m,rel in pairs(productOffsets)do if m.Parent then m:PivotTo(shellStart*rel)end end
        pulseKey(key,false)
        setScreen(screen,"VENDING...",Color3.fromRGB(112,221,236))
        if eventLight then eventLight.Color=Color3.fromRGB(112,221,236)end
        task.wait(.12+.03*strain)

        -- Stage 4: CLUNK and a tiny tray kick instead of another whole-machine shake.
        if self.Audio then self.Audio:PlayMachine("Clunk",root,{Volume=.54+.06*strain,PlaybackSpeed=.97-.02*strain})end
        setScreen(screen,"COLLECT!",Color3.fromRGB(105,225,145))
        if eventLight then eventLight.Color=Color3.fromRGB(105,225,145)end
        if tray and trayOffset then
            t0=os.clock();duration=.16
            while tray.Parent and os.clock()-t0<duration do
                local t=math.clamp((os.clock()-t0)/duration,0,1)
                local kick=math.sin(math.pi*t)*(.10+.035*strain)
                tray.CFrame=shellStart*trayOffset*CFrame.new(0,0,-kick)
                RunService.RenderStepped:Wait()
            end
            tray.CFrame=shellStart*trayOffset
        else
            task.wait(.16)
        end

        -- Stage 5: return to ready after the physical reveal has had time to become readable.
        task.wait(.08)
    end,debug.traceback)

    restore()
    if not ok then warn("[ShakeVM] Machine interaction animation failed: "..tostring(err))end
end

function MachineInteractionController:Init(events,audio)
    self.Audio=audio
    events.DropSpawned.OnClientEvent:Connect(function(payload)
        local folder=workspace:FindFirstChild("Machines")
        local machine=folder and payload and folder:FindFirstChild(payload.MachineId)
        if machine then task.spawn(function()self:Animate(machine,payload)end)end
    end)
end

return MachineInteractionController

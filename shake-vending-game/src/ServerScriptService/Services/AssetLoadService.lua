local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Manifest = require(ReplicatedStorage.Shared.AssetManifest)
local Config = require(ReplicatedStorage.Shared.Config)

local AssetLoadService = {
    Loaded = {},
    Failures = {},
}

local function sanitize(root)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("BaseScript") or d:IsA("ModuleScript") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction")
            or d:IsA("BindableEvent") or d:IsA("BindableFunction") or d:IsA("Tool") or d:IsA("Humanoid")
            or d:IsA("AnimationController") or d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
            d:Destroy()
        elseif d:IsA("Sound") then
            d:Destroy()
        elseif d:IsA("BodyMover") or d:IsA("JointInstance") then
            d:Destroy()
        elseif d:IsA("Constraint") then
            d:Destroy()
        elseif d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = false
            d.CanQuery = true
            d.Massless = true
        end
    end
end

local function unwrap(wrapper, key)
    local children = wrapper:GetChildren()
    if #children == 1 then
        local child = children[1]
        child.Parent = nil
        wrapper:Destroy()
        if child:IsA("BasePart") then
            local m = Instance.new("Model")
            child.Parent = m
            m.PrimaryPart = child
            child = m
        end
        child.Name = key
        return child
    end
    wrapper.Name = key
    return wrapper
end

local function ensurePrimary(model)
    if not model:IsA("Model") then return end
    if model.PrimaryPart then return end
    local best
    local bestVol = -1
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local vol = d.Size.X*d.Size.Y*d.Size.Z
            if vol > bestVol then best, bestVol = d, vol end
        end
    end
    model.PrimaryPart = best
end

function AssetLoadService:GetFolder()
    local assets = ReplicatedStorage:FindFirstChild("Assets") or Instance.new("Folder")
    assets.Name = "Assets"; assets.Parent = ReplicatedStorage
    local imported = assets:FindFirstChild("ImportedModels") or Instance.new("Folder")
    imported.Name = "ImportedModels"; imported.Parent = assets
    return imported
end

function AssetLoadService:LoadOne(key)
    if self.Loaded[key] then return self.Loaded[key] end
    local def = Manifest[key]
    if not def then return nil, "UnknownAsset" end
    local folder = self:GetFolder()
    local existing = folder:FindFirstChild(key)
    if existing then self.Loaded[key]=existing; return existing end

    local ok, loaded = pcall(AssetService.LoadAssetAsync, AssetService, def.Id)
    if not ok or not loaded then
        self.Failures[key] = tostring(loaded)
        warn("[Assets] Failed", key, def.Id, loaded)
        return nil, loaded
    end
    sanitize(loaded)
    local source = unwrap(loaded, key)
    ensurePrimary(source)
    source:SetAttribute("CreatorStoreAssetId", def.Id)
    source:SetAttribute("CreatorStoreRole", def.Role or "Unknown")
    source:SetAttribute("Sanitized", true)
    source.Parent = folder
    self.Loaded[key] = source
    return source
end

local function boundedLoad(service,keys,maxWorkers,timeoutSeconds)
    if #keys==0 then return 0 end
    local cursor,finished=1,0
    local workerCount=math.min(maxWorkers or 6,#keys)
    for _=1,workerCount do
        task.spawn(function()
            while true do
                local index=cursor
                cursor+=1
                local key=keys[index]
                if not key then break end
                service:LoadOne(key)
                finished+=1
            end
        end)
    end
    local deadline=os.clock()+(timeoutSeconds or Config.AssetLoadTimeoutSeconds)
    while finished<#keys and os.clock()<deadline do task.wait(0.05) end
    return finished
end

function AssetLoadService:Init()
    local folder = self:GetFolder()
    ReplicatedStorage:SetAttribute("ThirdPartyAssetsAllowed", nil)
    ReplicatedStorage:SetAttribute("CreatorAssetsReady", false)
    ReplicatedStorage:SetAttribute("CreatorAssetsError", nil)
    ReplicatedStorage:SetAttribute("WarmAssetsReady", false)

    local queues = {Critical={}, Warm={}, Background={}, Lazy={}}
    for key, def in pairs(Manifest) do
        if def.AutoLoad and not folder:FindFirstChild(key) then
            local phase = queues[def.LoadPhase] and def.LoadPhase or "Background"
            table.insert(queues[phase], key)
        end
    end
    for _, queue in pairs(queues) do table.sort(queue) end

    local criticalFinished = boundedLoad(self, queues.Critical, 6, math.min(Config.AssetLoadTimeoutSeconds, 20))

    local function hasAny(...)
        for _,key in ipairs({...}) do if folder:FindFirstChild(key) then return true end end
        return false
    end
    local missing={}
    if not hasAny("VendingMachineDetailed","VendingMachine","VendingMachineStudded","VendingMachineModern") then table.insert(missing,"VendingMachine") end
    if not hasAny("HubShop","LowPolyShop") then table.insert(missing,"HubShop") end
    if not hasAny("Podium") then table.insert(missing,"Podium") end
    if not hasAny("SimulatorUI") then table.insert(missing,"SimulatorUI") end
    local itemFamilies=0
    for _,key in ipairs({"SodaCan","WaterBottle","PotatoChips","Chocolate","StoreItemsPack","RobotToy"}) do
        if folder:FindFirstChild(key) then itemFamilies+=1 end
    end
    if itemFamilies<3 then table.insert(missing,"3+ item-model families") end

    local ready=#missing==0
    ReplicatedStorage:SetAttribute("CreatorAssetsReady",ready)
    ReplicatedStorage:SetAttribute("ThirdPartyAssetsAllowed", #folder:GetChildren()>0 and true or false)
    if ready then
        print(string.format("[ShakeVM] Critical Creator Store pack ready: %d sanitized assets (%d/%d attempts finished)",#folder:GetChildren(),criticalFinished,#queues.Critical))
    else
        local message="Creator Store visuals could not fully load: "..table.concat(missing,", ")..". In Studio enable Game Settings > Security > Allow Loading Third Party Assets, then restart Play."
        if criticalFinished<#queues.Critical then message..=" Core asset loading also hit the startup timeout." end
        ReplicatedStorage:SetAttribute("CreatorAssetsError",message)
        warn("[ShakeVM]",message)
        return false
    end

    local warmDone=boundedLoad(self,queues.Warm,4,math.min(Config.AssetLoadTimeoutSeconds,8))
    ReplicatedStorage:SetAttribute("WarmAssetsReady",warmDone>=#queues.Warm)
    if #queues.Warm>0 then print(string.format("[ShakeVM] Warm Creator Store donors: %d/%d attempts finished",warmDone,#queues.Warm)) end
    if #queues.Background>0 then
        task.spawn(function()
            task.wait(2)
            local done=boundedLoad(self,queues.Background,3,Config.AssetLoadTimeoutSeconds)
            print(string.format("[ShakeVM] Background Creator Store donors: %d/%d attempts finished",done,#queues.Background))
        end)
    end
    return true
end

return AssetLoadService

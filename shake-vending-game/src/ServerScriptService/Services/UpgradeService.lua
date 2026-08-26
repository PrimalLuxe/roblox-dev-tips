local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.Config)
local UpgradeService={}
function UpgradeService:GetCost(name,level)local rule=Config.UpgradeRules[name];if not rule then return nil end;return math.floor(rule.BaseCost*(rule.Growth^(math.max(1,level)-1)))end
function UpgradeService:Buy(player,name)if type(name)~="string" then return false,"InvalidUpgrade" end;local rule=Config.UpgradeRules[name];if not rule then return false,"InvalidUpgrade" end;local profile=self.DataService:GetProfile(player);if not profile then return false,"ProfileNotLoaded" end;local level=profile.Upgrades[name] or 1;if level>=rule.Max then return false,"MAX LEVEL" end;local cost=self:GetCost(name,level);if profile.Coins<cost then return false,"Need "..tostring(cost).." coins" end;profile.Coins-=cost;profile.Upgrades[name]=level+1;return true,name.." → Lv."..tostring(level+1) end
function UpgradeService:Init(RemoteService,DataService)self.DataService=DataService;RemoteService.Events.UpgradeAction.OnServerEvent:Connect(function(player,name)if not RemoteService:Allow(player,"upgrade",4,7) then return end;local ok,msg=self:Buy(player,name);RemoteService.Events.Toast:FireClient(player,{Text=msg,Kind=ok and "Success" or "Warn"})end)end
return UpgradeService

local HttpService=game:GetService("HttpService")
local Util={}
function Util.DeepCopy(value)if type(value)~="table" then return value end;local out={};for k,v in pairs(value) do out[Util.DeepCopy(k)]=Util.DeepCopy(v) end;return out end
function Util.Reconcile(target,template)for k,v in pairs(template) do if target[k]==nil then target[k]=Util.DeepCopy(v) elseif type(v)=="table" and type(target[k])=="table" then Util.Reconcile(target[k],v) end end;return target end
function Util.Guid()return HttpService:GenerateGUID(false)end
function Util.FindInventoryIndex(profile,instanceId)for i,item in ipairs(profile.Inventory) do if item.InstanceId==instanceId then return i,item end end;return nil,nil end
function Util.ArrayRemoveValue(t,value)for i=#t,1,-1 do if t[i]==value then table.remove(t,i) end end end
function Util.RemoveItemReferences(profile,instanceId)if not profile or not instanceId then return end;if profile.Favorites then profile.Favorites[instanceId]=nil end;if profile.Equipped then for slot,id in pairs(profile.Equipped) do if id==instanceId then profile.Equipped[slot]=nil end end end;if profile.Showcase then for i,id in pairs(profile.Showcase) do if id==instanceId then profile.Showcase[i]=nil end end end end
function Util.FormatInteger(n)local s=tostring(math.floor(tonumber(n) or 0));local sign="";if s:sub(1,1)=="-" then sign="-";s=s:sub(2) end;local out=s;while true do local replaced,count=out:gsub("^(%d+)(%d%d%d)","%1,%2");out=replaced;if count==0 then break end end;return sign..out end
return Util

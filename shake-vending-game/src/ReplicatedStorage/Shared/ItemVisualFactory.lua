local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(script.Parent.ItemDefinitions)
local Mutations = require(script.Parent.MutationDefinitions)
local Factory = {}

local fallbackDonors={
    Can={"SodaCan","SodaCanMesh","BloxyColaMesh"},Bottle={"WaterBottle","Bottle","DrinkBottle"},Bag={"PotatoChips","ChipsPack"},Bar={"Chocolate"},Box={"CookieStack","Chocolate","CandyPack"},Lollipop={"Lollipop","CandyPack"},Ball={"BubbleGumProp","SlimeBlob","CandyPack"},Capsule={"GachaMachinePack","CrownProp","RobotToy"},Robot={"RobotToy","RobotToyAlt","TinyRobot"},UFO={"RobotToyAlt","RobotToy"},Duck={"RubberDuck"},Plush={"BunnyPlush","RobotToy"},Cube={"DiceProp","QuestionMarkProp","CookieStack"},
}
local familyKeywords={
    Can={"can","cola","soda","drink"},Bottle={"bottle","water","drink"},Bag={"bag","chip","snack","pretzel"},Bar={"bar","chocolate"},Box={"box","cookie","candy","snack"},Lollipop={"lollipop","candy"},Ball={"bubble","gum","ball","slime","cotton","candy"},Capsule={"capsule","gacha","egg","prize","ball"},Robot={"robot","toy"},UFO={"ufo","ship","space"},Duck={"duck"},Plush={"plush","bunny","rabbit"},Cube={"dice","cube","question","box"},
}
local function importedFolder()local assets=ReplicatedStorage:FindFirstChild("Assets");return assets and assets:FindFirstChild("ImportedModels")end
local function prepare(model)
    local firstPart
    for _,d in ipairs(model:GetDescendants())do
        if d:IsA("BaseScript")or d:IsA("ModuleScript")or d:IsA("RemoteEvent")or d:IsA("RemoteFunction")or d:IsA("ClickDetector")or d:IsA("ProximityPrompt")or d:IsA("Tool")or d:IsA("Humanoid")or d:IsA("AnimationController")then d:Destroy()
        elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=true;d.Massless=true;firstPart=firstPart or d end
    end
    if model:IsA("Model")and not model.PrimaryPart then model.PrimaryPart=firstPart end;return firstPart
end
local function ensureModel(obj)if obj:IsA("Model")then return obj end;local m=Instance.new("Model");obj.Parent=m;if obj:IsA("BasePart")then m.PrimaryPart=obj end;return m end
local function textTokens(s)local out={};for token in s:lower():gmatch("[%w]+")do if #token>=3 then table.insert(out,token)end end;return out end
local function semanticCandidates(source)
    local out={};for _,d in ipairs(source:GetDescendants())do
        if d:IsA("Model")and d:FindFirstChildWhichIsA("BasePart",true)then table.insert(out,d)
        elseif d:IsA("BasePart")then local parentModel=d:FindFirstAncestorOfClass("Model");if not parentModel or parentModel==source then table.insert(out,d)end end
    end;return out
end
local function scoreCandidate(candidate,item)
    local name=candidate.Name:lower();local score=0
    for _,tok in ipairs(textTokens(item.Name))do if name:find(tok,1,true)then score+=14 end end
    for _,tok in ipairs(familyKeywords[item.VisualFamily]or{})do if name:find(tok,1,true)then score+=5 end end
    for _,bad in ipairs({"machine","shop","store","stand","floor","wall","script","button","sign"})do if name:find(bad,1,true)then score-=9 end end
    for _,bad in ipairs({"pack","assets","bundle","collection","set"})do if name:find(bad,1,true)then score-=18 end end
    local partCount=0;for _,d in ipairs(candidate:GetDescendants())do if d:IsA("BasePart")then partCount+=1 end end;if candidate:IsA("BasePart")then partCount=1 end
    if partCount>18 then score-=35 elseif partCount>10 then score-=8 end
    return score
end
local function extractFromPack(source,item)
    local best,bestScore=nil,0;for _,candidate in ipairs(semanticCandidates(source))do local score=scoreCandidate(candidate,item);if score>bestScore then best,bestScore=candidate,score end end
    if not best or bestScore<5 then return nil end;local clone=best:Clone();source:Destroy();return clone
end
local function findDonor(folder,item,skipExact)
    if not folder then return nil end;if not skipExact then local exact=folder:FindFirstChild(item.AssetKey);if exact then return exact end end
    for _,key in ipairs(fallbackDonors[item.VisualFamily]or{})do if key~=item.AssetKey or skipExact then local donor=folder:FindFirstChild(key);if donor then return donor end end end
    for _,key in ipairs({"SodaCan","WaterBottle","PotatoChips","Chocolate","RobotToy","CookieStack"})do local donor=folder:FindFirstChild(key);if donor then return donor end end
end
local function hasTexture(p)return(p:IsA("MeshPart")and p.TextureID~="")or p:FindFirstChildWhichIsA("SurfaceAppearance")~=nil end
local function restyleBase(model,item)
    for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then if p:IsA("Part")and p.Transparency<.65 then p.TopSurface=Enum.SurfaceType.Studs end;if not hasTexture(p)and p.Material~=Enum.Material.Metal and p.Material~=Enum.Material.Glass and p.Material~=Enum.Material.Neon then p.Color=item.Color:Lerp(p.Color,.20);p.Material=Enum.Material.Plastic end end end
end
local function applyMutation(model,mutationName)
    local mutation=Mutations[mutationName]or Mutations.None;for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then if mutation.Color then p.Color=p.Color:Lerp(mutation.Color,.66)end;if mutation.Material and not hasTexture(p)then p.Material=mutation.Material end end end;model:SetAttribute("MutationEffect",mutation.Effect)
end
local missingReported={};local function reportMissing(item)if missingReported[item.Id]then return end;missingReported[item.Id]=true;warn(string.format("[ShakeVM][Visuals] No sanitized Creator Store donor is available for %s (%s). Visual omitted; ownership/data remain intact.",item.Name,item.Id))end
function Factory.Create(baseItemId,mutationName)
    local item=Items[baseItemId];assert(item,"Unknown item "..tostring(baseItemId));local folder=importedFolder();local src=findDonor(folder,item,false);local model
    if src then
        model=ensureModel(src:Clone());prepare(model);local shouldExtract=(item.AssetKey=="StoreItemsPack"or item.AssetKey=="CandyPack"or item.AssetKey=="GachaMachinePack")
        if shouldExtract then local extracted=extractFromPack(model,item);if extracted then model=ensureModel(extracted)else model:Destroy();local fallback=findDonor(folder,item,true);model=fallback and ensureModel(fallback:Clone())or nil end end
        if model then prepare(model);restyleBase(model,item);pcall(function()local size=model:GetExtentsSize();local longest=math.max(size.X,size.Y,size.Z);if longest>0 then model:ScaleTo(model:GetScale()*(2.15/longest))end end)end
    end
    if not model then reportMissing(item);return nil end;model.Name=baseItemId.."_"..(mutationName or"None");model:SetAttribute("BaseItemId",baseItemId);model:SetAttribute("MutationId",mutationName or"None");applyMutation(model,mutationName or"None");return model
end
function Factory.CreateFallback(baseItemId,mutationName)return Factory.Create(baseItemId,mutationName)end
function Factory.PrepareForViewport(model)prepare(model);if model.PrimaryPart then model:PivotTo(CFrame.new())end end
return Factory

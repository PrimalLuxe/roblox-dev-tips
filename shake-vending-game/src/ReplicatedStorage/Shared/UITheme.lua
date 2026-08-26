local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UITheme = {}
local defaultTheme = {Panel=Color3.fromRGB(32,38,50),Panel2=Color3.fromRGB(43,51,66),Button=Color3.fromRGB(57,75,99),Accent=Color3.fromRGB(84,202,255),Accent2=Color3.fromRGB(255,207,79),Text=Color3.fromRGB(255,255,255),Muted=Color3.fromRGB(185,198,216),Radius=14,Font=Enum.Font.GothamBold}
local function luminance(c)return 0.2126*c.R+0.7152*c.G+0.0722*c.B end
local function saturation(c)local mx=math.max(c.R,c.G,c.B);local mn=math.min(c.R,c.G,c.B);return mx==0 and 0 or (mx-mn)/mx end
function UITheme.Get()
    local theme=table.clone(defaultTheme);local assets=ReplicatedStorage:FindFirstChild("Assets");local imported=assets and assets:FindFirstChild("ImportedModels");local source=imported and imported:FindFirstChild("SimulatorUI");if not source then return theme end
    local darkest,darkLum;local accent,accentSat=nil,0
    for _,d in ipairs(source:GetDescendants()) do
        if d:IsA("GuiObject") and d.BackgroundTransparency<0.95 then local c=d.BackgroundColor3;local lum=luminance(c);local sat=saturation(c);if not darkest or lum<darkLum then darkest,darkLum=c,lum end;if sat>accentSat and lum>0.2 then accent,accentSat=c,sat end
        elseif d:IsA("TextLabel") or d:IsA("TextButton") then if d.Font then theme.Font=d.Font end
        elseif d:IsA("UICorner") and d.CornerRadius.Offset>0 then theme.Radius=math.clamp(d.CornerRadius.Offset,8,22) end
    end
    if darkest then theme.Panel=darkest;theme.Panel2=darkest:Lerp(Color3.new(1,1,1),0.08);theme.Button=darkest:Lerp(Color3.new(1,1,1),0.16) end
    if accent then theme.Accent=accent end
    return theme
end
return UITheme

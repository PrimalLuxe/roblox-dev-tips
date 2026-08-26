local UITheme={}

-- Pixel-authored product/vending UI. No runtime donor palette and no rounded-card dependency.
local THEME={
    Canvas=Color3.fromRGB(220,227,229),
    Panel=Color3.fromRGB(246,239,220),
    Panel2=Color3.fromRGB(255,250,234),
    PanelInset=Color3.fromRGB(218,222,213),
    Button=Color3.fromRGB(33,52,68),
    ButtonHover=Color3.fromRGB(42,76,101),
    ButtonText=Color3.fromRGB(255,249,229),
    Accent=Color3.fromRGB(49,134,211),
    Accent2=Color3.fromRGB(213,165,47),
    Red=Color3.fromRGB(202,71,65),
    Success=Color3.fromRGB(62,156,96),
    Text=Color3.fromRGB(25,38,51),
    Muted=Color3.fromRGB(86,98,105),
    Outline=Color3.fromRGB(20,31,42),
    Shadow=Color3.fromRGB(13,20,27),
    Radius=0,
    Pixel=3,
    Font=Enum.Font.GothamBold,
}
function UITheme.Get()return table.clone(THEME)end
return UITheme

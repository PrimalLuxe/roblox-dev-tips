local UITheme = {}

-- ShakeVM owns its interface palette. Creator Store UI assets may be inspected as references,
-- but they never become runtime theme authorities. This keeps the product identity stable even
-- when donor assets are replaced or fail to load.
local theme = {
    Panel = Color3.fromRGB(255, 248, 226),
    Panel2 = Color3.fromRGB(244, 235, 207),
    Button = Color3.fromRGB(34, 74, 116),
    ButtonHover = Color3.fromRGB(43, 91, 139),
    ButtonPressed = Color3.fromRGB(27, 60, 94),
    Accent = Color3.fromRGB(49, 142, 207),
    Accent2 = Color3.fromRGB(238, 181, 58),
    Text = Color3.fromRGB(31, 49, 70),
    TextOnDark = Color3.fromRGB(255, 252, 239),
    Muted = Color3.fromRGB(99, 112, 124),
    Outline = Color3.fromRGB(43, 57, 72),
    Shadow = Color3.fromRGB(28, 41, 53),
    Success = Color3.fromRGB(66, 166, 102),
    Danger = Color3.fromRGB(210, 78, 72),
    Warning = Color3.fromRGB(221, 143, 55),
    Radius = 14,
    Font = Enum.Font.GothamBold,
    HeadingFont = Enum.Font.GothamBlack,
}

function UITheme.Get()
    return table.clone(theme)
end

return UITheme

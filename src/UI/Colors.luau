local Theme = settings().Studio.Theme

local function studio(name: string): Color3
    return Theme:GetColor((Enum.StudioStyleGuideColor :: any)[name])
end

local COLORS = {
    background = studio("MainBackground"),
    tabBar = studio("ViewPortBackground"),
    tabActive = studio("Button"),
    accent = studio("FilterButtonAccent"),
    accentHover = studio("LinkText"),
    text = studio("ButtonText"),
    textMuted = studio("SubText"),
    card = studio("Mid"),
    cardHover = studio("Tab"),
    border = studio("Border"),
    inputBackground = studio("InputFieldBackground"),
    inputBorder = studio("InputFieldBorder"),
    success = studio("DialogMainButton"),
    error = studio("ErrorText"),

    -- Per-section accent stripes. These deliberately don't track the Studio
    -- theme so each section keeps a recognizable identity.
    sectionAccents = {
        general = Color3.fromRGB(120, 170, 255),
        terrain = Color3.fromRGB(180, 140, 90),
        lighting = Color3.fromRGB(255, 210, 110),
        workspace = Color3.fromRGB(120, 200, 160),
        music = Color3.fromRGB(200, 140, 230),
        material = Color3.fromRGB(110, 210, 230),
        instances = Color3.fromRGB(240, 130, 180),
        source = Color3.fromRGB(120, 170, 255),
        options = Color3.fromRGB(180, 180, 200),
        runtime = Color3.fromRGB(150, 230, 150),
    },
}

return COLORS

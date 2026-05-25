local Theme = settings().Studio.Theme

local COLORS = {
    background = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
    tabBar = Theme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground),
    tabActive = Theme:GetColor(Enum.StudioStyleGuideColor.Button),
    accent = Theme:GetColor(Enum.StudioStyleGuideColor.FilterButtonAccent),
    text = Theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
    textMuted = Theme:GetColor(Enum.StudioStyleGuideColor.SubText),
}

return COLORS
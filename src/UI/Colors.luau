local Theme = settings().Studio.Theme

local COLORS = {
    background = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
    tabBar = Theme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground),
    tabActive = Theme:GetColor(Enum.StudioStyleGuideColor.Button),
    accent = Theme:GetColor(Enum.StudioStyleGuideColor.FilterButtonAccent),
    accentHover = Theme:GetColor(Enum.StudioStyleGuideColor.LinkText),
    text = Theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
    textMuted = Theme:GetColor(Enum.StudioStyleGuideColor.SubText),
    card = Theme:GetColor(Enum.StudioStyleGuideColor.Mid),
    border = Theme:GetColor(Enum.StudioStyleGuideColor.Border),
    inputBackground = Theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
    inputBorder = Theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
    success = Theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
    error = Theme:GetColor(Enum.StudioStyleGuideColor.ErrorText),
}

return COLORS

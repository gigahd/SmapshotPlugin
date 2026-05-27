--!strict
--[[
    Color math used by Form components: shade towards black/white, compute
    luminance, derive a high-contrast text color for any background.
]]
local Shading = {}

local function clamp01(n: number): number
    return math.clamp(n, 0, 1)
end

function Shading.shade(color: Color3, amount: number): Color3
    return Color3.new(clamp01(color.R + amount), clamp01(color.G + amount), clamp01(color.B + amount))
end

function Shading.luminance(color: Color3): number
    return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

function Shading.contrastingText(bg: Color3): Color3
    return if Shading.luminance(bg) > 0.55
        then Color3.fromRGB(20, 20, 24)
        else Color3.fromRGB(245, 245, 248)
end

function Shading.hoverShade(bg: Color3): Color3
    local amount = if Shading.luminance(bg) > 0.55 then -0.06 else 0.08
    return Shading.shade(bg, amount)
end

function Shading.pressShade(bg: Color3): Color3
    local amount = if Shading.luminance(bg) > 0.55 then -0.14 else -0.08
    return Shading.shade(bg, amount)
end

return Shading

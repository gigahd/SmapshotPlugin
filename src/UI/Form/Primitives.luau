--!nonstrict
--[[
    Tiny Vide.create wrappers reused by Form components.
]]
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

local Primitives = {}

function Primitives.corner(radius: number?): UICorner
    return create("UICorner")({
        CornerRadius = UDim.new(0, radius or 6),
    })
end

function Primitives.stroke(
    color: any,
    thickness: number?,
    transparency: any?
): UIStroke
    return create("UIStroke")({
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

return Primitives

--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Primitives = require(script.Parent.Primitives)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local spring = Vide.spring

type StatusKind = "info" | "success" | "error"

return function(props: {
    text: () -> string,
    kind: () -> StatusKind,
    layoutOrder: number?,
})
    local function visible()
        return props.text() ~= ""
    end
    local function color()
        local kind = props.kind()
        if kind == "error" then return Colors.error end
        if kind == "success" then return Colors.success end
        return Colors.textMuted
    end
    return create("Frame")({
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = spring(color, 0.18, 1),
        BackgroundTransparency = spring(function()
            return if visible() then 0.78 else 1
        end, 0.18, 1),
        BorderSizePixel = 0,
        Visible = visible,
        LayoutOrder = props.layoutOrder,
        Primitives.corner(5),
        create("UIPadding")({
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        }),
        create("TextLabel")({
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = props.text,
            TextColor3 = color,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }),
    })
end

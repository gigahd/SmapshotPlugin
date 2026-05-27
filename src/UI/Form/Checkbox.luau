--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Primitives = require(script.Parent.Primitives)
local Shading = require(script.Parent.Shading)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source
local spring = Vide.spring

return function(props: {
    value: () -> boolean,
    onToggle: () -> (),
    layoutOrder: number?,
})
    local hovered = source(false)
    return create("TextButton")({
        Size = UDim2.fromOffset(18, 18),
        LayoutOrder = props.layoutOrder,
        BackgroundColor3 = spring(function()
            if props.value() then
                return if hovered() then Shading.shade(Colors.accent, 0.08) else Colors.accent
            end
            return if hovered() then Shading.shade(Colors.inputBackground, 0.06) else Colors.inputBackground
        end, 0.18, 1),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = function()
            return if props.value() then "✓" else ""
        end,
        TextColor3 = function()
            return if props.value() then Shading.contrastingText(Colors.accent) else Colors.textMuted
        end,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Activated = props.onToggle,
        MouseEnter = function() hovered(true) end,
        MouseLeave = function() hovered(false) end,
        Primitives.corner(4),
        Primitives.stroke(Colors.inputBorder, 1, 0.4),
    })
end

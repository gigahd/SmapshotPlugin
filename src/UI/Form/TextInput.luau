--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Primitives = require(script.Parent.Primitives)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source
local spring = Vide.spring

return function(props: {
    value: ((string) -> string) & (() -> string),
    placeholder: string?,
    width: UDim2?,
    layoutOrder: number?,
    visible: (() -> boolean)?,
})
    local focused = source(false)
    return create("TextBox")({
        Size = props.width or UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Colors.inputBackground,
        BorderSizePixel = 0,
        Text = props.value,
        PlaceholderText = props.placeholder,
        PlaceholderColor3 = Colors.textMuted,
        TextColor3 = Colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        Focused = function() focused(true) end,
        FocusLost = function() focused(false) end,
        Primitives.corner(5),
        create("UIStroke")({
            Color = spring(function()
                return if focused() then Colors.accent else Colors.inputBorder
            end, 0.18, 1),
            Thickness = 1,
            Transparency = spring(function()
                return if focused() then 0 else 0.4
            end, 0.18, 1),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }),
        create("UIPadding")({
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
        Vide.changed("Text", function(text: string)
            props.value(text)
        end),
    })
end

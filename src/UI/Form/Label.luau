--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

return function(props: {
    text: any,
    width: UDim2?,
    layoutOrder: number?,
    muted: boolean?,
    align: Enum.TextXAlignment?,
    visible: (() -> boolean)?,
})
    return create("TextLabel")({
        Size = props.width or UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text,
        TextColor3 = if props.muted then Colors.textMuted else Colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = props.align or Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
    })
end

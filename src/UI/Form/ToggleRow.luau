--!nonstrict
local Checkbox = require(script.Parent.Checkbox)
local Colors = require(script.Parent.Parent.Colors)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

return function(props: {
    value: () -> boolean,
    onToggle: () -> (),
    label: string,
    description: string?,
    layoutOrder: number?,
    visible: (() -> boolean)?,
})
    return create("TextButton")({
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        Activated = props.onToggle,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
        Checkbox({
            value = props.value,
            onToggle = props.onToggle,
            layoutOrder = 1,
        }),
        create("TextLabel")({
            Size = UDim2.new(1, -26, 1, 0),
            BackgroundTransparency = 1,
            Text = props.label,
            TextColor3 = Colors.text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = 2,
        }),
    })
end

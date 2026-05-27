--!nonstrict
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

return function(props: {
    layoutOrder: number?,
    height: number?,
    visible: (() -> boolean)?,
    children: { Instance },
})
    return create("Frame")({
        Size = UDim2.new(1, 0, 0, props.height or 24),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
        }),
        table.unpack(props.children),
    })
end

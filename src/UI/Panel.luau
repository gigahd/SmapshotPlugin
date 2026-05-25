--!nonstrict
const Colors = require(script.Parent.Colors)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create

return function(props: { name: string, title: string, visible: () -> boolean, children: { Instance } })
    return create("Frame")({
        Name = props.name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = props.visible,

        create("UIPadding")({
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        create("TextLabel")({
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Text = props.title,
            TextColor3 = Colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        table.unpack(props.children)
    })
end
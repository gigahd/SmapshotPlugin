--!nonstrict
const Colors = require(script.Parent.Colors)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create

const Form = {}

function Form.Section(props: { title: string, layoutOrder: number?, children: { Instance } })
    return create("Frame")({
        Name = props.title .. "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,

        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
        create("TextLabel")({
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Text = props.title,
            TextColor3 = Colors.textMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
        }),
        table.unpack(props.children),
    })
end

function Form.Row(props: {
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

function Form.Checkbox(props: { value: () -> boolean, onToggle: () -> (), layoutOrder: number? })
    return create("TextButton")({
        Size = UDim2.fromOffset(16, 16),
        LayoutOrder = props.layoutOrder,
        BackgroundColor3 = function()
            return if props.value() then Colors.accent else Colors.tabBar
        end,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = function()
            return if props.value() then "✓" else ""
        end,
        TextColor3 = Colors.text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Activated = props.onToggle,
    })
end

function Form.Label(props: { text: any, width: UDim2?, layoutOrder: number? })
    return create("TextLabel")({
        Size = props.width or UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text,
        TextColor3 = Colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = props.layoutOrder,
    })
end

function Form.Button(props: {
    text: string,
    onClick: () -> (),
    width: UDim2?,
    layoutOrder: number?,
    primary: boolean?,
})
    return create("TextButton")({
        Size = props.width or UDim2.fromOffset(100, 24),
        BackgroundColor3 = if props.primary then Colors.accent else Colors.tabActive,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = props.text,
        TextColor3 = Colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        LayoutOrder = props.layoutOrder,
        Activated = props.onClick,
    })
end

function Form.SegmentedToggle(props: {
    value: () -> string,
    options: { string },
    onSelect: (string) -> (),
    layoutOrder: number?,
})
    local children: { Instance } = {
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }
    for i, option in props.options do
        table.insert(children, create("TextButton")({
            Size = UDim2.new(1 / #props.options, 0, 1, 0),
            BackgroundColor3 = function()
                return if props.value() == option then Colors.accent else Colors.tabBar
            end,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = option,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = function()
                return if props.value() == option then Colors.text else Colors.textMuted
            end,
            LayoutOrder = i,
            Activated = function()
                props.onSelect(option)
            end,
        }))
    end
    return create("Frame")({
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
        table.unpack(children),
    })
end

function Form.TextInput(props: {
    value: ((string) -> string) & (() -> string),
    placeholder: string?,
    width: UDim2?,
    layoutOrder: number?,
})
    return create("TextBox")({
        Size = props.width or UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Colors.tabBar,
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
        create("UIPadding")({
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        }),
        Vide.changed("Text", function(text: string)
            props.value(text)
        end),
    })
end

function Form.ToggleRow(props: {
    value: () -> boolean,
    onToggle: () -> (),
    label: string,
    layoutOrder: number?,
})
    return Form.Row({
        layoutOrder = props.layoutOrder,
        children = {
            Form.Checkbox({
                value = props.value,
                onToggle = props.onToggle,
                layoutOrder = 1,
            }),
            Form.Label({
                text = props.label,
                width = UDim2.new(1, -22, 1, 0),
                layoutOrder = 2,
            }),
        },
    })
end

return Form

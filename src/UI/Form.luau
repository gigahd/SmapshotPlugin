--!nonstrict
const Colors = require(script.Parent.Colors)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create

const Form = {}

local function corner(radius: number?)
    return create("UICorner")({
        CornerRadius = UDim.new(0, radius or 6),
    })
end

local function stroke(color: Color3, thickness: number?, transparency: number?)
    return create("UIStroke")({
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

function Form.Section(props: { title: string, layoutOrder: number?, children: { Instance } })
    return create("Frame")({
        Name = props.title .. "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Colors.card,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = props.layoutOrder,

        corner(8),
        stroke(Colors.border, 1, 0.5),
        create("UIPadding")({
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }),
        create("Frame")({
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = 0,

            create("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
            }),
            create("Frame")({
                Name = "AccentBar",
                Size = UDim2.fromOffset(3, 14),
                BackgroundColor3 = Colors.accent,
                BorderSizePixel = 0,
                LayoutOrder = 0,
                corner(2),
            }),
            create("TextLabel")({
                Size = UDim2.new(1, -9, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                Text = props.title,
                TextColor3 = Colors.text,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            }),
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
        Size = UDim2.fromOffset(18, 18),
        LayoutOrder = props.layoutOrder,
        BackgroundColor3 = function()
            return if props.value() then Colors.accent else Colors.inputBackground
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
        corner(4),
        stroke(Colors.inputBorder, 1, 0.4),
    })
end

function Form.Label(props: {
    text: any,
    width: UDim2?,
    layoutOrder: number?,
    muted: boolean?,
    align: Enum.TextXAlignment?,
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
    })
end

function Form.Button(props: {
    text: string,
    onClick: () -> (),
    width: UDim2?,
    layoutOrder: number?,
    primary: boolean?,
    disabled: (() -> boolean)?,
})
    local function isDisabled()
        return props.disabled and props.disabled()
    end
    return create("TextButton")({
        Size = props.width or UDim2.fromOffset(100, 24),
        BackgroundColor3 = function()
            if isDisabled() then
                return Colors.tabBar
            end
            return if props.primary then Colors.accent else Colors.tabActive
        end,
        BackgroundTransparency = function()
            return if isDisabled() then 0.3 else 0
        end,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = props.text,
        TextColor3 = function()
            return if isDisabled() then Colors.textMuted else Colors.text
        end,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        LayoutOrder = props.layoutOrder,
        Active = function()
            return not isDisabled()
        end,
        Activated = function()
            if isDisabled() then
                return
            end
            props.onClick()
        end,
        corner(5),
    })
end

function Form.SegmentedToggle(props: {
    value: () -> string,
    options: { string },
    onSelect: (string) -> (),
    layoutOrder: number?,
    visible: (() -> boolean)?,
})
    local children: { Instance } = {
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        create("UIPadding")({
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
        }),
    }
    for i, option in props.options do
        table.insert(children, create("TextButton")({
            Size = UDim2.new(1 / #props.options, -2, 1, 0),
            BackgroundColor3 = Colors.accent,
            BackgroundTransparency = function()
                return if props.value() == option then 0 else 1
            end,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = option,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = function()
                return if props.value() == option then Colors.text else Colors.textMuted
            end,
            LayoutOrder = i,
            Activated = function()
                props.onSelect(option)
            end,
            corner(4),
        }))
    end
    return create("Frame")({
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Colors.inputBackground,
        BorderSizePixel = 0,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        corner(6),
        stroke(Colors.inputBorder, 1, 0.5),
        table.unpack(children),
    })
end

function Form.TextInput(props: {
    value: ((string) -> string) & (() -> string),
    placeholder: string?,
    width: UDim2?,
    layoutOrder: number?,
    visible: (() -> boolean)?,
})
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
        corner(5),
        stroke(Colors.inputBorder, 1, 0.4),
        create("UIPadding")({
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
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
        Form.Checkbox({
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

type StatusKind = "info" | "success" | "error"

function Form.StatusBanner(props: {
    text: () -> string,
    kind: () -> StatusKind,
    layoutOrder: number?,
})
    local function visible()
        return props.text() ~= ""
    end
    local function color()
        local kind = props.kind()
        if kind == "error" then
            return Colors.error
        elseif kind == "success" then
            return Colors.success
        end
        return Colors.textMuted
    end
    return create("Frame")({
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Visible = visible,
        LayoutOrder = props.layoutOrder,
        corner(5),
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

return Form
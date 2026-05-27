--!nonstrict
--[[
    A scrollable list of string entries with a × button per row.
    Used by every section that needs the "pinned list" UX (Instances, name
    filters, BaseMaterial filter).
]]
local Colors = require(script.Parent.Parent.Colors)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local values = Vide.values

local ROW_HEIGHT = 24
local INNER_ROW_HEIGHT = 20

return function(props: {
    items: () -> { string },
    onRemove: (string) -> (),
    visible: (() -> boolean)?,
    layoutOrder: number?,
    maxRows: number?,
    isValid: ((string) -> boolean)?,
})
    local maxRows = props.maxRows or 5

    local function row(name: string): Frame
        return create("Frame")({
            Size = UDim2.new(1, 0, 0, INNER_ROW_HEIGHT),
            BackgroundTransparency = 1,
            create("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            }),
            create("TextLabel")({
                Size = UDim2.new(1, -22, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Code,
                TextSize = 12,
                TextColor3 = if props.isValid and not props.isValid(name) then Colors.error else Colors.text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = 1,
            }),
            create("TextButton")({
                Size = UDim2.fromOffset(18, 18),
                BackgroundColor3 = Colors.error,
                BackgroundTransparency = 0.55,
                BorderSizePixel = 0,
                Text = "×",
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Colors.text,
                AutoButtonColor = true,
                LayoutOrder = 2,
                Activated = function()
                    props.onRemove(name)
                end,
                create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
            }),
        })
    end

    return create("ScrollingFrame")({
        Size = function()
            local n = #props.items()
            if n == 0 then
                return UDim2.new(1, 0, 0, 0)
            end
            return UDim2.new(1, 0, 0, math.min(n, maxRows) * ROW_HEIGHT)
        end,
        BackgroundColor3 = Colors.inputBackground,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        LayoutOrder = props.layoutOrder,
        Visible = if props.visible
            then function()
                return props.visible() and #props.items() > 0
            end
            else function()
                return #props.items() > 0
            end,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        create("UIPadding")({
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
        }),
        create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
        values(props.items, function(name: string)
            return row(name)
        end),
    })
end

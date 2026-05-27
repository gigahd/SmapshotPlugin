--!nonstrict
--[[
    Recently-loaded asset ids/names rendered as clickable rows. Tapping a row
    calls `onPick(id)`; the × button removes the entry from the recent list.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local RecentAssets = require(script.Parent.Parent.Parent.Helper.RecentAssets)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local values = Vide.values

local ROW_HEIGHT = 24

return function(props: {
    visible: () -> boolean,
    onPick: (number) -> (),
    layoutOrder: number,
})
    local entries = RecentAssets.list()

    local function row(entry): Frame
        return create("Frame")({
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            create("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            }),
            create("TextButton")({
                Size = UDim2.new(1, -22, 1, 0),
                BackgroundColor3 = Colors.tabActive,
                BackgroundTransparency = 0.6,
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Text = `{entry.name}  ·  {entry.id}`,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Colors.text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = 1,
                Activated = function() props.onPick(entry.id) end,
                create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
                create("UIPadding")({
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                }),
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
                Activated = function() RecentAssets.remove(entry.id) end,
                create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
            }),
        })
    end

    return create("Frame")({
        Name = "Recent",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
        Form.Label({
            text = function()
                local n = #entries()
                if n == 0 then
                    return "Recent: <empty>"
                end
                return `Recent ({n}):`
            end,
            muted = true,
            width = UDim2.new(1, 0, 0, 16),
            layoutOrder = 1,
        }),
        create("ScrollingFrame")({
            Size = function()
                local n = #entries()
                if n == 0 then return UDim2.new(1, 0, 0, 0) end
                return UDim2.new(1, 0, 0, math.min(n, 5) * ROW_HEIGHT)
            end,
            BackgroundColor3 = Colors.inputBackground,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            LayoutOrder = 2,
            Visible = function() return #entries() > 0 end,
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
            values(entries, function(entry) return row(entry) end),
        }),
    })
end

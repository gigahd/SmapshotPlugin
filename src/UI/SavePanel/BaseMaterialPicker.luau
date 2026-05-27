--!nonstrict
--[[
    BaseMaterial picker: a pinned list (with × per row) plus a scrollable list
    of `Enum.Material` values that aren't pinned yet. Click any available row to
    add it; click × in the pinned list to remove it.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local PinList = require(script.Parent.PinList)
local StringSetOps = require(script.Parent.StringSetOps)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create
local derive = Vide.derive
local values = Vide.values

local ROW_HEIGHT = 24

local function allMaterialNames(): { string }
    local result: { string } = {}
    for _, item in Enum.Material:GetEnumItems() do
        table.insert(result, item.Name)
    end
    table.sort(result)
    return result
end
local ALL_MATERIALS = allMaterialNames()

return function(props: {
    enabled: () -> boolean,
    items: any,
    layoutOrder: number,
}): Frame
    local available = derive(function(): { string }
        local pinned = props.items()
        local result: { string } = {}
        for _, name in ALL_MATERIALS do
            if not table.find(pinned, name) then
                table.insert(result, name)
            end
        end
        return result
    end)

    local function addMaterial(name: string)
        StringSetOps.addMany(props.items, { name })
    end

    local function availableRow(name: string): TextButton
        return create("TextButton")({
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = Colors.tabActive,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Text = name,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = Colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Activated = function() addMaterial(name) end,
            create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
            create("UIPadding")({
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        })
    end

    return create("Frame")({
        Name = "BaseMaterialPicker",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
        Visible = props.enabled,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }),
        Form.Label({
            text = function()
                local n = #props.items()
                if n == 0 then
                    return "No materials pinned - no BaseMaterial filter applied"
                end
                return `Pinned: {n} BaseMaterial(s)`
            end,
            muted = true,
            width = UDim2.new(1, 0, 0, 16),
            layoutOrder = 1,
        }),
        PinList({
            items = props.items,
            onRemove = function(target)
                StringSetOps.remove(props.items, target)
            end,
            layoutOrder = 2,
        }),
        Form.Label({
            text = "Click to add:",
            muted = true,
            width = UDim2.new(1, 0, 0, 16),
            layoutOrder = 3,
        }),
        create("ScrollingFrame")({
            Size = function()
                local n = #available()
                if n == 0 then return UDim2.new(1, 0, 0, 0) end
                return UDim2.new(1, 0, 0, math.min(n, 6) * ROW_HEIGHT)
            end,
            BackgroundColor3 = Colors.inputBackground,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            LayoutOrder = 4,
            Visible = function() return #available() > 0 end,
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
            values(available, availableRow),
        }),
    })
end

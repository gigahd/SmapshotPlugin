--!nonstrict
--[[
    Animated card. Outer Frame is height-animated (via useMotion); inner
    UIListLayout's AbsoluteContentSize feeds the natural height. ClipsDescendants
    keeps mid-shrink overflow hidden.
]]
local Colors = require(script.Parent.Parent.Colors)
local Primitives = require(script.Parent.Primitives)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local VideRipple = require(script.Parent.Parent.Parent.Packages.VideRipple)
local create = Vide.create
local source = Vide.source
local useMotion = VideRipple.useMotion

local PADDING_TOP = 10
local PADDING_BOTTOM = 10

local function header(title: string, accent: Color3): Frame
    return create("Frame")({
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
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Primitives.corner(2),
        }),
        create("TextLabel")({
            Size = UDim2.new(1, -9, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Text = title,
            TextColor3 = Colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }),
    })
end

return function(props: {
    title: string,
    layoutOrder: number?,
    accent: Color3?,
    children: { Instance },
})
    local accent = props.accent or Colors.accent

    local naturalHeight = source(0)
    local animatedHeight, heightMotion = useMotion(0)
    local initialized = false
    Vide.effect(function()
        local target = naturalHeight()
        if target <= 0 then return end
        if not initialized then
            initialized = true
            -- Snap on first measurement (set the goal too, otherwise the spring
            -- pulls back to 0 and the card collapses immediately).
            heightMotion:setGoal(target)
            heightMotion:setPosition(target)
        else
            heightMotion:spring(target, { dampingRatio = 1, frequency = 4 })
        end
    end)

    return create("Frame")({
        Name = props.title .. "Section",
        Size = function() return UDim2.new(1, 0, 0, animatedHeight()) end,
        BackgroundColor3 = Colors.card,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = props.layoutOrder,
        ClipsDescendants = true,
        Primitives.corner(8),
        Primitives.stroke(Colors.border, 1, 0.5),
        create("UIPadding")({
            PaddingTop = UDim.new(0, PADDING_TOP),
            PaddingBottom = UDim.new(0, PADDING_BOTTOM),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Vide.changed("AbsoluteContentSize", function(size: Vector2)
                if size.Y > 0 then
                    naturalHeight(size.Y + PADDING_TOP + PADDING_BOTTOM)
                end
            end),
        }),
        header(props.title, accent),
        table.unpack(props.children),
    })
end

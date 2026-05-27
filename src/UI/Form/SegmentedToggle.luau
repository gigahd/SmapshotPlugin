--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Primitives = require(script.Parent.Primitives)
local Shading = require(script.Parent.Shading)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local VideRipple = require(script.Parent.Parent.Parent.Packages.VideRipple)
local create = Vide.create
local source = Vide.source
local spring = Vide.spring
local useMotion = VideRipple.useMotion

return function(props: {
    value: () -> string,
    options: { string },
    onSelect: (string) -> (),
    layoutOrder: number?,
    visible: (() -> boolean)?,
    accent: Color3?,
    height: number?,
    textSize: number?,
})
    local accent = props.accent or Colors.accent
    local count = #props.options
    local height = props.height or 28
    local textSize = props.textSize or 12

    local function indexOf(option: string): number
        for i, v in props.options do
            if v == option then
                return i
            end
        end
        return 1
    end

    local indicatorPos, indicatorPosMotion = useMotion(UDim2.new(0, 3, 0.5, 0))
    -- Snap on first run (the persisted value may not be option 1, otherwise the
    -- slider would visibly slide from option 1 → current on mount); spring on
    -- every subsequent change.
    local firstRun = true
    Vide.effect(function()
        local i = indexOf(props.value())
        local target = UDim2.new((i - 1) / count, 3, 0.5, 0)
        if firstRun then
            firstRun = false
            indicatorPosMotion:setGoal(target)
            indicatorPosMotion:setPosition(target)
        else
            indicatorPosMotion:spring(target, { dampingRatio = 1, frequency = 4 })
        end
    end)

    local buttons: { Instance } = {
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        }),
    }
    for i, option in props.options do
        local hovered = source(false)
        table.insert(buttons, create("TextButton")({
            Size = UDim2.new(1 / count, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = option,
            Font = Enum.Font.GothamMedium,
            TextSize = textSize,
            TextColor3 = spring(function()
                if props.value() == option then
                    return Shading.contrastingText(accent)
                end
                return if hovered() then Colors.text else Colors.textMuted
            end, 0.18, 1),
            LayoutOrder = i,
            Activated = function() props.onSelect(option) end,
            MouseEnter = function() hovered(true) end,
            MouseLeave = function() hovered(false) end,
        }))
    end

    return create("Frame")({
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Colors.inputBackground,
        BorderSizePixel = 0,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        Primitives.corner(6),
        Primitives.stroke(Colors.inputBorder, 1, 0.5),
        create("Frame")({
            Name = "Slider",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = indicatorPos,
            Size = UDim2.new(1 / count, -6, 1, -6),
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            ZIndex = 1,
            create("UICorner")({ CornerRadius = UDim.new(0, 4) }),
        }),
        create("Frame")({
            Name = "Buttons",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ZIndex = 2,
            table.unpack(buttons),
        }),
    })
end

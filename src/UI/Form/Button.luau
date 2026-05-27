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

local RIPPLE_DIAMETER = 240
local RIPPLE_DURATION = 0.55

return function(props: {
    text: string | () -> string,
    onClick: () -> (),
    width: UDim2?,
    layoutOrder: number?,
    primary: boolean?,
    visible: (() -> boolean)?,
    disabled: (() -> boolean)?,
    accent: Color3?,
})
    local hovered = source(false)
    local pressed = source(false)
    local function isDisabled()
        return props.disabled and props.disabled()
    end
    local activeColor = if props.primary
        then (props.accent or Colors.accent)
        else Colors.tabActive

    local ripplePos = source(UDim2.fromScale(0.5, 0.5))
    local rippleProgress, rippleMotion = useMotion(0)
    local buttonRef = source(nil :: TextButton?)

    local function fireRipple(x: number, y: number)
        local btn = buttonRef()
        if btn then
            ripplePos(UDim2.fromOffset(x - btn.AbsolutePosition.X, y - btn.AbsolutePosition.Y))
        else
            ripplePos(UDim2.fromScale(0.5, 0.5))
        end
        rippleMotion:setPosition(0)
        rippleMotion:tween(1, { duration = RIPPLE_DURATION, easing = "quadOut" })
    end

    local rippleColor = if Shading.luminance(activeColor) > 0.55
        then Color3.fromRGB(10, 10, 14)
        else Color3.fromRGB(255, 255, 255)

    return create("TextButton")({
        Size = props.width or UDim2.fromOffset(100, 24),
        BackgroundColor3 = spring(function()
            if isDisabled() then return Colors.tabBar end
            if pressed() then return Shading.pressShade(activeColor) end
            if hovered() then return Shading.hoverShade(activeColor) end
            return activeColor
        end, 0.15, 1),
        BackgroundTransparency = function()
            return if isDisabled() then 0.3 else 0
        end,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Text = props.text,
        TextColor3 = function()
            if isDisabled() then return Colors.textMuted end
            if props.primary then return Shading.contrastingText(activeColor) end
            return Colors.text
        end,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        LayoutOrder = props.layoutOrder,
        Visible = props.visible,
        Active = function() return not isDisabled() end,
        Activated = function()
            if isDisabled() then return end
            props.onClick()
        end,
        MouseEnter = function() hovered(true) end,
        MouseLeave = function()
            hovered(false)
            pressed(false)
        end,
        MouseButton1Down = function(x: number, y: number)
            if isDisabled() then return end
            pressed(true)
            fireRipple(x, y)
        end,
        MouseButton1Up = function() pressed(false) end,
        Primitives.corner(5),
        Vide.action(function(instance: Instance)
            buttonRef(instance :: TextButton)
        end),
        create("Frame")({
            Name = "Ripple",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = ripplePos,
            Size = function()
                local d = RIPPLE_DIAMETER * rippleProgress()
                return UDim2.fromOffset(d, d)
            end,
            BackgroundColor3 = rippleColor,
            BackgroundTransparency = function()
                return 0.55 + rippleProgress() * 0.45
            end,
            BorderSizePixel = 0,
            ZIndex = 2,
            create("UICorner")({ CornerRadius = UDim.new(1, 0) }),
        }),
    })
end

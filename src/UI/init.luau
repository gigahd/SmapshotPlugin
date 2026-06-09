--!nonstrict
local Colors = require(script.Colors)
local Form = require(script.Form)
local Smapshot = require(script.Parent.Packages.Smapshot)
local Vide = require(script.Parent.Packages.Vide)
local VideRipple = require(script.Parent.Packages.VideRipple)
local LoadPanel = require(script.LoadPanel)
local SavePanel = require(script.SavePanel)
local create = Vide.create
local source = Vide.source
local useMotion = VideRipple.useMotion

type TabId = "Save" | "Load"

-- Plugin version mirrors wally.toml; bump both together.
local PLUGIN_VERSION = "0.2.0"
local SMAPSHOT_VERSION = Smapshot.ReadVersion(Smapshot.Snapshot({})) or "?"

local TAB_BAR_HEIGHT = 34
local TAB_BAR_PADDING_TOP = 6
local TAB_BAR_PADDING_BOTTOM = 6
local VERSION_FOOTER_HEIGHT = 16
local CONTENT_OFFSET = TAB_BAR_HEIGHT + TAB_BAR_PADDING_TOP + TAB_BAR_PADDING_BOTTOM

local function setupUI(widget: DockWidgetPluginGui)
    local activeTab = source("Save" :: TabId)

    -- Both panels are always "visible" — the viewport clip + offscreen position
    -- decides which one is actually shown.
    local alwaysTrue = function()
        return true
    end

    Vide.mount(function()
        -- Slide rail: holds Save and Load side-by-side and animates the X offset.
        -- Must be inside the mount so useMotion's Vide.cleanup has a reactive scope.
        local railPos, railMotion = useMotion(UDim2.fromScale(0, 0))
        Vide.effect(function()
            local x = if activeTab() == "Save" then 0 else -1
            railMotion:spring(UDim2.fromScale(x, 0), { dampingRatio = 1, frequency = 3 })
        end)

        return create("Frame")({
            Name = "Root",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Colors.background,
            BorderSizePixel = 0,
            Parent = widget,

            create("Frame")({
                Name = "TabBar",
                Size = UDim2.new(1, -16, 0, TAB_BAR_HEIGHT),
                Position = UDim2.fromOffset(8, TAB_BAR_PADDING_TOP),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,

                Form.SegmentedToggle({
                    value = activeTab,
                    options = { "Save", "Load" },
                    onSelect = function(option)
                        activeTab(option :: TabId)
                    end,
                    height = TAB_BAR_HEIGHT,
                    textSize = 14,
                    accent = Colors.accent,
                }),
            }),

            create("TextLabel")({
                Name = "VersionFooter",
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -8, 1, -2),
                Size = UDim2.new(0, 240, 0, VERSION_FOOTER_HEIGHT - 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = Colors.textMuted,
                TextTransparency = 0.2,
                Text = `Plugin v{PLUGIN_VERSION}  ·  Smapshot v{SMAPSHOT_VERSION}`,
            }),

            -- Viewport clips the rail so the inactive panel stays hidden.
            create("Frame")({
                Name = "Viewport",
                Position = UDim2.new(0, 0, 0, CONTENT_OFFSET),
                Size = UDim2.new(1, 0, 1, -CONTENT_OFFSET - VERSION_FOOTER_HEIGHT),
                BackgroundTransparency = 1,
                ClipsDescendants = true,

                create("Frame")({
                    Name = "Rail",
                    Size = UDim2.new(2, 0, 1, 0),
                    Position = railPos,
                    BackgroundTransparency = 1,

                    create("Frame")({
                        Name = "SaveSlot",
                        Size = UDim2.new(0.5, 0, 1, 0),
                        Position = UDim2.fromScale(0, 0),
                        BackgroundTransparency = 1,
                        SavePanel({ visible = alwaysTrue }),
                    }),
                    create("Frame")({
                        Name = "LoadSlot",
                        Size = UDim2.new(0.5, 0, 1, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        BackgroundTransparency = 1,
                        LoadPanel({ visible = alwaysTrue }),
                    }),
                }),
            }),
        })
    end)
end

return function(pluginId, plugin, toggleButton: PluginToolbarButton)
    local widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGuiAsync(
        pluginId,
        DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 755, 317, 300, 300)
    )
    widget.Title = "Smapshot"
    toggleButton.Click:Connect(function()
        widget.Enabled = not widget.Enabled
    end)
    setupUI(widget)
end

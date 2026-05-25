--!nonstrict
const Colors = require(script.Colors)
local Vide = require(script.Parent.Packages.Vide)
const LoadPanel = require(script.LoadPanel)
const SavePanel = require(script.SavePanel)
local create = Vide.create
local source = Vide.source


type TabId = "Save" | "Load"

local function TabButton(props: {
    label: string,
    layoutOrder: number,
    isActive: () -> boolean,
    onClick: () -> (),
})
    return create("TextButton")({
        Name = props.label .. "Tab",
        LayoutOrder = props.layoutOrder,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = function()
            return if props.isActive() then Colors.tabActive else Colors.tabBar
        end,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Text = props.label,
        TextColor3 = function()
            return if props.isActive() then Colors.text else Colors.textMuted
        end,
        Activated = props.onClick,

        create("Frame")({
            Name = "ActiveIndicator",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = Colors.accent,
            BorderSizePixel = 0,
            Visible = function()
                return props.isActive()
            end,
        }),
    })
end



local function setupUI(widget: DockWidgetPluginGui)
    local activeTab = source("Save" :: TabId)

    local function isActive(tab: TabId)
        return function()
            return activeTab() == tab
        end
    end

    Vide.mount(function()
        return create("Frame")({
            Name = "Root",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Colors.background,
            BorderSizePixel = 0,
            Parent = widget,

            create("Frame")({
                Name = "TabBar",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Colors.tabBar,
                BorderSizePixel = 0,

                create("UIListLayout")({
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
                TabButton({
                    label = "Save",
                    layoutOrder = 1,
                    isActive = isActive("Save"),
                    onClick = function()
                        activeTab("Save")
                    end,
                }),
                TabButton({
                    label = "Load",
                    layoutOrder = 2,
                    isActive = isActive("Load"),
                    onClick = function()
                        activeTab("Load")
                    end,
                }),
            }),

            create("Frame")({
                Name = "Content",
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 1, -32),
                BackgroundTransparency = 1,

                SavePanel({
                    visible = isActive("Save"),
                }),
                LoadPanel({
                    visible = isActive("Load"),
                }),
            }),
        })
    end)
end

return function(pluginId, plugin, toggleButton: PluginToolbarButton)
    local widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGuiAsync(
        pluginId,
        DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 755, 317, 100, 100)
    )
    widget.Title = "Smapshot"
    toggleButton.Click:Connect(function()
        widget.Enabled = not widget.Enabled
    end)
    setupUI(widget)
end

--!nonstrict
const Selection = game:GetService("Selection")
const ServerStorage = game:GetService("ServerStorage")

const Smapshot = require(script.Parent.Parent.Smapshot)
const Colors = require(script.Parent.Colors)
const Form = require(script.Parent.Form)
const GetOrCreateSmapshotFolder = require(script.Parent.Parent.Helper.GetOrCreateSmapshotFolder)
const Panel = require(script.Parent.Panel)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source



return function(props: { visible: () -> boolean })
    local exportType = source("Folder")
    local saveDefaults = source(false)

    local terrainEnabled = source(false)
    local terrainSlice = source(nil :: BasePart?)

    local instancesEnabled = source(false)
    local instancesList = source({} :: { Instance })

    local lightingEnabled = source(false)

    local status = source("")

    local function pickSlice()
        for _, item in Selection:Get() do
            if item:IsA("BasePart") then
                terrainSlice(item)
                return
            end
        end
        status("No BasePart in selection")
    end

    local function pickInstances()
        instancesList(table.clone(Selection:Get()))
    end

    local function doSave()
        local config: Smapshot.SaveConfig = {
            exportType = exportType() :: any,
            saveDefaults = saveDefaults(),
        }
        if terrainEnabled() then
            config.terrain = { slice = terrainSlice() }
        end
        if instancesEnabled() then
            config.instances = instancesList()
        end
        if lightingEnabled() then
            config.lighting = {}
        end

        local ok, result = pcall(Smapshot.Save, config)
        if not ok then
            status("Save failed: " .. tostring(result))
            return
        end
        result.Parent = GetOrCreateSmapshotFolder()
        Selection:Set({ result })
        status("Saved as " .. result.Name)
    end

    return Panel({
        name = "SavePanel",
        title = "Save Map",
        visible = props.visible,
        children = {
            create("ScrollingFrame")({
                Size = UDim2.new(1, 0, 1, -28),
                Position = UDim2.fromOffset(0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Colors.textMuted,
                ScrollingDirection = Enum.ScrollingDirection.Y,

                create("UIListLayout")({
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                }),
                create("UIPadding")({
                    PaddingRight = UDim.new(0, 8),
                }),

                Form.Section({
                    title = "Export",
                    layoutOrder = 1,
                    children = {
                        Form.SegmentedToggle({
                            value = exportType,
                            options = { "Folder", "Model" },
                            onSelect = function(option)
                                exportType(option)
                            end,
                            layoutOrder = 1,
                        }),
                        Form.ToggleRow({
                            value = saveDefaults,
                            onToggle = function()
                                saveDefaults(not saveDefaults())
                            end,
                            label = "Save default property values",
                            layoutOrder = 2,
                        }),
                    },
                }),

                Form.Section({
                    title = "Terrain",
                    layoutOrder = 2,
                    children = {
                        Form.ToggleRow({
                            value = terrainEnabled,
                            onToggle = function()
                                terrainEnabled(not terrainEnabled())
                            end,
                            label = "Include terrain",
                            layoutOrder = 1,
                        }),
                        Form.Row({
                            layoutOrder = 2,
                            children = {
                                Form.Label({
                                    text = function()
                                        local part = terrainSlice()
                                        return if part
                                            then "Slice: " .. part.Name
                                            else "Slice: full terrain"
                                    end,
                                    width = UDim2.new(1, -184, 1, 0),
                                    layoutOrder = 1,
                                }),
                                Form.Button({
                                    text = "Use Selection",
                                    onClick = pickSlice,
                                    width = UDim2.fromOffset(110, 24),
                                    layoutOrder = 2,
                                }),
                                Form.Button({
                                    text = "Clear",
                                    onClick = function()
                                        terrainSlice(nil)
                                    end,
                                    width = UDim2.fromOffset(60, 24),
                                    layoutOrder = 3,
                                }),
                            },
                        }),
                    },
                }),

                Form.Section({
                    title = "Instances",
                    layoutOrder = 3,
                    children = {
                        Form.ToggleRow({
                            value = instancesEnabled,
                            onToggle = function()
                                instancesEnabled(not instancesEnabled())
                            end,
                            label = "Include instances",
                            layoutOrder = 1,
                        }),
                        Form.Row({
                            layoutOrder = 2,
                            children = {
                                Form.Label({
                                    text = function()
                                        return string.format("%d selected", #instancesList())
                                    end,
                                    width = UDim2.new(1, -184, 1, 0),
                                    layoutOrder = 1,
                                }),
                                Form.Button({
                                    text = "Use Selection",
                                    onClick = pickInstances,
                                    width = UDim2.fromOffset(110, 24),
                                    layoutOrder = 2,
                                }),
                                Form.Button({
                                    text = "Clear",
                                    onClick = function()
                                        instancesList({})
                                    end,
                                    width = UDim2.fromOffset(60, 24),
                                    layoutOrder = 3,
                                }),
                            },
                        }),
                    },
                }),

                Form.Section({
                    title = "Lighting",
                    layoutOrder = 4,
                    children = {
                        Form.ToggleRow({
                            value = lightingEnabled,
                            onToggle = function()
                                lightingEnabled(not lightingEnabled())
                            end,
                            label = "Include lighting",
                            layoutOrder = 1,
                        }),
                    },
                }),

                Form.Row({
                    layoutOrder = 5,
                    height = 32,
                    children = {
                        Form.Button({
                            text = "Save",
                            onClick = doSave,
                            primary = true,
                            width = UDim2.fromOffset(120, 28),
                            layoutOrder = 1,
                        }),
                        Form.Label({
                            text = status,
                            width = UDim2.new(1, -130, 1, 0),
                            layoutOrder = 2,
                        }),
                    },
                }),
            }),
        },
    })
end

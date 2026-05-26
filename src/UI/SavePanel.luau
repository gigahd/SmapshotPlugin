--!nonstrict
const Selection = game:GetService("Selection")

const Form = require(script.Parent.Form)
const GetOrCreateSmapshotFolder = require(script.Parent.Parent.Helper.GetOrCreateSmapshotFolder)
const Panel = require(script.Parent.Panel)
const Smapshot = require(script.Parent.Parent.Packages.Smapshot)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source

local function parseNameList(text: string): { string }
    const result: { string } = {}
    for _, raw in string.split(text, ",") do
        const trimmed = string.gsub(raw, "^%s*(.-)%s*$", "%1")
        if trimmed ~= "" then
            table.insert(result, trimmed)
        end
    end
    return result
end

return function(props: { visible: () -> boolean })
    local mapName = source("")
    local saveDefaults = source(false)

    local terrainEnabled = source(false)
    local terrainSlice = source(nil :: BasePart?)

    local instancesEnabled = source(false)
    local instancesList = source({} :: { Instance })
    local ignoreInstanceParents = source(false)

    local lightingEnabled = source(false)
    local filterEffects = source(false)
    local filterMode = source("Whitelist")
    local effectNames = source("")

    local status = source("")
    local statusKind = source("info" :: "info" | "success" | "error")

    local function setStatus(text: string, kind: "info" | "success" | "error"?)
        status(text)
        statusKind(kind or "info")
    end

    local function pickSlice()
        for _, item in Selection:Get() do
            if item:IsA("BasePart") then
                terrainSlice(item)
                setStatus("Slice set to " .. item.Name, "info")
                return
            end
        end
        setStatus("No BasePart in selection", "error")
    end

    local function pickInstances()
        const selected = table.clone(Selection:Get())
        instancesList(selected)
        setStatus(string.format("%d instance(s) captured", #selected), "info")
    end

    local function doSave()
        local config: Smapshot.SnapshotConfig = {
            saveDefaults = saveDefaults(),
            saveLocation = GetOrCreateSmapshotFolder(),
        }
        const trimmedName = string.gsub(mapName(), "^%s*(.-)%s*$", "%1")
        if trimmedName ~= "" then
            config.name = trimmedName
        end
        if terrainEnabled() then
            config.terrain = { slice = terrainSlice() }
        end
        if instancesEnabled() then
            config.instances = instancesList()
            config.instanceConfig = { ignoreParents = ignoreInstanceParents() }
        end
        if lightingEnabled() then
            local lighting: Smapshot.LightingConfig = {}
            if filterEffects() then
                const names = parseNameList(effectNames())
                if #names > 0 then
                    if filterMode() == "Whitelist" then
                        lighting.effectsWhiteList = names
                    else
                        lighting.effectsBlackList = names
                    end
                end
            end
            config.lighting = lighting
        end
        local ok, result = pcall(Smapshot.Snapshot, config)
        if not ok then
            setStatus("Save failed: " .. tostring(result), "error")
            return
        end
        Selection:Set({ result })
        setStatus("Saved as " .. result.Name, "success")
    end

    return Panel({
        name = "SavePanel",
        title = "Save Snapshot",
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
                ScrollingDirection = Enum.ScrollingDirection.Y,

                create("UIListLayout")({
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                }),
                create("UIPadding")({
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 6),
                }),

                Form.Section({
                    title = "General",
                    layoutOrder = 1,
                    children = {
                        Form.Label({
                            text = "Snapshot name",
                            muted = true,
                            width = UDim2.new(1, 0, 0, 16),
                            layoutOrder = 1,
                        }),
                        Form.TextInput({
                            value = mapName,
                            placeholder = "MapSave (auto-named if blank)",
                            width = UDim2.new(1, 0, 0, 26),
                            layoutOrder = 2,
                        }),
                        Form.ToggleRow({
                            value = saveDefaults,
                            onToggle = function()
                                saveDefaults(not saveDefaults())
                            end,
                            label = "Save default property values",
                            layoutOrder = 3,
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
                            visible = terrainEnabled,
                            children = {
                                Form.Label({
                                    text = function()
                                        local part = terrainSlice()
                                        return if part then "Slice: " .. part.Name else "Slice: full terrain"
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
                            visible = instancesEnabled,
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
                        Form.ToggleRow({
                            value = ignoreInstanceParents,
                            onToggle = function()
                                ignoreInstanceParents(not ignoreInstanceParents())
                            end,
                            label = "Ignore original parents",
                            layoutOrder = 3,
                            visible = instancesEnabled,
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
                        Form.ToggleRow({
                            value = filterEffects,
                            onToggle = function()
                                filterEffects(not filterEffects())
                            end,
                            label = "Filter lighting effects",
                            layoutOrder = 2,
                            visible = lightingEnabled,
                        }),
                        Form.SegmentedToggle({
                            value = filterMode,
                            options = { "Whitelist", "Blacklist" },
                            onSelect = function(option)
                                filterMode(option)
                            end,
                            layoutOrder = 3,
                            visible = function()
                                return lightingEnabled() and filterEffects()
                            end,
                        }),
                        Form.TextInput({
                            value = effectNames,
                            placeholder = "e.g. Sky, Atmosphere, BloomEffect",
                            width = UDim2.new(1, 0, 0, 26),
                            layoutOrder = 4,
                            visible = function()
                                return lightingEnabled() and filterEffects()
                            end,
                        }),
                    },
                }),

                Form.StatusBanner({
                    text = status,
                    kind = statusKind,
                    layoutOrder = 5,
                }),

                Form.Row({
                    layoutOrder = 6,
                    height = 32,
                    children = {
                        Form.Button({
                            text = "Save Snapshot",
                            onClick = doSave,
                            primary = true,
                            width = UDim2.new(1, 0, 0, 30),
                            layoutOrder = 1,
                        }),
                    },
                }),
            }),
        },
    })
end

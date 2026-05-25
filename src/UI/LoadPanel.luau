--!nonstrict
const Selection = game:GetService("Selection")

const Smapshot = require(script.Parent.Parent.Smapshot)
const Colors = require(script.Parent.Colors)
const Form = require(script.Parent.Form)
const GetOrCreateSmapshotFolder = require(script.Parent.Parent.Helper.GetOrCreateSmapshotFolder)
const Panel = require(script.Parent.Panel)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source

type Mode = "Instance" | "Asset ID"

return function(props: { visible: () -> boolean })
    local mode = source("Instance" :: Mode)
    local sourceInstance = source(nil :: Instance?)
    local assetIdText = source("")
    local keepDirty = source(false)
    local status = source("")

    local function isMode(m: Mode)
        return function()
            return mode() == m
        end
    end

    local function pickInstance()
        for _, item in Selection:Get() do
            if item:IsA("Folder") or item:IsA("Model") then
                sourceInstance(item)
                return
            end
        end
        status("No Folder or Model in selection")
    end

    local function doLoad()
        if mode() == "Instance" then
            local target = sourceInstance()
            if not target then
                status("No source instance set")
                return
            end
            status("Loading...")
            task.spawn(function()
                local ok, err = pcall(Smapshot.LoadAsync, target, keepDirty())
                status(if ok then "Loaded from " .. target.Name else "Load failed: " .. tostring(err))
            end)
        else
            local id = tonumber(assetIdText())
            if not id then
                status("Asset ID must be a number")
                return
            end
            status("Loading asset " .. id .. "...")
            task.spawn(function()
                local ok, err = pcall(Smapshot.LoadAsync, id, keepDirty())
                if ok then
                    status(`Loaded asset: {id}`)
                    err.Parent = GetOrCreateSmapshotFolder()
                else
                    status(`Load failed: {err}`)
                end
            end)
        end
    end

    return Panel({
        name = "LoadPanel",
        title = "Load Map",
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
                    title = "Source",
                    layoutOrder = 1,
                    children = {
                        Form.SegmentedToggle({
                            value = mode,
                            options = { "Instance", "Asset ID" },
                            onSelect = function(option)
                                mode(option :: Mode)
                            end,
                            layoutOrder = 1,
                        }),
                        Form.Row({
                            layoutOrder = 2,
                            visible = isMode("Instance"),
                            children = {
                                Form.Label({
                                    text = function()
                                        local inst = sourceInstance()
                                        return if inst
                                            then "Source: " .. inst.Name
                                            else "Source: <none>"
                                    end,
                                    width = UDim2.new(1, -184, 1, 0),
                                    layoutOrder = 1,
                                }),
                                Form.Button({
                                    text = "Use Selection",
                                    onClick = pickInstance,
                                    width = UDim2.fromOffset(110, 24),
                                    layoutOrder = 2,
                                }),
                                Form.Button({
                                    text = "Clear",
                                    onClick = function()
                                        sourceInstance(nil)
                                    end,
                                    width = UDim2.fromOffset(60, 24),
                                    layoutOrder = 3,
                                }),
                            },
                        }),
                        Form.Row({
                            layoutOrder = 3,
                            visible = isMode("Asset ID"),
                            children = {
                                Form.Label({
                                    text = "Asset ID:",
                                    width = UDim2.fromOffset(60, 24),
                                    layoutOrder = 1,
                                }),
                                Form.TextInput({
                                    value = assetIdText,
                                    placeholder = "1234567890",
                                    width = UDim2.new(1, -66, 1, 0),
                                    layoutOrder = 2,
                                }),
                            },
                        }),
                    },
                }),

                Form.Section({
                    title = "Options",
                    layoutOrder = 2,
                    children = {
                        Form.ToggleRow({
                            value = keepDirty,
                            onToggle = function()
                                keepDirty(not keepDirty())
                            end,
                            label = "Keep dirty terrain chunks",
                            layoutOrder = 1,
                        }),
                    },
                }),

                Form.Row({
                    layoutOrder = 3,
                    height = 32,
                    children = {
                        Form.Button({
                            text = "Load",
                            onClick = doLoad,
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

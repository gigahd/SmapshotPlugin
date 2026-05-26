--!nonstrict
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Selection = game:GetService("Selection")

const Form = require(script.Parent.Form)
const GetOrCreateSmapshotFolder = require(script.Parent.Parent.Helper.GetOrCreateSmapshotFolder)
const Panel = require(script.Parent.Panel)
const Smapshot = require(script.Parent.Parent.Packages.Smapshot)
const Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source

type Mode = "Instance" | "Asset ID"
type StatusKind = "info" | "success" | "error"

return function(props: { visible: () -> boolean })
    local mode = source("Instance" :: Mode)
    local sourceInstance = source(nil :: Instance?)
    local assetIdText = source("")
    local keepDirty = source(false)
    local status = source("")
    local statusKind = source("info" :: StatusKind)

    local function setStatus(text: string, kind: StatusKind?)
        status(text)
        statusKind(kind or "info")
    end

    local function isMode(m: Mode)
        return function()
            return mode() == m
        end
    end

    local function pickInstance()
        for _, item in Selection:Get() do
            if item:IsA("Folder") or item:IsA("Model") then
                sourceInstance(item)
                setStatus("Source set to " .. item.Name, "info")
                return
            end
        end
        setStatus("No Folder or Model in selection", "error")
    end

    local function findPackageModule(): ModuleScript?
        local packages = script.Parent.Parent:FindFirstChild("Packages")
        local index = packages and packages:FindFirstChild("_Index")
        if not index then
            return nil
        end
        for _, entry in index:GetChildren() do
            if string.sub(entry.Name, 1, #"gigahd_smapshot") == "gigahd_smapshot" then
                local module = entry:FindFirstChild("smapshot")
                if module and module:IsA("ModuleScript") then
                    return module
                end
            end
        end
        return nil
    end

    local function doInstall()
        local module = findPackageModule()
        if not module then
            setStatus("Could not locate bundled Smapshot package", "error")
            return
        end
        local existing = ReplicatedStorage:FindFirstChild("Smapshot")
        if existing then
            existing:Destroy()
        end
        local clone = module:Clone()
        clone.Name = "Smapshot"
        clone.Parent = ReplicatedStorage
        Selection:Set({ clone })
        setStatus(if existing then "Replaced ReplicatedStorage.Smapshot" else "Installed ReplicatedStorage.Smapshot", "success")
    end

    local function doLoad()
        if mode() == "Instance" then
            local target = sourceInstance()
            if not target then
                setStatus("No source instance set", "error")
                return
            end
            setStatus("Loading...", "info")
            task.spawn(function()
                if not Smapshot.IsSnapshot(target) then
                    setStatus(`{target} is not a valid Smapshot`)
                end
                local ok, err = pcall(Smapshot.Load, target, keepDirty())
                if ok then
                    setStatus("Loaded from " .. target.Name, "success")
                else
                    setStatus("Load failed: " .. tostring(err), "error")
                end
            end)
        else
            local id = tonumber(assetIdText())
            if not id then
                setStatus("Asset ID must be a number", "error")
                return
            end
            setStatus("Loading asset " .. id .. "...", "info")
            task.spawn(function(): ()
                local ok, err = pcall(Smapshot.LoadAssetAsync, id, keepDirty())
                if ok then
                    setStatus(`Loaded asset: {id}`, "success")
                    err.Parent = GetOrCreateSmapshotFolder()
                else
                    setStatus(`Load failed: {err}`, "error")
                end
            end)
        end
    end

    return Panel({
        name = "LoadPanel",
        title = "Load Snapshot",
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
                                        return if inst then "Source: " .. inst.Name else "Source: <none>"
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
                            height = 26,
                            visible = isMode("Asset ID"),
                            children = {
                                Form.TextInput({
                                    value = assetIdText,
                                    placeholder = "Asset ID (e.g. 1234567890)",
                                    width = UDim2.new(1, 0, 1, 0),
                                    layoutOrder = 1,
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
                            label = "Don't reset any unset properties",
                            layoutOrder = 1,
                        }),
                    },
                }),

                Form.StatusBanner({
                    text = status,
                    kind = statusKind,
                    layoutOrder = 3,
                }),

                Form.Row({
                    layoutOrder = 4,
                    height = 32,
                    children = {
                        Form.Button({
                            text = "Load Snapshot",
                            onClick = doLoad,
                            primary = true,
                            width = UDim2.new(1, 0, 0, 30),
                            layoutOrder = 1,
                        }),
                    },
                }),

                Form.Section({
                    title = "Runtime Package",
                    layoutOrder = 5,
                    children = {
                        Form.Label({
                            text = "Install the Smapshot module into ReplicatedStorage so games can load snapshots at runtime without Wally.",
                            muted = true,
                            width = UDim2.new(1, 0, 0, 32),
                            layoutOrder = 1,
                        }),
                        Form.Row({
                            layoutOrder = 2,
                            height = 28,
                            children = {
                                Form.Button({
                                    text = "Install to ReplicatedStorage",
                                    onClick = doInstall,
                                    width = UDim2.new(1, 0, 0, 26),
                                    layoutOrder = 1,
                                }),
                            },
                        }),
                    },
                }),
            }),
        },
    })
end

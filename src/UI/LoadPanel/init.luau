--!nonstrict
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Form = require(script.Parent.Form)
local Panel = require(script.Parent.Panel)
local Smapshot = require(script.Parent.Parent.Packages.Smapshot)
local Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source

local OptionsSection = require(script.OptionsSection)
local RuntimeSection = require(script.RuntimeSection)
local SectionsSection = require(script.SectionsSection)
local SourceSection = require(script.SourceSection)

type StatusKind = "info" | "success" | "error"

local FOOTER_HEIGHT = 72

return function(props: { visible: () -> boolean })
    local status = source("")
    local statusKind = source("info" :: StatusKind)
    local function setStatus(text: string, kind: StatusKind?)
        status(text)
        statusKind(kind or "info")
    end
    local deps = { setStatus = setStatus }

    local sourceSection = SourceSection()
    local optionsSection = OptionsSection()
    local sectionsSection = SectionsSection()
    local runtimeSection = RuntimeSection(deps)

    local function recordHistory<T...>(label: string, fn: (T...) -> any, ...: T...): (boolean, any)
        local recording = ChangeHistoryService:TryBeginRecording(label)
        local ok, result = pcall(fn, ...)
        if recording then
            ChangeHistoryService:FinishRecording(
                recording,
                if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel
            )
        end
        return ok, result
    end

    local function doLoad()
        local target = sourceSection.liveSnapshotInstance()
        if not target then
            setStatus("Select a snapshot Folder/Model in Explorer", "error")
            return
        end
        if not Smapshot.IsCompatible(target) then
            local version = Smapshot.ReadVersion(target)
            if version then
                setStatus(`{target.Name}: snapshot version {version} is incompatible`, "error")
            else
                setStatus(`{target.Name} is not a valid Smapshot`, "error")
            end
            return
        end
        setStatus("Loading " .. target.Name .. "...", "info")
        task.spawn(function()
            local config: Smapshot.LoadConfig = {}
            optionsSection.contributeToConfig(config)
            sectionsSection.contributeToConfig(config)
            local ok, err = recordHistory("Smapshot: Load " .. target.Name, Smapshot.Load, target, config)
            if ok then
                setStatus("Loaded from " .. target.Name, "success")
            else
                setStatus("Load failed: " .. tostring(err), "error")
            end
        end)
    end

    return Panel({
        name = "LoadPanel",
        title = "Load Snapshot",
        visible = props.visible,
        children = {
            create("ScrollingFrame")({
                Size = UDim2.new(1, 0, 1, -28 - FOOTER_HEIGHT),
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
                sourceSection.ui,
                optionsSection.ui,
                sectionsSection.ui,
                runtimeSection.ui,
            }),
            create("Frame")({
                Name = "Footer",
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, FOOTER_HEIGHT),
                BackgroundTransparency = 1,
                create("UIListLayout")({
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                }),
                Form.StatusBanner({ text = status, kind = statusKind, layoutOrder = 1 }),
                Form.Button({
                    text = "Load Snapshot",
                    onClick = doLoad,
                    primary = true,
                    width = UDim2.new(1, 0, 0, 32),
                    layoutOrder = 2,
                }),
            }),
        },
    })
end

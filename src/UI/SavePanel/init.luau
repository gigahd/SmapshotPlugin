--!nonstrict
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Form = require(script.Parent.Form)
local GetOrCreateSmapshotFolder = require(script.Parent.Parent.Helper.GetOrCreateSmapshotFolder)
local Panel = require(script.Parent.Panel)
local Smapshot = require(script.Parent.Parent.Packages.Smapshot)
local Vide = require(script.Parent.Parent.Packages.Vide)
local create = Vide.create
local source = Vide.source

local GeneralSection = require(script.GeneralSection)
local TerrainSection = require(script.TerrainSection)
local LightingSection = require(script.LightingSection)
local WorkspaceSection = require(script.WorkspaceSection)
local MusicSection = require(script.MusicSection)
local MaterialSection = require(script.MaterialSection)
local InstancesSection = require(script.InstancesSection)

type StatusKind = "info" | "success" | "error"

local FOOTER_HEIGHT = 72

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

return function(props: { visible: () -> boolean })
    local status = source("")
    local statusKind = source("info" :: StatusKind)
    local function setStatus(text: string, kind: StatusKind?)
        status(text)
        statusKind(kind or "info")
    end
    local deps = { setStatus = setStatus }

    local general = GeneralSection()
    local terrain = TerrainSection(deps)
    local lighting = LightingSection(deps)
    local workspace = WorkspaceSection(deps)
    local music = MusicSection(deps)
    local material = MaterialSection(deps)
    local instances = InstancesSection(deps)

    local sections = { general, terrain, lighting, workspace, music, material, instances }

    local function doSave()
        local config: Smapshot.SnapshotConfig = {
            saveLocation = GetOrCreateSmapshotFolder(),
        }
        for _, section in sections do
            if not section.contributeToConfig(config) then
                return
            end
        end
        local name = general.trimmedName()
        local label = if name ~= "" then `Smapshot: Save "{name}"` else "Smapshot: Save"
        local ok, result = recordHistory(label, Smapshot.Snapshot, config)
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
                general.ui,
                terrain.ui,
                lighting.ui,
                workspace.ui,
                music.ui,
                material.ui,
                instances.ui,
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
                    text = "Save Snapshot",
                    onClick = doSave,
                    primary = true,
                    width = UDim2.new(1, 0, 0, 32),
                    layoutOrder = 2,
                }),
            }),
        },
    })
end

--!nonstrict
--[[
    "Source" section: pick between live-Selection mode or Asset ID mode,
    show a live preview, and surface the recently-loaded asset list.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local LiveSelection = require(script.Parent.Parent.Parent.Helper.LiveSelection)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local RecentList = require(script.Parent.RecentList)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

export type Mode = "Instance" | "Asset ID"

local function liveSnapshotInstance(): Instance?
    for _, item in LiveSelection.current() do
        if (item:IsA("Folder") or item:IsA("Model")) and Smapshot.IsCompatible(item) then
            return item
        end
    end
    for _, item in LiveSelection.current() do
        if item:IsA("Folder") or item:IsA("Model") then
            return item
        end
    end
    return nil
end

return function()
    local mode = persist("load.mode", "Instance" :: Mode)
    local assetIdText = persist("load.assetIdText", "")

    local function isMode(m: Mode)
        return function() return mode() == m end
    end

    local ui = Form.Section({
        title = "Source",
        layoutOrder = 1,
        accent = Colors.sectionAccents.source,
        children = {
            Form.SegmentedToggle({
                value = mode,
                options = { "Instance", "Asset ID" },
                onSelect = function(option) mode(option :: Mode) end,
                layoutOrder = 1,
                accent = Colors.sectionAccents.source,
            }),
            Form.Label({
                text = function()
                    local inst = liveSnapshotInstance()
                    if not inst then
                        return "Source: <none> - select a snapshot in Explorer"
                    end
                    if Smapshot.IsCompatible(inst) then
                        return `Source: {inst.Name} (live from selection)`
                    end
                    return `Source: {inst.Name} (not a valid Smapshot)`
                end,
                muted = true,
                width = UDim2.new(1, 0, 0, 18),
                layoutOrder = 2,
                visible = isMode("Instance"),
            }),
            Form.TextInput({
                value = assetIdText,
                placeholder = "Asset ID (e.g. 1234567890)",
                width = UDim2.new(1, 0, 0, 26),
                layoutOrder = 3,
                visible = isMode("Asset ID"),
            }),
            RecentList({
                visible = isMode("Asset ID"),
                onPick = function(id: number)
                    assetIdText(tostring(id))
                end,
                layoutOrder = 4,
            }),
        },
    })

    return {
        ui = ui,
        mode = mode,
        assetIdText = assetIdText,
        liveSnapshotInstance = liveSnapshotInstance,
    }
end

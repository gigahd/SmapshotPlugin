--!nonstrict
--[[
    "Terrain" section: include toggle + slice path picker.
    The slice is a stored `Workspace.X.Y`-style path; live-resolved on save.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local LiveSelection = require(script.Parent.Parent.Parent.Helper.LiveSelection)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local ResolvePath = require(script.Parent.Parent.Parent.Helper.ResolvePath)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

type Status = "info" | "success" | "error"

return function(deps: { setStatus: (string, Status?) -> () })
    local enabled = persist("save.terrainEnabled", false)
    local slicePath = persist("save.terrainSlicePath", "")

    local function resolve(): (BasePart?, string?)
        local path = slicePath()
        if path == "" then
            return nil, nil
        end
        local instance = ResolvePath(path)
        if instance and instance:IsA("BasePart") then
            return instance, nil
        end
        if not instance then
            return nil, `Path not found: {path}`
        end
        return nil, `{path} is a {instance.ClassName}, expected BasePart`
    end

    local function pickFromSelection()
        local part = LiveSelection.firstOfClass("BasePart") :: BasePart?
        if not part then
            deps.setStatus("Select a BasePart in Explorer first", "error")
            return
        end
        slicePath(part:GetFullName())
        deps.setStatus(`Slice set to {part.Name}`, "info")
    end

    local function clear()
        slicePath("")
        deps.setStatus("Slice cleared (full terrain)", "info")
    end

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then
            return true
        end
        local slice, err = resolve()
        if err then
            deps.setStatus(`Terrain: {err}`, "error")
            return false
        end
        config.terrainConfig = { slice = slice }
        return true
    end

    local ui = Form.Section({
        title = "Terrain",
        layoutOrder = 2,
        accent = Colors.sectionAccents.terrain,
        children = {
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include terrain",
                layoutOrder = 1,
            }),
            Form.Label({
                text = "Slice path (leave empty for full terrain)",
                muted = true,
                width = UDim2.new(1, 0, 0, 16),
                layoutOrder = 2,
                visible = enabled,
            }),
            Form.TextInput({
                value = slicePath,
                placeholder = "e.g. Workspace.ArenaBounds",
                width = UDim2.new(1, 0, 0, 26),
                layoutOrder = 3,
                visible = enabled,
            }),
            Form.Row({
                layoutOrder = 4,
                height = 26,
                visible = enabled,
                children = {
                    Form.Button({
                        text = "Pick from Selection",
                        onClick = pickFromSelection,
                        width = UDim2.new(0.5, -3, 1, 0),
                        layoutOrder = 1,
                    }),
                    Form.Button({
                        text = "Clear",
                        onClick = clear,
                        width = UDim2.new(0.5, -3, 1, 0),
                        layoutOrder = 2,
                    }),
                },
            }),
            Form.Label({
                text = function()
                    local _, err = resolve()
                    if err then return err end
                    if slicePath() == "" then return "Resolves to: full terrain" end
                    return "Resolves to: BasePart found"
                end,
                muted = true,
                width = UDim2.new(1, 0, 0, 16),
                layoutOrder = 5,
                visible = enabled,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

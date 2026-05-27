--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local LiveSelection = require(script.Parent.Parent.Parent.Helper.LiveSelection)
local PinList = require(script.Parent.PinList)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local ResolvePath = require(script.Parent.Parent.Parent.Helper.ResolvePath)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)
local StringSetOps = require(script.Parent.StringSetOps)

local persist = PluginSettings.source

type Status = "info" | "success" | "error"

return function(deps: { setStatus: (string, Status?) -> () })
    local enabled = persist("save.instancesEnabled", false)
    local paths = persist("save.instancePaths", {} :: { string })
    local saveParents = persist("save.saveInstanceParents", false)

    local function addFromSelection()
        local selected = LiveSelection.current()
        if #selected == 0 then
            deps.setStatus("Select instances in Explorer first", "error")
            return
        end
        local toAdd: { string } = {}
        for _, inst in selected do
            table.insert(toAdd, inst:GetFullName())
        end
        local added = StringSetOps.addMany(paths, toAdd)
        local total = #paths()
        if added == 0 then
            deps.setStatus(`All {#selected} instance(s) already pinned`, "info")
        else
            deps.setStatus(`Pinned {added} new instance(s); {total} total`, "info")
        end
    end

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then return true end
        local instances: { Instance } = {}
        local missing: { string } = {}
        for _, path in paths() do
            local instance = ResolvePath(path)
            if instance then
                table.insert(instances, instance)
            else
                table.insert(missing, path)
            end
        end
        if #missing > 0 then
            deps.setStatus(`Instances: {#missing} path(s) couldn't be resolved (first: {missing[1]})`, "error")
            return false
        end
        if #instances == 0 then
            deps.setStatus("Instances section is on, but the pinned list is empty", "error")
            return false
        end
        config.instanceConfig = { instances = instances, saveParents = saveParents() }
        return true
    end

    local ui = Form.Section({
        title = "Instances (advanced)",
        layoutOrder = 7,
        accent = Colors.sectionAccents.instances,
        children = {
            Form.Label({
                text = "For most maps just use the Workspace section above. This is for capturing arbitrary instances outside Workspace.",
                muted = true,
                width = UDim2.new(1, 0, 0, 32),
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include pinned instances",
                layoutOrder = 2,
            }),
            Form.Row({
                layoutOrder = 3,
                height = 26,
                visible = enabled,
                children = {
                    Form.Button({
                        text = "Add from Selection",
                        onClick = addFromSelection,
                        width = UDim2.new(0.5, -3, 1, 0),
                        layoutOrder = 1,
                    }),
                    Form.Button({
                        text = "Clear all",
                        onClick = function() StringSetOps.clear(paths) end,
                        width = UDim2.new(0.5, -3, 1, 0),
                        layoutOrder = 2,
                    }),
                },
            }),
            Form.Label({
                text = function()
                    local n = #paths()
                    if n == 0 then
                        return "No instances pinned - click 'Add from Selection' to pin some"
                    end
                    return `Pinned: {n} instance(s)`
                end,
                muted = true,
                width = UDim2.new(1, 0, 0, 18),
                layoutOrder = 4,
                visible = enabled,
            }),
            PinList({
                items = paths,
                onRemove = function(target)
                    StringSetOps.remove(paths, target)
                end,
                visible = enabled,
                layoutOrder = 5,
                isValid = function(path) return ResolvePath(path) ~= nil end,
            }),
            Form.ToggleRow({
                value = saveParents,
                onToggle = function() saveParents(not saveParents()) end,
                label = "Remember original parents (restored on load)",
                layoutOrder = 6,
                visible = enabled,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

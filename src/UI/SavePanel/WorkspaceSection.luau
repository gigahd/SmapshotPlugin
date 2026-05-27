--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local NameFilter = require(script.Parent.NameFilter)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

type FilterMode = "Whitelist" | "Blacklist"
type Status = "info" | "success" | "error"

return function(deps: { setStatus: (string, Status?) -> () })
    local enabled = persist("save.workspaceEnabled", true)
    local saveCameraCFrame = persist("save.saveCameraCFrame", false)
    local filterEnabled = persist("save.workspaceFilterEnabled", false)
    local mode = persist("save.workspaceFilterMode", "Whitelist" :: FilterMode)
    local names = persist("save.workspaceNamesList", {} :: { string })

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then
            return true
        end
        local workspaceConfig: Smapshot.WorkspaceConfig = {
            saveCameraCFrame = saveCameraCFrame(),
        }
        if filterEnabled() and #names() > 0 then
            if mode() == "Whitelist" then
                workspaceConfig.whitelist = names()
            else
                workspaceConfig.blacklist = names()
            end
        end
        config.workspaceConfig = workspaceConfig
        return true
    end

    local ui = Form.Section({
        title = "Workspace",
        layoutOrder = 4,
        accent = Colors.sectionAccents.workspace,
        children = {
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include workspace",
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = saveCameraCFrame,
                onToggle = function() saveCameraCFrame(not saveCameraCFrame()) end,
                label = "Save camera CFrame",
                layoutOrder = 2,
                visible = enabled,
            }),
            Form.ToggleRow({
                value = filterEnabled,
                onToggle = function() filterEnabled(not filterEnabled()) end,
                label = "Filter workspace children",
                layoutOrder = 3,
                visible = enabled,
            }),
            NameFilter({
                enabled = function() return enabled() and filterEnabled() end,
                mode = mode,
                items = names,
                accent = Colors.sectionAccents.workspace,
                layoutOrder = 4,
                setStatus = deps.setStatus,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

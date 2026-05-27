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
    local enabled = persist("save.lightingEnabled", false)
    local filterEnabled = persist("save.lightingFilterEnabled", false)
    local mode = persist("save.lightingFilterMode", "Whitelist" :: FilterMode)
    local names = persist("save.lightingNamesList", {} :: { string })

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then
            return true
        end
        local lighting: Smapshot.LightingConfig = {}
        if filterEnabled() and #names() > 0 then
            if mode() == "Whitelist" then
                lighting.whitelist = names()
            else
                lighting.blacklist = names()
            end
        end
        config.lightingConfig = lighting
        return true
    end

    local ui = Form.Section({
        title = "Lighting",
        layoutOrder = 3,
        accent = Colors.sectionAccents.lighting,
        children = {
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include lighting",
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = filterEnabled,
                onToggle = function() filterEnabled(not filterEnabled()) end,
                label = "Filter lighting children",
                layoutOrder = 2,
                visible = enabled,
            }),
            NameFilter({
                enabled = function() return enabled() and filterEnabled() end,
                mode = mode,
                items = names,
                accent = Colors.sectionAccents.lighting,
                layoutOrder = 3,
                setStatus = deps.setStatus,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

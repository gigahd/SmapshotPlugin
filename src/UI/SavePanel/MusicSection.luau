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
    local enabled = persist("save.musicEnabled", false)
    local filterEnabled = persist("save.musicFilterEnabled", false)
    local mode = persist("save.musicFilterMode", "Whitelist" :: FilterMode)
    local names = persist("save.musicNamesList", {} :: { string })

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then
            return true
        end
        local musicConfig: Smapshot.MusicConfig = {}
        if filterEnabled() and #names() > 0 then
            if mode() == "Whitelist" then
                musicConfig.whitelist = names()
            else
                musicConfig.blacklist = names()
            end
        end
        config.musicConfig = musicConfig
        return true
    end

    local ui = Form.Section({
        title = "Music",
        layoutOrder = 5,
        accent = Colors.sectionAccents.music,
        children = {
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include music (SoundService)",
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = filterEnabled,
                onToggle = function() filterEnabled(not filterEnabled()) end,
                label = "Filter SoundService children",
                layoutOrder = 2,
                visible = enabled,
            }),
            NameFilter({
                enabled = function() return enabled() and filterEnabled() end,
                mode = mode,
                items = names,
                accent = Colors.sectionAccents.music,
                layoutOrder = 3,
                setStatus = deps.setStatus,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

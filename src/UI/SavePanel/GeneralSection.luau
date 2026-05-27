--!nonstrict
--[[
    "General" section: snapshot name + save-defaults toggle.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

export type Section = {
    ui: Instance,
    contributeToConfig: (Smapshot.SnapshotConfig) -> boolean,
    trimmedName: () -> string,
}

return function(): Section
    local mapName = persist("save.mapName", "")
    local saveDefaults = persist("save.saveDefaults", false)

    local function trimmedName(): string
        return (string.gsub(mapName() or "", "^%s*(.-)%s*$", "%1"))
    end

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        config.saveDefaults = saveDefaults()
        local name = trimmedName()
        if name ~= "" then
            config.name = name
        end
        return true
    end

    local ui = Form.Section({
        title = "General",
        layoutOrder = 1,
        accent = Colors.sectionAccents.general,
        children = {
            Form.Label({
                text = "Snapshot name",
                muted = true,
                width = UDim2.new(1, 0, 0, 16),
                layoutOrder = 1,
            }),
            Form.TextInput({
                value = mapName,
                placeholder = "Snapshot (auto-named if blank)",
                width = UDim2.new(1, 0, 0, 26),
                layoutOrder = 2,
            }),
            Form.ToggleRow({
                value = saveDefaults,
                onToggle = function()
                    saveDefaults(not saveDefaults())
                end,
                label = "Save default property values",
                layoutOrder = 3,
            }),
        },
    })

    return {
        ui = ui,
        contributeToConfig = contributeToConfig,
        trimmedName = trimmedName,
    }
end

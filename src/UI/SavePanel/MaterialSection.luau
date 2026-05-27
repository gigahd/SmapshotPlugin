--!nonstrict
local BaseMaterialPicker = require(script.Parent.BaseMaterialPicker)
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local NameFilter = require(script.Parent.NameFilter)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

type FilterMode = "Whitelist" | "Blacklist"
type Status = "info" | "success" | "error"

local function namesToMaterials(names: { string }): { Enum.Material }?
    if #names == 0 then return nil end
    local result: { Enum.Material } = {}
    for _, name in names do
        local ok, mat = pcall(function() return (Enum.Material :: any)[name] end)
        if ok and typeof(mat) == "EnumItem" then
            table.insert(result, mat)
        else
            return nil, name
        end
    end
    return result
end

return function(deps: { setStatus: (string, Status?) -> () })
    local enabled = persist("save.materialEnabled", false)
    local baseFilterEnabled = persist("save.materialBaseFilterEnabled", false)
    local baseList = persist("save.materialBaseFilterList", {} :: { string })
    local nameFilterEnabled = persist("save.materialFilterEnabled", false)
    local nameMode = persist("save.materialFilterMode", "Whitelist" :: FilterMode)
    local names = persist("save.materialNamesList", {} :: { string })

    local function contributeToConfig(config: Smapshot.SnapshotConfig): boolean
        if not enabled() then return true end
        local materialConfig: Smapshot.MaterialConfig = {}
        if nameFilterEnabled() and #names() > 0 then
            if nameMode() == "Whitelist" then
                materialConfig.whitelist = names()
            else
                materialConfig.blacklist = names()
            end
        end
        if baseFilterEnabled() then
            local mats, badName = namesToMaterials(baseList())
            if not mats then
                if badName then
                    deps.setStatus(`Material: unknown Enum.Material "{badName}"`, "error")
                    return false
                end
            else
                materialConfig.materialFilter = mats
            end
        end
        config.materialConfig = materialConfig
        return true
    end

    local ui = Form.Section({
        title = "Material",
        layoutOrder = 6,
        accent = Colors.sectionAccents.material,
        children = {
            Form.ToggleRow({
                value = enabled,
                onToggle = function() enabled(not enabled()) end,
                label = "Include materials (MaterialService)",
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = baseFilterEnabled,
                onToggle = function() baseFilterEnabled(not baseFilterEnabled()) end,
                label = "Filter by BaseMaterial",
                layoutOrder = 2,
                visible = enabled,
            }),
            BaseMaterialPicker({
                enabled = function() return enabled() and baseFilterEnabled() end,
                items = baseList,
                layoutOrder = 3,
            }),
            Form.ToggleRow({
                value = nameFilterEnabled,
                onToggle = function() nameFilterEnabled(not nameFilterEnabled()) end,
                label = "Filter MaterialVariant children by name",
                layoutOrder = 4,
                visible = enabled,
            }),
            NameFilter({
                enabled = function() return enabled() and nameFilterEnabled() end,
                mode = nameMode,
                items = names,
                accent = Colors.sectionAccents.material,
                layoutOrder = 5,
                setStatus = deps.setStatus,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

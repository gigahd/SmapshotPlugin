--!nonstrict
--[[
    "Sections" section: per-section load overrides exposed by the 0.4.0
    LoadConfig. Each snapshot section can inherit the global defaults, force
    clone/consume, or be skipped entirely on load.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

local persist = PluginSettings.source

type Mode = "Inherit" | "Clone" | "Consume" | "Skip"

local MODES: { Mode } = { "Inherit", "Clone", "Consume", "Skip" }

-- Maps each LoadConfig section field to its display name and accent stripe.
local SECTIONS = {
    { key = "terrain", label = "Terrain", accent = Colors.sectionAccents.terrain },
    { key = "light", label = "Lighting", accent = Colors.sectionAccents.lighting },
    { key = "workspace", label = "Workspace", accent = Colors.sectionAccents.workspace },
    { key = "music", label = "Music", accent = Colors.sectionAccents.music },
    { key = "material", label = "Material", accent = Colors.sectionAccents.material },
    { key = "instance", label = "Instances", accent = Colors.sectionAccents.instances },
}

-- Translates a UI mode into the per-section overwrite passed to Smapshot.Load.
-- `Inherit` returns nil so the section falls back to the global defaults.
local function overwriteFor(mode: Mode): Smapshot.SimpleLoadOverwrite?
    if mode == "Skip" then
        return { ignoreOnLoad = true }
    elseif mode == "Consume" then
        return { consume = true }
    elseif mode == "Clone" then
        return { consume = false }
    end
    return nil
end

return function()
    local modes: { [string]: () -> Mode } = {}
    for _, section in SECTIONS do
        modes[section.key] = persist(`load.section.{section.key}`, "Inherit" :: Mode)
    end

    local function contributeToConfig(config: Smapshot.LoadConfig)
        for _, section in SECTIONS do
            config[section.key] = overwriteFor(modes[section.key]())
        end
    end

    local children: { Instance } = {
        Form.Label({
            text = "Override how each section loads. Inherit uses the global defaults above.",
            muted = true,
            width = UDim2.new(1, 0, 0, 28),
            layoutOrder = 1,
        }),
    }
    for i, section in SECTIONS do
        local mode = modes[section.key]
        table.insert(
            children,
            create("Frame")({
                Name = section.label,
                Size = UDim2.new(1, 0, 0, 46),
                BackgroundTransparency = 1,
                LayoutOrder = i + 1,
                create("UIListLayout")({
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                }),
                Form.Label({
                    text = section.label,
                    width = UDim2.new(1, 0, 0, 16),
                    layoutOrder = 1,
                }),
                Form.SegmentedToggle({
                    value = mode,
                    options = MODES,
                    onSelect = function(option)
                        mode(option :: Mode)
                    end,
                    accent = section.accent,
                    height = 26,
                    textSize = 11,
                    layoutOrder = 2,
                }),
            })
        )
    end

    local ui = Form.Section({
        title = "Sections",
        layoutOrder = 3,
        accent = Colors.sectionAccents.general,
        children = children,
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

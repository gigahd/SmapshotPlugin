--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local persist = PluginSettings.source

return function()
    local keepDirty = persist("load.keepDirty", false)
    local consume = persist("load.consume", false)

    -- These become the LoadConfig globals; per-section overrides (see
    -- SectionsSection) take precedence over them.
    local function contributeToConfig(config: Smapshot.LoadConfig)
        config.globalKeepDirty = keepDirty()
        config.globalConsume = consume()
    end

    local ui = Form.Section({
        title = "Global Defaults",
        layoutOrder = 2,
        accent = Colors.sectionAccents.options,
        children = {
            Form.Label({
                text = "Applied to every section unless overridden below.",
                muted = true,
                width = UDim2.new(1, 0, 0, 16),
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = keepDirty,
                onToggle = function()
                    keepDirty(not keepDirty())
                end,
                label = "Keep dirty (don't clear existing state before loading)",
                layoutOrder = 2,
            }),
            Form.ToggleRow({
                value = consume,
                onToggle = function()
                    consume(not consume())
                end,
                label = "Consume (reparent contents - faster, snapshot becomes unusable)",
                layoutOrder = 3,
            }),
        },
    })

    return { ui = ui, contributeToConfig = contributeToConfig }
end

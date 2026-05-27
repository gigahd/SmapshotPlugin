--!nonstrict
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local PluginSettings = require(script.Parent.Parent.Parent.Helper.PluginSettings)

local persist = PluginSettings.source

return function()
    local keepDirty = persist("load.keepDirty", false)
    local consume = persist("load.consume", false)

    local ui = Form.Section({
        title = "Options",
        layoutOrder = 2,
        accent = Colors.sectionAccents.options,
        children = {
            Form.ToggleRow({
                value = keepDirty,
                onToggle = function() keepDirty(not keepDirty()) end,
                label = "Keep dirty (don't clear existing state before loading)",
                layoutOrder = 1,
            }),
            Form.ToggleRow({
                value = consume,
                onToggle = function() consume(not consume()) end,
                label = "Consume (reparent contents - faster, snapshot becomes unusable)",
                layoutOrder = 2,
            }),
        },
    })

    return { ui = ui, keepDirty = keepDirty, consume = consume }
end

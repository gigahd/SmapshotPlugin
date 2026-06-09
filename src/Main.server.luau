local PluginSettings = require(script.Parent.Helper.PluginSettings)

-- Init must happen BEFORE any module that calls PluginSettings.source at load
-- time (e.g. the SavePanel sections); otherwise those sources see no plugin
-- and fall back to defaults forever.
PluginSettings.init(plugin)

local UI = require(script.Parent.UI)

local pluginId = "Smapshot"
local toolbar = plugin:CreateToolbar(pluginId)
local toggleButton: PluginToolbarButton = toolbar:CreateButton(pluginId, "Toggle Smapshot widget", "rbxassetid://134865792537892")

UI(pluginId, plugin, toggleButton)

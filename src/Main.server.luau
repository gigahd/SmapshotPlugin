const UI = require(script.Parent.UI)
local pluginId = "Smapshot"
local toolbar = plugin:CreateToolbar(pluginId)

local toggleButton: PluginToolbarButton = toolbar:CreateButton(pluginId, "Toggle Smapshot widget", "rbxassetid://79099450880702")


UI(pluginId, plugin, toggleButton)
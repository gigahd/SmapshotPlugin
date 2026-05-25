const UI = require(script.Parent.UI)
local pluginId = "Smapshot"
local toolbar = plugin:CreateToolbar(pluginId)

local toggleButton: PluginToolbarButton = toolbar:CreateButton("Toggle View", "Toggle Smapshot widget", "rbxassetid://4998267428")


UI(pluginId, plugin, toggleButton)
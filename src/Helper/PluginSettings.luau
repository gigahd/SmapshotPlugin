local Vide = require(script.Parent.Parent.Packages.Vide)

local PREFIX = "Smapshot/"

local pluginRef: Plugin? = nil

local PluginSettings = {}

function PluginSettings.init(plugin: Plugin)
    pluginRef = plugin
end

local function safeGet(key: string): any
    if not pluginRef then
        return nil
    end
    local ok, value = pcall(function()
        return pluginRef:GetSetting(PREFIX .. key)
    end)
    if not ok then
        warn(`[Smapshot] failed to read setting "{key}": {value}`)
        return nil
    end
    return value
end

local function safeSet(key: string, value: any)
    if not pluginRef then
        return
    end
    local ok, err = pcall(function()
        pluginRef:SetSetting(PREFIX .. key, value)
    end)
    if not ok then
        warn(`[Smapshot] failed to write setting "{key}": {err}`)
    end
end

--[[
    Returns a Vide source whose value is persisted to plugin settings. The
    source is initialized from any previously stored value (or `default` if
    nothing is stored or the stored type doesn't match `default`'s type).
    Writes flow through `plugin:SetSetting`; failures are warned but don't
    crash.
]]
function PluginSettings.source<T>(key: string, default: T): ((T) -> T) & (() -> T)
    local stored = safeGet(key)
    local initial: T = if stored ~= nil and type(stored) == type(default) then stored else default
    local src = Vide.source(initial)

    return function(...): T
        if select("#", ...) > 0 then
            local newValue = (...) :: T
            if newValue ~= src() then
                safeSet(key, newValue)
                return src(newValue)
            end
            return src()
        end
        return src()
    end :: any
end

return PluginSettings

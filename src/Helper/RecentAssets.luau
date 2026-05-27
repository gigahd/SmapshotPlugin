--!strict
--[[
    Persistent list of recently-loaded asset IDs (with their snapshot names).
    Capped at MAX_RECENT entries, most-recent-first, deduped by id.
]]
local PluginSettings = require(script.Parent.PluginSettings)

local MAX_RECENT = 10

export type Entry = { id: number, name: string }

local entries: any = PluginSettings.source("load.recentAssets", {} :: { Entry })

local RecentAssets = {}

function RecentAssets.list(): () -> { Entry }
    return entries
end

function RecentAssets.add(id: number, name: string)
    local current: { Entry } = entries()
    local next: { Entry } = { { id = id, name = name } }
    for _, entry in current do
        if entry.id ~= id and #next < MAX_RECENT then
            table.insert(next, entry)
        end
    end
    entries(next)
end

function RecentAssets.remove(id: number)
    local current: { Entry } = entries()
    local next: { Entry } = {}
    for _, entry in current do
        if entry.id ~= id then
            table.insert(next, entry)
        end
    end
    entries(next)
end

function RecentAssets.clear()
    entries({})
end

return RecentAssets

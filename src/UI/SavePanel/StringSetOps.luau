--!strict
--[[
    Pure functions for mutating a `{ string }` Vide source as if it were a set.
    Append-only with deduping; remove preserves order.
]]
local StringSetOps = {}

function StringSetOps.addMany(srcFn: ({ string }?) -> { string }, items: { string }): number
    local current = srcFn()
    local next = table.clone(current)
    local added = 0
    for _, name in items do
        if not table.find(next, name) then
            table.insert(next, name)
            added += 1
        end
    end
    if added > 0 then
        srcFn(next)
    end
    return added
end

function StringSetOps.remove(srcFn: ({ string }?) -> { string }, target: string)
    local current = srcFn()
    local next: { string } = {}
    for _, name in current do
        if name ~= target then
            table.insert(next, name)
        end
    end
    srcFn(next)
end

function StringSetOps.clear(srcFn: ({ string }?) -> { string })
    srcFn({})
end

return StringSetOps

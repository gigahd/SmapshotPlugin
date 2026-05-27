--[[
    Resolves a dotted path produced by `Instance:GetFullName()` back to an
    Instance, or returns nil if any segment doesn't exist. The first segment is
    treated as a service name (e.g. "Workspace", "ReplicatedStorage"); subsequent
    segments use FindFirstChild.

    Caveat: instance names containing literal "." cannot be unambiguously
    represented as a dotted path and will fail to resolve.
]]
return function(path: string): Instance?
    if path == nil or path == "" then
        return nil
    end

    local parts = string.split(path, ".")
    if #parts == 0 then
        return nil
    end

    local ok, service: Instance? = pcall(function()
        return game:GetService(parts[1])
    end)
    if not ok or not service then
        return nil
    end

    local current: Instance = service
    for i = 2, #parts do
        local nextInst = current:FindFirstChild(parts[i])
        if not nextInst then
            return nil
        end
        current = nextInst
    end

    return current
end

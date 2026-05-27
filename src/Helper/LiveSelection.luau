local Selection = game:GetService("Selection")

local Vide = require(script.Parent.Parent.Packages.Vide)

local current = Vide.source(Selection:Get())

Selection.SelectionChanged:Connect(function()
    current(Selection:Get())
end)

local function firstOfClass(className: string): Instance?
    for _, item in current() do
        if item:IsA(className) then
            return item
        end
    end
    return nil
end

local function countOfClass(className: string): number
    local n = 0
    for _, item in current() do
        if item:IsA(className) then
            n += 1
        end
    end
    return n
end

return {
    current = current,
    firstOfClass = firstOfClass,
    countOfClass = countOfClass,
}

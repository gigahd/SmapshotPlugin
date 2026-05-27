--!nonstrict
--[[
    "Source" section: shows a live preview of the selected snapshot
    Folder/Model in Explorer.
]]
local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)
local LiveSelection = require(script.Parent.Parent.Parent.Helper.LiveSelection)
local Smapshot = require(script.Parent.Parent.Parent.Packages.Smapshot)

local function liveSnapshotInstance(): Instance?
    for _, item in LiveSelection.current() do
        if (item:IsA("Folder") or item:IsA("Model")) and Smapshot.IsCompatible(item) then
            return item
        end
    end
    for _, item in LiveSelection.current() do
        if item:IsA("Folder") or item:IsA("Model") then
            return item
        end
    end
    return nil
end

return function()
    local ui = Form.Section({
        title = "Source",
        layoutOrder = 1,
        accent = Colors.sectionAccents.source,
        children = {
            Form.Label({
                text = function()
                    local inst = liveSnapshotInstance()
                    if not inst then
                        return "Source: <none> - select a snapshot in Explorer"
                    end
                    if Smapshot.IsCompatible(inst) then
                        return `Source: {inst.Name} (live from selection)`
                    end
                    return `Source: {inst.Name} (not a valid Smapshot)`
                end,
                muted = true,
                width = UDim2.new(1, 0, 0, 18),
                layoutOrder = 1,
            }),
        },
    })

    return {
        ui = ui,
        liveSnapshotInstance = liveSnapshotInstance,
    }
end
